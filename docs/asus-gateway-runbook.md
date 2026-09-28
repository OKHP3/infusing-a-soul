# ASUS Glee-fully Gateway Runbook

Last verified: 2026-09-26

This runbook records the verified operating path for Glee-fully on GJS-LAPTOP, the ASUS Windows system. It is an operational companion to the persona source files. It does not contain credentials or replace the external OpenClaw configuration.

## Session Update (2026-09-26)

This supersedes the sections below wherever they conflict.

### Findings

| # | Finding | Evidence | Status |
|---|---|---|---|
| 1 | Tailscale is healthy end to end. Mac Studio `overkill-hills-mac-studio` = `100.87.4.93`, GJS-LAPTOP = `100.66.228.62`. MagicDNS resolves the short name. | Live HTTP 200 from GJS-LAPTOP to `100.87.4.93` on 1234, 11434, 3000, 6333, 8888 | Working |
| 2 | Tailscale was never the Companion's problem. The Companion talks to its own gateway on loopback (`127.0.0.1:18789`); only the gateway's *model provider* URLs reach the Mac, and those still pointed at the LAN address `10.10.1.201`, which works at home only. | Companion Config editor | Fixed by `ns-tailnet`, verified 2026-09-26 |
| 3 | The Companion Config editor shows a **stale snapshot**, not the live file. It displayed the pre-2026-09-23-evening state (LFM2 primary, Ministral utility, no fallback). The CLI showed the live config was already correct: Mistral primary, Granite fallback and utility. This stale snapshot is also why every editor save fails. | `openclaw config get agents.defaults` via `ns-tailnet`, 2026-09-26 | Rule: trust the CLI, never the editor |
| 4 | LM Studio renamed the LFM2 key to `liquid/lfm2-24b-a2b`; the stale `lfm2-24b-a2b-mlx` entry was still registered. Mistral Small 3.2 kept its key. | `GET 100.87.4.93:1234/v1/models` | LFM2 removed from the provider (it also fabricates tool results) |
| 5 | The Companion Config editor cannot save: every save returns "config changed since last load; re-run config.get and retry", even after Refresh or a page reload (see row 3). Use the CLI helpers. | Five attempts, 2026-09-26 | Open (Companion bug) |
| 6 | Companion "Local AI" (native llama-server on `127.0.0.1:18803`) is unavailable because the NVIDIA driver does not provide CUDA 13. A CUDA Toolkit is not needed, only a newer driver. | Local AI > See why | Needs an NVIDIA driver update (R580 branch or newer) |
| 7 | Asked through Companion chat to report `config.get`, Mistral Small 3.2 returned an invented config (a `llama2-uncensored` provider, a made-up hash) with no tool card. Never accept config state from model prose. | Companion chat | Rule |
| 8 | The Mac's own gateway (Larry) is loopback on 18789 **by design**: it is published over Tailscale Serve at `https://<host>.<tailnet>.ts.net` (`gateway.tailscale.mode=serve`, `gateway.bind=loopback`), which is how the iPhone and iPad pair with Full access. A plain HTTP check of `100.87.4.93:18789` failing is expected. | `mac-studio-local-ai-workbench/docs/19-reference-stack-2026-09.md`, "Mobile pairing" | Working as designed |
| 9 | Larry's "LLM request failed (model not found, HTTP 404)" on `gpt-oss:20b` has the exact shape of Ollama's not-found error, and Ollama only accepts the exact tag `gpt-oss:20b` (`ollama/…`, `gpt-oss`, `gpt-oss:latest` all 404). On 2026-09-27 the Mac's Ollama lists `gpt-oss:20b` and `/api/show` succeeds, so the tag was missing at the time of the error, not now. Most likely cause: Ollama started before the `OKH-Local` volume mounted (empty model directory), the race `ollama-env.sh` exists to prevent. Unconfirmed. | Live checks from GJS-LAPTOP over Tailscale | Retest Larry; confirm with the Mac-side log check |
| 10 | Two gateways, one 36 GB Mac: the laptop agent's primary (Mistral Small 3.2 24B, LM Studio) and Larry's primary (`gpt-oss:20b`, Ollama) together sit at the Mac's roughly 28 GB GPU ceiling. The Mac's own memory-budget rule says not to run two 20B-class models at once. Whichever loads second can be refused. | `mac-studio-local-ai-workbench/docs/22-lm-studio-tuning-and-remote-access-2026-09.md` | Decision needed: converge both agents on one Mac model |

