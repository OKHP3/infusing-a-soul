---
title: "OpenClaw Persona and Skill Architecture"
primary_topic: "OpenClaw persona and skill architecture"
source_platform: "Perplexity"
capture_mode: "full-paste"
completeness: "partial"
extraction_depth: "comprehensive"
requested_extraction_depth: "highly detailed"
source_title: "I've been working to set up local AI on my new Mac Studio"
source_date: "unknown"
source_time_context: "Unknown; source discusses a viability check framed as June 2026"
source_locator: "Perplexity thread supplied in request; omitted from repository artifact"
retention_decision: "redacted"
source_independence: "pass"
generated_at: "2026-07-22T16:36:44Z"
schema_version: "2.0"
artifact_type: thread-context-extract
---

# OpenClaw Persona and Skill Architecture

## Introduction

This partial Perplexity capture evaluates a local-first OpenClaw architecture built around two different machines, two distinct personas, and a layered division of responsibility. The Mac Studio is proposed as the trusted primary instance for Larry the Lobster, while the Asus is proposed as a narrower, sandboxed helper for Glee-fully, experimentation, orchestration, and lower-stakes work. The core design separates identity and voice in `SOUL.md`, task capability in domain-specific `SKILL.md` files, and intent classification in a deliberately narrow router skill. The capture then extends that design into an installation-first rollout, a branch-first migration of former Custom GPTs, a prompt test suite, a cross-instance handoff protocol, and a two-layer Notion and GitHub capture workflow. The supplied text supports the architecture as a viable design proposal, but it does not prove that OpenClaw has been installed, that current platform behavior matches the assistant's June 2026 claims, that the embedded files were deployed, or that the supplied Notion and Perplexity pages were accessible. Three named DOCX, PDF, and Markdown sidecars were not present at their stated local paths, so this artifact preserves their missing status rather than claiming cross-file completeness.

## Extraction profile

- **Requested depth:** highly detailed
- **Selected depth:** comprehensive
- **Selection basis:** the user explicitly requested a high-quality and very detailed synthesis using the Perplexity-specific and shared extraction skills
- **Profile changes:** none
- **Focus areas:** Mac Studio primary versus Asus helper; Larry and Glee-fully persona separation; `SOUL.md` and `SKILL.md` architecture; router and handoff rules; OpenClaw installation sequencing; former Custom GPT migration; local capture, Notion, and GitHub roles; privacy, access, fidelity, and governance limits
- **Must preserve:** the dual-instance proposal; the layered mental model; the recommended pilot sequence; rejected alternatives and their rationale; the embedded SOUL and skill package; the Capture & Route prompt; the archive contract; unresolved verification and implementation gaps
- **Safe exclusions:** repetitive executive-summary language, repeated follow-up offers, empty lines, and interface chrome are compressed or excluded from the semantic body
- **Coverage rule:** each visible question, answer, prompt, embedded artifact group, and source-sidecar reference receives an individual turn or element disposition; embedded file contents are retained as text-derived assets, not treated as separately attached files
- **Not carried forward:** a lossless transcript, exact private Notion URL, unsupported source bibliography, unverified platform behavior as settled fact, and unavailable DOCX/PDF/Markdown payloads
- **Source-independence test:** pass for understanding the architecture, rationale, current conceptual state, and resume plan; file-specific validation, source-page inspection, Notion schema resolution, and GitHub reconciliation remain blocked by missing or inaccessible sidecars

## Coverage accounting

| Material class | Assessed | Retained | Compressed | Omitted with reason | Missing or unavailable | Notes |
|---|---:|---:|---:|---:|---:|---|
| Turns or turn groups | 11 | 11 | 0 | 0 | 0 | Flattened capture normalized from profile-avatar, answer-step, heading, and prompt boundaries; some embedded artifact boundaries remain medium or low confidence |
| Rich elements and sidecars | 22 | 15 | 0 | 0 | 7 | Text-derived SOUL, router, skill, diagram, and prompt records retained; source-panel labels were assessed, but three named local files, source locators, and source cards are unavailable |
| Decisions and alternatives | 18 | 18 | 0 | 0 | 0 | Architecture, trust, rollout, migration, routing, and archive choices preserved with claim classes |
| Reusable assets | 16 | 16 | 0 | 0 | 0 | Mental models, contracts, prompts, test plans, handoff format, and risk controls extracted separately |

## Source synopsis

The visible capture starts with a user asking whether a new Mac Studio should become the main local-AI host while an Asus Windows laptop becomes a secondary OpenClaw helper. The answer presents four deployment options: Windows Hub on a separate account, WSL2, a dedicated VM, or a remote helper. WSL2 is favored for Linux compatibility, but the recommended operating model is broader than a runtime choice: the Asus should be a sandboxed helper with a separate operating-system account, narrow permissions, limited credentials, and no public internet exposure. The Mac Studio is assigned the heavier local-AI work. The Asus is better suited to orchestration, monitoring, summaries, inbox triage, scheduled jobs, or a remote-control bridge. Local model inference on the Asus is treated as optional and should begin with a small model after memory and latency are measured.

