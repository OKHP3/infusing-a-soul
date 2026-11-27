<#
.SYNOPSIS
  Read-only snapshot for the post-upgrade doctor follow-ups on GJS-LAPTOP's OpenClawGateway distro.
  Changes nothing. Redacts any line that looks like it carries a key, token, or secret.
  Output: .local/gateway-updates/followups-<stamp>.log and .local/gateway-updates/live-workspace/ (gitignored).
#>
[CmdletBinding()]
param([string]$Distro = 'OpenClawGateway', [string]$User = 'openclaw')
$repo = Split-Path -Parent $PSScriptRoot
$dir = Join-Path $repo '.local\gateway-updates'
New-Item -ItemType Directory -Force -Path (Join-Path $dir 'live-workspace') | Out-Null
$out = Join-Path $dir ("followups-{0}.log" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
function Run([string]$Script, [string]$U = $User) { (($Script -replace "`r", '') + "`n#") | wsl.exe -d $Distro -u $U -- bash -l -s 2>&1 }

$collect = @'
set +e
sec(){ printf '\n===== %s =====\n' "$1"; }
red(){ sed -E 's/((key|token|secret|password|apikey|api_key|authorization)[^:=]*[:=][[:space:]]*)("?)[^",[:space:]]+/\1\3<redacted>/Ig'; }
sec "versions"; openclaw --version 2>&1 | tail -1; node --version 2>/dev/null; ls -la ~/.openclaw/tools/
sec "automations list"; openclaw automations list 2>&1 | red | head -60
sec "heartbeat-main detail"; (openclaw automations show 1a1a4e52-95c7-4c79-ae7c-f8e88ad4f44e --json 2>&1 || openclaw automations get 1a1a4e52-95c7-4c79-ae7c-f8e88ad4f44e 2>&1) | red | head -120
sec "automations edit --help"; openclaw automations edit --help 2>&1 | head -60
sec "secrets --help"; openclaw secrets --help 2>&1 | head -40
sec "secrets configure --help"; openclaw secrets configure --help 2>&1 | head -60
sec "secrets apply --help"; openclaw secrets apply --help 2>&1 | head -60
sec "secrets audit --check"; openclaw secrets audit --check 2>&1 | red | head -40
sec "backup --help"; openclaw backup --help 2>&1 | head -40
sec "backup create --help"; openclaw backup create --help 2>&1 | head -40
sec "backup enable --help"; openclaw backup enable --help 2>&1 | head -40
sec "memory settings"; openclaw config get memory.search.rememberAcrossConversations 2>&1 | tail -3; openclaw config get plugins.entries.active-memory 2>&1 | red | tail -10
sec "lmstudio models (maxTokens)"; openclaw config get models.providers.lmstudio.models 2>&1 | red | head -60
sec "ollama-local models (maxTokens)"; openclaw config get models.providers.ollama-local.models 2>&1 | red | head -60
sec "agents.defaults"; openclaw config get agents.defaults 2>&1 | red | head -60
sec "systemd unit"; systemctl --user cat openclaw-gateway.service 2>&1 | red
sec "systemd version / user@ stop timeout"; systemctl --version | head -1; systemctl show user@1000.service -p TimeoutStopUSec 2>&1
sec "gateway install --help"; openclaw gateway install --help 2>&1 | head -60
sec "installer: node / prefix / service handling"; I=$(readlink -f ~/.openclaw/tools/node)/lib/node_modules/openclaw/scripts/install-cli.sh; echo "$I"; grep -nE -- '--node-version|--prefix|--no-onboard|--no-service|tools/node|ln -s|gateway (install|restart|start)|systemctl|rm -rf' "$I" 2>/dev/null | head -60
sec "workspace"; ls -la ~/.openclaw/workspace/ 2>&1; find ~/.openclaw -maxdepth 4 -iname 'TOOLS*.md*' -not -path '*/node_modules/*' 2>/dev/null
'@
"Gateway follow-ups snapshot  $(Get-Date -Format o)" | Out-File -Encoding utf8 $out
Run $collect | Out-File -Append -Encoding utf8 $out
"systemd: root view of user@1000 drop-ins" | Out-File -Append -Encoding utf8 $out
Run 'ls -la /etc/systemd/system/user@1000.service.d/ 2>&1; systemctl --version | head -1' 'root' | Out-File -Append -Encoding utf8 $out

# Copy the live (post-merge) persona files for repo sync. Text only; no config or credentials.
foreach ($f in 'AGENTS.md','SOUL.md','IDENTITY.md','USER.md','HEARTBEAT.md','MEMORY.md') {
  $text = (Run "cat ~/.openclaw/workspace/$f 2>/dev/null") -join "`n"
  if ($text.Trim()) { [IO.File]::WriteAllText((Join-Path $dir "live-workspace\$f"), $text + "`n", [Text.UTF8Encoding]::new($false)) }
}
Write-Host "Snapshot written to $out (+ live-workspace\)" -ForegroundColor Green