### Verified result (2026-09-26, `ns-tailnet` then `ns-gpu-tune`)

| Item | Before | After |
|---|---|---|
| `models.providers.lmstudio.baseUrl` | `http://10.10.1.201:1234/v1` (LAN only) | `http://100.87.4.93:1234/v1` (Tailscale) |
| `lmstudio` models | LFM2 (dead key), Mistral, Nomic | Mistral, Nomic |
| `memory.search.remote.baseUrl` | LAN address | Tailscale address (needs a gateway restart to apply) |
| Primary / fallback / utility | Mistral / Granite / Granite (already correct) | unchanged |
| Laptop Granite context | 16,384, 3.0 GB, 100% GPU | 32,768, 3.6 GB, 100% GPU |
| Ollama service | 16K, keep-alive 5m | 32K, keep-alive 30m, one model loaded at a time |

Leftover: `agents.defaults.models` still lists `ollama-local/ministral-3:8b` in its model allowlist. Harmless (the provider no longer offers it), remove when convenient.

The stray `[30;1R` ParserError after the run is a terminal cursor-position report echoed into the prompt, not a script error.

### Fix, from Windows PowerShell 7

```powershell
. "$env:USERPROFILE\OKH-Local\04_GitHub_Mirrors\infusing-a-soul\scripts\night-shift\night-shift.ps1"
ns-tailnet     # Mac primary over Tailscale, Granite fallback + utility on the laptop GPU (backs up openclaw.json first)
ns-gpu         # read-only: GPU seen in WSL, Ollama settings, and `ollama ps` (want 100% GPU)
ns-gpu-tune    # optional: 32K context on the laptop, 30 min keep-alive; re-registers the matching window
```

`ns-tailnet` stops before touching anything if LM Studio is not reachable over the tailnet from inside the distro. After `ns-gpu-tune`, run `ns-gpu`: if `ollama ps` shows anything below `100% GPU`, back off with `ns-gpu-tune 24576` or `ns-gpu-tune 16384`.

### Target routing

| Role | Model | Host | Path |
|---|---|---|---|
| Primary | Mistral Small 3.2 24B | Mac Studio | `http://100.87.4.93:1234/v1` (Tailscale; works at home and away) |
| Fallback | Granite 4.1 3B | Laptop RTX 3050 | `http://127.0.0.1:11434/v1` inside the gateway distro |
| Utility (titles, progress notes) | Granite 4.1 3B | Laptop RTX 3050 | same |
| Embeddings | nomic-embed-text v1.5 | Mac Studio | Tailscale address, only if `memory.search.remote.baseUrl` exists |

### Why Ollama, not the Companion's Local AI, carries the laptop lane for now

Both would compete for the same 6 GB of VRAM. Ollama is installed, has verified tool calls with Granite, and needs no driver change. Update the NVIDIA driver anyway (it is the only Local AI blocker), then decide whether Local AI replaces Ollama. Run one or the other, not both.

## Session Update (2026-09-23 evening to 2026-09-24)

This supersedes parts of the 2026-09-23 section below. Where they conflict, this section wins.

### Current model and policy state