The next user turn describes a larger idea: convert the former Custom GPT ecosystem into an OpenClaw package. The user identifies `SOUL.md` as a place for persona, voice, tone, and style; `SKILL.md` as a place for former GPT capabilities; and a routing skill as the dispatch layer. Larry the Lobster is proposed for the Mac Studio primary instance. Glee-fully is proposed for the Asus sandbox. The answer calls the idea viable if it is built as a layered system rather than a single giant prompt. It treats the existing Glee-fully Personalizable Tools material as a source corpus of reusable tonal primitives, including `Bleeds Glee`, `ForgeDialect.A1`, and `Watchkeeper.Core`.

The assistant's central design rule is a clean separation of concerns:

1. `SOUL.md` answers, "Who am I?"
2. `ROUTER.SKILL.md` answers, "What kind of request is this?"
3. A task `SKILL.md` answers, "How do I do this job well?"
4. Instance assignment answers, "Where should this happen, and how trusted is that environment?"

The capture warns that prompt entanglement is the primary failure mode. If voice, routing, and task execution are allowed to mutate one another, the system becomes hard to debug and tune. The proposed remedy is to keep the router narrow and boring, the persona expressive, and task skills specific. It recommends starting with one persona file, three to five representative skills, and one lightweight router instead of attempting a full-suite migration immediately.

The following user turn asks for a viability check framed as June 2026, followed by a prerequisite and installation plan. The answer says the concept is doable with scope discipline and adds a governance caveat: current Skill Workshop behavior is described as proposal-first and apply-later rather than as an unconstrained agent-authored live skill workflow. This is a source assertion that needs current first-party verification. The recommended sequence is install-first pilot: establish prerequisites, install OpenClaw, complete onboarding, validate one minimal `SOUL.md` and one or two pilot skills, and only then expand into the Glee-fully conversion program. The proposed thread structure is Phase 1 for prerequisites and installation, Phase 2 for OpenClaw configuration, and tertiary threads for domain-by-domain skill conversion.

The capture then contains a large `Capture & Route Prompt` and its apparent execution result. The prompt defines a Brain hub, an intake page, Chat Threads, Extracts, Domains, Projects, GitHub reconciliation, and a Notion-to-GitHub routing hub. It requires an origin boundary gate, exhaustive nugget extraction, domain routing, source- and extract-level deduplication, two-layer writes, a backlink, and an archive contract. Its archive rule requires at least 70 percent value extraction plus a title, origin, one-line summary, and a real backlink. Retrieval must work across topic or domain, date, origin, and canonical destination link. The apparent execution result classifies the material as personal AI architecture work, extracts 29 candidate nuggets, proposes AI Skills as the primary domain, flags Experimentation and Technical Tooling as secondary candidates, reports that deduplication and GitHub reconciliation were not completed, and leaves the source link pending. Those execution claims are preserved as source output, not as verified live Notion or GitHub operations.

The final portion contains two generations of embedded artifacts. An earlier draft provides Larry and Glee-fully `SOUL.md` files, a router, technical and creative pilot skills, an architecture diagram, and a short build backlog. A later package expands the two souls, defines tone registers and mode toggles, adds hard stops for trust and credentials, specifies a router with domain and confidence/stakes axes, and provides creative, code-build, and writing-and-drafting skills. The package also defines a `[HANDOFF]` structure from Glee-fully to Larry and a ten-prompt comparative test suite as a future quality gate. The source ends with Perplexity-style source-panel labels such as `Web`, `Files`, `Notion`, and `GitHub`, but no actual source cards, URLs, attachments, or connector results are present in the readable payload.

The durable conclusion is a staged, two-plane operating model. The active work plane is the Mac Studio and its trusted Larry instance, with GitHub as the likely canonical home for current writing, configuration, and migration artifacts. The experimental plane is the Asus and its sandboxed Glee-fully instance. The historical knowledge plane is a local or repository-based context archive, with Notion as a possible searchable index or extract destination after schema inspection. The design is viable as a proposal. Its next proof point is a small Mac Studio installation and pilot, not a full persona migration or an unverified Notion write.

## Turn ledger

