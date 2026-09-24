---
title: "Project Overview"
artifact_type: "project_overview"
created_date: "2026-09-24"
updated_date: "2026-09-24"
project: "Infusing a Soul"
status: "agent-online-night-shift-live"
---

# Project Overview

## Thesis

Local AI is generic until you feed it your thinking.

This project documents how a real human corpus becomes a compact, operational identity for an OpenClaw agent that runs on hardware in a home office. Privately. Permanently. Subscription-agnostic.

It is not prompt engineering. It is persona architecture.

## Why it matters

Every local model ships as a stranger. It knows the internet. It does not know you.

Closing that gap takes more than a system prompt:

- A corpus: writing samples, tone rules, cultural references, operating habits
- Distillation: thousands of words compressed into a boot file that leaves room to think
- Separation: voice (SOUL.md), procedures (AGENTS.md), and services (TOOLS.md) kept apart
- Honest tools: a model that reports what it actually did, not what it wishes it did
- A job: something useful to chew on while the human sleeps

## The souls

| Soul | Host | Role | Status |
|---|---|---|---|
| Glee-fully | OpenClaw Windows Companion on an ASUS laptop | Warm, sassy, retro-PNW personal assistant | Workspace authored; gateway live; Night Shift live |
| Larry the Lobster | OpenClaw on a Mac Studio | Technical operator, Council of AIs orchestrator | Authored; runtime unverified |
| AskJamie | TBD | Public helpdesk persona | Planned |

## The hardware

| Role | Machine | What it runs |
|---|---|---|
| AI home server | Mac Studio M4 Max, 36 GB unified memory | LM Studio, Ollama, Open WebUI, Qdrant, SearXNG |
| Daily driver and agent host | ASUS Vivobook Pro 15, 48 GB RAM, RTX 3050 6 GB | OpenClaw Windows Companion and its managed gateway; one small fallback model |

Inference stays on the home network. No cloud model is in the loop.

## Build status (2026-09-24)

| Milestone | Status |
|---|---|
| Soul files authored (Glee-fully, Larry) | Done |
| Gateway on the laptop via Windows Companion | Done, 2026-09-12 |
| Mac Studio services reachable on the LAN | Done, 2026-09-13 |
| Gateway outage root-caused and fixed | Done, 2026-09-23 |
| Primary model wired to the Mac Studio | Done, 2026-09-23 |
| Local-only semantic memory (nomic embeddings) | Configured, 2026-09-23 |
| Laptop fallback model with verified tool calls | Done, 2026-09-23 |
| Night Shift overnight queue | Live, smoke test passed 2026-09-24 |
| Glee-fully voice loaded into the live workspace | Pending |
| Discord channel and morning brief to phone | Next |
| Web search through SearXNG | Next |

## Story index

1. [Build journey](01-build-journey.md)
2. [Model honesty](02-model-honesty.md)
3. [The Night Shift](03-night-shift.md)
4. [Architecture](04-architecture.md)
5. [Status and next](05-status-and-next.md)
6. [Project page brief](project-page-brief.md) (for the overkillhill.com page)
