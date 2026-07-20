# Technology inventory

Last reviewed: 2026-07-20

This repository is a Markdown documentation corpus and persona package library. It is not a TypeScript, Vite, Tailwind, JavaScript, or Python application. There is no package manifest, lockfile, application source tree, build command, or test suite in this checkout. Therefore the repository has no in-place versions for those technologies.

## Technologies actually used or documented

| Technology | Role in this solution | Version in this repository or deployment record | Latest stable checked | Update source | Tracking status |
| --- | --- | --- | --- | --- | --- |
| Markdown | Documentation, persona workspace files, corpus and skills | No formal version pinned | CommonMark specification is the current compatibility target | [CommonMark](https://commonmark.org/) | Manual, format has no single product release |
| Git | Source control for the corpus | Not pinned in the repository | Latest stable varies by platform | [git-scm.com](https://git-scm.com/downloads) | Manual, host-installed |
| GitHub | Repository hosting and proposed scheduled audit | `OKHP3/infusing-a-soul` | Service, no repository-pinned version | [GitHub Actions](https://docs.github.com/en/actions) | Workflow audit |
| Python | Standard-library version audit script and workflow runner | Not pinned in the repository | `3.14.6` | [Python downloads](https://www.python.org/downloads/) | Workflow runtime |
| GitHub Actions checkout | Checks out the repository for the audit | `v6` | `v6.0.2` | [checkout releases](https://github.com/actions/checkout/releases) | Dependabot or manual review |
| GitHub Actions upload-artifact | Preserves the audit report | `v7` | `v7.0.1` | [upload-artifact releases](https://github.com/actions/upload-artifact/releases) | Dependabot or manual review |
| OpenClaw | External agent runtime loading persona workspace files | Referenced, but not pinned in this repository | `2026.7.1` | [OpenClaw latest release](https://github.com/openclaw/openclaw/releases/latest) | Weekly audit |
| LM Studio | Local model serving and inference provider | Model endpoints documented, application version not pinned | `0.4.19` | [LM Studio download](https://lmstudio.ai/download) | Weekly audit |
| Ollama | Secondary local model runtime | Model tag documented, application version not pinned | `0.32.1` | [Ollama latest release](https://github.com/ollama/ollama/releases/latest) | Weekly audit |
| Qdrant | Vector search and semantic memory service | Endpoint documented, server version not pinned | `1.18.3` | [Qdrant latest release](https://github.com/qdrant/qdrant/releases/latest) | Weekly audit |
| SearXNG | Web metasearch service | Endpoint documented, version not pinned | No GitHub stable release; rolling project state | [SearXNG releases](https://github.com/searxng/searxng/releases), [SearXNG tags](https://github.com/searxng/searxng/tags) | Weekly audit, tag or image required |
| Discord | Documented channel integration for Glee-fully | Bot/channel configuration is external and not pinned here | Discord API v10 is the documented stable API version | [Discord API versioning](https://discord.com/developers/docs/reference#api-versioning) | External runtime check |
| WSL2 / Ubuntu | Documented Glee-fully gateway host environment | WSL2 and Ubuntu named, distro and WSL build not pinned | Microsoft distributes current WSL updates | [WSL update documentation](https://learn.microsoft.com/en-us/windows/wsl/basic-commands) | Host maintenance |
| macOS | Documented Larry and service host environment | Mac Studio named, macOS version not pinned | Current stable depends on the host hardware and Apple release | [Apple macOS](https://www.apple.com/macos/) | Host maintenance |

## Explicitly absent

TypeScript, JavaScript, Node.js, Vite, Tailwind CSS, React, Next.js, npm, pnpm, Yarn, Docker, and database client libraries are not used by the authored solution. Python is used only by the version-audit script added with this review, and is not an application runtime dependency.

The model names and tags in persona READMEs and `workspace/TOOLS.md` are model artifacts, not software runtime versions. They are intentionally listed separately from this technology inventory.

## Update policy

The scheduled workflow at `.github/workflows/check-technology-versions.yml` runs the standard-library Python checker at `scripts/check-technology-versions.py`. It queries authoritative release endpoints, compares them with the verified snapshot above, and opens an issue when a tracked release changes. It does not update or deploy external OpenClaw, LM Studio, Ollama, Qdrant, SearXNG, Discord, WSL, or macOS installations. Those changes require an authorized operator and a compatibility check on the target host.

When a future application manifest is added, enable Dependabot for that ecosystem and pin workflow actions to reviewed versions. Until then, an external-version audit is the correct automation for this repository.