| Turn | Role | Role confidence | Boundary evidence | Content elements | Summary |
|---|---|---|---|---|---|
| T001 | user | medium | Profile-avatar marker followed by a first-person question about the Mac Studio and Asus | E001 | Asks whether the Mac Studio should be the primary local-AI host and whether the Asus can run a secondary OpenClaw helper. |
| T002 | assistant | medium | `Completed 3 steps`, executive summary, option table, recommendation, risks, and next actions | E001, E008 | Recommends an isolated Asus helper, favors Windows Hub or WSL2 over a full-trust setup, and reserves heavy inference for the Mac Studio. |
| T003 | user | medium | First-person concept statement followed by `3 attachments` | E001, E005 | Proposes Larry on the Mac Studio, Glee-fully on the Asus, `SOUL.md` for identity and voice, `SKILL.md` for former Custom GPT capabilities, and a router skill. |
| T004 | assistant | medium | Structured answer with executive summary, options, recommendation, risks, next actions, and a four-line mental model | E001 | Confirms viability as a layered architecture and identifies prompt entanglement, router overreach, migration sprawl, persona bleed, and trust confusion as risks. |
| T005 | user | medium | Explicit request to fully vet viability in June 2026 and plan prerequisites, installation, configuration, and tertiary conversion threads | E001 | Requests a Phase 1 installation plan, a Phase 2 configuration thread, and later domain-specific conversion work. |
| T006 | assistant | medium | `Completed 2 steps`, current-state framing, option comparison, recommendation, and risk list | E001 | Recommends install-first piloting with a dual-instance target and warns that skill governance may be proposal-first rather than unconstrained live mutation. |
| T007 | user | medium | Explicit `# Capture & Route Prompt` heading and a seven-step operational contract | E016 | Supplies a reusable capture protocol for origin gating, exhaustive nugget extraction, routing, deduplication, Notion/GitHub reconciliation, backlinks, and archiving. |
| T008 | assistant | medium | `Completed 20 steps` followed by named steps, tables, and a green-light request | E016, E017 | Reports a 29-nugget extraction, candidate domains, incomplete dedupe and GitHub checks, pending source backlink, and a proposed Notion write. These live-system claims are not independently verified. |
| T009 | unknown embedded artifact block | low | File headings, `text` markers, and an architecture diagram appear without explicit speaker labels | E009-E014 | Contains an earlier draft package for two souls, a router, technical and creative skills, and a short backlog. Preserved as supplied content with uncertain ownership. |
| T010 | user | medium | Imperative `Complete the full build and write` appears immediately before a new `Completed 20 steps` marker | E015 | Requests completion of the full package after the earlier draft and backlog. |
| T011 | assistant | medium | `Based on your attached files... here is the complete build` followed by titled SOUL and SKILL artifacts | E015-E021 | Supplies expanded Larry and Glee-fully souls, a router, creative, code, and writing skills, an architecture map, and operating constraints. They are design artifacts, not deployment evidence. |
| T012 | unknown UI/source chrome | high | Trailing source-panel labels `Sources`, `Web`, `Files`, `Notion`, and `GitHub` have no attached payload | E008 | Indicates that the originating surface contained sources or file references, but the readable transfer does not contain the underlying cards or files. |

## Content element ledger

| Element | Turn | Type | Owner | Fidelity | Source locator | Destination reference | Catalog action |
|---|---|---|---|---|---|---|---|
| E001 | T001-T006 | file | user | text-extracted | `pasted-text.txt`, supplied attachment | Source synopsis, turn ledger, decisions, and provenance | retain |
| E002 | orphaned | generated_file | user | referenced-not-supplied | Named DOCX sidecar, not present at the supplied local path | Provenance and missing-source limits | flag-missing |
| E003 | orphaned | generated_file | user | referenced-not-supplied | Named PDF sidecar, not present at the supplied local path | Provenance and missing-source limits | flag-missing |
| E004 | orphaned | generated_file | user | referenced-not-supplied | Named Markdown sidecar, not present at the supplied local path | Provenance and missing-source limits | flag-missing |
| E005 | T003 | file references | user | metadata-only | Capture says `3 attachments`, but no payloads are included in the readable text | Normalization exceptions and provenance | flag-missing |
| E006 | orphaned | source_locator | user | metadata-only | Perplexity thread link supplied in the request; exact locator omitted from repository artifact | Provenance and source-boundary note | flag-missing |
| E007 | orphaned | source_locator | user | metadata-only | Notion page titled `Infusing a Soul: Making Local AI Know You`; page body and schema unavailable | Notion report-only routing | flag-missing |
| E008 | T002, T004, T006, T012 | citation/source-panel cluster | unknown | metadata-only | `Sources`, `Web 72`, `Files 14`, `Notion`, and `GitHub` labels without cards or URLs | Limits and citation status | flag-missing |
| E009 | T009 | generated_file content | unknown | text-extracted | Earlier Larry `SOUL.md` draft embedded in the paste | Reusable assets, seed package inventory | retain |
| E010 | T009 | generated_file content | unknown | text-extracted | Earlier Glee-fully `SOUL.md` draft embedded in the paste | Reusable assets, seed package inventory | retain |
| E011 | T009 | generated_file content | unknown | text-extracted | Earlier router `SKILL.md` draft embedded in the paste | Reusable assets, router contract | retain |
| E012 | T009 | generated_file content | unknown | text-extracted | Earlier technical execution pilot skill embedded in the paste | Reusable assets, pilot inventory | retain |
| E013 | T009 | generated_file content | unknown | text-extracted | Earlier creative work pilot skill embedded in the paste | Reusable assets, pilot inventory | retain |
| E014 | T009 | diagram | unknown | text-extracted | ASCII architecture diagram showing user input, router, two instances, skills, and sandbox label | Reusable methods and assets | retain |
| E015 | T011 | generated_file content | assistant | text-extracted | Expanded Larry `SOUL.md` artifact | Reusable assets, seed package inventory | retain |
| E016 | T007-T008 | prompt and execution result | user / assistant | text-extracted | `Capture & Route Prompt`, its targets, seven steps, nugget table, routing notes, and archive gate | Reusable methods, Notion report-only plan, decisions | retain |
| E017 | T008 | extract table | assistant | text-extracted | 29 candidate nuggets and proposed Chat Threads / Extracts rows | Value inventory and open verification gaps | retain |
| E018 | T011 | generated_file content | assistant | text-extracted | Expanded Glee-fully `SOUL.md` artifact | Reusable assets, seed package inventory | retain |
| E019 | T011 | generated_file content | assistant | text-extracted | Expanded `ROUTER.SKILL.md` artifact | Reusable assets, router contract | retain |
| E020 | T011 | generated_file content | assistant | text-extracted | `SKILL.creative-and-persona.md` artifact | Reusable assets, pilot inventory | retain |
| E021 | T011 | generated_file content | assistant | text-extracted | `SKILL.code-build.md` and `SKILL.writing-and-drafting.md` artifacts | Reusable assets, pilot inventory | retain |
| E022 | T011 | diagram | assistant | text-extracted | System map showing Larry, Glee-fully, router, skills, and handoff | Reusable methods and assets | retain |