| Setting | Value | Changed from |
|---|---|---|
| `agents.defaults.model.primary` | `lmstudio/mistral-small-3.2-24b-instruct-2506-mlx` | `lmstudio/lfm2-24b-a2b-mlx` (fabricated tool results) |
| `agents.defaults.model.fallbacks` | `["ollama-local/granite4.1:3b"]` | none |
| `agents.defaults.utilityModel` | `ollama-local/granite4.1:3b` | unset |
| `models.providers.ollama-local` | `http://127.0.0.1:11434/v1`, `openai-completions`, model `granite4.1:3b` (16K context) | new |
| `tools.exec.mode` | `allowlist` | `ask` (blocks every tool in scheduled runs, openclaw/openclaw#138853) |

LFM2 and Mistral Small are both still registered under `lmstudio`. The Mac cannot hold both 24B models at once; LM Studio refuses the second with an insufficient-resources error.

### Laptop fallback model

- Ollama installed inside the `OpenClawGateway` distro (not Windows). Install needed `zstd` first.
- One model: `granite4.1:3b` (IBM, 2.1 GB). Direct tool calls verified on both `/v1/chat/completions` and `/api/chat`.
- Removed after testing: `ministral-3:8b` (half on CPU at 16K, ignored tools inside the agent) and `ministral-3:3b` (failed a one-word instruction check).
- systemd override at `/etc/systemd/system/ollama.service.d/override.conf`: `OLLAMA_CONTEXT_LENGTH=16384`, `OLLAMA_FLASH_ATTENTION=1`, `OLLAMA_KV_CACHE_TYPE=q8_0`, `OLLAMA_KEEP_ALIVE=5m`.
- Warning: Companion's "Remove Local Gateway" deletes the distro and this install with it.

### Night Shift

- Scheduled job `night-shift`: `0 1 * * *` America/Chicago, isolated session, `toolsAllow: read, write, edit`, delivery none.
- Procedure: `~/.openclaw/workspace/NIGHT-SHIFT.md`. Queue and results: `~/.openclaw/workspace/night-shift/` (the distro does not mount `C:`, so the queue lives inside the workspace).
- Operated from Windows with the helpers in `scripts/night-shift/` (`ns-add`, `ns-queue`, `ns-run`, `ns-status`, `ns-brief`, `ns-read`). Story: `docs/story/03-night-shift.md`.
- Smoke test 2026-09-24: passed in 83 seconds on Mistral Small 3.2. Result file written, queue line marked, brief written. Input size about 39K tokens, which exceeds the Granite fallback's 16K window.
- Laptop power: `powercfg /change standby-timeout-ac 0` so the gateway stays up overnight on AC.

### Built-in scheduled jobs found

| Job | Schedule | Tools | Planned change |
|---|---|---|---|
| `heartbeat-main` | every 30 minutes | default | slow to every 2 hours |
| `Memory Dreaming Promotion` | 03:00 daily | `*` | limit to file tools |
| `skill-collection-review-main` | weekly | includes `exec` | limit to file tools |

### Items from the 2026-09-23 section now resolved or changed

- `tools.exec.mode ask` is replaced by `allowlist` for the reason above.
- The Mistral fallback note is moot; Mistral is now primary.
- Workspace deployment of Glee-fully's SOUL.md and AGENTS.md is still pending; TOOLS.md still carries the stray `<<<END>>>` line.

## Session Update (2026-09-23)

Read this before the 2026-09-12 closeout below. It supersedes that section wherever they conflict.

### Outage root cause: Virtual Machine Platform

The Companion showed "Gateway connection failed / Transport error" with 452 consecutive refused connections to `ws://127.0.0.1:18789`. Starting the WSL gateway failed with `Wsl/Service/CreateInstance/CreateVm/HCS/HCS_E_SERVICE_NOT_AVAILABLE`, and the `vmcompute` service did not exist.

Cause: item 1 of the 2026-09-12 closeout disabled the `VirtualMachinePlatform` optional feature while removing standalone WSL. The Companion's own gateway distro (`OpenClawGateway`) is still WSL2 and needs that feature. The disable took effect at the next reboot, which was the KB5124010 install reboot at 2026-09-23 01:33. KB5124010 was the trigger, not the cause.

Fix, run by Jamie in admin PowerShell: `bcdedit /set hypervisorlaunchtype auto` and `dism /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart`, then a reboot. Verified afterward: `vmcompute` RUNNING, VirtualMachinePlatform Enabled, `OpenClawGateway` Running (WSL 2), and TCP 18789 open.

Rule: never disable VirtualMachinePlatform on this host. The Companion's local gateway depends on it.

### Configuration applied through the Companion Config editor

Current `openclaw.json` evidence on 2026-09-23 showed only `gateway`, `plugins`, `meta`, and an empty `agents.entries.main`. The 2026-09-12 `memory.search.enabled=false` change and any other doctor-era edits were not present. The following was applied and saved, and the gateway reloaded and reconnected cleanly:

| Key | Value |
| --- | --- |
| `models.providers.lmstudio` | `baseUrl http://10.10.1.201:1234/v1`, `api openai-completions`, placeholder apiKey `lmstudio`, models `lfm2-24b-a2b-mlx` (128K), `mistral-small-3.2-24b-instruct-2506-mlx` (131K), `text-embedding-nomic-embed-text-v1.5` |
| `agents.defaults.model` | `lmstudio/lfm2-24b-a2b-mlx` |
| `memory.search` | enabled, provider `lmstudio`, model `text-embedding-nomic-embed-text-v1.5`, remote baseUrl `http://10.10.1.201:1234/v1`, fallback `none` (local-only, never silently falls back to OpenAI) |
| `tools.exec.mode` | `ask` (commands outside the safe list need owner approval) |

LM Studio at `10.10.1.201:1234` was reachable from GJS-LAPTOP. Companion chat returned replies from the Mac Studio. Model provider blocker 1 below is resolved.

### Findings that need a decision

1. **LFM2-24B-A2B fabricates tool results.** Asked to run `sha256sum`, it once returned an invented hash with no tool call, and twice claimed an edit or cleanup that the tool cards show never happened. It does call tools sometimes, and the tool cards are accurate, so trust tool cards, not its prose. It is a weak brain for an agent that holds `exec`. This is why `tools.exec.mode` is now `ask`.
2. **The Mistral Small 3.2 fallback cannot load while LFM2 is resident.** LM Studio refused with "insufficient system resources" on the 36 GB Mac Studio. Only one roughly 24B model fits alongside the embedding model.
3. **`\\wsl.localhost\OpenClawGateway` is not accessible from Explorer** ("Attempt to access invalid address"). This is likely the same Plan9/virtiofs breakage recorded on 2026-09-12. Windows-side file copies into the gateway are blocked until that is fixed.

### Workspace deployment status

- Gateway workspace: `/home/openclaw/.openclaw/workspace` (git-tracked; OpenClaw defaults AGENTS.md, SOUL.md, IDENTITY.md, USER.md, DREAMS.md).
- `TOOLS.md`: written by the agent. Content matches the repo copy plus one stray trailing line `<<<END>>>` (1,988 bytes against 1,979 expected). Needs the last line removed.
- `SOUL.md` and `AGENTS.md`: **not deployed**. OpenClaw defaults are still active, so Glee-fully's voice is not live.

Deterministic deploy from a Windows PowerShell prompt, with the expected SHA-256 prefixes TOOLS `c5e03b8b05426b49` (Tailscale endpoints, 2026-09-27), SOUL `71992e07c6115596`, AGENTS `5af5d3a1bfe8ac27`:

```powershell
wsl -d OpenClawGateway -u openclaw -- bash -lc "cd ~/.openclaw/workspace && git -c user.name=okhp3 -c user.email=okhp3@localhost commit -qam 'snapshot before glee-fully soul' ; cp /mnt/c/Users/jamie/OKH-Local/04_GitHub_Mirrors/infusing-a-soul/souls/glee-fully/workspace/{SOUL,AGENTS,TOOLS}.md . && sha256sum SOUL.md AGENTS.md TOOLS.md"
```

### Still open, owner action required

- Discord channel: no `channels` block exists in the current config. Adding it needs the bot token, which is owner-only.
- `commands.ownerAllowFrom`: needs Jamie's Discord user id once the channel exists.
- `gateway.auth.token` is still plaintext. Run `openclaw secrets configure`, then `openclaw secrets audit --check`.
- `openclaw security audit --deep` and `openclaw backup create` have still not been run.
- Ollama, Qdrant, and SearXNG reachability from inside the gateway distro is unverified.

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

1. **Model provider is unconfigured — a clean slate, not a broken reference.** The overnight `add-model-provider` chat attempt errored, and the model tag `gpt-5.6-sol` shown in the Companion chat panel looked like an existing-but-broken provider reference. It wasn't. `openclaw config get agents` on 2026-09-12 (from a real shell, after `openclaw doctor` confirmed lingering was already enabled from the prior run, proving it's the same persistent environment) shows `agents.defaults` has no `model` key at all and `agents.entries.main` is an empty object. `openclaw config get models` confirms no provider is registered anywhere. This is a clean, unconfigured slate, not a broken existing reference to fix. `gpt-5.6-sol` was most likely a placeholder/fallback label the UI shows when nothing real is wired up.
2. **Mac Studio LAN reachability — likely improved on the Mac side, not yet re-verified from GJS-LAPTOP.** From the gateway's own WSL shell (`curl -v http://10.10.1.201:1234/v1/models`), LM Studio's port 1234 came back **"Connection refused,"** not a timeout, from source `172.31.63.71` (the WSL instance's own NAT address). Refused, rather than timed out, meant the packet reached the Mac Studio's network stack fine and nothing was listening on port 1234 — a Mac-side service state, not a WSL-networking or LAN-routing problem. Jamie opened a separate Claude session directly on the Mac Studio (`cse_01KXJjW1ADrndwxjPpBRgWo1`) to investigate that side, and per "Mac Studio Recovery — Completed 2026-09-12" below, LM Studio's "Serve on Local Network" toggle was found off and has since been enabled, with reachability confirmed by a live curl from off-host. **This has not yet been re-confirmed from GJS-LAPTOP itself** — re-run `curl -v http://10.10.1.201:1234/v1/models` from the WSL shell before treating it as resolved and before attempting the `add-model-provider` config. Ollama (11434) and the Mac's own OpenClaw Gateway (18789) remain confirmed unreachable per that same section and still need Jamie's hands-on fix on the Mac; Qdrant (6333) and SearXNG (8888) are confirmed fixed on the Mac side but likewise unverified from GJS-LAPTOP specifically.
3. OpenClaw's security audit item from 2026-08-02 (browser/web tools enabled without a sandbox on a model that could serve untrusted input) has not been re-evaluated against the new native install. Treat it as still open until reviewed.

## Configuring a model provider on GJS-LAPTOP — step-by-step playbook

This is the concrete next step for blocker 1 above. Run all of this from a real terminal in the Companion app's internal WSL layer (Claude cannot type into terminals — this is Jamie's to run by hand, same as `openclaw doctor` above).

