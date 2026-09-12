# ASUS Glee-fully Gateway Runbook

Last verified: 2026-09-12

This runbook records the verified operating path for Glee-fully on GJS-LAPTOP, the ASUS Windows system. It is an operational companion to the persona source files. It does not contain credentials or replace the external OpenClaw configuration.

## Thread Closeout (2026-09-12)

This update was produced during a 2026-09-12 session that began as a WSL troubleshooting request and ended in an architecture change. Read this section before touching anything else on this host.

**What changed since the 2026-08-02 verification:**

1. WSL2 is fully removed from GJS-LAPTOP. The `Ubuntu` distro was unregistered and uninstalled, the `Microsoft-Windows-Subsystem-Linux` and `VirtualMachinePlatform` optional features were disabled, and Appx/registry/file residue was cleared. There is no WSL-hosted gateway on this machine anymore. Everything below in the pre-2026-09-12 sections that references WSL, Ubuntu, `systemd`, or the `WSL Boot` scheduled task is historical only.
2. Glee-fully's gateway now runs as a native Windows service through **OpenClaw Windows Companion** (the "Hub" app), installed fresh from `docs.openclaw.ai/install`. This was a deliberate decision: OpenClaw had never actually been exercised end-to-end on this host, so rather than repair a broken WSL install, Jamie chose to remove WSL entirely and adopt the native Windows path.
3. During the Companion setup wizard, the only two gateway options offered were "Install a local gateway (WSL)" [recommended by the installer] or "Connect to an existing gateway." There is currently no true no-WSL local-gateway option in this build. Jamie was asked directly and chose **local gateway (WSL) anyway**, accepting that the installer provisions its own internal WSL layer even though the standalone WSL install was just removed. This is expected and not a regression: the Companion app manages that internal layer itself: it is not the same as the old manually-configured Ubuntu distro.
4. Gateway pairing succeeded. Diagnostics confirm **Connected, OpenClaw is connected to `ws://127.0.0.1:18789`** (loopback, same port the old WSL gateway used). Node mode is set to **Standard** tier with Canvas, Screen capture, TTS, STT, Device info, and System access active; Browser control, Camera, Location, Share, and Windows Ollama are inactive. Native Windows startup persistence is enabled through the Companion app itself, which supersedes the old `WSL Boot` scheduled-task workaround. That original blocker (task 1 in the pre-2026-09-12 list below) is resolved by the new architecture.
5. **Model provider routing to the Mac Studio is not yet configured, and this is the open item.** See "Current blockers" below.
6. `device_bash` (the direct shell bridge from Claude's side to this host) was broken for the entire 2026-09-12 session, root-caused to a September 8 Windows update breaking a Plan9/virtiofs mount. No shell commands could be run against this host from that channel; all work this session was either GUI computer-use through the Companion app, File Explorer, and WSL Settings, or done by Jamie directly at the keyboard.

## Current blockers

1. **Model provider is unconfigured and the in-app configuration path is currently blocked.** OpenClaw Companion ships a built-in skill, `add-model-provider` ("Add and live-prove a model provider with non-interactive config one-liners, without exposing credentials"), that is meant to be invoked by asking the OpenClaw agent itself in the Companion **Chat** tab, not through a settings form. A chat message was sent asking it to add an `lmstudio` provider (`baseUrl: http://mac-studio.local:1234/v1`, `apiKey: "lmstudio"` — this is LM Studio's own documented placeholder for its local server, not a real secret) and to live-prove reachability before changing anything. The request came back **"Agent error"** with no response. The chat panel showed a model tag of `gpt-5.6-sol` on the attempted turn, meaning some provider is already referenced in the agent's config, but it is not answering. This is a chicken-and-egg problem: the safe, credential-free configuration path runs through the agent's own chat, and the agent cannot process that request while its current model is broken. **This needs Jamie to look at directly** — either fix or replace whatever `gpt-5.6-sol` is pointing at (Gateway > Connection or the underlying `openclaw.json`), or use `openclaw doctor` from a real terminal, before the `add-model-provider` chat-based path can be retried. No credential was written or exposed at any point; the attempted config never got far enough to touch a key.
2. Mac Studio LAN endpoint reachability (LM Studio 1234, Ollama 11434, Qdrant 6333, SearXNG 8888) is **still unverified**. The chat-based reachability test above never ran because the agent errored before it could execute. This has not been re-checked since the 2026-08-02 note that these were unreachable from the ASUS.
3. OpenClaw's security audit item from 2026-08-02 (browser/web tools enabled without a sandbox on a model that could serve untrusted input) has not been re-evaluated against the new native install. Treat it as still open until reviewed.

## Readiness check

The old `.\scripts\check-asus-gateway-readiness.ps1` script assumes the WSL-hosted architecture (checks `wsl` registration, the `WSL Boot` task, and an in-distro `systemd` service) and is **no longer accurate** for the native Companion-app gateway. It should be rewritten or retired; until then, use the Companion app's own **Diagnostics** page (Connected/Disconnected banner, "Run gateway doctor", "Create diagnostics bundle") as the source of truth for gateway health.

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

The active configuration needs owner-approved remediation before the Discord bot serves anyone beyond its trusted owner. Re-verify each of these against the new native install; none have been confirmed since 2026-08-02:

1. Enable OpenClaw sandboxing for the 24B model, or deny browser and web tool groups for that model.
2. Disable `gateway.controlUi.allowInsecureAuth` unless there is a current, documented debugging need.
3. Restrict the OpenClaw state directory to the account that runs the gateway.
4. Migrate plaintext tokens and provider keys from `openclaw.json` into OpenClaw's secret store.
5. Pin non-bundled plugin versions and set an explicit `plugins.allow` list.

These are intentional configuration decisions because they can alter model capabilities and deployment behavior. They are not applied automatically.

## Status vocabulary

Use these labels consistently in future repository and Notion updates:

- `authored`: persona workspace artifacts are complete and versioned.
- `runtime unverified`: the deployment is documented but lacks a dated successful host and dependency check.
- `active`: the gateway, primary model endpoint, and authorized channel smoke test all passed on the same dated check.

The verified status on 2026-09-12 is: `authored / runtime unverified`. The gateway itself is confirmed reachable for the first time on this host (an improvement over 2026-08-02, where it depended on a WSL workaround), but the primary model endpoint and channel smoke test remain unverified, and the chat-based provider configuration path is currently blocked pending Jamie's review of the existing broken model reference.

## Historical: pre-2026-09-12 WSL-based operating notes

The sections below describe the WSL2/Ubuntu architecture that was in place through 2026-08-02 and was fully decommissioned on 2026-09-12. Kept for history; do not follow these as current instructions.

### Confirmed host state (as of 2026-08-02, superseded)

- GJS-LAPTOP had Ubuntu on WSL2, with `systemd=true` configured.
- The `okhp3` WSL user had `dbus-launch` available and user lingering enabled.
- OpenClaw `2026.6.1` was installed in Ubuntu.
- The `openclaw-gateway.service` was enabled and launched Glee-fully's configured gateway on loopback port `18789`.

### Former blocker and workaround (resolved by removal, not by fixing)

The Windows Scheduled Task named `WSL Boot` was absent, and Ubuntu shut down about 15-20 seconds after its last client exited on WSL `2.7.3`, stopping the gateway even with the systemd service enabled. The documented workaround was:

```powershell
schtasks /create /tn "WSL Boot" /tr "wsl.exe -d Ubuntu --exec dbus-launch true" /sc onstart /ru "$env:USERNAME"
```

This workaround was never applied. Instead, on 2026-09-12, the whole WSL-hosted approach was removed in favor of the native Companion app, which does not have this idle-termination problem because it is not WSL-hosted.