## Normalization exceptions

1. **The paste is flattened.** It has profile-avatar text, `Completed N steps` markers, headings, `text` labels, and source-panel labels, but not a complete explicit user/assistant transcript. Roles are assigned from boundary evidence, not writing style alone.
2. **Embedded artifact ownership is uncertain in the earlier package.** The block containing the first SOUL and skill drafts is retained as an unknown-owned embedded artifact group. The later full-build block has stronger assistant boundary evidence.
3. **The source page and sidecars are not interchangeable with the pasted text.** The Perplexity locator, Notion page, and three named local files are provenance or referenced elements, not additional evidence available for semantic interpretation.
4. **Citations are not verified.** The source-panel counts and labels do not supply actual URLs or source cards. Assistant claims about OpenClaw, WSL2, ASUS guidance, Skill Workshop governance, shared links, permissions, or platform behavior remain source assertions that need current primary-source verification.
5. **The phrase `as of June 2026` is subject time context, not capture metadata.** The exact conversation date, export time, and version of OpenClaw are unknown.
6. **The 29 nuggets are a source-produced extraction, not a completed live database write.** The same block explicitly says that deduplication and GitHub reconciliation were not completed and that a source link remained pending.
7. **The source's `AI Skills` and `Experimentation/Meta-R&D` routing candidates are not a resolved Notion destination.** They are preserved as source output pending connector-backed schema inspection.
8. **The phrase `local training data` is ambiguous.** It may mean retrieval files, prompt-time context, a local index, or fine-tuning material. The capture does not settle the distinction.
9. **The source contains concrete persona and skill drafts but no runtime evidence.** A file-shaped block is not proof that the file exists on the Mac Studio, Asus, or in this repository.
10. **Interface chrome is excluded from semantic conclusions.** `Profile avatar`, `Completed N steps`, `text`, `Sources`, `Web`, `Files`, `Notion`, and `GitHub` are retained only where they establish boundaries or provenance.

## Value inventory

| Area | Extracted value | Claim class | Source support |
|---|---|---|---|
| Purpose | Build a practical local-AI and OpenClaw operating model with a trusted Mac Studio primary, a sandboxed Asus helper, and reusable persona/skill assets | stated | T001-T006 |
| Context and constraints | Mac Studio is treated as the stronger local-AI host; Asus is Windows-based or assumed so; the user wants to preserve and repackage Glee-fully materials; current installation status is not shown | stated / unknown | T001, T003, T005 |
| Reasoning and alternatives | Separate identity, routing, capability, and trust location because a monolithic prompt entangles voice, dispatch, and execution | inferred synthesis from stated recommendations | T003-T006, T011 |
| Reasoning and alternatives | Prefer WSL2 or a separate account for the Asus helper, with a VM or remote host as stronger-isolation alternatives | proposal | T002 |
| Decisions and outcomes | Treat Larry on the Mac Studio as primary and Glee-fully on the Asus as sandboxed helper | proposal adopted as leading architecture in the source | T003-T006, T011 |
| Decisions and outcomes | Use an install-first pilot, then configuration, then branch-first skill conversion | proposal | T005-T006 |
| Reusable assets | Four-part identity/routing/skill/instance mental model | stated framework | T004, T011 |
| Reusable assets | SOUL minimum structure: identity, voice, tone calibration, prohibited behaviors, and mode toggles | proposal | T004, T009 |
| Reusable assets | Router contract with domain classification, confidence and stakes, fallback, one-question ambiguity handling, and no execution | proposal | T009, T011 |
| Reusable assets | Cross-instance handoff format: `[HANDOFF] [task summary] [result] [open questions]` | stated design | T009, T011 |
| Reusable assets | Pilot package: creative/persona, code-build, and writing-and-drafting skills, with planning, research, operations, and meta skills still queued | stated package inventory | T009-T011 |
| Reusable assets | Comparative test suite using the same ten prompts for Larry and Glee-fully, measuring persona consistency, routing accuracy, and failure modes | proposal | T004, T009 |
| Reusable assets | Capture & Route Prompt with origin gate, nugget extraction, routing, dedupe, two-layer writes, backlink, and archive contract | stated embedded prompt | T007 |
| Reusable assets | Archive eligibility threshold of at least 70 percent value plus title, origin, summary, backlink, and four retrieval axes | stated embedded rule | T007-T008 |
| Risks and limits | Persona bleed, router overreach, migration sprawl, sandbox trust confusion, source drift, missing file access, unverified citations, and Notion dedupe or schema gaps | stated risks / unresolved | T002, T004, T006, T008 |

