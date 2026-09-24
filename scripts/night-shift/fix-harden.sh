#!/usr/bin/env bash
# Point fallback + utility at Granite, restrict the night-shift job to file tools, and move exec off 'ask'
# (ask mode blocks ALL tools in scheduled runs: openclaw/openclaw#138853).
set -u
echo "== 1. Laptop provider: Granite 4.1 3B"
openclaw config set models.providers.ollama-local.models '[{"id":"granite4.1:3b","name":"Granite 4.1 3B (Laptop GPU)","reasoning":false,"input":["text"],"cost":{"input":0,"output":0,"cacheRead":0,"cacheWrite":0},"contextWindow":16384,"maxTokens":4096}]' --replace < /dev/null
echo "== 2. Fallback and Utility Model"
openclaw models fallbacks remove ollama-local/ministral-3:8b < /dev/null
openclaw models fallbacks add ollama-local/granite4.1:3b < /dev/null
openclaw config set agents.defaults.utilityModel ollama-local/granite4.1:3b < /dev/null
echo "== 3. Exec policy: ask -> allowlist (deterministic safe commands only, no approval gate)"
openclaw config set tools.exec.mode allowlist < /dev/null
echo "== 4. Night Shift job: file tools only"
id=$(openclaw cron list --json 2>/dev/null < /dev/null | python3 -c 'import sys,json;d=json.load(sys.stdin);j=d.get("jobs",d) if isinstance(d,dict) else d;print(next(x["id"] for x in j if x.get("name")=="night-shift"))')
echo "night-shift job id: $id"
openclaw cron edit "$id" --tools read,write,edit < /dev/null
echo "== 5. Verify"
openclaw config get agents.defaults.model --json < /dev/null
openclaw config get agents.defaults.utilityModel < /dev/null
openclaw config get tools --json < /dev/null
openclaw cron list --json < /dev/null | python3 -c 'import sys,json;d=json.load(sys.stdin);j=d.get("jobs",d) if isinstance(d,dict) else d;[print(x["name"],x.get("payload",{}).get("toolsAllow"),x.get("schedule")) for x in j]'
