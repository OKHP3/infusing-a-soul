---
title: "Status and Next"
artifact_type: "status_board"
created_date: "2026-09-24"
updated_date: "2026-09-24"
project: "Infusing a Soul"
---

# Status and Next

## Status board (2026-09-24)

| Area | Status | Evidence |
|---|---|---|
| Gateway health | Live | Companion connected; outage fixed 2026-09-23 |
| Primary model | Live | Night Shift smoke test on Mistral Small 3.2 |
| Laptop fallback | Configured | Direct tool calls verified; agent-level failover not yet exercised |
| Semantic memory | Configured | Local embeddings set; recall not yet exercised |
| Night Shift | Live | Smoke test passed; first real queue loaded |
| Glee-fully voice in the live workspace | Pending | OpenClaw default workspace files still active |
| Discord channel | Not started | Needs owner-supplied bot token |
| Web search | Not started | SearXNG on the Mac is reachable but not wired into the agent |

## Next, in order

1. Tighten the built-in scheduled jobs: slower heartbeat, file-only tools for background jobs.
2. Evaluate a lighter bootstrap context so the laptop fallback can cover a Night Shift run.
3. Load Glee-fully's SOUL.md, AGENTS.md, and TOOLS.md into the live workspace.
4. Discord: morning brief to phone, queue tasks from phone, owner-only command allowlist.
5. Web search through SearXNG so research tasks stop getting blocked.
6. Open WebUI tuning on the Mac, with Qdrant for the personal corpus.
7. Move the gateway to the Mac.

## Open risks

| Risk | Mitigation |
|---|---|
| A known OpenClaw issue blocks tools in scheduled runs under approval-gated shell modes | Shell mode set to allowlist; job restricted to file tools |
| Laptop must stay awake overnight | Plugged in, sleep disabled on AC; long-term fix is moving the gateway |
| Plaintext gateway token in config | Migrate to the OpenClaw secret store |