## Decisions and rationale

### Leading decisions

1. **Adopt a dual-instance target state.** Larry belongs on the Mac Studio as the high-trust primary. Glee-fully belongs on the Asus as an experimental and helper persona. The rationale is isolation, safer experimentation, and a visible trust boundary.
2. **Keep identity, routing, capability, and instance trust separate.** `SOUL.md` carries persona and voice. `ROUTER.SKILL.md` classifies intent. Task skills carry procedures. The instance determines the permission boundary. This is the source's central maintainability decision.
3. **Keep the router narrow and boring.** The router may classify, select, pass context, and exit. It should not add voice, execute the task, rewrite the request, or make the persona more intelligent by stealth.
4. **Start with a pilot instead of a full-suite migration.** Install OpenClaw, validate a minimal soul and one or two skills, then expand. This limits migration sprawl and exposes platform realities before the source corpus is converted at scale.
5. **Migrate branch-level capabilities before twig-level specializations.** The source recommends grouping former Custom GPTs by durable capability first, then splitting only when repeated use justifies the extra files.
6. **Preserve the Mac/Asus trust split.** The Asus should not receive primary credentials or whole-filesystem access. Any cross-instance action with production consequence requires handoff and operator confirmation.
7. **Use the active work plane and archive plane deliberately.** The source's capture protocol treats GitHub as the likely active source of truth for current writing and system artifacts, while Notion and local Markdown serve indexing, extracts, and historical context. This is a design direction, not a verified repository policy for every future artifact.
8. **Use a two-layer capture model.** One thread-level record preserves source identity and summary. Extract-level records preserve reusable decisions, frameworks, prompts, checklists, and findings. This is intended to keep a searchable archive from becoming a Markdown graveyard.

### Rejected or deprioritized alternatives

- **One giant persona prompt:** rejected because prompt entanglement would make voice, routing, and execution hard to debug and tune.
- **Single-instance persona multiplexing:** deprioritized because switching Larry and Glee-fully inside one instance increases persona bleed and routing confusion.
- **Full-trust Asus helper:** rejected because it would erase the security value of the sandbox and widen the blast radius of an agent with file and tool access.
- **Heavy local inference on the Asus as the default:** deprioritized because the source expects Mac Studio hardware to be the better inference host and the Asus to handle lighter orchestration or experimentation.
- **Full Glee-fully conversion before installation:** rejected because the design could overfit to assumptions about OpenClaw before a working pilot is observed.
- **1:1 conversion of every historical Custom GPT:** deprioritized in favor of branch-level capability grouping and later twig specialization.
- **Blind or immediate Notion write:** not authorized by this repository task and not supported by a fetched schema. The source's own capture result left dedupe, exact destination, and GitHub reconciliation incomplete.

### Not settled by the source

The capture does not establish how OpenClaw injects or scopes `SOUL.md` relative to skills, the exact skill directory layout for the target version, the Mac Studio or Asus hardware specifications, the operating-system account and network design, the credentials boundary, the cross-instance transport, the authoritative repository for the generated package, or the acceptance criteria for a successful installation. It also does not establish a Notion database schema, idempotency key, source retention policy, legal or platform-policy position, or whether "local training data" means retrieval material or model fine-tuning data.

## Actionable handoff

- **Current state:** The source contains a coherent architecture proposal and substantial text-derived seed artifacts. It does not prove installation, deployment, live Notion writes, GitHub reconciliation, or successful runtime behavior.
- **Resume point:** Build and verify a small Mac Studio pilot first. The first useful deliverable is a prerequisite and installation checklist tied to the actual Mac Studio OS, hardware, OpenClaw version, and chosen install path.
- **Required context:** Restore or reattach the three missing sidecars if their contents matter; verify current first-party OpenClaw documentation; define trust, network, credential, and source-of-truth boundaries; then run the pilot before broad conversion.

