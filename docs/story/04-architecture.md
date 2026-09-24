---
title: "Architecture"
artifact_type: "architecture"
created_date: "2026-09-24"
updated_date: "2026-09-24"
project: "Infusing a Soul"
---

# Architecture

Two machines. One agent. Every token stays in the house.

## Topology

```mermaid
flowchart LR
  subgraph Laptop["ASUS laptop (daily driver)"]
    Companion["OpenClaw Windows Companion"]
    subgraph WSL["Managed gateway environment"]
      Gateway["OpenClaw gateway"]
      Workspace["Workspace: SOUL, AGENTS, TOOLS, NIGHT-SHIFT"]
      Queue["night-shift queue and results"]
      Ollama["Ollama: Granite 4.1 3B"]
    end
    PS["PowerShell ns-* helpers"]
  end
  subgraph Mac["Mac Studio (AI home server)"]
    LMS["LM Studio: Mistral Small 3.2 24B, nomic embeddings"]
    OWU["Open WebUI"]
    QD["Qdrant"]
    SX["SearXNG"]
  end
  Companion --> Gateway
  PS --> Queue
  Gateway --> Workspace
  Gateway --> Queue
  Gateway -- "primary model" --> LMS
  Gateway -- "fallback and utility model" --> Ollama
  Gateway -- "memory embeddings" --> LMS
```

## Model routing

| Role | Model | Host | Notes |
|---|---|---|---|
| Primary | Mistral Small 3.2 24B | Mac Studio | Passed the honesty test |
| Fallback | Granite 4.1 3B | Laptop GPU | Takes over when the Mac is unreachable |
| Utility | Granite 4.1 3B | Laptop GPU | Session titles and progress notes |
| Embeddings | nomic-embed-text v1.5 | Mac Studio | Memory search, no cloud fallback |

## Policy

| Setting | Value | Reason |
|---|---|---|
| Shell commands (interactive) | Allowlist | Safe commands only, no approval prompt that a scheduled run cannot answer |
| Night Shift tools | read, write, edit | Unattended work gets the narrowest toolbox |
| Memory fallback | none | Never silently send text to a cloud provider |

## Design choices

- **The Mac serves, the laptop visits.** Heavy models and shared services live on the Mac. The laptop carries one small model that unloads after five minutes idle.
- **Config over installs.** The Companion's config editor and the OpenClaw CLI did most of the work. Nothing was added to the laptop that the Mac already provides.
- **Evidence over assurance.** Tool cards and file checks decide whether work happened.

## Where this is heading

Move the gateway itself to the Mac, with the laptop, phone, and tablet as clients. That is the SHOAL end state, and it lets the laptop sleep.
