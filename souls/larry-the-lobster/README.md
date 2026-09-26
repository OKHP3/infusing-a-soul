# Larry the Lobster

Technical power-user persona for the Mac Studio OpenClaw instance. ROY-principled, ForgeDialect.A1, decision-memo tone. Modeled after Larry the Lobster from SpongeBob SquarePants: sincere, direct, zero cynicism, built to hype and to build.

## Deployment

| Field | Value |
|-------|-------|
| Platform | OpenClaw on Mac Studio M4 Max (native macOS) |
| Channel | Control UI, iOS/iPadOS via Tailscale Serve, iMessage |
| Primary Model | ollama/gpt-oss:20b (as of 2026-09-25) |
| Fallbacks | lmstudio/liquid/lfm2-24b-a2b, then ollama/llama3.1:8b |
| Vector DB | Qdrant (localhost:6333) |
| Search | SearXNG (localhost:8888) |

## Design Intent

Larry is Jamie's personal Council of AIs orchestrator. He handles the content pipeline (Notion staging, GitHub commits), research vault operations, Mermaid diagramming workflow, and technical analysis. His voice channels the SpongeBob character's wholesome gym-bro energy into technical work: fitness metaphors applied to code, zero sarcasm, total sincerity, and a genuine belief that building things up is better than tearing them down.

Larry operates on the Mac Studio and is air-gapped from Glee-fully's persona, credentials, and scope. Two machines, two agents, two personas, zero credential crossover.

## Source Corpus

- **Research Corpus**: `references/larry-research-corpus.md` (franchise-wide character study, 10 sections, episode-level citations)
- **Research Prompt**: `references/larry-research-prompt.md` (reusable prompt for expanding the corpus)

## Build History

| Phase | Scope | Status |
|-------|-------|--------|
| Phase 1 | OpenClaw install on Mac Studio, CLI gateway | Complete (prior thread) |
| Phase 2 | SOUL.md, AGENTS.md, TOOLS.md authoring | Complete (2026-06-06) |
| Phase 2.5 | Deployed to live workspace; rebuilt on OpenClaw 2026.9.6 templates (TOOLS.md folded into AGENTS.md `## Tools`, IDENTITY.md added, USER.md directive model) | Complete (2026-09-25) |
| Phase 3 | AgentSkill conversion | Queued |
| Phase 4 | Routing, interop, Glee-fully relay testing | Queued |

## Word Budget

| File | Words | Target | Status |
|------|-------|--------|--------|
| SOUL.md | 379 | ~300 | Slightly over (richer persona source) |
| AGENTS.md | 365 | ~400 | On target |
| TOOLS.md | 267 | ~300 | On target |
| **Combined** | **1,011** | **<1,500** | **32% under ceiling** |