| Action | Owner | Status | Dependencies | Evidence or acceptance condition |
|---|---|---|---|---|
| Restore or reattach the named DOCX, PDF, and Markdown files | user | blocked | Files must be present or attached in a readable workspace path | Each file is cataloged and compared against the text capture; no cross-file completeness claim remains unsupported |
| Inventory Mac Studio and Asus hardware, OS versions, accounts, and available storage | user / agent | ready | Access to both machines; no secrets required in the repository | A written deployment matrix identifies inference, orchestration, and sandbox roles |
| Verify current OpenClaw installation and skill guidance from first-party sources | user / agent | ready | Internet or operator-provided documentation; exact version captured | The install plan names a verified version and does not rely on the source's unverified June 2026 assertions |
| Define the Asus trust boundary | user | ready | Decision on separate account, WSL2, VM, or remote host | Allowed folders, credentials, network exposure, and prohibited actions are explicit |
| Install and onboard the Mac Studio pilot | user / authorized operator | proposed | Hardware and version prerequisites; explicit authorization on the target machine | Gateway, workspace loading, and one safe test task work on the Mac Studio |
| Create the minimum Larry `SOUL.md` | user / agent | proposed | Confirmed workspace location and voice decisions | The file loads, stays within its content role, and does not claim unverified permissions |
| Create one router and two or three pilot skills | user / agent | proposed | Confirmed skill format and pilot domains | The router selects the intended skill on a small labeled prompt set without executing the task itself |
| Define handoff and authority rules between Larry and Glee-fully | user / agent | proposed | Cross-instance communication method and trust model | A sandbox result is labeled, structured, and requires Larry/operator ratification before production consequence |
| Run the same ten prompts against the pilot package | reviewer | proposed | Both instances or a simulation of both personas; expected outputs | Persona consistency, routing accuracy, and failure modes are recorded per prompt |
| Inventory former Custom GPTs and map them to branch-level skills | user / agent | proposed | Access to the source corpus and current naming taxonomy | Each candidate is classified as migrate, merge, defer, or retire with rationale |
| Define the GitHub source-of-truth and archive boundary | user | ready | Repository and branch policy | Current writing and deployable artifacts have one canonical location; historical context is labeled as archive/reference |
| Resolve the Notion destination and schema before any write | user / authorized connector | blocked | Connector, page/database fetch, schema, visibility, and dedupe key | A dry-run property map and duplicate check precede a smallest-safe write |
| Pilot the Capture & Route protocol on a bounded batch | user / agent | proposed | Source access, privacy decision, extract schema, and Notion/GitHub routing | Each source has a boundary, each nugget has a disposition, re-running the batch is idempotent, and archive eligibility is explicit |

## Reusable methods and assets

### Layered architecture contract

| Layer | Question | Durable responsibility | Guardrail |
|---|---|---|---|
| `SOUL.md` | Who am I? | Identity, voice, tone calibration, prohibited behavior, and persona modes | Does not become a task manual or router |
| `ROUTER.SKILL.md` | What kind of request is this? | Intent domain, confidence/stakes, skill selection, fallback, and escalation | Classifies and exits; it does not execute or editorialize |
| Task `SKILL.md` | How do I do this job well? | Domain procedures, output format, quality rules, and escalation triggers | Stays task-specific and respects the active soul |
| Instance assignment | Where should this happen? | Trust, permissions, credentials, network, and handoff target | Sandboxed work cannot silently become production work |

### Minimum soul structure

The source proposes five minimum sections for a first pilot: identity, voice, tone calibration, prohibited behaviors, and persona-mode toggles. The expanded artifacts add instance identity, trust level, credential scope, handoff target, and escalation path. These are design inputs, not a verified OpenClaw requirement.

### Router contract

1. Receive the raw operator input.
2. Classify the task domain.
3. Classify confidence and stakes.
4. Route automatically when confidence is sufficient.
5. Ask one clarifying question when the request is low-confidence and high-stakes.
6. Pass the full context to the selected skill without rewriting it.
7. Let the skill execute.
8. Append a stakes flag after high-stakes output when needed.

The source's expanded router domains are systems, code, writing, research, creative work, operations, chat, and meta. Its proposed instance routing sends production and high-trust operations to Larry, creative exploration to Glee-fully, and ambiguous cases to Larry by default.

### Seed package inventory

