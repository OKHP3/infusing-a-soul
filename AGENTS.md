# infusing-a-soul: Agent Guide

## Project identity

- **Suite**: OverKill Hill P3 / Writings
- **Repository**: `https://github.com/OKHP3/infusing-a-soul`
- **Type**: Documentation corpus, deployable AI persona packages, and a scheduled external-version audit
- **Primary subject**: Designing persistent, distinct local AI identities through corpus design, persona distillation, and workspace procedures
- **External runtime**: OpenClaw agents using the files under each persona's `workspace/` directory
- **Current checkout status**: Documentation is active, but implementation and deployment status varies by persona

The project is not an application package. This checkout contains Markdown guidance, persona configuration, research material, templates, corpus staging directories, local agent skills, Python and Node contributor utilities, a PowerShell readiness checker, and a scheduled technology audit. Seven private skill package manifests expose Node test commands without third-party dependencies. Skill tests and version-audit tests are present; there is no root application entry point or frontend build.

## Mission and vision

- **Confirmed purpose**: Document the architecture and build process for private, persistent local AI personas, and preserve the files used to configure those personas.
- **Inferred mission**: Turn a large human source corpus into a compact, operational identity that can run on local hardware while leaving most of the model context available for conversation.
- **Inferred vision**: A maintained library of distinct, reusable AI souls with separated voice, procedures, tools, references, and skills.
- **Unknown**: The repository does not define a formal product roadmap, release process, owner policy, or production support commitment.

## Scope and boundaries

In scope:

- Persona research, source-corpus organization, distillation methodology, and deployable OpenClaw workspace files.
- Documentation under `docs/`, writing drafts under `article/`, and source-material staging under `corpus/`.
- Persona packages under `souls/` and repository-local skills under `.agents/skills/`.

Out of scope unless explicitly requested:

- OpenClaw gateway configuration, model downloads, service changes, or deployment to another machine.
- Changes to related repositories, Notion pages, Discord, Qdrant, SearXNG, LM Studio, or Ollama.
- Inventing persona facts, source-corpus contents, runtime guarantees, roadmap commitments, or validation results.

## Repository structure

- `README.md`: project overview, persona inventory, method summary, hardware context, and license intent.
- `docs/methodology.md`: three-layer corpus collection, distillation, and deployment model.
- `docs/phase-2-soul-writing.md`: historical Glee-fully Phase 2 design record and word-budget rationale.
- `docs/technology-inventory.md`: dated technology review, evidence boundaries, and upgrade procedure.
- `docs/technology-versions.json`: machine-readable upstream baselines and dated installed-version evidence.
- `docs/story/`: numbered story documents (00 overview through 05 status) plus `project-page-brief.md`, the source for the overkillhill.com project page. Public-facing: keep LAN addresses, tokens, IDs, and Notion URLs out.
- `scripts/night-shift/`: Night Shift overnight-queue helpers (PowerShell) and the gateway-side shell scripts they pipe into the Companion's WSL distro.
- `tests/`: network-free regression tests for the technology audit.
- `article/drafts/`: article or public-writing drafts. Currently empty except for `.gitkeep`.
- `context/threads/`: redacted, standalone extracts from external AI threads. These preserve provenance and resume context but are not current runtime authority.
- `corpus/vernacular/`: tone and voice source material. Currently empty except for `.gitkeep`.
- `corpus/governance/`: governance and operating-model source material. Currently empty except for `.gitkeep`.
- `corpus/templates/`: reusable writing and prompt templates. Currently empty except for `.gitkeep`.
- `souls/_template/`: scaffold for new personas. Its README documents the intended copy-and-fill workflow.
- `souls/glee-fully/`: authored Glee-fully persona package with deployable workspace files. Its references and skills directories are currently placeholders.
- `souls/larry-the-lobster/`: authored Larry persona package with deployable workspace files and a research corpus.
- `souls/askjamie/`: planned persona. Its workspace is not yet authored.
- `.agents/skills/`: active repository-local skills, references, evaluations, and validation helpers.
- `skills/`: selected portable skill promotion mirrors. This is separate from the active `.agents/skills/` surface and requires provenance review before removal or replacement.
- `CLAUDE.md`: short pointer to this root guide.

Each persona's `workspace/` files have a narrower content role:

- `SOUL.md`: identity, voice, personality, tone, and boundaries.
- `AGENTS.md`: persona operating procedures. These are content artifacts and are not replacements for this root guide.
- `TOOLS.md`: connected services, endpoints, and persona-specific safety rules.

Persona-local `workspace/AGENTS.md` files apply only to their own persona directories. The `_template` version is a blank scaffold, not an active persona policy.

## Technology and runtime model

