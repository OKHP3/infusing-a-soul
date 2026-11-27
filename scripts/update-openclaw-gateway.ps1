<#
.SYNOPSIS
  Updates the OpenClaw gateway inside the Companion-owned OpenClawGateway WSL distro on GJS-LAPTOP.

.DESCRIPTION
  OpenClaw Companion updates itself. The gateway it runs does not. This script closes that gap:
    1. Records the gateway version and update status before the change.
    2. Takes a file-level backup of ~/.openclaw to a Windows folder (unless -SkipBackup).
    3. Runs `openclaw update` (with --yes when this gateway build supports it). The updater
       prepares the new release beside the running one and rolls back on its own if the candidate
       cannot start.
    4. Records the version, update status, and model defaults after the change.
  Everything is written to .local/gateway-updates/ (gitignored). -DryRun previews the update
  without backing up or changing anything.

  The backup archive contains gateway credentials (gateway.auth.token). It stays on this PC.
  Never commit or upload it.

.EXAMPLE
  pwsh -NoProfile -ExecutionPolicy Bypass -File .\scripts\update-openclaw-gateway.ps1 -DryRun
.EXAMPLE
  pwsh -NoProfile -ExecutionPolicy Bypass -File .\scripts\update-openclaw-gateway.ps1
#>
[CmdletBinding()]
param(
  [string]$Distro = 'OpenClawGateway',
  [string]$User = 'openclaw',
  [string]$BackupRoot = (Join-Path $env:USERPROFILE 'OKH-Local\openclaw-backups'),
  [switch]$DryRun,
  [switch]$SkipBackup,
  # Bypass the gateway's own updater (needed when it is broken, e.g. the 2026.9.3/9.4 rollback-verification
  # timeout, openclaw/openclaw#161257): stop the service, npm-install the target with the gateway's own
  # Node, run a read-only doctor, start the service. Requires the backup (cannot be combined with -SkipBackup).
  [switch]$Manual,
  [string]$TargetVersion = 'latest'
)

$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$logDir = Join-Path $repo '.local\gateway-updates'
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$log = Join-Path $logDir "gateway-update-$stamp.log"
Start-Transcript -Path $log | Out-Null

function Invoke-Gateway([string]$Command, [switch]$AllowFail) {
  Write-Host "`n>>> $Command" -ForegroundColor Cyan
  # Feed the command on stdin. Passing it as an argument lets wsl.exe re-parse the line, which
  # breaks quoting and $-expansion (seen 2026-11-25: PATH export lost, service start never ran).
  (($Command -replace "`r", '') + "`n#") | wsl.exe -d $Distro -u $User -- bash -l -s | Out-Host
  $code = $LASTEXITCODE
  if ($code -ne 0) {
    if ($AllowFail) { Write-Host "(exit $code, continuing)" -ForegroundColor Yellow }
    else { throw "Command failed with exit code ${code}: $Command" }
  }
}