| Asset | Intended role | Distinctive rules preserved | State in this extract |
|---|---|---|---|
| Larry `SOUL.md` | Mac Studio primary identity | Direct, dry, precise, no hollow affirmations, explicit uncertainty, no credential exposure, no silent failure | Text-derived design seed; runtime loading unverified |
| Glee-fully `SOUL.md` | Asus sandbox identity | Warm, vernacular, experimental, scoped, transparent, no production commits, neutral handoff mode | Text-derived design seed; runtime loading unverified |
| Router skill | Shared dispatch | Domain plus confidence/stakes; one question for ambiguity; no execution; Larry default for ambiguous high-trust cases | Text-derived design seed; runtime loading unverified |
| Creative/persona skill | Glee-fully-preferred capability | Establish audience, tone, and constraint; generate distinct options; recommend one; use overlays deliberately | Text-derived pilot seed |
| Code-build skill | Larry-preferred capability | Establish runtime and contract; correct over clever; explicit errors; tests; no production sandbox deployment | Text-derived pilot seed |
| Writing-and-drafting skill | Shared writing capability | Establish purpose, audience, register, constraint; preserve distinctive voice; flag structural issues separately | Text-derived pilot seed |
| System map and ASCII diagrams | Architecture communication | User input to router to instance to skill; sandbox output labeled and handed off | Text-derived diagrams |

### Handoff protocol

The source proposes this compact cross-instance structure:

```text
[HANDOFF]
[task summary]
[result]
[open questions]
```

Glee-fully should use a neutral handoff mode, label experimental output, and defer production or high-trust execution to Larry. Operator confirmation remains required before irreversible actions, external side effects, or writes outside designated workspaces.

### Capture and archive protocol

The embedded Capture & Route Prompt is reusable as a separate operational asset. Its seven steps are:

1. Load the Brain hub and run the origin boundary gate.
2. Extract a thread summary and exhaustive, one-idea-per-row nuggets.
3. Route through a live Domains table.
4. Search both thread-level and extract-level records for duplicates.
5. Write a thread row and extract rows with relations and next actions.
6. Reconcile against the canonical GitHub repository and preserve a backlink.
7. Archive only when value recovery and retrieval criteria are met.

The archive rule is source-derived. It requires at least 70 percent value extracted, a title, origin, one-line summary, and at least one real backlink. Retrieval must work through topic or domain, date, origin, and canonical destination link. The threshold is an operating target, not a measured result.

### Risk and control checklist

| Risk | Control to test |
|---|---|
| Persona bleed between Larry and Glee-fully | Separate instances or strong mode boundaries; compare identical prompts |
| Router overreach | Keep classification, selection, and handoff separate from execution |
| Migration sprawl and drift | Branch-level migration first; version and review each skill |
| Asus blast radius | Separate account or WSL2/VM boundary, narrow folders, minimal credentials, no public exposure |
| Platform and documentation drift | Capture exact versions and verify first-party guidance before installation |
| Unverified skill governance assumptions | Test proposal/apply workflow on a disposable pilot |
| Missing or flattened rich content | Keep an element ledger and preserve a missing state for files, diagrams, citations, and artifacts |
| Notion archive becomes a graveyard | Use thread and extract indexes, stable titles, domains, projects, statuses, relations, and dedupe |
| Cross-machine filesystem failure | Use a known shared path or repository handoff plus a preflight access test |
| Silent archive staleness | Mark historical versus active authority and record source dates when known |

## Open questions and limits

1. **Missing sidecars:** What do the named DOCX, PDF, and Markdown files contain, and do they change the architecture or the attached seed artifacts?
2. **Source completeness:** Is the readable `pasted-text.txt` a full Perplexity copy, an export excerpt, or a manually flattened selection? The visible payload is partial for operational purposes.
3. **Source-page access:** What is the exact content of the Perplexity thread and the Notion page? The supplied web locators could not be opened here, and no page body was supplied.
4. **Current OpenClaw behavior:** Which official version and documentation should govern `SOUL.md`, workspace-scoped skills, Skill Workshop, gateway setup, and Windows/WSL2 support?
5. **Hardware reality:** What are the Mac Studio model, unified memory, storage, OS, and model-serving constraints? What are the Asus CPU, RAM, GPU, Windows version, and WSL2/VM support?
6. **Installation order:** Should the Mac Studio be installed and validated completely before any Asus work, or should the Asus sandbox be prepared in parallel after the Mac pilot is stable?
7. **Credential boundary:** Which services, tokens, folders, and external endpoints may Larry access? Which may Glee-fully access? Which actions must always require operator confirmation?
8. **Cross-instance transport:** How will a sandbox result reach Larry without granting the Asus primary credentials or write authority?
9. **Soul inheritance:** How does the runtime apply `SOUL.md` constraints to a selected skill? Is it injected automatically, loaded from a fixed workspace, or enforced by authoring convention?
10. **Skill layout and governance:** What is the exact directory and frontmatter contract in the chosen OpenClaw version, and what changes require proposal, review, or apply steps?
11. **Migration taxonomy:** Which former Custom GPTs are durable capabilities, which are persona overlays, which are one-off prompts, and which should be retired rather than converted?
12. **Test acceptance:** What counts as passing for routing accuracy, persona consistency, safe refusal, handoff quality, and sandbox isolation across the ten-prompt comparison?
13. **GitHub authority:** Which repository and branch are canonical for souls, skills, tests, and generated context? How are historical extracts distinguished from active source files?
14. **Notion destination:** Is the supplied page a container, a full export, an index, or a landing page? What database/data-source schema, relation targets, and status values exist?
15. **Dedupe:** What stable key identifies the same Perplexity thread, export revision, or reusable extract across repeated captures?
16. **Source retention:** Should raw exports stay in an owner-controlled private archive, be hashed, be kept outside GitHub, or be deleted after extraction verification?
17. **Local training meaning:** Does the user want retrieval files, prompt-time context, a local vector index, supervised fine-tuning material, or another form of local learning?
18. **Policy and terms:** Before scaling source capture or automation, what current first-party rules govern access, export, archiving, and automated use?
19. **Runtime status:** The source's embedded file blocks are not evidence that OpenClaw was installed or that any persona or skill loaded successfully.
20. **Notion and GitHub claims:** The source's 29-nugget result and route status are not evidence of completed live writes or repository reconciliation.

