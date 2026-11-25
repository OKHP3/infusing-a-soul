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
  [switch]$SkipBackup
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
  wsl.exe -d $Distro -u $User -- bash -lc $Command | Out-Host
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
  Invoke-Gateway 'openclaw --version'
  Invoke-Gateway 'openclaw update status' -AllowFail

  if ($DryRun) {
    Write-Host "`n== Dry run (no backup, no changes) ==" -ForegroundColor Green
    Invoke-Gateway 'openclaw update --dry-run' -AllowFail
    return
  }

  if (-not $SkipBackup) {
    Write-Host "`n== Backup ==" -ForegroundColor Green
    New-Item -ItemType Directory -Force -Path $BackupRoot | Out-Null
    $wslBackup = (wsl.exe -d $Distro -u $User -- wslpath -a $BackupRoot).Trim()
    Invoke-Gateway "tar -czf '$wslBackup/openclaw-home-$stamp.tgz' -C ~ .openclaw && ls -lh '$wslBackup/openclaw-home-$stamp.tgz'"
  }

  Write-Host "`n== Update ==" -ForegroundColor Green
  Invoke-Gateway 'if openclaw update --help 2>/dev/null | grep -q -- "--yes"; then openclaw update --yes; else openclaw update; fi'

  Write-Host "`n== After ==" -ForegroundColor Green
  Invoke-Gateway 'openclaw --version'
  Invoke-Gateway 'openclaw update status' -AllowFail
  Invoke-Gateway 'openclaw config get agents.defaults' -AllowFail

  Write-Host "`nDone. Next: Companion account menu > gateway row > Reconnect, confirm the row shows the new version, then run 'openclaw doctor' interactively." -ForegroundColor Green
}
finally {
  Stop-Transcript | Out-Null
}
