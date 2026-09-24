# Night Shift helpers for OpenClaw Windows Companion. Dot-source this file, or add the line below to $PROFILE:
#   . "$env:USERPROFILE\OKH-Local\04_GitHub_Mirrors\infusing-a-soul\scripts\night-shift\night-shift.ps1"
$NS_Distro = 'OpenClawGateway'
$NS_Here   = Split-Path -Parent $MyInvocation.MyCommand.Path

function Invoke-NSBash([string]$Cmd) { wsl -d $NS_Distro -u openclaw -- bash -lc $Cmd }

# Pipe a local script into the distro: strip Windows CRs, save to /tmp, run with stdin detached
function Invoke-NSScript([string]$Name, [string]$Arg = '') {
  Get-Content -Raw "$NS_Here\$Name" | wsl -d $NS_Distro -u openclaw -- bash -c "tr -d '\r' > /tmp/$Name && bash -l /tmp/$Name $Arg < /dev/null"
}
function ns-setup { Invoke-NSScript 'night-shift-setup.sh' }
function ns-diag  { Invoke-NSScript 'diag-tools.sh' }
function ns-fix   { Invoke-NSScript 'fix-harden.sh' }

# Queue a task:  ns-add Draft 3 hooks, Jamie voice, no em dashes
# Uses the raw typed line so commas and punctuation survive exactly as written.
function ns-add {
  $line = $MyInvocation.Line
  $i = $line.IndexOf('ns-add')
  $task = if ($i -ge 0) { $line.Substring($i + 6).Trim() } else { ($args -join ' ') }
  if ($task.Length -ge 2 -and (($task[0] -eq '"' -and $task[-1] -eq '"') -or ($task[0] -eq "'" -and $task[-1] -eq "'"))) { $task = $task.Substring(1, $task.Length - 2) }
  if (-not $task) { Write-Host "Usage: ns-add <task text>" -ForegroundColor Yellow; return }
  "- [ ] $task" | wsl -d $NS_Distro -u openclaw -- bash -c 'tr -d "\r" >> ~/.openclaw/workspace/night-shift/queue.md'
  Write-Host "Queued: $task" -ForegroundColor Green
}

function ns-queue { Invoke-NSBash 'cat ~/.openclaw/workspace/night-shift/queue.md' }

# Morning brief: ns-brief (newest results folder) or ns-brief 2026-09-24
function ns-brief([string]$Date = '') { Invoke-NSScript 'brief.sh' $Date }

# Run history and errors for the night-shift job
function ns-status { Invoke-NSScript 'status.sh' }

# Read one result:  ns-read 2026-09-24 01
function ns-read([string]$Date, [string]$Num) {
  Invoke-NSBash "cat ~/.openclaw/workspace/night-shift/results/$Date/$Num-*.md"
}

# Run the Night Shift right now (smoke tests, or when you want it before bed)
function ns-run { Invoke-NSScript 'run-now.sh' }

Write-Host "Night Shift helpers loaded: ns-add, ns-queue, ns-run, ns-brief, ns-read, ns-setup, ns-diag, ns-fix, ns-status" -ForegroundColor Cyan
