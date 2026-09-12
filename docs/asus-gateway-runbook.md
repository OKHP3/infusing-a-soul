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

## Mac Studio Recovery — Completed 2026-09-12

An authorized operator (Claude, working directly on the Mac Studio via screen control, with Jamie's approval to execute needed changes) ran the recovery pass this section asks for. Verified end to end with live HTTP checks made from a separate network path to the Mac Studio's LAN address, not just from the Mac itself.

**Mac Studio's current LAN address: `10.10.1.201`** (Wi-Fi network `HillHouse`, subnet `255.255.255.0`, router `10.10.1.254`). This is almost certainly what had drifted and broken Glee-fully's old `mac-studio.local` / cached-IP assumptions — confirm `mac-studio.local` still resolves correctly from GJS-LAPTOP, and if not, use the raw IP above until mDNS is confirmed reliable on the HillHouse network.

| Service | Port | Result before | Fix applied | Result after (verified by live curl from off-host) |
| --- | ---: | --- | --- | --- |
| LM Studio | 1234 | Bound to `127.0.0.1` only ("Serve on Local Network" was OFF) | Enabled Serve on Local Network in LM Studio's server settings | Reachable at `http://10.10.1.201:1234` — HTTP 200 |
| Open WebUI | 3000 | Docker port binding was `127.0.0.1:3000->8080` (explicit loopback-only bind) | Recreated the `open-webui` container from the same image (`ghcr.io/open-webui/open-webui:v0.11.0`) and the same named volume (`open-webui:/app/backend/data`, so all data/users/chats persisted), this time with an all-interfaces port publish | Reachable at `http://10.10.1.201:3000` — HTTP 200 |
| Ollama | 11434 | Bound to `127.0.0.1` only | **Not fixed — needs Jamie.** No Ollama.app is installed; it runs headless via `brew services`. See "Ollama LAN exposure" below. | Still unreachable — HTTP connect failure from off-host |
| Qdrant | 6333 (+6334 gRPC) | Docker port binding was `127.0.0.1` only on both ports. **Also found and fixed a stale bind mount**: the running container's storage bind pointed at `/Volumes/DKH-Local/07_Local_LLMs/qdrant`, a path that no longer exists on this Mac (the drive is now named `OKH-Local`). The container had been running since before the rename and never lost its open file handle, so this was invisible until a restart was attempted. | Recreated the container against the correct current path `/Volumes/OKH-Local/07_Local_LLMs/qdrant` (same data — collections and raft state — confirmed intact), with all-interfaces port publish on 6333 and 6334 | Reachable at `http://10.10.1.201:6333` — HTTP 200 |
| SearXNG | 8888 | Docker port binding was `127.0.0.1:8888->8080` | Recreated the `searxng` container from the same image with the same two host bind mounts (`/Users/okh/searxng/config`, `/Users/okh/searxng/data`), all-interfaces port publish | Reachable at `http://10.10.1.201:8888` — HTTP 200 |
| OpenClaw Gateway | 18789 | Not checked in the 2026-08-02 or earlier 2026-09-12 passes | Investigated but **not fixed — needs Jamie**. See "OpenClaw Gateway LAN exposure" below. | Still unreachable — HTTP connect failure from off-host, despite the Control UI's own "Gateway Host" card cosmetically showing `10.10.1.201:18789` (that field is just the host's self-reported LAN address for display, not proof the gateway is listening on it) |

### Ollama LAN exposure — needs Jamie

Ollama on this Mac was installed and is managed through `brew services` (per `mac-studio-local-ai-workbench/mac-studio-setup/LOCAL_WORKBENCH_STATUS.md`), with no Ollama.app / menu-bar presence to toggle network exposure from a GUI, and no terminal-typing access available to the automation that did the rest of this pass. Ollama defaults to binding `127.0.0.1:11434` unless `OLLAMA_HOST` says otherwise. From a real Terminal on the Mac Studio:

```zsh
launchctl setenv OLLAMA_HOST "0.0.0.0"
brew services restart ollama
```

Then re-verify with `curl http://10.10.1.201:11434/api/tags` from another machine on HillHouse. If `launchctl setenv` doesn't survive a reboot in practice, the more durable fix is adding `Environment="OLLAMA_HOST=0.0.0.0"` to the Homebrew-managed launchd plist for the ollama service (`brew services info ollama --json` will show its plist path) and restarting the service.

### OpenClaw Gateway LAN exposure — needs Jamie

This is the important one for the SHOAL ("local AI server for Windows/iPhone/iPad") goal: the Mac Studio's own OpenClaw Gateway is listening on `127.0.0.1:18789` only, confirmed by a failed connection from off-host while every other service above succeeded. OpenClaw Control's own Gateway settings page (Connections → Gateway) only exposes the *client-side* connect target (`ws://127.0.0.1:18789`, i.e. where this Control UI itself connects to, since it runs on the same Mac) — it has no visible toggle for the gateway's own listen/bind address. That setting most likely lives in the gateway's own config (`openclaw.json` or equivalent, referenced elsewhere in this repo's security-decisions list) as something like a `gateway.host` / `gateway.bindHost` key, or an environment variable read at gateway startup. This needs Jamie (or a session with real terminal access to the Mac Studio) to locate that key, set it to `0.0.0.0`, and restart the gateway — then re-verify with a WebSocket/HTTP check against `10.10.1.201:18789` from another device on HillHouse.

Also worth noting while in there: Devices (OpenClaw Control → Devices) currently lists only this Mac Studio itself and its own `openclaw-control-ui` — no Windows, iPhone, or iPad device has been paired to this gateway yet. Once the bind address is fixed, GJS-LAPTOP (or a phone/tablet OpenClaw client) still needs to actually pair to it — that's a separate, deliberate step on each client device, not something that follows automatically from the gateway being reachable.

### Architecture note for the Windows side

Per this runbook's own "Thread Closeout (2026-09-12)" section above: GJS-LAPTOP's OpenClaw Companion runs its **own** local gateway (`ws://127.0.0.1:18789`, internal to the Companion app's managed WSL layer) — it is not, today, a client of this Mac Studio's gateway. That means the fastest path to "Glee-fully talks to the Mac's models" is almost certainly **not** pairing GJS-LAPTOP to the Mac's Gateway at all, but adding LM Studio (and/or Ollama, once its LAN exposure is fixed) as a model provider inside GJS-LAPTOP's own OpenClaw, pointed at `http://10.10.1.201:1234/v1` (LM Studio) — exactly the `add-model-provider` attempt blocker 1 already describes, which is a Windows-side problem (broken `gpt-5.6-sol` model reference blocking the agent chat) unrelated to anything fixed in this update. The Mac-side reachability blocker that attempt was waiting on is now cleared for LM Studio; Ollama needs the fix above first if Glee-fully is meant to use it too.

If the actual intent is closer to the SHOAL vision — one shared Mac-hosted OpenClaw Gateway that GJS-LAPTOP, an iPhone, and an iPad all pair into as clients, rather than each device running its own local OpenClaw — then the Gateway LAN exposure fix above is the blocking item, and device pairing from each client is the step after that.

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
