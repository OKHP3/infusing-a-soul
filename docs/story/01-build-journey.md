---
title: "Build Journey"
artifact_type: "build_journal"
created_date: "2026-09-24"
updated_date: "2026-09-24"
project: "Infusing a Soul"
---

# Build Journey

A dated record of how Glee-fully went from authored files to a working overnight agent. Dates are America/Chicago.

## Timeline

| Date | Milestone |
|---|---|
| 2026-06 | Glee-fully and Larry soul files authored. Larry's research corpus assembled. |
| 2026-08-02 | First gateway verification on the laptop under a hand-built WSL install. Persistence and Mac reachability both failed. |
| 2026-09-12 | Standalone WSL removed. OpenClaw Windows Companion installed with its own managed gateway. Pairing succeeded on loopback. |
| 2026-09-13 | Mac Studio services opened to the LAN: LM Studio, Ollama, Open WebUI, Qdrant, SearXNG. |
| 2026-09-23 | Gateway outage traced and fixed. Models wired. Honesty tests run. Laptop fallback installed. Night Shift built. |
| 2026-09-24 | Night Shift smoke test passed end to end. First real queue loaded. |

## 2026-09-23: the long day

### The outage

The Companion showed "Transport error." Four hundred fifty-two refused connections in a row.

The app was fine. The gateway underneath it could not boot.

Root cause: the 9/12 cleanup that removed standalone WSL also disabled the Virtual Machine Platform feature. The Companion's own gateway still runs on WSL2 and needs it. The change waited quietly for the next reboot, which happened to be an overnight Windows update. The update was the trigger, not the cause.

Fix: re-enable the feature, set the hypervisor to launch at boot, reboot. Rule recorded: never disable Virtual Machine Platform on this host.

### Wiring the brain

The gateway config was nearly empty. No provider, no model, no memory.

Through the Companion's built-in config editor:

- LM Studio on the Mac registered as the model provider
- Memory search pointed at a local nomic embedding model, with no cloud fallback
- Shell commands put behind a policy gate

### Finding out which models tell the truth

The first model wired in fabricated tool results. That story gets its own page: [Model honesty](02-model-honesty.md).

### A lifeboat on the laptop

The Mac is the server. The laptop is the daily driver and should stay light.

So the laptop got exactly one small model in Ollama, inside the gateway's own Linux environment, unloaded after five minutes idle. It exists for the moments the Mac is unreachable and for small internal jobs like titling sessions.

### The Night Shift

A queue you fill during the day. A job that works through it at 1:00 AM. Results waiting by morning. See [The Night Shift](03-night-shift.md).

## Lessons that shaped the design

- A cleanup step on one layer can silently break another. Record what every system change touches.
- A model that can run commands must report honestly what it ran. Verify with tool evidence, never with the model's own summary.
- Unattended work needs a narrower toolbox than attended work.
- The fastest fix is often a config file, not a new install.
