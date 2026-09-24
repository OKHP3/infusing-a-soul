#!/usr/bin/env bash
# Read-only diagnostics: does granite4.1:3b tool-call via Ollama, and what is OpenClaw's tool policy?
set -u
echo "=== 1. Direct Ollama tool-call test (OpenAI-compatible /v1) ==="
cat > /tmp/t.json <<'J'
{"model":"granite4.1:3b","messages":[{"role":"user","content":"What is the weather in Dallas?"}],
 "tools":[{"type":"function","function":{"name":"get_weather","description":"Get current weather",
 "parameters":{"type":"object","properties":{"city":{"type":"string"}},"required":["city"]}}}]}
J
r=$(curl -s -m 170 http://127.0.0.1:11434/v1/chat/completions -d @/tmp/t.json)
echo "$r" | grep -o '"tool_calls".\{0,160\}' || { echo "NO tool_calls. Raw reply:"; echo "$r" | head -c 600; echo; }
echo
echo "=== 2. Direct Ollama tool-call test (native /api/chat) ==="
sed 's/}]}$/}],"stream":false}/' /tmp/t.json > /tmp/t2.json
r2=$(curl -s -m 170 http://127.0.0.1:11434/api/chat -d @/tmp/t2.json)
echo "$r2" | grep -o '"tool_calls".\{0,160\}' || { echo "NO tool_calls. Raw reply:"; echo "$r2" | head -c 600; echo; }
echo
echo "=== 3. OpenClaw tool policy ==="
openclaw config get tools --json 2>&1 | tail -n 40
echo
echo "=== 4. OpenClaw agents.defaults ==="
openclaw config get agents.defaults --json 2>&1 | tail -n 40
