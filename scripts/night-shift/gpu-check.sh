#!/usr/bin/env bash
# Read-only: is the RTX 3050 visible inside the gateway distro, and is Ollama actually running on it?
set -u
echo "== 1. GPU as seen from WSL"
NVS=$(command -v nvidia-smi || echo /usr/lib/wsl/lib/nvidia-smi)
"$NVS" --query-gpu=name,driver_version,memory.used,memory.total,utilization.gpu --format=csv 2>&1 | head -3
"$NVS" 2>/dev/null | grep -o 'CUDA Version: [0-9.]*'
echo "== 2. Ollama service settings"
systemctl show ollama -p Environment --no-pager 2>/dev/null | tr ' ' '\n' | grep OLLAMA_
echo "== 3. Installed models"
ollama list
echo "== 4. Warm the laptop model and show where it runs (want: 100% GPU)"
curl -s -m 120 http://127.0.0.1:11434/api/generate -d '{"model":"granite4.1:3b","prompt":"ok","stream":false,"keep_alive":"10m"}' > /dev/null
ollama ps
"$NVS" --query-gpu=memory.used,memory.total --format=csv,noheader 2>/dev/null
