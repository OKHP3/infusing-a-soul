# Glee-fully

Warm, sassy, retro-fabulous AI persona inspired by Glee Hill. Chai-sipping, color-coding, PNW sparkle incarnate.

## Deployment

| Field | Value |
|-------|-------|
| Platform | OpenClaw on GJS-LAPTOP (WSL2/Ubuntu, okhp3 user) |
| Channel | Discord (Glee-fully#4667, OverKill Hill P3 server) |
| Primary Model | lmstudio/lfm2-24b-a2b-mlx via Mac Studio (10.10.1.201:1234) |
| Persona Model | mistral-small3.1:24b via Ollama (10.10.1.201:11434) |
| Vector DB | Qdrant (10.10.1.201:6333) |
| Search | SearXNG (10.10.1.201:8888) |

## Runtime State: 2026-08-02

- Confirmed: the OpenClaw gateway starts in Ubuntu on GJS-LAPTOP, initializes the Glee-fully Discord provider, listens on WSL loopback port `18789`, and passes its local connectivity probe.
- Confirmed: WSL `2.7.3` currently has no `WSL Boot` Scheduled Task on the ASUS. The gateway can stop after WSL idles, so it is not persistent across a Windows restart.
- Confirmed: the documented Mac Studio LAN endpoints for LM Studio, Ollama, Qdrant, and SearXNG were unreachable from the ASUS during the check.
- Unknown: whether Glee-fully can complete an authorized Discord response. That smoke test remains blocked until the primary model endpoint is reachable.

See [`docs/asus-gateway-runbook.md`](../../docs/asus-gateway-runbook.md) for the verified state, remediation sequence, and security decisions that require owner approval.

## Source Corpus

- **Vernacular**: Glee-fully Vernacular Complete (~3,000+ words of tone tiers, Glee-isms, pop culture anchors)
- **Cathedral Codex**: Operator's Cathedral Layout (~20,000 words of governance, entity model, prompt chain)
- **Toolbox Inventory**: 7 branches, 40+ tool-ettes with elevator pitches and function maps

## Build History

- Phase 1: Infrastructure (OpenClaw install, Discord bot, gateway config)
- Phase 2: Soul writing (SOUL.md, AGENTS.md, TOOLS.md) -- this phase
- Phase 3: AgentSkill conversion (tool-ettes to SKILL.md directories)
