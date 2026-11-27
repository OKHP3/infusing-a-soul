<#
.SYNOPSIS
  Installs GitHub CLI (gh) inside the Companion-owned OpenClawGateway WSL distro.

.DESCRIPTION
  The gateway Dashboard's GitHub connections ("Continue with GitHub") fails with
  "GitHub CLI (`gh`) is required on the Gateway host" until gh exists inside the distro.
  The Windows gh install does not count. This script adds GitHub's official apt repository,
  installs gh as root, and prints the version as the gateway's runtime user sees it.
  It does NOT log in: the Dashboard's device-code flow writes its own private gh profile.
  Transcript goes to .local/gateway-updates/ (gitignored).

.EXAMPLE
  pwsh -NoProfile -ExecutionPolicy Bypass -File .\scripts\install-gateway-gh.ps1
#>
[CmdletBinding()]
param(
  [string]$Distro = 'OpenClawGateway',
  [string]$User = 'openclaw'
)
$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$logDir = Join-Path $repo '.local\gateway-updates'
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$log = Join-Path $logDir ("gateway-gh-install-{0}.log" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
Start-Transcript -Path $log | Out-Null
try {
  $install = @'
set -uo pipefail
. /etc/os-release; echo "Distro: $PRETTY_NAME"
command -v apt-get >/dev/null || { echo "apt-get not found; this script supports Debian/Ubuntu only"; exit 3; }
if command -v gh >/dev/null; then echo "gh already installed: $(gh --version | head -1)"; exit 0; fi
export DEBIAN_FRONTEND=noninteractive
echo "--- apt-get update (base) ---"; apt-get update 2>&1 | tail -15
apt-get install -y -q curl ca-certificates 2>&1 | tail -3
echo "--- adding GitHub CLI apt repository ---"
install -d -m 0755 /etc/apt/keyrings
if curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg -o /etc/apt/keyrings/githubcli-archive-keyring.gpg; then
  chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list
  apt-get update 2>&1 | tail -15
else
  echo "WARN: could not download the GitHub CLI keyring (cli.github.com unreachable?)"
fi
echo "--- apt-cache policy gh ---"; apt-cache policy gh 2>&1
if apt-get install -y -q gh 2>&1 | tail -5 && command -v gh >/dev/null; then exit 0; fi
echo "--- apt route failed; falling back to the official .deb from GitHub releases ---"
arch=$(dpkg --print-architecture)
tag=$(curl -fsSL https://api.github.com/repos/cli/cli/releases/latest | sed -n 's/.*"tag_name": *"v\([^"]*\)".*/\1/p' | head -1)
[ -n "$tag" ] || { echo "ERROR: could not read latest gh release from api.github.com"; exit 4; }
url="https://github.com/cli/cli/releases/download/v${tag}/gh_${tag}_linux_${arch}.deb"
echo "Downloading $url"
curl -fsSL "$url" -o /tmp/gh.deb || { echo "ERROR: download failed"; exit 5; }
apt-get install -y -q /tmp/gh.deb 2>&1 | tail -5
command -v gh >/dev/null || { echo "ERROR: gh still not installed"; exit 6; }
'@
  (($install -replace "`r", '') + "`n#") | wsl.exe -d $Distro -u root -- bash -s | Out-Host
  if ($LASTEXITCODE -ne 0) { throw "gh install failed inside $Distro (exit $LASTEXITCODE)" }

  Write-Host "`n>>> As gateway user '$User':" -ForegroundColor Cyan
  "command -v gh && gh --version | head -1`n#" | wsl.exe -d $Distro -u $User -- bash -l -s | Out-Host
  if ($LASTEXITCODE -ne 0) { throw "gh is not on PATH for $User" }

  Write-Host "`nDone. Back in the Dashboard: GitHub connections > Connect GitHub > For the system > Continue with GitHub." -ForegroundColor Green
}
finally { Stop-Transcript | Out-Null }
