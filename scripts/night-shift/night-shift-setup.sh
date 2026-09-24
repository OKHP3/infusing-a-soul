#!/usr/bin/env bash
# Night Shift setup for OpenClaw on GJS-LAPTOP. Idempotent. Run as the openclaw user inside OpenClawGateway.
set -euo pipefail
WS=$HOME/.openclaw/workspace
TODAY=$(date +%F)

echo "== 1. Preflight"
command -v openclaw >/dev/null || { echo "FAIL: openclaw CLI not on PATH"; exit 1; }
WINROOT=""
for m in /mnt/c $(findmnt -rn -t drvfs,9p,virtiofs -o TARGET 2>/dev/null); do
  [ -d "$m/Users/jamie" ] && { WINROOT="$m"; break; }
done
if [ -n "$WINROOT" ]; then
  WIN="$WINROOT/Users/jamie/OKH-Local/night-shift"
  echo "ok: Windows drive found at $WINROOT; queue will live in C:\\Users\\jamie\\OKH-Local\\night-shift"
else
  WIN="$WS/night-shift"
  echo "note: no Windows drive mounted in this distro; queue will live inside the workspace (use the PowerShell helpers)"
fi

echo "== 2. Queue folders"
mkdir -p "$WIN/inbox" "$WIN/results"
if [ ! -f "$WIN/queue.md" ]; then
cat > "$WIN/queue.md" <<'Q'
# Night Shift Queue

One task per line. The 1:00 AM run works top to bottom and marks each line when done.
Drop any files you want processed into the inbox folder and mention them by name.

Status marks: [ ] waiting, [x] done (link to result), [!] blocked (reason given)

- [ ] Smoke test: write a four-line poem about a lobster who works the night shift, in Glee-fully's voice.
Q
echo "created queue.md with one smoke-test task"
else echo "queue.md already exists, left untouched"; fi

echo "== 3. Link the folder into the agent workspace"
if [ "$WIN" = "$WS/night-shift" ]; then echo "queue is already inside the workspace"
elif [ -L "$WS/night-shift" ]; then echo "link exists"
else ln -s "$WIN" "$WS/night-shift"; echo "linked $WS/night-shift -> $WIN"; fi

echo "== 4. Night Shift procedure (workspace/NIGHT-SHIFT.md)"
[ -f "$WS/NIGHT-SHIFT.md" ] && cp "$WS/NIGHT-SHIFT.md" "$WS/NIGHT-SHIFT.md.bak"
cat > "$WS/NIGHT-SHIFT.md" <<'P'
# NIGHT-SHIFT.md: Overnight Queue Procedure

You are running unattended while Jamie sleeps. Work carefully, not fast.

## Inputs
- Queue: night-shift/queue.md (lines starting with "- [ ]" are waiting)
- Files: night-shift/inbox/ (only when a task names them)

## For each waiting task, top to bottom, at most 8 per night
1. Read the task. If it needs something you cannot do with the rules below, mark it blocked.
2. Do the work. Prefer depth and accuracy over length.
3. Write the result to night-shift/results/YYYY-MM-DD/NN-short-slug.md (today's date, NN = 01, 02, ...).
   Start each result with: the task text, a 3 to 5 bullet summary, then the full output.
4. Edit that line in queue.md:
   - done: "- [x] task text -> results/YYYY-MM-DD/NN-short-slug.md"
   - blocked: "- [!] task text (blocked: one-line reason)"
5. Move to the next task. Never stop the whole run because one task failed.

## When the queue is done
Write night-shift/results/YYYY-MM-DD/00-morning-brief.md:
- one line per task with status and the single most useful takeaway
- anything that needs Jamie's decision, at the top

## Hard rules
- Only use file read and file write tools, and only inside night-shift/.
- Never run shell commands. Never delete, move, or rename files.
- Never send messages, post, email, purchase, or contact anyone.
- Never invent sources, numbers, quotes, or tool results. If unsure, say so in the result.
- No em dashes. US English. Short paragraphs. Tables for comparisons.
- If a task asks for current events or live web data and you have no web tool, mark it blocked.
P
echo "wrote NIGHT-SHIFT.md"

echo "== 5. Scheduled job (1:00 AM Central, isolated session, no external delivery)"
if openclaw cron list --json 2>/dev/null | grep -q '"night-shift"'; then
  echo "job 'night-shift' already exists"
else
  openclaw cron add --name "night-shift" --cron "0 1 * * *" --tz "America/Chicago" --session isolated \
    --no-deliver \
    --message "Run the Night Shift. Read NIGHT-SHIFT.md in your workspace and follow it exactly. Use your file tools for every read and write; do not describe work you did not actually perform."
fi

echo "== 6. Current jobs"
openclaw cron list
echo
echo "Next: run the smoke test with:  openclaw cron run <night-shift job id>"
echo "Then check results for $TODAY (ns-brief in PowerShell, or the folder above)"
