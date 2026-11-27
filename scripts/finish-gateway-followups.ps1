<#
.SYNOPSIS
  Finishes two items from apply-gateway-followups.ps1 (2026-11-25):
  a. Removes the leftover stale TOOLS.md block (old "## 1. LM Studio" ... "<<<END>>>") from the live AGENTS.md.
  b. Moves the Gateway service onto Node 24.22.1: repoints ~/.openclaw/tools/node, drops the redundant
     TMPDIR line, and refreshes the unit with `openclaw gateway install --force --runtime-path <24.22.1 node>`.
     Waits up to 7 minutes for Listening (a graceful stop may drain for up to 330 s); rolls back to the
     saved unit and node-v24.19.0 otherwise.
  Scripts avoid `exit` inside `bash -l -s` (a login shell's logout path returned a false exit 1 on 2026-11-25).
#>
[CmdletBinding()]
param([string]$Distro = 'OpenClawGateway', [string]$User = 'openclaw', [string]$NodeVersion = '24.22.1')
$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$logDir = Join-Path $repo '.local\gateway-updates'
Start-Transcript -Path (Join-Path $logDir "followups-finish-$stamp.log") | Out-Null
function Invoke-Gateway([string]$Command, [switch]$AllowFail) {
  Write-Host "`n>>> $(($Command -split "`n")[0])" -ForegroundColor Cyan
  (($Command -replace "`r", '') + "`n#") | wsl.exe -d $Distro -u $User -- bash -l -s | Out-Host
  $code = $LASTEXITCODE
  if ($code -ne 0) { if ($AllowFail) { Write-Host "(exit $code, continuing)" -ForegroundColor Yellow } else { throw "Step failed with exit code ${code}" } }
}
$wait = @'
ok=0; for i in $(seq 1 84); do if openclaw gateway status --deep 2>/dev/null | grep -q 'Listening: 127.0.0.1:18789'; then ok=1; break; fi; sleep 5; done
echo "listening=$ok after $((i*5))s"; test "$ok" = 1
'@
try {
  Write-Host "== a. Live AGENTS.md leftover block ==" -ForegroundColor Green
  Invoke-Gateway @"
set -e
cd ~/.openclaw/workspace
python3 - <<'PY'
import re
p='AGENTS.md'; s=open(p,encoding='utf-8').read()
m=re.search(r'^## 1\. LM Studio \(Primary Model\)\n.*?^<<<END>>>\n\n?', s, flags=re.M|re.S)
if not m: print('no leftover block (already clean)')
else:
    s=s[:m.start()]+s[m.end():]; open(p,'w',encoding='utf-8').write(s); print('removed', m.end()-m.start(), 'bytes')
PY
echo "END markers: `$(grep -c '<<<END>>>' AGENTS.md || true)  lfm2 refs: `$(grep -c 'lfm2' AGENTS.md || true)"
grep -n '^## \|^### ' AGENTS.md | sed -n '/Tools/,/Automations/p'
git -c user.name=okhp3 -c user.email=okhp3@localhost commit -qam 'Remove stale TOOLS.md block $stamp' || echo 'nothing to commit'
"@

  Write-Host "`n== b. Service onto Node $NodeVersion ==" -ForegroundColor Green
  Invoke-Gateway "cp ~/.config/systemd/user/openclaw-gateway.service ~/openclaw-backups/openclaw-gateway.service.pre-node-$stamp && test -x ~/.openclaw/tools/node-v$NodeVersion/bin/node && test -f ~/.openclaw/tools/node-v$NodeVersion/lib/node_modules/openclaw/dist/index.js && ~/.openclaw/tools/node-v$NodeVersion/bin/node --version"
  try {
    Invoke-Gateway @"
set -e
ln -sfn ~/.openclaw/tools/node-v$NodeVersion ~/.openclaw/tools/node
sed -i '/^Environment=TMPDIR=\/tmp$/d' ~/.config/systemd/user/openclaw-gateway.service
systemctl --user daemon-reload
export PATH="`$HOME/.openclaw/tools/node-v$NodeVersion/bin:`$PATH"
openclaw gateway install --force --runtime-path "`$HOME/.openclaw/tools/node-v$NodeVersion/bin/node" 2>&1 | grep -v 'SECURITY WARNING' | tail -25
"@
    Invoke-Gateway $wait
    Invoke-Gateway "systemctl --user cat openclaw-gateway.service | grep -E '^ExecStart|^Delegate|TMPDIR'; systemctl --user cat openclaw-gateway.service | grep -q 'node-v$NodeVersion/bin/node' && openclaw gateway status --deep 2>&1 | grep -E 'Gateway version|Runtime:|Connectivity|Listening|Service config issue|SECURITY'"
    Write-Host "`nNode/runtime: OK on $NodeVersion" -ForegroundColor Green
  }
  catch {
    Write-Host "Runtime step failed: $($_.Exception.Message). Rolling back." -ForegroundColor Red
    Invoke-Gateway "cp ~/openclaw-backups/openclaw-gateway.service.pre-node-$stamp ~/.config/systemd/user/openclaw-gateway.service; ln -sfn ~/.openclaw/tools/node-v24.19.0 ~/.openclaw/tools/node; systemctl --user daemon-reload; systemctl --user reset-failed openclaw-gateway.service 2>/dev/null; systemctl --user restart openclaw-gateway.service" -AllowFail
    Invoke-Gateway $wait -AllowFail
    Write-Host "Node/runtime: ROLLED BACK" -ForegroundColor Red
  }
}
finally { Stop-Transcript | Out-Null }
