<#
.SYNOPSIS
  Read-only inference health check for GJS-LAPTOP: Mac Studio LM Studio/Ollama over Tailscale (from Windows
  and from the OpenClawGateway distro) and the laptop Ollama inside the distro. Changes nothing.
  Output: .local/gateway-updates/inference-<stamp>.log
#>
[CmdletBinding()]
param([string]$Distro = 'OpenClawGateway', [string]$User = 'openclaw', [string]$Mac = '100.87.4.93')
$repo = Split-Path -Parent $PSScriptRoot
$out = Join-Path $repo ('.local\gateway-updates\inference-{0}.log' -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
function W($t) { $t | Out-File -Append -Encoding utf8 $out }
W "Inference check $(Get-Date -Format o)"
W "`n===== Windows: Tailscale ====="
$ts = Get-Command tailscale -ErrorAction SilentlyContinue
if ($ts) { W ((& tailscale status 2>&1 | Select-Object -First 15) -join "`n"); W ((& tailscale ping -c 2 $Mac 2>&1) -join "`n") } else { W 'tailscale CLI not on PATH' }
W "`n===== Windows: TCP to Mac ports ====="
foreach ($p in 1234, 11434, 6333, 8888) {
  $r = Test-NetConnection -ComputerName $Mac -Port $p -WarningAction SilentlyContinue -InformationLevel Quiet
  W ("{0}:{1} -> {2}" -f $Mac, $p, $r)
}
$probe = @"
set +e
sec(){ printf '\n===== %s =====\n' "`$1"; }
sec "distro -> Mac LM Studio /v1/models"; curl -s -m 8 -o /dev/null -w 'http=%{http_code} t=%{time_total}s\n' http://${Mac}:1234/v1/models || echo "curl exit `$?"
sec "distro -> Mac Ollama /api/tags"; curl -s -m 8 http://${Mac}:11434/api/tags | head -c 400; echo
sec "laptop Ollama service"; systemctl is-active ollama 2>&1; systemctl --user is-active ollama 2>&1; pgrep -af 'ollama serve' | head -3
sec "laptop Ollama /api/tags"; curl -s -m 8 http://127.0.0.1:11434/api/tags | head -c 600; echo
sec "laptop Ollama /api/ps"; curl -s -m 8 http://127.0.0.1:11434/api/ps | head -c 600; echo
sec "laptop Ollama tiny generate (granite4.1:3b, 90s max)"; curl -s -m 90 http://127.0.0.1:11434/api/generate -d '{"model":"granite4.1:3b","prompt":"Reply with the single word pong.","stream":false,"options":{"num_predict":8}}' | head -c 500; echo; echo "curl exit `$?"
sec "GPU"; nvidia-smi --query-gpu=name,memory.used,memory.total,driver_version --format=csv 2>&1 | head -5
sec "ollama journal (last 40)"; journalctl -u ollama --no-pager -n 40 2>/dev/null | cut -c1-220 || echo 'no system ollama journal'
sec "provider baseUrls"; openclaw config get models.providers.ollama-local.baseUrl 2>&1 | tail -1; openclaw config get models.providers.lmstudio.baseUrl 2>&1 | tail -1
sec "gateway log: provider errors (last 25)"; grep -hiE 'provider-transport|fetch failed|ECONNREFUSED|ollama|lmstudio' ~/.openclaw/logs/openclaw-`$(date +%F).log /tmp/openclaw/openclaw-`$(date +%F).log 2>/dev/null | tail -25 | cut -c1-300
"@
W "`n===== Distro probes ====="
((($probe -replace "`r", '') + "`n#") | wsl.exe -d $Distro -u $User -- bash -l -s 2>&1) | Out-File -Append -Encoding utf8 $out
Write-Host "Inference check written to $out" -ForegroundColor Green
