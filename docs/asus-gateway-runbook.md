# ASUS Glee-fully Gateway Runbook

Last verified: 2026-09-12

This runbook records the verified operating path for Glee-fully on GJS-LAPTOP, the ASUS Windows system. It is an operational companion to the persona source files. It does not contain credentials or replace the external OpenClaw configuration.

## Thread Closeout (2026-09-12)

This update was produced during a 2026-09-12 session that began as a WSL troubleshooting request and ended in an architecture change. Read this section before touching anything else on this host.

**What changed since the 2026-08-02 verification:**

1. WSL2 is fully removed from GJS-LAPTOP. The `Ubuntu` distro was unregistered and uninstalled, the `Microsoft-Windows-Subsystem-Linux` and `VirtualMachinePlatform` optional features were disabled, and Appx/registry/file residue was cleared. There is no WSL-hosted gateway on this machine anymore, and this runbook no longer documents the old WSL-based operating path.
2. Glee-fully's gateway now runs as a native Windows service through **OpenClaw Windows Companion** (the "Hub" app), installed fresh from `docs.openclaw.ai/install`. This was a deliberate decision: OpenClaw had never actually been exercised end-to-end on this host, so rather than repair a broken WSL install, Jamie chose to remove WSL entirely and adopt the native Windows path.
3. During the Companion setup wizard, the only two gateway options offered were "Install a local gateway (WSL)" [recommended by the installer] or "Connect to an existing gateway." There is currently no true no-WSL local-gateway option in this build. Jamie was asked directly and chose **local gateway (WSL) anyway**, accepting that the installer provisions its own internal WSL layer even though the standalone WSL install was just removed. This is expected and not a regression: the Companion app manages that internal layer itself: it is not the same as the old manually-configured Ubuntu distro.
4. Gateway pairing succeeded. Diagnostics confirm **Connected, OpenClaw is connected to `ws://127.0.0.1:18789`** (loopback). Node mode is set to **Standard** tier with Canvas, Screen capture, TTS, STT, Device info, and System access active; Browser control, Camera, Location, Share, and Windows Ollama are inactive. Native Windows startup persistence is enabled through the Companion app itself, which resolves the original persistence blocker for good, there's no scheduled-task workaround to maintain anymore.
5. **Model provider routing to the Mac Studio is not yet configured, and this is the open item.** See "Current blockers" below.
6. `device_bash` (the direct shell bridge from Claude's side to this host) was broken for the entire 2026-09-12 session, root-caused to a September 8 Windows update breaking a Plan9/virtiofs mount. No shell commands could be run against this host from that channel; all work this session was either GUI computer-use through the Companion app, File Explorer, and WSL Settings, or done by Jamie directly at the keyboard.

## Current blockers

1. **Model provider is unconfigured and the in-app configuration path is currently blocked.** OpenClaw Companion ships a built-in skill, `add-model-provider` ("Add and live-prove a model provider with non-interactive config one-liners, without exposing credentials"), that is meant to be invoked by asking the OpenClaw agent itself in the Companion **Chat** tab, not through a settings form. A chat message was sent asking it to add an `lmstudio` provider (`baseUrl: http://mac-studio.local:1234/v1`, `apiKey: "lmstudio"` — this is LM Studio's own documented placeholder for its local server, not a real secret) and to live-prove reachability before changing anything. The request came back **"Agent error"** with no response. The chat panel showed a model tag of `gpt-5.6-sol` on the attempted turn, meaning some provider is already referenced in the agent's config, but it is not answering. This is a chicken-and-egg problem: the safe, credential-free configuration path runs through the agent's own chat, and the agent cannot process that request while its current model is broken. **This needs Jamie to look at directly** — either fix or replace whatever `gpt-5.6-sol` is pointing at (Gateway > Connection or the underlying `openclaw.json`), or use `openclaw doctor` from a real terminal, before the `add-model-provider` chat-based path can be retried. No credential was written or exposed at any point; the attempted config never got far enough to touch a key.
2. Mac Studio LAN endpoint reachability (LM Studio 1234, Ollama 11434, Qdrant 6333, SearXNG 8888) is **still unverified**. The chat-based reachability test above never ran because the agent errored before it could execute. This has not been re-checked since the 2026-08-02 note that these were unreachable from the ASUS.
3. OpenClaw's security audit item from 2026-08-02 (browser/web tools enabled without a sandbox on a model that could serve untrusted input) has not been re-evaluated against the new native install. Treat it as still open until reviewed.

## `openclaw doctor` findings (2026-09-12)

Jamie ran `openclaw doctor` from a real terminal after waking up (Claude cannot type into terminals; this had to be done by hand). It runs inside the Companion app's internal WSL layer, per item 3 in Thread Closeout above. Findings, most actionable first:

| Finding | Detail | Action |
| --- | --- | --- |
| Plaintext secret in config | `openclaw.json` has a plaintext token at `gateway.auth.token`. Doctor does not print the value. | Run `openclaw secrets configure` or `openclaw secrets apply` to move it to a SecretRef, then confirm with `openclaw secrets audit --check`. This is the concrete instance of security-decision item 4 below. |
| No command owner configured | No account is set as the human operator allowed to run owner-only commands (`/diagnostics`, `/export-session`, `/export-trajectory`, `/config`) or approve dangerous actions. | Set `commands.ownerAllowFrom` to your channel user id, e.g. `openclaw config set commands.ownerAllowFrom '["telegram:123456789"]'`, then restart the gateway. Worth doing before broadening access past just you. |
| Systemd lingering | The internal WSL layer runs the gateway as a systemd user service. Without lingering, systemd can stop the user session (and kill the gateway) on logout or idle. | **Done.** Jamie answered Yes; doctor confirmed "Enabled systemd lingering for openclaw." Same class of fix as the old `WSL Boot` scheduled-task workaround, just inside the new internal layer. |
| 30 allowed skills unusable in this environment | Missing binaries/env vars/config for things like `github`, `gh-issues`, `obsidian`, `spotify-player`, `trello`, `1password`, `camsnap`. Doctor asked whether to disable them in config (default: No). | Left at **No**. They're inert either way; disabling now just means remembering to re-enable each one later if/when its credential gets configured. Revisit with `openclaw skills check --agent <id>` once any of these are actually wanted. |
| Not a git checkout | This OpenClaw install can't self-update via `git pull`. | Run `openclaw update` to update via npm/pnpm, then re-run doctor. |
| No successful backup recorded | No backup has ever completed. | Run `openclaw backup create` now; consider `openclaw backup enable --repository <dir>` for scheduled versioned backups. |
| Legacy Browser Relay Authentication enabled | `browser.extensionRelay.allowLegacyAuth=true`. | Update paired Chrome extensions / external CDP clients to Relay Auth v2, then set `allowLegacyAuth=false`. |
| Host desktop lab disabled | `desktop.host.enabled=false`. | Informational only, no action unless you want that feature. |
| GitHub project search is public-only | No `gateway.controlUi.github.token` or `GH_TOKEN`/`GITHUB_TOKEN` set. | Only matters if you want private-repo project search from the gateway. |

| Memory search has no API key | `memory.search.enabled` provider is `openai`, no `OPENAI_API_KEY` found. Semantic recall will not work without one. This is separate from the chat-completion model behind the `gpt-5.6-sol` error above; doctor does not appear to validate that path directly. | **Done.** Ran `openclaw config set memory.search.enabled false`. Jamie has ChatGPT Pro, not separate OpenAI API billing, and doesn't want to open that billing relationship just for this. Revisit later by pointing memory search at a local embedding model on the Mac Studio via LM Studio or Ollama instead of OpenAI, once that endpoint is reachable. |

Doctor completed cleanly after these. Its own recommendation to also run `openclaw security audit --deep` has not been done yet.

**Next step to actually unblock the model provider:** with a live shell now open (`openclaw@GJs-Laptop:~$`), run `openclaw config get agents.defaults.model` to see what `gpt-5.6-sol` resolves to and why it's erroring, rather than continuing to fight the Companion GUI.

**Operational note:** clicking "Run gateway doctor" from the Companion Diagnostics page more than once opens a new interactive terminal each time, and each one independently blocks on the same Yes/No prompts. Multiple stuck PowerShell windows asking the identical question is expected if doctor was launched more than once; answer one, then close the rest rather than answering each separately.

## Readiness check

Run the PowerShell checker from the repository root:

```powershell
.\scripts\check-asus-gateway-readiness.ps1
```

It was rewritten on 2026-09-12 for the native Companion-app architecture. It reports, without reading or printing secrets:

- Whether the OpenClaw Windows Companion process is running.
- Whether the gateway is listening on loopback port `18789`.
- Whether the Companion diagnostics log exists and was updated recently.
- Whether native startup persistence is registered (Run key, Startup folder, or a scheduled task).
- TCP reachability from Windows to the four documented Mac Studio services.

The script exits nonzero when any required check fails. It is a readiness check, not a repair tool. The Companion app's own **Diagnostics** page (Connected/Disconnected banner, "Run gateway doctor", "Create diagnostics bundle") is the other source of truth for gateway health, and is the better tool for digging into *why* a check failed.

## Required Mac Studio recovery

From the Mac Studio, an authorized operator must verify that the following documented services listen on the LAN address expected by Glee-fully and are permitted through the host firewall:

| Service | Port | Glee-fully role |
| --- | ---: | --- |
| LM Studio | 1234 | Primary model inference |
| Ollama | 11434 | Secondary persona model |
| Qdrant | 6333 | Semantic-memory store |
| SearXNG | 8888 | Current-information search |

Once reachable, retry the `add-model-provider` chat request documented above (or configure the provider directly), and re-run gateway doctor. A successful model endpoint check is the minimum prerequisite for an end-to-end Discord smoke test.

## Security decisions before broadening access

The active configuration needs owner-approved remediation before the Discord bot serves anyone beyond its trusted owner. Re-verify each of these against the new native install; only item 4 has been confirmed since 2026-08-02, via `openclaw doctor` on 2026-09-12 (see the findings table above):

1. Enable OpenClaw sandboxing for the 24B model, or deny browser and web tool groups for that model.
2. Disable `gateway.controlUi.allowInsecureAuth` unless there is a current, documented debugging need.
3. Restrict the OpenClaw state directory to the account that runs the gateway.
4. **Confirmed 2026-09-12:** `openclaw.json` has a plaintext secret at `gateway.auth.token`. Migrate it (and any other plaintext provider keys) into OpenClaw's secret store with `openclaw secrets configure` / `openclaw secrets apply`, then verify with `openclaw secrets audit --check`.
5. Pin non-bundled plugin versions and set an explicit `plugins.allow` list.
6. **New from doctor:** set a command owner (`commands.ownerAllowFrom`) before broadening access past Jamie.
7. **New from doctor:** move off Legacy Browser Relay Authentication (`browser.extensionRelay.allowLegacyAuth=false` once clients support v2).

These are intentional configuration decisions because they can alter model capabilities and deployment behavior. They are not applied automatically.

## Status vocabulary

Use these labels consistently in future repository and Notion updates:

- `authored`: persona workspace artifacts are complete and versioned.
- `runtime unverified`: the deployment is documented but lacks a dated successful host and dependency check.
- `active`: the gateway, primary model endpoint, and authorized channel smoke test all passed on the same dated check.

The verified status on 2026-09-12 is: `authored / runtime unverified`. The gateway itself is confirmed reachable for the first time on this host (an improvement over 2026-08-02, where it depended on a since-removed WSL workaround), but the primary model endpoint and channel smoke test remain unverified, and the chat-based provider configuration path is currently blocked pending Jamie's review of the existing broken model reference.
