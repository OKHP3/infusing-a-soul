<#
.SYNOPSIS
  Read-only diagnosis of a failed OpenClaw gateway update ("global-install-failed") in the
  Companion-owned OpenClawGateway WSL distro. Changes nothing.

.DESCRIPTION
  Collects update status, the global install layout under ~/.openclaw/tools, ownership,
  free space, running gateway processes, and the newest update-related log tails.
  Does not print openclaw.json or any credential file.
  Output: .local/gateway-updates/gateway-update-diag-<stamp>.log (gitignored).
#>
[CmdletBinding()]
param([string]$Distro = 'OpenClawGateway', [string]$User = 'openclaw')
$repo = Split-Path -Parent $PSScriptRoot
$logDir = Join-Path $repo '.local\gateway-updates'
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$out = Join-Path $logDir ("gateway-update-diag-{0}.log" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
$diag = @'
set +e
sec(){ printf '\n===== %s =====\n' "$1"; }
NM="$HOME/.openclaw/tools/node-v24.19.0/lib/node_modules"
sec "identity"; whoami; id; uname -a
sec "openclaw --version"; openclaw --version
sec "which openclaw / node"; command -v openclaw; readlink -f "$(command -v openclaw)"; command -v node; node --version
sec "openclaw update status --json"; openclaw update status --json 2>&1 | head -200
sec "tools dir"; ls -la "$HOME/.openclaw/tools/" 2>&1
sec "node_modules listing"; ls -la "$NM" 2>&1
sec "openclaw package entries (incl. staged/backup)"; ls -ld "$NM"/openclaw* "$NM"/.openclaw* 2>&1
sec "ownership not openclaw under node_modules (top 2 levels)"; find "$NM" -maxdepth 2 ! -user "$(whoami)" -printf '%u:%g %p\n' 2>&1 | head -40
sec "immutable/readonly attrs"; lsattr -d "$NM" "$NM"/openclaw* 2>&1 | head
sec "disk"; df -h "$HOME" /tmp 2>&1
sec "gateway processes"; ps -eo pid,user,etime,cmd | grep -i '[o]penclaw' | cut -c1-220
sec "open handles in package dir"; (command -v lsof >/dev/null && lsof +D "$NM/openclaw" 2>/dev/null | head -20) || echo "lsof not installed"
sec "recent update-related files under ~/.openclaw (24h)"; find "$HOME/.openclaw" -maxdepth 4 -mmin -1440 \( -iname '*update*' -o -iname '*npm*' -o -iname '*install*' \) -not -path '*/node_modules/*' -printf '%TY-%Tm-%Td %TH:%TM %s %p\n' 2>/dev/null | sort | tail -30
sec "newest npm debug log tail"; L=$(ls -t "$HOME"/.npm/_logs/*.log 2>/dev/null | head -1); [ -n "$L" ] && { echo "$L"; tail -n 80 "$L"; } || echo "no npm logs"
sec "update failure reports (newest 2)"; for f in $(ls -t "$HOME"/.openclaw/logs/support/openclaw-update-failure-*.json 2>/dev/null | head -2); do echo "--- $f"; cat "$f"; echo; done
sec "gateway log: update/install/swap lines"; grep -hiE 'update\.run|install|swap|EBUSY|EACCES|EPERM|ENOTEMPTY|EEXIST|rename' /tmp/openclaw/openclaw-$(date +%F).log 2>/dev/null | tail -40 | awk '{print substr($0,1,400)}'
sec "user journal: openclaw units, last 45 min"; journalctl --user --since "-45 min" --no-pager 2>/dev/null | grep -iE 'swap|install|update|rename|EBUSY|EACCES|EPERM|ENOTEMPTY|EEXIST' | tail -40 | awk '{print substr($0,1,400)}'
sec "update run scopes: full journal output (last 2 runs)"; for u in $(journalctl --user --since "-6 hours" --no-pager -o cat 2>/dev/null | grep -o 'openclaw-update-[0-9a-f-]*\.scope' | sort -u | tail -2); do echo "--- $u"; journalctl --user -u "$u" --no-pager -o short-iso 2>/dev/null | tail -120 | awk '{print substr($0,1,500)}'; done
sec "handoff dirs in /tmp"; for d in $(ls -dt /tmp/openclaw-update-run-handoff-* 2>/dev/null | head -2); do echo "--- $d"; ls -la "$d"; for f in "$d"/*.log "$d"/*.txt; do [ -f "$f" ] && { echo ">> $f (log lines + stderr, JSON body omitted)"; grep -vE '^[[:space:]]+|^[{}]' "$f" | awk '{print substr($0,1,600)}' | tail -120; echo ">> stderr/error fields:"; grep -iE 'stderr|npm (err|error)|EEXIST|ENOTEMPTY|EACCES|EPERM|EBUSY|rename|swap' "$f" | awk '{print substr($0,1,1500)}' | tail -40; }; done; done
sec "latest triage prompt: findings"; P=$(ls -t "$HOME"/.openclaw/logs/support/openclaw-triage-prompt-*.md 2>/dev/null | head -1); [ -n "$P" ] && { echo "$P"; grep -n -iE -A6 'finding|warning|error|swap|stderr' "$P" | grep -v -iE 'token|secret|password|apikey' | head -120 | awk '{print substr($0,1,600)}'; }
sec "npm logs written in last 2h"; for L in $(find "$HOME/.npm/_logs" -mmin -120 -name '*.log' 2>/dev/null | sort); do echo "--- $L"; grep -E ' (error|warn|verbose exit|verbose stack)' "$L" | tail -25 | awk '{print substr($0,1,400)}'; done
sec "files in installed package modified after install (top 40 by time)"; P="$NM/openclaw"; echo "package dir mtime: $(stat -c %y "$P")"; find "$P" -newer "$P/package.json" -type f -printf '%TY-%Tm-%Td %TH:%TM %s %P\n' 2>/dev/null | sort | tail -40; echo "count newer than package.json: $(find "$P" -newer "$P/package.json" -type f 2>/dev/null | wc -l)"; echo "total files in package: $(find "$P" -type f 2>/dev/null | wc -l)"
sec "openclaw systemd user units"; systemctl --user list-units --all --no-pager 'openclaw*' 2>&1 | head -20; systemctl --user list-unit-files --no-pager 'openclaw*' 2>&1 | head -20
sec "update help (this build)"; openclaw update --help 2>&1 | sed -n '1,60p' 
'@
"Gateway update diagnosis  $(Get-Date -Format o)" | Out-File -Encoding utf8 $out
(($diag -replace "`r", '') + "`n#") | wsl.exe -d $Distro -u $User -- bash -s 2>&1 | Out-File -Append -Encoding utf8 $out
Write-Host "Diagnosis written to $out" -ForegroundColor Green