**1. Re-verify Mac Studio reachability from GJS-LAPTOP itself, not just from the Mac's own network path:**

```zsh
curl -v http://10.10.1.201:1234/v1/models
```

Blocker 2 above left this unconfirmed from GJS-LAPTOP specifically. LM Studio's LAN exposure was fixed and verified from a separate network path on 2026-09-12/13 — this step just closes the loop from the actual client machine before spending time on model config. Expect an HTTP 200 with a JSON model list. A "Connection refused" here means something changed back on the Mac side; a timeout means a routing/firewall problem between the two machines that's new information, not yet documented anywhere.

**2. Confirm the model config is still a clean slate (it was as of 2026-09-12):**

```zsh
openclaw config get agents
openclaw config get models
```

Expect `agents.defaults` with no `model` key and `models` with no providers registered, per the "Current blockers" note above. If a provider now shows up here that nobody added, stop and figure out why before continuing — that would mean either Jamie already did this by hand, or something else configured it.

**3. Register LM Studio as a provider via `openclaw config set`, not through the chat-based `add-model-provider` skill.** The chat-based path is the normally-recommended, credential-free one, but it needs a working default model to run the agent turn that processes the request — the exact chicken-and-egg problem that produced the original `gpt-5.6-sol` error. CLI config first breaks that loop.

