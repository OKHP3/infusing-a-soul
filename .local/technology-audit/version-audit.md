# Technology version audit

Checked at: 2026-09-19T03:02:05+00:00

UNCHANGED compares upstream with the reviewed release baseline. It does not verify installed versions.
Recorded versions are dated observations; check the evidence before planning an upgrade.

| Technology | Recorded version / context | Reviewed upstream | Latest retrieved | Result |
| --- | --- | --- | --- | --- |
| OpenClaw | 2026.6.1 (Historical WSL deployment, 2026-08-02; replacement gateway version unknown) | 2026.9.5 | 2026.9.5 | UNCHANGED |
| Ollama | Unknown (External host version not recorded or reachable in this audit) | 0.34.2 | 0.34.2 | UNCHANGED |
| Qdrant | Unknown (External host version not recorded or reachable in this audit) | 1.19.1 | 1.19.1 | UNCHANGED |
| Open WebUI | 0.11.0 (Mac container image in docs/asus-gateway-runbook.md, 2026-09-12; not reverified live) | 0.11.3 | 0.11.3 | UNCHANGED |
| actions/checkout | v6 -> 7.0.1 (Workflow before this change -> proposed SHA pin) | 7.0.1 | 7.0.1 | UNCHANGED |
| actions/setup-python | v6 -> 7.0.0 (Workflow before this change -> proposed SHA pin) | 7.0.0 | 7.0.0 | UNCHANGED |
| actions/upload-artifact | v7 -> 7.0.1 (Workflow before this change -> proposed SHA pin) | 7.0.1 | 7.0.1 | UNCHANGED |
| PowerShell | 7.6.5 (Local shell observation, 2026-09-18 America/Chicago) | 7.6.6 | 7.6.6 | UNCHANGED |
| Git for Windows | 2.55.0.windows.5 (Local git --version, 2026-09-18 America/Chicago) | 2.55.0.windows.5 | 2.55.0.windows.5 | UNCHANGED |
| WSL | 2.7.14.0 (Local wsl --version, 2026-09-18 America/Chicago; distribution not inspected) | 2.7.14 | 2.7.14 | UNCHANGED |
| Docker Engine / CLI | 29.6.1 (Local client only, 2026-09-18 America/Chicago; Mac engine unknown) | 29.8.1 | 29.8.1 | UNCHANGED |
| Homebrew | Unknown (External host version not recorded or reachable in this audit) | 7.0.4 | 7.0.4 | UNCHANGED |
| GitHub CLI | 2.96.0 (Local gh --version, 2026-09-18 America/Chicago; CI binary is runner-managed) | 2.101.0 | 2.101.0 | UNCHANGED |
| Python | 3.14.0rc1 (Local py -3; workflow selects 3.14, 2026-09-18 America/Chicago) | 3.14.7 | 3.14.7 | UNCHANGED |
| Node.js Current | 24.11.1 (Local node --version; repository has no engines pin, 2026-09-18 America/Chicago) | 26.9.0 | 26.9.0 | UNCHANGED |
| Node.js LTS | 24.11.1 (Same local Node installation; LTS is the proposed maintenance channel) | 24.21.0 | 24.21.0 | UNCHANGED |
| npm | 11.6.2 (Local npm --version; seven private skill packages have no dependencies, 2026-09-18 America/Chicago) | 12.0.2 | 12.0.2 | UNCHANGED |
| LM Studio | Unknown (Mac application version unknown; model tag does not identify application version) | 0.4.24 | 0.4.24 | UNCHANGED |
| Docker Desktop | 4.81.0 (build 232925) (Local executable product metadata, 2026-09-18 America/Chicago; Mac Desktop version unknown) | 4.91.0 | 4.91.0 | UNCHANGED |
| SearXNG | Unknown (Container documented; installed image digest and commit unknown) | Rolling; docs identify 2026.9.18+c0042add3 | Unknown | MANUAL_CHECK |
| OpenClaw Windows Hub / Companion | Unknown (Companion in docs/asus-gateway-runbook.md; installed app version unknown) | 2026.9.4 | 2026.9.4 | UNCHANGED |
| Windows 11 | 25H2 26200.9457 (Local registry and WSL version output, 2026-09-18 America/Chicago) | 26H1 28000.2956; 25H2 26200.9457 | Unknown | MANUAL_CHECK |
| Ubuntu | Unknown (Historical WSL distro and Companion-managed WSL layer; distro version unknown) | 26.04.1 LTS | Unknown | MANUAL_CHECK |
| macOS | Unknown (Mac Studio is documented; installed OS version unknown) | 27.0 Golden Gate | Unknown | MANUAL_CHECK |
| Discord API | Unknown (Channel documented; API version selected by external OpenClaw installation) | 10 | Unknown | MANUAL_CHECK |
| Markdown / GitHub Flavored Markdown | Unknown (Markdown corpus; no renderer or specification pin) | CommonMark 0.31.2 | Unknown | MANUAL_CHECK |
| YAML | Unknown (Workflow, skill metadata, fixtures; local minimal parser is not a full YAML implementation) | 1.2.2 | Unknown | MANUAL_CHECK |
| JSON | Unknown (Skill schemas, fixtures, metadata, and version manifest) | RFC 8259 | Unknown | MANUAL_CHECK |
| JavaScript / ECMAScript | No language-edition pin (17 .mjs and 2 .cjs files in the initial tracked checkout; Node provides the implementation) | ECMAScript 2026, ECMA-262 edition 17 | Unknown | MANUAL_CHECK |
| GitHub / GitHub Actions hosted runner | Unknown (GitHub hosting and Actions; runner-managed Bash and system tools) | Managed service / ubuntu-latest | Unknown | MANUAL_CHECK |
| ClickClack / terminal interface | Unknown (Named only in Larry TOOLS; upstream product identity not established) | Unknown | Unknown | MANUAL_CHECK |

