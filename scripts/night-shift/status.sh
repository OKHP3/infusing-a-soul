#!/usr/bin/env bash
# Show recent night-shift runs, gateway date/timezone, and newest results.
id=$(openclaw cron list --json 2>/dev/null | python3 -c 'import sys,json;d=json.load(sys.stdin);j=d.get("jobs",d) if isinstance(d,dict) else d;print(next(x["id"] for x in j if x.get("name")=="night-shift"))')
echo "== gateway clock: $(date '+%F %T %Z')"
echo "== recent runs for night-shift ($id)"
openclaw cron runs --id "$id" --limit 3 2>/dev/null || openclaw cron runs "$id" 2>/dev/null | tail -n 60
echo "== results folders"
ls -1t ~/.openclaw/workspace/night-shift/results/ 2>/dev/null | head -5 || echo "(none)"
