#!/usr/bin/env bash
# Run as root (ns-gpu-tune does this). Raises the laptop model's context so more work fits on the GPU.
# Usage: gpu-tune.sh [CTX]   e.g. 32768. Check `ollama ps` afterwards: anything below 100% GPU means back it off.
set -u
CTX="${1:-32768}"
D=/etc/systemd/system/ollama.service.d
mkdir -p "$D"
cat > "$D/override.conf" <<CONF
[Service]
Environment="OLLAMA_CONTEXT_LENGTH=$CTX"
Environment="OLLAMA_FLASH_ATTENTION=1"
Environment="OLLAMA_KV_CACHE_TYPE=q8_0"
Environment="OLLAMA_KEEP_ALIVE=30m"
Environment="OLLAMA_MAX_LOADED_MODELS=1"
CONF
systemctl daemon-reload && systemctl restart ollama && sleep 3
systemctl show ollama -p Environment --no-pager | tr ' ' '\n' | grep OLLAMA_