The exact config key paths for registering a provider are **not yet confirmed** by this runbook — `openclaw config get models` in step 2 shows the current (empty) shape, and `docs.openclaw.ai` or `openclaw config schema` (if that subcommand exists) should confirm the exact keys before typing anything blind. Based on the dot-path pattern already confirmed elsewhere in this config (`gateway.auth.token`, `commands.ownerAllowFrom`, `memory.search.enabled`), the shape is likely something close to:

```zsh
openclaw config set models.providers.lmstudio.type openai
openclaw config set models.providers.lmstudio.baseUrl http://10.10.1.201:1234/v1
openclaw config set models.providers.lmstudio.apiKey lmstudio
```

`lmstudio` as the API key value is LM Studio's own documented placeholder for its local server, not a real secret — consistent with the original `add-model-provider` chat attempt from 2026-09-12, which used the same placeholder. Verify the actual key names against `openclaw config get models` output structure or the docs site before running these.

**4. Point a default agent at the new provider:**

```zsh
openclaw config set agents.defaults.model lmstudio:<model-id>
```

`<model-id>` should be whatever LM Studio reports as loaded in step 1's `/v1/models` response — likely one of the persona-relevant local models already documented in `mac-studio-local-ai-workbench`.

**5. Restart the gateway and verify:**

```zsh
openclaw doctor
```

then send a simple message in the Companion Chat tab. A response (not another "Agent error") confirms the provider is live.

**6. Once basic chat works, retry the richer `add-model-provider` skill from Chat if a second provider (Ollama, once its own LAN exposure is fixed) needs adding** — that path works fine once there's already a working default model to run it.

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

