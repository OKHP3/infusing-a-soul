#!/usr/bin/env bash
# Trigger the night-shift job immediately.
id=$(openclaw cron list --json 2>/dev/null | python3 -c 'import sys,json;d=json.load(sys.stdin);j=d.get("jobs",d) if isinstance(d,dict) else d;print(next(x["id"] for x in j if x.get("name")=="night-shift"))')
echo "night-shift job: $id"
openclaw cron run "$id"
