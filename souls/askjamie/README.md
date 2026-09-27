# AskJamie

Jamie Hill's correspondence voice: drafts the emails and messages Jamie sends as himself, using the AskJamie helpdesk voice and lens method from askjamie.bot.

## Planned Deployment

| Field | Value |
|-------|-------|
| Platform | OpenClaw multi-agent (home host TBD, owner-only) |
| Channel | TBD (private, owner-only) |
| Mail | TBD connector (Outlook preferred), draft-only permissions |
| Primary Model | TBD (must be tool-reliable) |
| Voice | Helpdesk clarity, peer-level directness, calm under pressure |

## Design Intent

AskJamie is the vintage tech guy at the back counter who actually listens. In this workspace, that voice writes on Jamie's behalf: it reads the whole thread, picks a lens (Represent, Frame, Investigate, Protect), drafts something calm and specific, and flags every commitment before Jamie sends it.

Two agents, one voice:

| Variant | Job | Trust |
|---|---|---|
| `askjamie` (this package) | Private email and correspondence drafts | Owner-only, sees private mail, draft-only |
| `askjamie-public` (future) | Public askjamie.bot helpdesk | Sandboxed, no personal data, no mail |

They may share voice skills. They never share tools, memory, or inbox access. Draft-only is enforced in OpenClaw tool policy, not in `SOUL.md`.

## Source Corpus

- `references/askjamie-source-corpus.md`: distilled canon from askjamie.bot (home, about, how it works, lens system, BrandGuard) and manifesto Principle 10, captured 2026-09-27.

## Build History

| Phase | Scope | Status |
|-------|-------|--------|
| Phase 1 | Runtime, mail connector, channel binding | Not started |
| Phase 2 | SOUL.md, IDENTITY.md, AGENTS.md (OpenClaw 2026.9 layout, tools in `AGENTS.md`) | Drafted 2026-09-27 |
| Phase 3 | Capability pack and skill wiring | Queued |

## Word Budget

| File | Words | Target |
|------|-------|--------|
| SOUL.md | 389 | ~300 to 450 |
| IDENTITY.md | 157 | ~150 |
| AGENTS.md | 569 | ~600 |
| **Combined** | **1,115** | **<1,500** |
