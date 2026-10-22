# Technology inventory and update policy

Reviewed: 2026-10-22 UTC. Repository baseline for this review: `325debf908ca8559aa71c4256a9752b463752d6e`.

## Question and scope

Which technologies does this solution actually use, which versions are recorded, what stable releases are available, and how will updates reach the solution?

This repository contains the Python workbench web app, its locked npm dependency tree, contributor utilities, personas, and documentation. The audit covers tracked source, runtime configuration, recorded host observations, and official upstream release channels. It does not claim a complete bill of materials for opaque external installations.

The older inventory's claim that there was no root app was stale. The root app is a React/Vite Python workbench; browser execution uses Pyodide/WebAssembly, not a server-side Python service. It includes HTML, CSS, SVG and a web manifest, with Alfa Slab One, DM Sans and JetBrains Mono fonts. GA4 is initialized by the app for SPA page views; its measurement ID is deliberately not copied into this inventory.

### Application and Replit runtime

| Item | Current evidence |
| --- | --- |
| App | React 19 + TypeScript 7 + Vite 8 + Tailwind CSS 4; code editor/workbench runs Python in-browser via Pyodide |
| npm production dependencies | `lucide-react` 1.61.0; `react` 19.3.1; `react-dom` 19.3.1 |
| npm development dependencies | `@playwright/test` 1.64.1; `@tailwindcss/vite` 4.3.3; `@types/react` 19.3.0; `@types/react-dom` 19.3.0; `@vitejs/plugin-react` 6.1.2; `tailwindcss` 4.3.3; `typescript` 7.0.2; `vite` 8.3.5 |
| Lock coverage | `package-lock.json` lockfileVersion 3 has 111 package records including the root (110 dependency records); exact versions are recorded for direct and transitive packages |
| Replit runtimes | Node 24.13.0, npm 11.6.2, Python 3.13.11 (observed in this Replit environment) |
| `.replit` runtime | `npm run dev`; Node 24 and Python 3.13 modules; port 5000 exposed on 80 |
| Replit Nix channel | `stable-25_05` |
| Managed system packages | `xorg.libX11`, `xorg.libxcb`, `xorg.libXrandr`, `xorg.libXcomposite`, `xorg.libXcursor`, `xorg.libXdamage`, `xorg.libXi`, `xorg.libXext`, `xorg.libXfixes`, `xorg.libXrender`, `xorg.libXinerama`, `libxkbcommon`, `mesa`, `gtk3`, `pango`, `cairo`, `gdk-pixbuf`, `glib`, `alsa-lib`, `dbus`, `at-spi2-core`, `nss`, `nspr`, `fontconfig`, `freetype`, `cups`, `expat`, `libdrm` |

The lockfile is the installed-source record; registry `latest` values are release research, not a recommendation to upgrade. Pyodide 314.0.7 is both the verified upstream stable release and the configured browser runtime. Source configuration is separate from deployment; browser acceptance evidence is recorded by CI.

## Version inventory

**Confirmed** means a repository file, local command, or official source was read during this audit. Historical deployment records establish what was recorded on that date, not what runs now. **Unknown** means no current version was obtained. Local tool observations describe this Windows machine, not the Mac or the gateway's internal environment.

### Executable tools and automation

