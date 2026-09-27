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

# Tailscale routing and laptop GPU (2026-09-26). See docs/asus-gateway-runbook.md, "Session Update (2026-09-26)".
# ns-tailnet [MacTailnetIp] [LaptopCtx]  -> Mac primary over Tailscale, Granite fallback + utility on the laptop GPU
function ns-tailnet([string]$Mac = '100.87.4.93', [int]$Ctx = 16384) { Invoke-NSScript 'tailnet-routing.sh' "$Mac $Ctx" }
# ns-gpu -> read-only: GPU visible in WSL, Ollama settings, and whether the model runs 100% on GPU
function ns-gpu { Invoke-NSScript 'gpu-check.sh' }
# ns-gpu-tune [Ctx] -> raise the laptop context (root), then re-register the model with the matching window
function ns-gpu-tune([int]$Ctx = 32768) {
  Get-Content -Raw "$NS_Here\gpu-tune.sh" | wsl -d $NS_Distro -u root -- bash -c "tr -d '\r' > /tmp/gpu-tune.sh && bash /tmp/gpu-tune.sh $Ctx < /dev/null"
  ns-tailnet '100.87.4.93' $Ctx
}

# ns-route [fix] -> find (and with 'fix', repoint) every file still using the Mac's LAN address
function ns-route([string]$Mode = 'check') { Invoke-NSScript 'route-check.sh' $Mode }

Write-Host "Night Shift helpers loaded: ns-add, ns-queue, ns-run, ns-brief, ns-read, ns-setup, ns-diag, ns-fix, ns-status, ns-tailnet, ns-gpu, ns-gpu-tune, ns-route" -ForegroundColor Cyan
