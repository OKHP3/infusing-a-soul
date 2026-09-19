# Technology inventory and update policy

Reviewed: 2026-09-18 America/Chicago (2026-09-19 UTC). Repository baseline: `f9b1f2d13bd370586676677b935e1dcf9788370e`.

## Question and scope

Which technologies does this solution actually use, which versions are recorded, what stable releases are available, and how will updates reach the solution?

This is a persona/documentation repository with executable maintenance and contributor utilities. It has no root application package or frontend build. The audit covers tracked source, local tool versions, documented external services, and official upstream release channels. It does not claim a complete transitive software bill of materials for opaque external installations.

The previous July inventory incorrectly described JavaScript, Node, Docker, manifests, and tests as absent. The current checkout contains seven private skill package manifests, 17 `.mjs` files, two `.cjs` files, 23 Python files, a PowerShell readiness checker, skill tests, and an Actions workflow. All seven packages are version `0.1.0`, expose Node test commands, and declare no third-party dependencies. Python utilities use the standard library. These counts describe the baseline before this change added audit tests.

## Version inventory

**Confirmed** means a repository file, local command, or official source was read during this audit. Historical deployment records establish what was recorded on that date, not what runs now. **Unknown** means no current version was obtained. Local tool observations describe this Windows machine, not the Mac or the gateway's internal environment.

### Executable tools and automation