## Sources and follow-up

- OpenClaw: [https://api.github.com/repos/openclaw/openclaw/releases/latest](https://api.github.com/repos/openclaw/openclaw/releases/latest). Verify on the owning host, test compatibility, then upgrade and record the result.
- Ollama: [https://api.github.com/repos/ollama/ollama/releases/latest](https://api.github.com/repos/ollama/ollama/releases/latest). Verify on the owning host, test compatibility, then upgrade and record the result.
- Qdrant: [https://api.github.com/repos/qdrant/qdrant/releases/latest](https://api.github.com/repos/qdrant/qdrant/releases/latest). Verify on the owning host, test compatibility, then upgrade and record the result.
- Open WebUI: [https://api.github.com/repos/open-webui/open-webui/releases/latest](https://api.github.com/repos/open-webui/open-webui/releases/latest). Verify on the owning host, test compatibility, then upgrade and record the result.
- actions/checkout: [https://api.github.com/repos/actions/checkout/releases/latest](https://api.github.com/repos/actions/checkout/releases/latest). Dependabot proposes reviewed action pin changes.
- actions/setup-python: [https://api.github.com/repos/actions/setup-python/releases/latest](https://api.github.com/repos/actions/setup-python/releases/latest). Dependabot proposes reviewed action pin changes.
- actions/upload-artifact: [https://api.github.com/repos/actions/upload-artifact/releases/latest](https://api.github.com/repos/actions/upload-artifact/releases/latest). Dependabot proposes reviewed action pin changes.
- PowerShell: [https://api.github.com/repos/PowerShell/PowerShell/releases/latest](https://api.github.com/repos/PowerShell/PowerShell/releases/latest). Verify on the owning host, test compatibility, then upgrade and record the result.
- Git for Windows: [https://api.github.com/repos/git-for-windows/git/releases/latest](https://api.github.com/repos/git-for-windows/git/releases/latest). Verify on the owning host, test compatibility, then upgrade and record the result.
- WSL: [https://api.github.com/repos/microsoft/WSL/releases/latest](https://api.github.com/repos/microsoft/WSL/releases/latest). Verify on the owning host, test compatibility, then upgrade and record the result.
- Docker Engine / CLI: [https://api.github.com/repos/moby/moby/releases/latest](https://api.github.com/repos/moby/moby/releases/latest). Verify on the owning host, test compatibility, then upgrade and record the result.
- Homebrew: [https://api.github.com/repos/Homebrew/brew/releases/latest](https://api.github.com/repos/Homebrew/brew/releases/latest). Verify on the owning host, test compatibility, then upgrade and record the result.
- GitHub CLI: [https://api.github.com/repos/cli/cli/releases/latest](https://api.github.com/repos/cli/cli/releases/latest). Verify on the owning host, test compatibility, then upgrade and record the result.
- Python: [https://www.python.org/downloads/](https://www.python.org/downloads/). CI automatically resolves stable 3.14 patches; review a new minor series before changing the workflow.
- Node.js Current: [https://nodejs.org/dist/index.json](https://nodejs.org/dist/index.json). Use the compatibility and host-upgrade procedure in docs/technology-inventory.md.
- Node.js LTS: [https://nodejs.org/dist/index.json](https://nodejs.org/dist/index.json). Use the compatibility and host-upgrade procedure in docs/technology-inventory.md.
- npm: [https://registry.npmjs.org/npm/latest](https://registry.npmjs.org/npm/latest). Use the compatibility and host-upgrade procedure in docs/technology-inventory.md.
- LM Studio: [https://lmstudio.ai/download](https://lmstudio.ai/download). Use the compatibility and host-upgrade procedure in docs/technology-inventory.md.
- Docker Desktop: [https://docs.docker.com/desktop/release-notes/](https://docs.docker.com/desktop/release-notes/). Use the compatibility and host-upgrade procedure in docs/technology-inventory.md.
- SearXNG: [https://docs.searxng.org/admin/installation-docker.html](https://docs.searxng.org/admin/installation-docker.html). Review image digest/commit weekly; back up config and validate search after update. No stable GitHub release channel.
- OpenClaw Windows Hub / Companion: [https://api.github.com/repos/openclaw/openclaw-windows-node/releases/latest](https://api.github.com/repos/openclaw/openclaw-windows-node/releases/latest). Use the Hub updater after verifying installed version and gateway compatibility; track gateway separately.
- Windows 11: [https://learn.microsoft.com/en-us/windows/release-health/windows11-release-information](https://learn.microsoft.com/en-us/windows/release-health/windows11-release-information). Use Windows Update eligibility. Keep 25H2 servicing current; do not force a different hardware release.
- Ubuntu: [https://releases.ubuntu.com/](https://releases.ubuntu.com/). Inspect /etc/os-release on the gateway before choosing a supported upgrade.
- macOS: [https://support.apple.com/en-us/109033](https://support.apple.com/en-us/109033). Record sw_vers, check hardware and service compatibility, then use Software Update.
- Discord API: [https://docs.discord.com/developers/reference](https://docs.discord.com/developers/reference). Review API deprecations monthly and validate through the supported OpenClaw integration.
- Markdown / GitHub Flavored Markdown: [https://spec.commonmark.org/](https://spec.commonmark.org/). CommonMark is a reference, not proof of renderer conformance. Preview changed Markdown; review spec annually.
- YAML: [https://yaml.org/spec/1.2.2/](https://yaml.org/spec/1.2.2/). Validate against the actual consumer; review format changes annually.
- JSON: [https://www.rfc-editor.org/info/rfc8259/](https://www.rfc-editor.org/info/rfc8259/). Validate JSON and schema contracts when changing files; standard-library parsers need no extra package.
- JavaScript / ECMAScript: [https://ecma-international.org/publications-and-standards/standards/ecma-262/](https://ecma-international.org/publications-and-standards/standards/ecma-262/). Track Node releases for executable compatibility. Language standard edition is not an installed runtime version.
- GitHub / GitHub Actions hosted runner: [https://github.com/actions/runner-images](https://github.com/actions/runner-images). Inspect run provenance and runner image announcements monthly. Managed service has no repository-controlled product version.
- ClickClack / terminal interface: [https://github.com/OKHP3/infusing-a-soul/blob/main/souls/larry-the-lobster/workspace/TOOLS.md](https://github.com/OKHP3/infusing-a-soul/blob/main/souls/larry-the-lobster/workspace/TOOLS.md). Identify the actual UI package and official publisher on the Mac before selecting an update source.

External services require a dated host version, backup, compatibility review, upgrade,
and smoke test. Changing reviewed_version acknowledges research only, never installation.