- The repository format is Markdown, JSON, and YAML plus repository-local skill assets and scripts. Python utilities use the standard library; Node skill utilities use built-in modules. See the technology inventory for host and upstream versions.
- The documented runtime is OpenClaw, with workspace files loaded by an agent at startup and full references loaded on demand by skills.
- The documented Glee-fully setup uses OpenClaw on GJS-LAPTOP and services hosted on a Mac Studio over the LAN. The September runbook describes Windows Companion with an internally managed WSL gateway; do not assume a purely native or historical standalone WSL installation without host evidence.
- The documented Larry setup uses OpenClaw natively on a Mac Studio and local service endpoints.
- These runtime details are documentation claims. A read-only PowerShell readiness checker is present, but no OpenClaw configuration or deployment authority is stored here. Neither source presence nor a release audit proves endpoint health.

## Status and known inconsistencies

- **Glee-fully**: As of 2026-09-24 the gateway is online under OpenClaw Windows Companion with a Mac Studio primary model and a laptop fallback, and the Night Shift smoke test passed. The live workspace still runs OpenClaw's default SOUL.md and AGENTS.md, and Discord is not connected. The referenced full source corpus is not present in this checkout, so corpus completeness is not verified here.
- **Larry the Lobster**: Workspace files and research materials are present. The root README calls Larry planned, while the persona README records Phases 1 and 2 as complete. Treat deployment as unresolved until verified outside this repository.
- **AskJamie**: Planned. The README says workspace files have not been written.
- **Phase 3 work**: Persona skill conversion is described as queued or next in the documentation. No persona skill directories contain authored skills in this checkout.
- **Historical claims**: Phase notes describe prior external sessions and deployments. Preserve them as history unless current repository evidence updates them.

## Safe change procedure

1. Read this guide and the nearest persona-local guidance before editing a file.
2. Inspect the current worktree and preserve any existing user changes.
3. Keep persona identity, operating procedures, connected services, and source references in their designated files.
4. Do not add credentials, private endpoint data beyond what is already intentionally documented, or machine-specific secrets.
5. Keep deployable workspace files compact. The template targets about 300 words for `SOUL.md`, numbered procedures for `AGENTS.md`, and one section per connected service in `TOOLS.md`. The combined target is under 1,500 words.
6. Preserve standalone punchy lines in authored writing. Do not consolidate them into paragraphs.
7. Do not use em dashes in generated content. Follow the OverKill Hill P3 brand rule that AutoCAD version references use R10 when relevant.
8. Use lowercase, hyphen-separated names for new persona directories and Markdown artifacts unless an existing convention requires otherwise.
9. Update documentation claims when repository evidence changes. Mark uncertain conclusions as inferred or unknown instead of filling gaps.
10. Do not modify application code, dependencies, generated artifacts, secrets, CI behavior, or related repositories as part of ordinary documentation maintenance.

## Development and validation

There is no application build or deployment command. Run version-audit tests with `py -3 -m unittest discover -s tests -v` on Windows, or `python -m unittest discover -s tests -v` on Linux. Skill-local test commands remain scoped to their packages.

Run `py -3 scripts/check-technology-versions.py` for a read-only upstream audit. Reports go to ignored `.local/technology-audit/`. Exit codes are 0 for unchanged automated baselines, 2 for new releases, and 1 for source failures or regressions. Unknown installed versions and manual tracks remain unknown even when the command succeeds.

The scheduled Actions audit and weekly Dependabot action updates are documented in `docs/technology-inventory.md`. They become active from the default branch. External runtime upgrades require the host-specific compatibility and verification procedure; updating an upstream baseline is not evidence of deployment.

The documented template workflow is:

```bash
cp -r souls/_template souls/your-persona-name
cd souls/your-persona-name
# Edit workspace/SOUL.md, AGENTS.md, and TOOLS.md
```

Use these checks for normal guidance or documentation changes:

```bash
git status --short --branch
git diff --check
rg --files
rg -n "TODO|TBD|planned|queued" README.md docs souls AGENTS.md CLAUDE.md
```

For persona changes, re-read all changed files and check that workspace word budgets, endpoint names, scope boundaries, and status labels agree with the related README and documentation. External runtime behavior must be tested on the target OpenClaw host by the owner or an explicitly authorized operator.

## Related projects and anchors

- Notion anchor: `https://app.notion.com/p/371812e0ced481d0b43cd6698a981709`
- Related repositories: `shoal-ai-server`, `vault-codices-biases-as-constants`, and `mac-studio-local-ai-workbench`
- Brand sites referenced by the README: `overkillhill.com`, `glee-fully.tools`, and `askjamie.bot`

## Keeping this guide current

Update this file when the repository gains a real runtime, manifest, test or build command, new persona package, deployment workflow, or a changed source-of-truth convention. Re-check claims against files and executable evidence. Keep historical decisions in the relevant dated document rather than presenting them as current operating requirements.