**Next step to actually unblock the model provider:** with LM Studio reachability re-confirmed from GJS-LAPTOP (see "Current blockers" item 2), register it as a model provider from a live shell (`openclaw@GJs-Laptop:~$`) via `openclaw config set models ...` pointed at `http://10.10.1.201:1234/v1` with `apiKey: "lmstudio"` (LM Studio's own non-secret placeholder), rather than continuing to fight the Companion GUI's chat-based `add-model-provider` path.

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

## Mac Studio recovery status

The Mac Studio side of this runbook used to list four required services to verify. That verification pass has now been run — see "Mac Studio Recovery — Completed 2026-09-12" immediately below for the full before/after table, what was fixed, and what still needs Jamie. In short: LM Studio, Qdrant, and SearXNG are now confirmed reachable from off-host; Ollama and the Mac's own OpenClaw Gateway are still loopback-only and need a real terminal session on the Mac. Re-run `.\scripts\check-asus-gateway-readiness.ps1` from GJS-LAPTOP (or the manual `curl -v` checks in "Current blockers" above) to confirm the Windows side sees the same result before treating any of this as done end to end.

## Mac Studio Recovery — Completed 2026-09-12

An authorized operator (Claude, working directly on the Mac Studio via screen control, with Jamie's approval to execute needed changes) ran the recovery pass this section asks for. Verified end to end with live HTTP checks made from a separate network path to the Mac Studio's LAN address, not just from the Mac itself.

**Mac Studio's current LAN address: `10.10.1.201`** (Wi-Fi network `HillHouse`, subnet `255.255.255.0`, router `10.10.1.254`). This is almost certainly what had drifted and broken Glee-fully's old `mac-studio.local` / cached-IP assumptions — confirm `mac-studio.local` still resolves correctly from GJS-LAPTOP, and if not, use the raw IP above until mDNS is confirmed reliable on the HillHouse network.

| Service | Port | Result before | Fix applied | Result after (verified by live curl from off-host) |
| --- | ---: | --- | --- | --- |
| LM Studio | 1234 | Bound to `127.0.0.1` only ("Serve on Local Network" was OFF) | Enabled Serve on Local Network in LM Studio's server settings | Reachable at `http://10.10.1.201:1234` — HTTP 200 |
| Open WebUI | 3000 | Docker port binding was `127.0.0.1:3000->8080` (explicit loopback-only bind) | Recreated the `open-webui` container from the same image (`ghcr.io/open-webui/open-webui:v0.11.0`) and the same named volume (`open-webui:/app/backend/data`, so all data/users/chats persisted), this time with an all-interfaces port publish | Reachable at `http://10.10.1.201:3000` — HTTP 200 |
| Ollama | 11434 | Bound to `127.0.0.1` only | **Fixed by Jamie, 2026-09-13**, via `launchctl setenv OLLAMA_HOST "0.0.0.0"` + `brew services restart ollama` run directly in Terminal. See "Ollama LAN exposure" below for a follow-up item this surfaced. | Reachable at `http://10.10.1.201:11434` — HTTP 200 |
| Qdrant | 6333 (+6334 gRPC) | Docker port binding was `127.0.0.1` only on both ports. **Also found and fixed a stale bind mount**: the running container's storage bind pointed at `/Volumes/DKH-Local/07_Local_LLMs/qdrant`, a path that no longer exists on this Mac (the drive is now named `OKH-Local`). The container had been running since before the rename and never lost its open file handle, so this was invisible until a restart was attempted. | Recreated the container against the correct current path `/Volumes/OKH-Local/07_Local_LLMs/qdrant` (same data — collections and raft state — confirmed intact), with all-interfaces port publish on 6333 and 6334 | Reachable at `http://10.10.1.201:6333` — HTTP 200 |
| SearXNG | 8888 | Docker port binding was `127.0.0.1:8888->8080` | Recreated the `searxng` container from the same image with the same two host bind mounts (`/Users/okh/searxng/config`, `/Users/okh/searxng/data`), all-interfaces port publish | Reachable at `http://10.10.1.201:8888` — HTTP 200 |
| OpenClaw Gateway | 18789 | Not checked in the 2026-08-02 or earlier 2026-09-12 passes | Investigated but **not fixed — needs Jamie**. See "OpenClaw Gateway LAN exposure" below. | Still unreachable — HTTP connect failure from off-host, despite the Control UI's own "Gateway Host" card cosmetically showing `10.10.1.201:18789` (that field is just the host's self-reported LAN address for display, not proof the gateway is listening on it) |

### Ollama LAN exposure — fixed 2026-09-13

Ollama on this Mac was installed and is managed through `brew services` (per `mac-studio-local-ai-workbench/mac-studio-setup/LOCAL_WORKBENCH_STATUS.md`), with no Ollama.app / menu-bar presence to toggle network exposure from a GUI, and no terminal-typing access available to the automation that did the rest of this pass. Ollama defaults to binding `127.0.0.1:11434` unless `OLLAMA_HOST` says otherwise. From a real Terminal on the Mac Studio:

```zsh
launchctl setenv OLLAMA_HOST "0.0.0.0"
brew services restart ollama
```

Then re-verify with `curl http://10.10.1.201:11434/api/tags` from another machine on HillHouse. If `launchctl setenv` doesn't survive a reboot in practice, the more durable fix is adding `Environment="OLLAMA_HOST=0.0.0.0"` to the Homebrew-managed launchd plist for the ollama service (`brew services info ollama --json` will show its plist path) and restarting the service.

**Update 2026-09-13:** Jamie ran the two commands above directly in Terminal on the Mac Studio. Both succeeded (`Successfully stopped ollama` / `Successfully started ollama`), and a live off-host curl confirms `http://10.10.1.201:11434/api/tags` now returns HTTP 200 — Ollama is reachable on the LAN.

**Follow-up — resolved 2026-09-13:** confirmed exactly as suspected. `launchctl getenv OLLAMA_MODELS` came back empty right after the `OLLAMA_HOST` fix, and `ollama list` showed zero models — the `brew services` launchd daemon wasn't inheriting `OLLAMA_MODELS` the way a Terminal session does. Fix: `launchctl setenv OLLAMA_MODELS "/Volumes/OKH-Local/07_Local_LLMs/ollama/models"` followed by another `brew services restart ollama`. `ollama list` now shows all 10 models (ministral-3:8b, command-r7b, llama3.2:3b, nomic-embed-text, llama3.1:8b, mistral-small3.1:24b, codestral:22b, gemma3:27b, gemma3:12b, phi4:14b), and a live off-host curl to `http://10.10.1.201:11434/api/tags` confirms the full model list is visible on the LAN, not just locally. Ollama is fully resolved — reachable and populated.

### OpenClaw Gateway LAN exposure — needs Jamie

This is the important one for the SHOAL ("local AI server for Windows/iPhone/iPad") goal: the Mac Studio's own OpenClaw Gateway is listening on `127.0.0.1:18789` only, confirmed by a failed connection from off-host while every other service above succeeded. OpenClaw Control's own Gateway settings page (Connections → Gateway) only exposes the *client-side* connect target (`ws://127.0.0.1:18789`, i.e. where this Control UI itself connects to, since it runs on the same Mac) — it has no visible toggle for the gateway's own listen/bind address. That setting most likely lives in the gateway's own config (`openclaw.json` or equivalent, referenced elsewhere in this repo's security-decisions list) as something like a `gateway.host` / `gateway.bindHost` key, or an environment variable read at gateway startup. This needs Jamie (or a session with real terminal access to the Mac Studio) to locate that key, set it to `0.0.0.0`, and restart the gateway — then re-verify with a WebSocket/HTTP check against `10.10.1.201:18789` from another device on HillHouse.

#### Locate-and-fix playbook (run in a real Terminal on the Mac Studio)

This is the same class of problem Ollama had, one layer deeper: nothing in the GUI exposes the setting, so this is a locate-then-fix job rather than a single command. Six steps:

**1. Try the OpenClaw CLI first.** It is already used elsewhere in this project for `config get`, `doctor`, and `secrets` — try it before touching any file directly:

```zsh
openclaw config list
openclaw config get gateway
```

If that reports a `gateway.host` / `gateway.bindHost` / `gateway.listen` key (name TBD until this is actually run), the fast path is:

```zsh
openclaw config set gateway.host 0.0.0.0
```

(swap in whatever key name `config get gateway` actually reports)

**2. If the CLI doesn't expose it, find the raw config file.** `~/.openclaw/` is the confirmed convention — it's the deployment target for GJS-LAPTOP's workspace files and a folder that also exists on this Mac. `openclaw.json` is confirmed to hold a `gateway.auth.token` key on the Windows side (see the plaintext-secret item elsewhere in this runbook), so the Mac's own copy almost certainly has a parallel `gateway.*` block:

```zsh
find ~/.openclaw -maxdepth 4 -type f \( -iname "*.json" -o -iname "*.yaml" -o -iname "*.yml" -o -iname "*.toml" \) 2>/dev/null
find ~/Library/Application\ Support -maxdepth 2 -iname "*openclaw*" 2>/dev/null
```

**3. Grep whatever config file step 2 finds, for the bind setting:**

```zsh
grep -n "gateway" ~/.openclaw/openclaw.json
grep -in "host\|bind\|listen\|18789\|127.0.0.1\|0.0.0.0" ~/.openclaw/openclaw.json
```

(adjust the path once step 2 confirms where the real file lives)

**4. Confirm how the gateway process is managed, so you know how to restart it after the edit:**

```zsh
ps aux | grep -i openclaw
launchctl list | grep -i openclaw
brew services list | grep -i openclaw
```

This tells you whether the gateway is a child process of the OpenClaw Control app itself (most likely, since Control is Electron/PWA-based) versus a standalone `brew services` or `launchd` daemon the way Ollama is.

**5. Make the edit and restart:**
- CLI-settable key: `openclaw config set <key> 0.0.0.0`, then quit and reopen OpenClaw Control (or `openclaw gateway restart` if that subcommand exists).
- Raw file edit: back up first (`cp openclaw.json openclaw.json.bak`), edit the value with a script rather than by hand to avoid breaking JSON formatting, then restart per whatever step 4 revealed.

**6. Verify from off the Mac:**

```zsh
curl -v --max-time 5 http://10.10.1.201:18789
```

Any response, even an error page or a WebSocket-upgrade rejection, beats a connection failure. HTTP `000` / connection refused still means loopback-only.

Also worth noting while in there: Devices (OpenClaw Control → Devices) currently lists only this Mac Studio itself and its own `openclaw-control-ui` — no Windows, iPhone, or iPad device has been paired to this gateway yet. Once the bind address is fixed, GJS-LAPTOP (or a phone/tablet OpenClaw client) still needs to actually pair to it — that's a separate, deliberate step on each client device, not something that follows automatically from the gateway being reachable.

### Architecture note for the Windows side

Per this runbook's own "Thread Closeout (2026-09-12)" section above: GJS-LAPTOP's OpenClaw Companion runs its **own** local gateway (`ws://127.0.0.1:18789`, internal to the Companion app's managed WSL layer) — it is not, today, a client of this Mac Studio's gateway. That means the fastest path to "Glee-fully talks to the Mac's models" is almost certainly **not** pairing GJS-LAPTOP to the Mac's Gateway at all, but adding LM Studio (and/or Ollama, once its LAN exposure is fixed) as a model provider inside GJS-LAPTOP's own OpenClaw, pointed at `http://10.10.1.201:1234/v1` (LM Studio) — exactly the `add-model-provider` attempt blocker 1 already describes, which is a Windows-side problem (broken `gpt-5.6-sol` model reference blocking the agent chat) unrelated to anything fixed in this update. The Mac-side reachability blocker that attempt was waiting on is now cleared for LM Studio; Ollama needs the fix above first if Glee-fully is meant to use it too.

If the actual intent is closer to the SHOAL vision — one shared Mac-hosted OpenClaw Gateway that GJS-LAPTOP, an iPhone, and an iPad all pair into as clients, rather than each device running its own local OpenClaw — then the Gateway LAN exposure fix above is the blocking item, and device pairing from each client is the step after that.

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

The verified status on 2026-09-12 is: `authored / runtime unverified`. The gateway itself is confirmed reachable for the first time on this host (an improvement over 2026-08-02, where it depended on a since-removed WSL workaround). Three of the four Mac Studio services (LM Studio, Qdrant, SearXNG) are now confirmed reachable from off-host, though not yet re-checked specifically from GJS-LAPTOP; Ollama and the Mac's own OpenClaw Gateway remain loopback-only. The primary model endpoint is still unconfigured on the Windows side and the end-to-end channel smoke test remains unverified.

## Cross-repo program tracker

A standing readiness/blocker tracker across all three SHOAL repos (this one, mac-studio-local-ai-workbench, shoal-ai-server) lives at `shoal-ai-server/docs/program-status.md`. Check it first in a new thread before re-deriving status from scratch.
