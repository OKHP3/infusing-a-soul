<#
.SYNOPSIS
  Applies the 2026-11-25 post-upgrade doctor follow-ups to the OpenClawGateway distro on GJS-LAPTOP.

.DESCRIPTION
  1. Verified OpenClaw backup (openclaw backup create --verify) plus a copy of the systemd unit.
  2. Enables the Active Memory plugin (remember-across-conversations is on by default).
  3. Replaces the stale "migrated from TOOLS.md" block in the live AGENTS.md with section 9 of the
     repo's souls/glee-fully/workspace/AGENTS.md (workspace git snapshot taken first).
  4. Host drop-in: TimeoutStopSec=330 for user@1000 (takes effect at the next WSL start).
  5. Removes the redundant Environment=TMPDIR=/tmp from the unit (it blocked installer refreshes), then
     runs the official CLI installer with --node-version 24.22.1, which installs Node beside the old
     runtime, repoints ~/.openclaw/tools/node, and refreshes the service (adds Delegate=yes).
     If the Gateway is not listening within 3 minutes, it restores the unit and the 24.19.0 runtime.
  Not changed on purpose: heartbeat-main tool scope (11.10's narrowing is accepted) and maxTokens caps
  (kept for local hardware). Secrets need the interactive helper; the script prints the steps.
  Transcript: .local/gateway-updates/followups-apply-<stamp>.log
#>
[CmdletBinding()]
param([string]$Distro = 'OpenClawGateway', [string]$User = 'openclaw', [string]$NodeVersion = '24.22.1', [string]$GatewayVersion = '2026.11.10')
$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$logDir = Join-Path $repo '.local\gateway-updates'
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
Start-Transcript -Path (Join-Path $logDir "followups-apply-$stamp.log") | Out-Null

function Invoke-Gateway([string]$Command, [string]$As = $User, [switch]$AllowFail) {
  Write-Host "`n>>> [$As] $(($Command -split "`n")[0])" -ForegroundColor Cyan
  (($Command -replace "`r", '') + "`n#") | wsl.exe -d $Distro -u $As -- bash -l -s | Out-Host
  $code = $LASTEXITCODE
  if ($code -ne 0) {
    if ($AllowFail) { Write-Host "(exit $code, continuing)" -ForegroundColor Yellow }
    else { throw "Step failed with exit code ${code}" }
  }
}

try {
  Write-Host "== Preflight ==" -ForegroundColor Green
  Invoke-Gateway "openclaw --version | grep -q '$GatewayVersion' && systemctl --user is-active openclaw-gateway.service && openclaw gateway status --deep 2>/dev/null | grep -E 'Listening|Connectivity'"

  Write-Host "`n== 1. Backup ==" -ForegroundColor Green
  Invoke-Gateway "mkdir -p ~/openclaw-backups && cp ~/.config/systemd/user/openclaw-gateway.service ~/openclaw-backups/openclaw-gateway.service.$stamp && openclaw backup create --output ~/openclaw-backups --verify 2>&1 | tail -15; test `${PIPESTATUS[0]} -eq 0"

  Write-Host "`n== 2. Active Memory ==" -ForegroundColor Green
  Invoke-Gateway "openclaw config set plugins.entries.active-memory.enabled true 2>&1 | tail -5; openclaw config get plugins.entries.active-memory 2>&1 | tail -5"

  Write-Host "`n== 3. Live AGENTS.md tool notes ==" -ForegroundColor Green
  $src = [IO.File]::ReadAllText((Join-Path $repo 'souls\glee-fully\workspace\AGENTS.md')) -replace "`r", ''
  $idx = $src.IndexOf('## 9. Tools and Connected Services')
  if ($idx -lt 0) { throw 'Repo AGENTS.md has no "## 9. Tools and Connected Services" section.' }
  $section = $src.Substring($idx)
  $b64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($section))
  Invoke-Gateway @"
set -e
cd ~/.openclaw/workspace
git -c user.name=okhp3 -c user.email=okhp3@localhost add -A >/dev/null 2>&1 || true
git -c user.name=okhp3 -c user.email=okhp3@localhost commit -qm 'snapshot before tool-notes sync $stamp' >/dev/null 2>&1 || true
echo '$b64' | base64 -d > /tmp/gf-tools.md
python3 - <<'PY'
import re
p='AGENTS.md'; s=open(p,encoding='utf-8').read()
sec=open('/tmp/gf-tools.md',encoding='utf-8').read()
body=sec.split('\n',1)[1].strip('\n')
body=re.sub(r'^### ', '#### ', body, flags=re.M)
new='### Glee-fully connected services (synced from repo, $stamp)\n\n'+body+'\n\n'
m=re.search(r'^### Local notes \(migrated from TOOLS\.md\)\n.*?(?=^## )', s, flags=re.M|re.S)
if m: s=s[:m.start()]+new+s[m.end():]
elif '### Glee-fully connected services' in s:
    s=re.sub(r'^### Glee-fully connected services.*?(?=^## )', new, s, flags=re.M|re.S)
else: raise SystemExit('no tool-notes block found in live AGENTS.md')
open(p,'w',encoding='utf-8').write(s)
PY
rm -f /tmp/gf-tools.md
grep -c '<<<END>>>' AGENTS.md || true
grep -n 'lfm2\|mistral-small-3.2' AGENTS.md | head
git -c user.name=okhp3 -c user.email=okhp3@localhost commit -qam 'Sync Glee-fully tool notes from repo $stamp' && git log --oneline -2
"@

  Write-Host "`n== 4. user@1000 stop timeout (host) ==" -ForegroundColor Green
  Invoke-Gateway "mkdir -p /etc/systemd/system/user@1000.service.d && printf '[Service]\nTimeoutStopSec=330\n' > /etc/systemd/system/user@1000.service.d/zz-openclaw-stop-timeout.conf && systemctl daemon-reload && systemctl show user@1000.service -p TimeoutStopUSec" -As root

  Write-Host "`n== 5. Unit TMPDIR + Node $NodeVersion via official installer ==" -ForegroundColor Green
  Invoke-Gateway "sed -i '/^Environment=TMPDIR=\/tmp$/d' ~/.config/systemd/user/openclaw-gateway.service && systemctl --user daemon-reload && grep -c TMPDIR ~/.config/systemd/user/openclaw-gateway.service || true"
  $installOk = $true
  try {
    Invoke-Gateway @"
set -euo pipefail
d=`$(mktemp -d /tmp/openclaw-installer-XXXXXX); trap 'rm -rf -- "`$d"' EXIT
curl -fsSL --connect-timeout 15 --max-time 300 --proto '=https' --tlsv1.2 -o "`$d/installer.sh" https://openclaw.ai/install-cli.sh
test -s "`$d/installer.sh"
bash -s -- --version '$GatewayVersion' --node-version '$NodeVersion' --no-onboard < "`$d/installer.sh" 2>&1 | tail -40
"@
    Invoke-Gateway @"
set -e
readlink ~/.openclaw/tools/node | grep -q 'node-v$NodeVersion'
systemctl --user cat openclaw-gateway.service | grep -E '^ExecStart|^Delegate'
for i in `$(seq 1 36); do openclaw gateway status --deep 2>/dev/null | grep -q 'Listening: 127.0.0.1:18789' && { echo LISTENING; openclaw --version; ~/.openclaw/tools/node/bin/node --version; exit 0; }; sleep 5; done
echo 'Gateway did not reach Listening within 3 minutes'; exit 1
"@
  }
  catch {
    $installOk = $false
    Write-Host "Node/runtime step failed: $($_.Exception.Message). Rolling back to node-v24.19.0 and the saved unit." -ForegroundColor Red
    Invoke-Gateway @"
cp ~/openclaw-backups/openclaw-gateway.service.$stamp ~/.config/systemd/user/openclaw-gateway.service
ln -sfn ~/.openclaw/tools/node-v24.19.0 ~/.openclaw/tools/node
systemctl --user daemon-reload; systemctl --user reset-failed openclaw-gateway.service 2>/dev/null; systemctl --user restart openclaw-gateway.service
for i in `$(seq 1 36); do openclaw gateway status --deep 2>/dev/null | grep -q 'Listening: 127.0.0.1:18789' && { echo ROLLED-BACK-LISTENING; exit 0; }; sleep 5; done; exit 1
"@ -AllowFail
  }

  Write-Host "`n== Final state ==" -ForegroundColor Green
  Invoke-Gateway "openclaw gateway status --deep 2>&1 | grep -E 'Gateway version|Runtime:|Connectivity|Listening|Service config issue'; openclaw secrets audit --check 2>&1 | head -3" -AllowFail
  if ($installOk) { Write-Host "`nNode/runtime: OK" -ForegroundColor Green } else { Write-Host "`nNode/runtime: ROLLED BACK, see log" -ForegroundColor Red }
  Write-Host @"

Last step (interactive, needs you): move the 4 plaintext secrets to SecretRefs. Values are unchanged; nothing is rotated.
  wsl -d $Distro -u $User
  openclaw secrets configure          # choose the built-in store/file provider; map all 4 findings; let it preflight and apply
  openclaw secrets audit --check      # expect plaintext=0
  openclaw secrets reload
"@ -ForegroundColor Yellow
}
finally { Stop-Transcript | Out-Null }