| Technology | In-place version / configuration | Latest stable retrieved | Source |
| --- | --- | --- | --- |
| Python | Windows `3.14.0rc1`; Replit `3.13.11`; CI selects stable `3.15` | `3.15.1` | [Python downloads](https://www.python.org/downloads/) |
| JavaScript / Node.js | Windows `24.11.1`; Replit `24.13.0` | Current `26.12.1`; LTS `24.22.1` | [Node release index](https://nodejs.org/dist/index.json) |
| npm | Windows and Replit `11.6.2`; root app has 11 direct dependencies and a v3 lockfile | `12.2.1` | [npm published latest](https://registry.npmjs.org/npm/latest) |
| PowerShell | Windows `7.6.5` | `7.6.7` | [PowerShell releases](https://github.com/PowerShell/PowerShell/releases/latest) |
| Git for Windows | Windows `2.56.0.windows.2` | `2.56.0.windows.2` | [Git for Windows releases](https://github.com/git-for-windows/git/releases/latest) |
| GitHub CLI | Windows `2.96.0`; CI binary is runner-managed | `2.103.0` | [GitHub CLI releases](https://github.com/cli/cli/releases/latest) |
| actions/checkout | `7.0.1`, commit-pinned in CI workflows | `7.0.1` | [checkout releases](https://github.com/actions/checkout/releases/latest) |
| actions/setup-python | `7.1.0`, commit-pinned in technology audit | `7.1.0` | [setup-python releases](https://github.com/actions/setup-python/releases/latest) |
| actions/setup-node | `7.1.0`, commit-pinned in app CI | `7.1.0` | [setup-node releases](https://github.com/actions/setup-node/releases/latest) |
| actions/upload-artifact | `7.0.2`, commit-pinned in CI workflows | `7.0.2` | [upload-artifact releases](https://github.com/actions/upload-artifact/releases/latest) |
| GitHub / Actions / Bash runner tools | Hosted service, `ubuntu-latest`; exact runner image varies by run | Managed service, no single application version | [Runner images](https://github.com/actions/runner-images) |

The Windows Python observation is a prerelease; Replit is on Python 3.13.11 and the workflow selects stable 3.15 patches independently. The checker uses GitHub's API directly and does not depend on the runner's GitHub CLI.

Node LTS is the proposed contributor-tool maintenance channel. OpenClaw has its own compatibility requirements: the retrieved install guide specifies Node `24.16+` or `26.1+`, recommending 26. The locally observed `24.11.1` falls below that current requirement, but the gateway's own Node version remains unknown. Validate the correct environment before upgrading. [OpenClaw installation requirements](https://docs.openclaw.ai/install)

### Persona runtimes, services, and hosts

| Technology | In-place version / evidence | Latest stable retrieved | Source |
| --- | --- | --- | --- |
| OpenClaw gateway | `2026.6.1` in August WSL record; replacement installation unknown | `2026.10.6` | [OpenClaw releases](https://github.com/openclaw/openclaw/releases/latest) |
| OpenClaw Windows Hub / Companion | Windows executable 2026.9.8-1, observed 2026-10-22; gateway separate | `2026.9.8-1` | [Windows Hub releases](https://github.com/openclaw/openclaw-windows-node/releases/latest) |
| LM Studio | Mac service documented; app version unknown | `0.4.26` | [LM Studio download](https://lmstudio.ai/download) |
| Ollama | Homebrew-managed Mac service; version unknown | `0.40.8` | [Ollama releases](https://github.com/ollama/ollama/releases/latest) |
| Qdrant | Docker-hosted Mac service; version unknown | `1.20.0` | [Qdrant releases](https://github.com/qdrant/qdrant/releases/latest) |
| Open WebUI | Image `0.11.0` recorded September 12; not reverified live | `0.12.3` | [Open WebUI releases](https://github.com/open-webui/open-webui/releases/latest) |
| SearXNG | Rolling docs observation `2026.10.19+81371861f`; deployed image digest/commit unknown | Same rolling docs observation; not a deployed image claim | [Container guidance](https://docs.searxng.org/admin/installation-docker.html) |
| Docker Engine / CLI | Windows CLI `29.6.1`; Mac engine unknown | `29.9.2` | [Docker Engine release](https://github.com/moby/moby/releases/latest) |
| Docker Desktop | Windows `4.81.0.232925`; Mac version unknown | `4.96.2` | [Docker Desktop notes](https://docs.docker.com/desktop/release-notes/) |
| Homebrew | Mac package manager recorded; version unknown | `7.0.10` | [Homebrew releases](https://github.com/Homebrew/brew/releases/latest) |
| WSL | Windows WSL `2.7.14.0`; gateway distro version unknown | `3.0.3` | [Microsoft WSL releases](https://github.com/microsoft/WSL/releases/latest) |
| Ubuntu | Historical WSL distro; actual installed version unknown | `26.10`; `26.04.1 LTS` | [Ubuntu releases](https://releases.ubuntu.com/) |
| Windows 11 | Contributor observation: 26H2 `26300.9711` | 26H2 `26300.9711`; 25H2 `26200.9711`; device-specific 26H1 `28000.3231` | [Microsoft release information](https://learn.microsoft.com/en-us/windows/release-health/windows11-release-information) |
| macOS | Mac Studio documented; installed OS version unknown | `27.0.1`; hardware eligibility must be checked | [Apple version table](https://support.apple.com/en-us/109033) |
| Discord API | Channel documented; integration's selected API version unknown | API `10` available | [Discord API versioning](https://docs.discord.com/developers/reference) |
| ClickClack / terminal UI | Named in Larry's TOOLS file; exact product identity and version unknown | Unknown until product is identified | [Repository evidence](../souls/larry-the-lobster/workspace/TOOLS.md) |

Read-only Windows contributor commands also observed PowerShell `7.6.5`, GitHub CLI `2.96.0`, WSL `2.7.14.0`, Docker CLI `29.6.1`, Docker Desktop `4.81.0.232925`, and Windows 26H2 build `26300.9711` on 2026-10-22. These are host observations, not Replit or Mac versions. The Replit Agent fetch of Microsoft release health required authorization; the audit coordinator independently read the official Microsoft table and local Windows registry on this date. Windows versions are servicing channels, not an instruction to install the numerically largest release.

Read-only version requests to the documented Mac Qdrant, Ollama, and Open WebUI endpoints failed from this session. No running version is inferred from their historical records. No services, images, operating systems, or model files were changed.

### Formats, models, and references

| Technology / artifact | Use and version boundary | Latest specification or maintenance method |
| --- | --- | --- |
| Markdown / GitHub Flavored Markdown | Corpus and persona files; no renderer pin | [CommonMark `0.31.2`](https://spec.commonmark.org/) is a reference, not a verified renderer setting |
| Mermaid renderer | Not a root dependency and not present in the app lockfile | npm `mermaid` `12.2.0` is reference-only; do not install it as part of this inventory |
| Mermaid Diagram Sync Assistant | Optional managed GitHub integration; app version is not exposed by repository files | Version unknown; inspect the integration in GitHub if it becomes relevant |
| YAML | Workflow, skill metadata, and fixtures; no edition pin | [YAML `1.2.2`](https://yaml.org/spec/1.2.2/); consumers have their own subsets |
| JSON | Schemas, fixtures, catalogs, and audit data | [RFC 8259](https://www.rfc-editor.org/info/rfc8259/) |
| ECMAScript | `.mjs` / `.cjs` contributor utilities; no target edition pin | [ECMA-262 edition 17, ECMAScript 2026](https://ecma-international.org/publications-and-standards/standards/ecma-262/); actual execution is governed by Node |
| Local model artifacts | Persona TOOLS names `lmstudio/lfm2-24b-a2b-mlx` and `mistral-small3.1:24b` | Tags do not establish immutable revision, quantization, digest, or newest suitable model; record these on the model host |
| Repository-local skills | Seven private package manifests say `0.1.0`; other skill versions and source provenance live in their metadata | Review against their canonical source; do not reinterpret skill version numbers as runtime dependency pins |

React, TypeScript, Vite, and Tailwind CSS are app dependencies with exact lockfile versions shown above. Mermaid is a package-registry reference only, not an app dependency; the optional sync assistant is managed outside this checkout and has no known app version. pnpm and Yarn remain references, not installed root package managers. DMN and protocols such as HTTP, WebSocket, and gRPC are contracts, not independently installed repository packages.

ChatGPT, Claude, Codex, Notion, Replit, browsers, and editors are authoring or integration surfaces, not persona-runtime dependencies. This inventory records the current Replit workspace runtime; it does not establish live GitHub Pages, another Replit project, or host/deployment parity.

## Source ledger and uncertainty

The links beside rows identify claim sources and publishers. Automated release values were retrieved by the fresh read-only audit on 2026-10-22; they describe upstream release research, not installed versions. Manual values use the linked official reference; where the Replit Agent could not read a source, the independent coordinator observation or remaining uncertainty is identified. The machine-readable ledger is [technology-versions.json](technology-versions.json), including retrieval time, baseline commit, installed/source evidence, parser, source, and follow-up.

Local evidence: tracked manifests and executable imports under `.agents/skills/` and `skills/`; [workflow](../.github/workflows/check-technology-versions.yml); [readiness checker](../scripts/check-asus-gateway-readiness.ps1); [September runbook](asus-gateway-runbook.md); [August closeout](../context/threads/2026-08-02-asus-gateway-runtime-closeout.md); persona TOOLS files; direct version commands and Windows executable/registry metadata.

| Consequential claim | Tier | Evidence | Consequence if false | Next check |
| --- | --- | --- | --- | --- |
| Root app uses React/Vite and browser-side Pyodide | Confirmed | package manifests, lockfile, app initialization | Missing runtime coverage | Re-inventory when dependencies or runtime URLs change |
| Listed upstream versions are available releases | Confirmed at retrieval | Official sources and generated live audit | Wrong upgrade target | Run the checker before maintenance |
| Current Mac and gateway installations match those releases | Unknown | Historical records and failed endpoint probes only | Unsafe upgrade or false completion claim | Collect versions on each owning host |
| Windows gateway has a purely native implementation | Unknown / conflicting records | Runbook describes native Companion plus an internal WSL gateway | Upgrade wrong runtime | Identify actual process, package, and distro before changing it |
| A newer version is compatible with the personas and data | Proposal pending tests | Release availability alone is insufficient | Behavioral regression or data migration failure | Backup, compatibility checks, and service smoke tests |
| Live GitHub Pages or other hosts match this checkout | Unknown | No live deployment or external host was inspected in this unit | False deployment/parity claim | Verify each destination from its own read-only source before relying on it |

## Implemented update mechanism

1. **Every day at 14:23 UTC**, the workflow tests the checker, checks 36 automated release tracks (including 11 direct npm dependencies and Pyodide), produces Markdown and JSON reports, and opens or refreshes one bot-owned tracking issue for new releases or source errors. Thirteen records remain manual/reference-only. Counts include separate Node Current and LTS tracks.
2. **Dependabot runs weekly** for GitHub Actions and root npm dependencies. It proposes updates, including major versions, through reviewable pull requests. There is no blanket auto-merge.
3. **Python patch releases update automatically in CI** through `python-version: '3.15'`, `check-latest: true`, and `allow-prereleases: false`. Tests run using the newly resolved stable patch. New Python minor/major series are detected by the audit and require a reviewed workflow change.
4. **Keep the registry manifest synchronized with package-lock.** All 11 direct dependencies have npm registry tracks; the v3 lockfile records transitive versions as well. Dependabot changes remain PRs; run type, content, build, and browser checks before merging major or runtime updates.

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

## Portability and publication gates

The lockfile contains 110 resolved package records. All downloads must use HTTPS on registry.npmjs.org. Replit package upgrades can write its internal firewall address into resolved fields. Run npm run normalize:lockfile after such upgrades, inspect the diff, then run npm run check:lockfile-portability. The normalizer changes only that exact known prefix and refuses changes beyond resolved URLs; locked versions and integrity values are preserved. CI checks portability before npm ci and tests the guard. The 29 affected original entries were independently matched to their official public tarballs and integrity hashes during this audit.

Node CI selects the latest stable patch of Node 24 with check-latest enabled. Audit CI now selects stable Python 3.15 patches; Windows and Replit interpreter observations above remain separate and were not upgraded by this change.

Pages publication is manual only through deploy-pages.yml on main. It calls reusable app CI with prepare-pages enabled. That job must pass portability, dependency installation, type checking, content and lockfile tests, build, and Chromium/Firefox/WebKit before preparing the Pages artifact. The deployment job needs that successful verification and uses the artifact from the same workflow. Verification has read-only repository permission; Pages and identity-token writes are confined to deployment. No deployment was dispatched during this maintenance.

Additional pinned Actions: actions/configure-pages 6.0.0, actions/upload-pages-artifact 5.0.0, and actions/deploy-pages 5.0.1. Official release endpoints are in the machine-readable ledger and weekly Actions Dependabot coverage applies.

Windows Companion observation, 2026-10-22: the running executable reports ProductVersion 2026.9.8-1 (FileVersion 2026.9.8.0). Its uninstall entry still says 2026.9.3. The executable observation takes precedence for this app only; gateway version and health remain separate.
