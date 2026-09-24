#!/usr/bin/env bash
# Show the morning brief for a date (arg 1) or the newest results folder.
R=~/.openclaw/workspace/night-shift/results
d="${1:-$(ls -1t "$R" 2>/dev/null | head -1)}"
[ -z "$d" ] && { echo "No results yet."; exit 0; }
echo "== results/$d"
cat "$R/$d/00-morning-brief.md" 2>/dev/null || ls -1 "$R/$d/" 2>/dev/null || echo "No results for $d."