try {
  Write-Host "OpenClaw gateway update  |  distro=$Distro user=$User dryRun=$DryRun  |  log: $log" -ForegroundColor Green

  $distros = (wsl.exe -l -q) -replace "`0", '' | Where-Object { $_.Trim() }
  if ($distros -notcontains $Distro) { throw "WSL distro '$Distro' not found. Installed: $($distros -join ', ')" }

  Write-Host "`n== Before ==" -ForegroundColor Green
  # AllowFail: a half-swapped install can leave the CLI itself unable to start, which is exactly when -Manual is needed.
  Invoke-Gateway 'openclaw --version' -AllowFail
  $active = "openclaw update status --json 2>/dev/null`n#" | wsl.exe -d $Distro -u $User -- bash -l -s | Out-String
  if ($active -match '"phase"\s*:\s*"(requested|staging|validating|activating|restarting|verifying)"') { throw 'Another update run is in progress. Wait for it to finish (openclaw update status), then rerun.' }
  Invoke-Gateway 'openclaw update status' -AllowFail

  if ($DryRun) {
    Write-Host "`n== Dry run (no backup, no changes) ==" -ForegroundColor Green
    Invoke-Gateway 'openclaw update --dry-run' -AllowFail
    return
  }

  if (-not $SkipBackup) {
    Write-Host "`n== Backup ==" -ForegroundColor Green
    New-Item -ItemType Directory -Force -Path $BackupRoot | Out-Null
    # Back up inside the distro first. The Companion-managed distro may not mount C: at /mnt/c,
    # so the copy to Windows goes through the \\wsl.localhost share from this side instead.
    $name = "openclaw-home-$stamp.tgz"
    Invoke-Gateway "mkdir -p ~/openclaw-backups && tar -czf ~/openclaw-backups/$name -C ~ .openclaw && ls -lh ~/openclaw-backups/$name"
    $src = "\\wsl.localhost\$Distro\home\$User\openclaw-backups\$name"
    try {
      Copy-Item -LiteralPath $src -Destination $BackupRoot -ErrorAction Stop
      Write-Host "Backup copied to $(Join-Path $BackupRoot $name)" -ForegroundColor Green
    }
    catch {
      Write-Host "WARN: could not copy the backup to Windows ($($_.Exception.Message)). It is kept inside the distro at ~/openclaw-backups/$name." -ForegroundColor Yellow
    }
  }

  if ($Manual) {
    if ($SkipBackup) { throw '-Manual requires the backup; drop -SkipBackup.' }
    Write-Host "`n== Manual install (bypasses the built-in updater) ==" -ForegroundColor Green
    $npmEnv = 'export PATH="$HOME/.openclaw/tools/node/bin:$PATH"'
    # Preflight before anything is stopped: the gateway's own node and npm must resolve.
    Invoke-Gateway "$npmEnv; command -v node && command -v npm && echo node=`$(node --version) npm=`$(npm --version) prefix=`$(npm prefix -g)"
    Invoke-Gateway 'systemctl --user stop openclaw-gateway.service; sleep 3; systemctl --user is-active openclaw-gateway.service || true'
    $stopped = $true
    try {
      Invoke-Gateway "$npmEnv; npm install -g openclaw@$TargetVersion --allow-scripts=openclaw --no-fund --no-audit 2>&1 | tail -25; test `${PIPESTATUS[0]} -eq 0"
    }
    catch {
      Write-Host "npm install failed. The previous package tree is in the backup above; restore with:" -ForegroundColor Red
      Write-Host "  tar -xzf <backup>.tgz -C ~ .openclaw/tools   (inside the distro), then start the service" -ForegroundColor Red
      Invoke-Gateway 'systemctl --user reset-failed openclaw-gateway.service 2>/dev/null; systemctl --user start openclaw-gateway.service; sleep 10; systemctl --user is-active openclaw-gateway.service' -AllowFail
      throw
    }
    Invoke-Gateway 'openclaw --version'
    Invoke-Gateway 'openclaw doctor --lint 2>&1 | tail -30' -AllowFail
    Invoke-Gateway 'systemctl --user reset-failed openclaw-gateway.service 2>/dev/null; systemctl --user start openclaw-gateway.service; sleep 15; systemctl --user is-active openclaw-gateway.service'
    Invoke-Gateway 'openclaw gateway status --deep 2>&1 | tail -25' -AllowFail
  }
  else {
    Write-Host "`n== Update ==" -ForegroundColor Green
    Invoke-Gateway 'if openclaw update --help 2>/dev/null | grep -q -- "--yes"; then openclaw update --yes; else openclaw update; fi'
  }

  Write-Host "`n== After ==" -ForegroundColor Green
  Invoke-Gateway 'openclaw --version'
  Invoke-Gateway 'openclaw update status' -AllowFail
  Invoke-Gateway 'openclaw config get agents.defaults' -AllowFail

  Write-Host "`nDone. Next: Companion account menu > gateway row > Reconnect, confirm the row shows the new version, then run 'openclaw doctor' interactively." -ForegroundColor Green
}
finally {
  Stop-Transcript | Out-Null
}