| Technology | In-place version / configuration | Latest stable retrieved | Source |
| --- | --- | --- | --- |
| Python | Local launcher selects `3.14.0rc1`; workflow selects stable `3.14` | `3.14.7` | [Python downloads](https://www.python.org/downloads/) |
| JavaScript / Node.js | Local Node `24.11.1`; skill utilities have no engine pin | Current `26.9.0`; LTS `24.21.0` | [Node release index](https://nodejs.org/dist/index.json) |
| npm | Local `11.6.2`; no repository dependencies or lockfiles | `12.0.2` | [npm published latest](https://registry.npmjs.org/npm/latest) |
| PowerShell | Local `7.6.5`; readiness script has no runtime pin | `7.6.6` | [PowerShell releases](https://github.com/PowerShell/PowerShell/releases/latest) |
| Git for Windows | Local `2.55.0.windows.5` | `2.55.0.windows.5` | [Git for Windows releases](https://github.com/git-for-windows/git/releases/latest) |
| GitHub CLI | Local `2.96.0`; old audit used the runner's bundled CLI | `2.101.0` | [GitHub CLI releases](https://github.com/cli/cli/releases/latest) |
| actions/checkout | Existing `v6`; this change pins `7.0.1` by commit | `7.0.1` | [checkout releases](https://github.com/actions/checkout/releases/latest) |
| actions/setup-python | Existing `v6`; this change pins `7.0.0` by commit | `7.0.0` | [setup-python releases](https://github.com/actions/setup-python/releases/latest) |
| actions/upload-artifact | Existing floating `v7`; this change pins `7.0.1` by commit | `7.0.1` | [upload-artifact releases](https://github.com/actions/upload-artifact/releases/latest) |
| GitHub / Actions / Bash runner tools | Hosted service, `ubuntu-latest`; exact runner image varies by run | Managed service, no single application version | [Runner images](https://github.com/actions/runner-images) |

The local Python prerelease should be replaced with a stable installation during host maintenance. The workflow selects stable patches independently and records its actual Python version in the run log. The new checker uses GitHub's API directly, so it no longer depends on the runner's GitHub CLI.

Node LTS is the proposed contributor-tool maintenance channel. OpenClaw has its own compatibility requirements: the retrieved install guide specifies Node `24.16+` or `26.1+`, recommending 26. The locally observed `24.11.1` falls below that current requirement, but the gateway's own Node version remains unknown. Validate the correct environment before upgrading. [OpenClaw installation requirements](https://docs.openclaw.ai/install)

### Persona runtimes, services, and hosts

| Technology | In-place version / evidence | Latest stable retrieved | Source |
| --- | --- | --- | --- |
| OpenClaw gateway | `2026.6.1` in the August 2 WSL record; replacement installation unknown | `2026.9.5` | [OpenClaw release](https://github.com/openclaw/openclaw/releases/tag/v2026.9.5) |
| OpenClaw Windows Hub / Companion | Installed per September runbook; version unknown | `2026.9.4` | [Windows Hub releases](https://github.com/openclaw/openclaw-windows-node/releases/latest) |
| LM Studio | Mac service documented; app version unknown | `0.4.24` | [LM Studio download](https://lmstudio.ai/download) |
| Ollama | Homebrew-managed Mac service; version unknown | `0.34.2` | [Ollama releases](https://github.com/ollama/ollama/releases/latest) |
| Qdrant | Docker-hosted Mac service; version unknown | `1.19.1` | [Qdrant releases](https://github.com/qdrant/qdrant/releases/latest) |
| Open WebUI | Image `0.11.0` recorded September 12; not reverified live | `0.11.3` | [Open WebUI releases](https://github.com/open-webui/open-webui/releases/latest) |
| SearXNG | Container documented; image digest and source revision unknown | Rolling, no stable GitHub release; docs identify `2026.9.18+c0042add3` | [Container guidance](https://docs.searxng.org/admin/installation-docker.html), [release channel](https://github.com/searxng/searxng/releases) |
| Docker Engine / CLI | Local CLI `29.6.1`; Mac engine unknown | `29.8.1` | [Docker Engine release](https://github.com/moby/moby/releases/latest) |
| Docker Desktop | Local executable `4.81.0`, build `232925`; Mac version unknown | `4.91.0` | [Docker Desktop notes](https://docs.docker.com/desktop/release-notes/) |
| Homebrew | Mac package manager recorded; version unknown | `7.0.4` | [Homebrew releases](https://github.com/Homebrew/brew/releases/latest) |
| WSL | Local `2.7.14.0`; gateway distribution version unknown | `2.7.14` | [Microsoft WSL releases](https://github.com/microsoft/WSL/releases/latest) |
| Ubuntu | Named in old deployment and Companion WSL records; version unknown | `26.04.1 LTS` | [Ubuntu releases](https://releases.ubuntu.com/) |
| Windows 11 | Local `25H2`, build `26200.9457` | Same build for 25H2; separate 26H1 channel `28000.2956` | [Microsoft release information](https://learn.microsoft.com/en-us/windows/release-health/windows11-release-information) |
| macOS | Mac Studio documented; OS version unknown | `27.0 Golden Gate`; hardware eligibility must be checked | [Apple version table](https://support.apple.com/en-us/109033) |
| Discord API | Channel documented; integration's selected API version unknown | API `10` available | [Discord API versioning](https://docs.discord.com/developers/reference) |
| ClickClack / terminal UI | Named in Larry's TOOLS file; exact product identity and version unknown | Unknown until product is identified | [Repository evidence](../souls/larry-the-lobster/workspace/TOOLS.md) |

OpenClaw's web release redirect initially showed `2026.9.4`; a fresh official API response and direct release page confirmed `2026.9.5`. The latest stable column uses that newer evidence. Windows versions are servicing channels, not a universal instruction to install the numerically largest release.

Read-only version requests to the documented Mac Qdrant, Ollama, and Open WebUI endpoints failed from this session. No running version is inferred from their historical records. No services, images, operating systems, or model files were changed.

### Formats, models, and references

| Technology / artifact | Use and version boundary | Latest specification or maintenance method |
| --- | --- | --- |
| Markdown / GitHub Flavored Markdown | Corpus and persona files; no renderer pin | [CommonMark `0.31.2`](https://spec.commonmark.org/) is a reference, not a verified renderer setting |
| YAML | Workflow, skill metadata, and fixtures; no edition pin | [YAML `1.2.2`](https://yaml.org/spec/1.2.2/); consumers have their own subsets |
| JSON | Schemas, fixtures, catalogs, and audit data | [RFC 8259](https://www.rfc-editor.org/info/rfc8259/) |
| ECMAScript | `.mjs` / `.cjs` contributor utilities; no target edition pin | [ECMA-262 edition 17, ECMAScript 2026](https://ecma-international.org/publications-and-standards/standards/ecma-262/); actual execution is governed by Node |
| Local model artifacts | Persona TOOLS names `lmstudio/lfm2-24b-a2b-mlx` and `mistral-small3.1:24b` | Tags do not establish immutable revision, quantization, digest, or newest suitable model; record these on the model host |
| Repository-local skills | Seven private package manifests say `0.1.0`; other skill versions and source provenance live in their metadata | Review against their canonical source; do not reinterpret skill version numbers as runtime dependency pins |

TypeScript, Vite, Tailwind CSS, React, and Next.js occur in skill guidance or examples. They have no executable application, dependency declaration, lockfile, or deployed frontend established here. Mermaid appears in an adversarial extraction fixture and a historical conversation reference; there is no repository-owned renderer or Mermaid package to upgrade. pnpm, Yarn, and related framework instructions are references rather than installed dependencies of this repository. This distinction also applies to schema vocabularies such as DMN and to protocols such as HTTP, WebSocket, and gRPC: they are contracts, not independently installed repository packages.

ChatGPT, Claude, Codex, Notion, Replit, browsers, and editors are authoring or integration surfaces mentioned in the corpus or this request. Their application versions are not persona-runtime dependencies. Replit inspection was attempted and returned `UNAUTHORIZED` with reauthentication required, so no Replit checkout or deployment parity is claimed.

## Source ledger and uncertainty

The links beside each row identify the exact claim source and publisher: Python Software Foundation, Node.js project, npm registry publisher, Microsoft, Docker/Moby, Homebrew, Apple, Canonical, Discord, Ecma, YAML, IETF, CommonMark, GitHub Actions, or the named upstream service project. They were retrieved during this review; official publisher release channels are the authority for available releases, not for installed versions. The machine-readable ledger is [technology-versions.json](technology-versions.json), including retrieval time, baseline commit, recorded-version evidence, release parser, source, and follow-up.

Local evidence: tracked manifests and executable imports under `.agents/skills/` and `skills/`; [workflow](../.github/workflows/check-technology-versions.yml); [readiness checker](../scripts/check-asus-gateway-readiness.ps1); [September runbook](asus-gateway-runbook.md); [August closeout](../context/threads/2026-08-02-asus-gateway-runtime-closeout.md); persona TOOLS files; direct version commands and Windows executable/registry metadata.

| Consequential claim | Tier | Evidence | Consequence if false | Next check |
| --- | --- | --- | --- | --- |
| Contributor utilities use Node/JavaScript and Python | Confirmed | Tracked executable files, imports, seven manifests | Missing maintenance coverage | Re-inventory when files or manifests change |
| Listed upstream versions are available releases | Confirmed at retrieval | Official sources and generated live audit | Wrong upgrade target | Run the checker before maintenance |
| Current Mac and gateway installations match those releases | Unknown | Historical records and failed endpoint probes only | Unsafe upgrade or false completion claim | Collect versions on each owning host |
| Windows gateway has a purely native implementation | Unknown / conflicting records | Runbook describes native Companion plus an internal WSL gateway | Upgrade wrong runtime | Identify actual process, package, and distro before changing it |
| A newer version is compatible with the personas and data | Proposal pending tests | Release availability alone is insufficient | Behavioral regression or data migration failure | Backup, compatibility checks, and service smoke tests |
| Replit copy matches GitHub | Unknown | Connector reauthentication error | Unseen dependency or deployment divergence | Reauthenticate, then inspect the specific Replit project |

## Implemented update mechanism

1. **Every day at 14:23 UTC**, the workflow tests the checker, checks 20 release tracks, produces Markdown and JSON reports, and opens or refreshes one bot-owned tracking issue for new releases or source errors. Eleven other records remain visibly manual. These totals include separate Node Current and LTS tracks.
2. **Dependabot runs weekly** for GitHub Actions. It proposes updates to commit-pinned actions, including major versions, through pull requests. The action commits in this change were resolved from the official stable tags. There is no auto-merge.
3. **Python patch releases update automatically in CI** through `python-version: '3.14'`, `check-latest: true`, and `allow-prereleases: false`. Tests run using the newly resolved stable patch. New Python minor/major series are detected by the audit and require a reviewed workflow change.
4. **New dependency ecosystems require inventory updates.** The existing seven Node packages contain no third-party dependencies, so empty npm Dependabot jobs would provide no updates. Add an npm/pip/Docker ecosystem job when an actual manifest with dependencies, lockfile, or owned Dockerfile is introduced.

The checker distinguishes `NEW_RELEASE`, `UNCHANGED`, `SOURCE_REGRESSION`, `SOURCE_ERROR`, and `MANUAL_CHECK`. It rejects prerelease tags, treats an older upstream response as a source problem, retains partial results, and keeps source failures in the artifacts and job summary. Source failures fail the audit job. New releases create a notice and tracking issue without being treated as a broken source. Repeated identical findings do not rewrite the issue. A clean audit does not auto-close a maintenance issue; close it after documenting the disposition.

`reviewed_version` means the release has been researched. It never means that a host was upgraded. Installed observations remain separate, dated fields. After investigating an alert, update the ledger and this dated inventory together through a reviewed change. Record either a verified upgrade or a reason to defer.

The workflow has read-only repository access and issue-write permission only in its scheduled/default-branch audit job. Pull requests run offline tests only. It does not gain SSH access or deployment credentials. Action updates and the enhanced schedule become active when this change reaches `main`; a successful local run alone does not establish activation.

## Upgrade and verification plan

| Owner / scope | Trigger and procedure | Acceptance and rollback |
| --- | --- | --- |
| Repository maintainer: Actions | Review Dependabot release notes and runner compatibility, run PR checks, merge | Green audit tests; revert the action pin if checks regress |
| Repository maintainer: Python | Stable patches resolve automatically; change both workflow series selectors after a new-series compatibility review | Audit tests and applicable skill Python tests on the candidate; revert selectors if needed |
| Host owner: Node, npm, PowerShell, Git, CLI | Review the daily report; inventory the correct host; use its existing package manager | Run the relevant utility tests and version commands; retain previous installer/runtime |
| Gateway owner: OpenClaw and Companion | Record both installed versions and gateway Node; back up state/config securely; review migration notes; use each product's stable updater | Gateway starts, workspace files load, primary model responds, and owner-authorized channel test passes; restore supported backup/version on failure |
| Mac service owner: LM Studio, Ollama, Qdrant, Open WebUI | Record app/image versions and digests; back up model/config/data metadata and persistent volumes; upgrade one service at a time | Inference responds with the same chosen model, vector data survives, UI works; roll back with migration-compatible backup |
| Mac service owner: SearXNG | Weekly compare actual deployed digest/commit with the official rolling image; review before replacing | Search returns expected results and config survives; retain previous image digest |
| Host owner: Windows, WSL, Ubuntu, macOS, Docker, Homebrew | Monthly native update review plus daily version alerts where available; follow compatible OS channels | Verify service startup after reboot and all persona dependencies; use the host's supported recovery procedure |
| Maintainer: formats, Discord, hosted runners, unidentified UI | Monthly API/runner review, annual format review, and immediate check when parsing/integration fails | Preview documents, validate fixtures, identify the UI package, and retest the affected integration |

Before upgrading external services, collect sanitized output from `openclaw --version`, `node --version`, `ollama --version`, `sw_vers`, `brew --version`, container image tags/digests, and the LM Studio/Companion About panels on their actual hosts. Record observation date and host role. Do not commit configuration secrets, authentication headers, or private conversation/model-response content.

## Validation and operation

Run from the repository root:

```powershell
py -3 -m unittest discover -s tests -v
py -3 scripts/check-technology-versions.py
```

On Linux, use `python` instead of `py -3`. Reports default to `.local/technology-audit/`, which is ignored by Git. Exit `0` means all automated sources match the reviewed baseline, `2` means new releases, and `1` means at least one source failed or regressed. Manual records and unknown installations remain unknown even with exit `0`. The scheduled workflow adds `--update-issue`; normal local runs never write to GitHub.

**Next action:** merge the verified maintenance change to activate its schedule and Dependabot configuration, then collect the missing host versions before approving external upgrades.
