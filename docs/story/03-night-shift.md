---
title: "The Night Shift"
artifact_type: "operating_procedure"
created_date: "2026-09-24"
updated_date: "2026-09-24"
project: "Infusing a Soul"
status: "live"
---

# The Night Shift

Stack it up during the day. Throw it over the wall at bedtime. Read the results with coffee.

## How it works

1. **Queue.** Tasks go into a plain Markdown checklist, one per line. Files to process go in an inbox folder.
2. **Run.** At 1:00 AM Central, an isolated OpenClaw session reads the procedure file and works the queue top to bottom, up to eight tasks.
3. **Record.** Each result is written to a dated results folder. Each queue line is marked done with a link, or blocked with a one-line reason.
4. **Brief.** The run ends with a morning brief: one line per task, decisions needed at the top.

## The daily loop from Windows

A small PowerShell helper set wraps everything, so the gateway's Linux environment never has to be touched by hand.

| Command | What it does |
|---|---|
| `ns-add <task>` | Queue a task for tonight |
| `ns-queue` | Show the queue with status marks |
| `ns-run` | Run the Night Shift now |
| `ns-status` | Show recent runs and any errors |
| `ns-brief` | Show the newest morning brief |
| `ns-read <date> <nn>` | Open one full result |

Source: [`scripts/night-shift/`](../../scripts/night-shift/).

## Safety by design

| Guardrail | Why |
|---|---|
| The scheduled job may use only read, write, and edit | Unattended plus shell is how things go wrong |
| The procedure forbids deleting, moving, messaging, posting, purchasing | The agent can create, never destroy or reach out |
| Work stays inside the night-shift folder | Blast radius of one directory |
| Never describe work not performed | Direct response to the fabrication found in [Model honesty](02-model-honesty.md) |
| Blocked beats guessed | A task needing live web data is marked blocked until web search is wired in |

## First run (2026-09-24)

| Check | Result |
|---|---|
| Model | Mistral Small 3.2 24B on the Mac Studio |
| Duration | 83 seconds |
| Result file written and linked from the queue | Yes |
| Morning brief written | Yes |

## Good work for the Night Shift today

- Drafts in a known voice: post hooks, outlines, first passes
- Summaries and reviews of files dropped in the inbox
- Brainstorms, ranked lists, comparison tables
- Rewrites and restructuring of existing text

## Not yet

- Anything needing current web data (web search is next)
- Anything needing shell commands (by design)

## Known limits

- The gateway runs on the laptop, so the laptop must be awake and plugged in overnight.
- A full run needs about 39K tokens of context. The laptop fallback model cannot hold that, so if the Mac is down at 1:00 AM the run fails rather than degrading. A lighter bootstrap context is being evaluated.
