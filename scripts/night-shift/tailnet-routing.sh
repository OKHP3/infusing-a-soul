#!/usr/bin/env bash
# Route the gateway to the Mac Studio over Tailscale and keep the laptop GPU as fallback + utility.
# Usage (via ns-tailnet): tailnet-routing.sh [MAC_TAILNET_IP] [LAPTOP_CTX]
# Stops before changing anything if LM Studio is not reachable over the tailnet from inside this distro.
set -u
MAC="${1:-100.87.4.93}"          # overkill-hills-mac-studio (Tailscale). Tailscale IPs are stable per device.
CTX="${2:-16384}"                # must match OLLAMA_CONTEXT_LENGTH (see gpu-tune.sh)
PRIMARY="mistral-small-3.2-24b-instruct-2506-mlx"
LOCAL="granite4.1:3b"
CFG="$HOME/.openclaw/openclaw.json"
providers() { openclaw config get models.providers --json 2>/dev/null < /dev/null | python3 -c 'import sys,json
d=json.load(sys.stdin)
for k,v in d.items(): print(" ",k,v.get("baseUrl"),[m["id"] for m in v.get("models",[])])'; }

echo "== 0. Tailnet reachability from inside the gateway distro"
for p in 1234 11434; do printf "  %s:%s -> " "$MAC" "$p"; curl -s -m 5 -o /dev/null -w "%{http_code}\n" "http://$MAC:$p/"; done
ids=$(curl -s -m 8 "http://$MAC:1234/v1/models" | python3 -c 'import sys,json;print(" ".join(m["id"] for m in json.load(sys.stdin)["data"]))' 2>/dev/null)
case " $ids " in *" $PRIMARY "*) echo "  LM Studio OK, primary model present";;
  *) echo "  STOP: LM Studio not reachable over the tailnet, or $PRIMARY missing. Nothing changed."; exit 1;; esac

echo "== 1. Laptop model present in Ollama?"
if ollama list 2>/dev/null | awk '{print $1}' | grep -qx "$LOCAL"; then echo "  $LOCAL installed"
else echo "  pulling $LOCAL"; ollama pull "$LOCAL" < /dev/null || { echo "  STOP: pull failed. Nothing changed."; exit 1; }; fi

echo "== 2. Backup and current state"
cp "$CFG" "$CFG.bak-$(date +%Y%m%d-%H%M%S)" && echo "  backup written next to $CFG"
openclaw config get agents.defaults --json < /dev/null
providers

echo "== 3. Providers: Mac over Tailscale, laptop over loopback"
openclaw config set models.providers.lmstudio.baseUrl "http://$MAC:1234/v1" < /dev/null
openclaw config set models.providers.lmstudio.models "[{\"id\":\"$PRIMARY\",\"name\":\"Mistral Small 3.2 24B (Mac Studio)\",\"reasoning\":false,\"input\":[\"text\"],\"cost\":{\"input\":0,\"output\":0,\"cacheRead\":0,\"cacheWrite\":0},\"contextWindow\":131072,\"maxTokens\":8192},{\"id\":\"text-embedding-nomic-embed-text-v1.5\",\"name\":\"Nomic Embed Text v1.5 (Mac Studio)\"}]" --replace < /dev/null
openclaw config set models.providers.ollama-local.models "[{\"id\":\"$LOCAL\",\"name\":\"Granite 4.1 3B (Laptop GPU)\",\"reasoning\":false,\"input\":[\"text\"],\"cost\":{\"input\":0,\"output\":0,\"cacheRead\":0,\"cacheWrite\":0},\"contextWindow\":$CTX,\"maxTokens\":4096}]" --replace < /dev/null

echo "== 4. Routing: Mac primary, laptop fallback + utility"
openclaw config set agents.defaults.model "{\"primary\":\"lmstudio/$PRIMARY\",\"fallbacks\":[\"ollama-local/$LOCAL\"]}" --replace < /dev/null
openclaw config set agents.defaults.utilityModel "ollama-local/$LOCAL" < /dev/null

echo "== 5. Memory embeddings follow the Mac to its tailnet address (only if the key already exists)"
if openclaw config get memory.search.remote.baseUrl < /dev/null > /dev/null 2>&1; then
  openclaw config set memory.search.remote.baseUrl "http://$MAC:1234/v1" < /dev/null
else echo "  memory.search.remote.baseUrl not set; left alone"; fi

echo "== 6. After"
openclaw config get agents.defaults --json < /dev/null
providers
echo "== 7. Live check: laptop model answers on the GPU"
curl -s -m 120 http://127.0.0.1:11434/api/generate -d "{\"model\":\"$LOCAL\",\"prompt\":\"Reply with the single word READY.\",\"stream\":false,\"keep_alive\":\"10m\"}" | python3 -c 'import sys,json;print("  reply:",json.load(sys.stdin).get("response","").strip()[:40])'
ollama ps
