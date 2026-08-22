# ASUS Glee-fully Gateway Runbook

Last verified: 2026-08-02

This runbook records the verified operating path for Glee-fully on GJS-LAPTOP, the ASUS Windows system. It is an operational companion to the persona source files. It does not contain credentials or replace the external OpenClaw configuration in Ubuntu.

## Thread Closeout

This runbook was established during the 2026-08-02 ASUS gateway verification thread. The same thread produced a portable continuation record under `context/threads/`. Together, these artifacts separate confirmed local gateway behavior from the blocked Mac Studio dependency path and the owner-approved security work that remains.

## Confirmed host state

- GJS-LAPTOP has Ubuntu on WSL2, with `systemd=true` configured.
- The `okhp3` WSL user has `dbus-launch` available and user lingering enabled.
- OpenClaw `2026.6.1` is installed in Ubuntu.
- The `openclaw-gateway.service` is enabled and launches Glee-fully's configured gateway on loopback port `18789`.
- The gateway reaches its ready state and its Discord provider initializes as Glee-fully when WSL is running.
- The source persona files live in this repository. The active OpenClaw workspace is a separate external workspace under the `okhp3` user's OpenClaw state directory.

## Current blockers

1. The Windows Scheduled Task named `WSL Boot` is absent. On WSL `2.7.3`, Ubuntu shuts down about 15 to 20 seconds after its last client exits, including after an interactive health check. This stops the gateway even though the systemd service is enabled.
2. The Mac Studio LAN endpoints configured for LM Studio, Ollama, Qdrant, and SearXNG were unreachable from this ASUS during the 2026-08-02 check. Glee-fully cannot complete model-backed responses until the primary model endpoint is reachable.
3. OpenClaw's security audit reports a critical risk: the configured 24B model has browser and web tools enabled without a sandbox. Do not expose the bot beyond its trusted-owner boundary until the owner chooses and applies a safe tool policy.

## Readiness check

Run the PowerShell checker from the repository root:

```powershell
.\scripts\check-asus-gateway-readiness.ps1
```

It reports, without reading or printing secrets:

- WSL distribution registration and WSL boot-task presence.
- `systemd`, user lingering, `dbus-launch`, and the OpenClaw service state inside Ubuntu.
- Whether the gateway listener is active on WSL loopback port `18789`.
- TCP reachability from Windows to the four documented Mac Studio services.

The script exits nonzero when any required check fails. It is a readiness check, not a repair tool.

## Required persistence repair

The WSL prerequisites are already present. Create the missing Windows boot task from an elevated PowerShell session, using the interactive credentials prompt for the `jamie` Windows account:

```powershell
schtasks /create /tn "WSL Boot" /tr "wsl.exe -d Ubuntu --exec dbus-launch true" /sc onstart /ru "$env:USERNAME"
```

This is the documented workaround for the WSL 2.6.1+ idle-termination regression. It starts Ubuntu at Windows boot through the current Windows user so the WSL systemd user service can remain available. Do not configure it as `SYSTEM`, because the user-owned Ubuntu distribution is not visible to that account.

After the task is created, either restart Windows or run the task, then verify:

```powershell
schtasks /run /tn "WSL Boot"
.\scripts\check-asus-gateway-readiness.ps1
```

When the gateway is listening, the local Control UI is available only on the ASUS at `http://127.0.0.1:18789/`. It is intentionally loopback-bound.

## Required Mac Studio recovery

From the Mac Studio, an authorized operator must verify that the following documented services listen on the LAN address expected by Glee-fully and are permitted through the host firewall:

| Service | Port | Glee-fully role |
| --- | ---: | --- |
| LM Studio | 1234 | Primary model inference |
| Ollama | 11434 | Secondary persona model |
| Qdrant | 6333 | Semantic-memory store |
| SearXNG | 8888 | Current-information search |

Rerun the ASUS readiness check after the Mac Studio recovery. A successful model endpoint check is the minimum prerequisite for an end-to-end Discord smoke test.

## Security decisions before broadening access

The active configuration needs owner-approved remediation before the Discord bot serves anyone beyond its trusted owner:

1. Enable OpenClaw sandboxing for the 24B model, or deny browser and web tool groups for that model.
2. Disable `gateway.controlUi.allowInsecureAuth` unless there is a current, documented debugging need.
3. Restrict the OpenClaw state directory to the `okhp3` user.
4. Migrate plaintext tokens and provider keys from `openclaw.json` into OpenClaw's secret store.
5. Pin non-bundled plugin versions and set an explicit `plugins.allow` list.

These are intentional configuration decisions because they can alter model capabilities and deployment behavior. They are not applied by the readiness script.

## Status vocabulary

Use these labels consistently in future repository and Notion updates:

- `authored`: persona workspace artifacts are complete and versioned.
- `runtime unverified`: the deployment is documented but lacks a dated successful host and dependency check.
- `active`: the gateway, primary model endpoint, and authorized channel smoke test all passed on the same dated check.

The verified status on 2026-08-02 is: `authored / runtime unverified`.