## Rehydration test

| Test | Result | Evidence or gap |
|---|---|---|
| A reader can explain the objective without the source platform | pass | The introduction and source synopsis state the machines, personas, layers, rollout, and archive purpose. |
| Decisions and consequential rationale are recoverable | pass | Leading decisions, rejected alternatives, risks, and their rationale are separated above. |
| Current state and next action are unambiguous | pass | The handoff says this is a design proposal without runtime proof and identifies a Mac Studio prerequisite and installation pilot as the resume point. |
| Retained assets are available or missing assets are explicitly cataloged | pass | Embedded artifacts and prompts are summarized as text-derived assets; named sidecars, citations, and external page bodies are ledgered as missing or unavailable. |
| No source account, thread, project, canvas, or connector is a runtime dependency | pass | The architecture and resume plan are understandable without reopening Perplexity or Notion; external verification remains a separately named dependency. |

- **Overall source-independence result:** pass
- **Blocked capability, if any:** Cross-file comparison, source-page inspection, citation verification, current platform validation, Notion schema resolution, live deduplication, GitHub reconciliation, and runtime deployment testing cannot be completed from the supplied readable payload alone.

## Provenance and retention

- **Source platform:** Perplexity, based on the user-supplied Perplexity locator and Perplexity-style source-panel labels in the pasted capture
- **Capture method:** `full-paste`, based on a flattened text transfer with visible UI markers and embedded prompt/output material
- **Capture boundary:** One readable attachment named `pasted-text.txt`; three named local sidecars were referenced but missing; a Perplexity thread locator and a Notion page locator were supplied as provenance markers but their page bodies were not available
- **Completeness:** partial
- **Source title:** `I've been working to set up local AI on my new Mac Studio`
- **Source time context:** unknown; the text discusses a viability check framed as June 2026, but exact conversation and export times are not supplied
- **Project context:** Glee-fully Personalizable Tools, Larry the Lobster, OpenClaw, GitHub, and Notion are named in the supplied material; private page structure and connector context are not supplied
- **Artifact status:** multiple file-shaped SOUL and SKILL drafts are embedded as text; no independently supplied file payload or runtime deployment proof is available
- **Citation and tool-output status:** source-panel counts and labels are present, but actual citation URLs, source cards, connector responses, and tool traces are not supplied; copied assistant claims remain source content and need verification
- **Retention decision:** redacted
- **Redaction and privacy notes:** The raw transcript is not reproduced. Exact private Notion and Perplexity locators are omitted from this repository artifact. Local machine paths, account-specific page identifiers, and any unavailable source payloads are not copied. No credentials or secrets were detected in the readable text.
- **Source caveats:** speaker boundaries are partly inferred; embedded artifact ownership is uncertain in one block; the named sidecars are unavailable; current platform claims, source counts, Notion/GitHub status, and runtime behavior are not independently verified.

## Notion capture routing

- **Mode:** `report_only`
- **Resolved destination type:** unresolved page or database; the user supplied a Notion page title and locator, but no connector-backed fetch or schema inspection is available
- **Safe to write:** No. No write was attempted.
- **Destination candidate:** `Infusing a Soul: Making Local AI Know You`, retained as a title only; exact private URL and page identifiers are omitted
- **Source-level status:** unverified, with no duplicate search completed
- **Primary domain candidate:** AI Skills, based on the source's own routing output; not connector-resolved
- **Secondary candidates:** Experimentation/Meta-R&D and Technical & Tooling Ecosystem, also source-derived and unverified
- **Extract plan:** 16 reusable assets are identified above, including the layered architecture, router contract, trust model, pilot package, handoff protocol, capture prompt, archive rule, and risk controls
- **Write log:** Created 0; updated 0; skipped 0; redacted private locators and unavailable payloads; pending destination fetch, schema mapping, source/extract dedupe, GitHub reconciliation, and post-write verification
- **Required future sequence:** fetch the target page or data source, inspect existing content and schema, search for thread- and extract-level duplicates, prepare a property map, write the smallest safe page/row set, and fetch again to verify
