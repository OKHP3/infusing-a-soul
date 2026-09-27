# Night Shift scripts

Overnight task queue for the OpenClaw gateway managed by OpenClaw Windows Companion. Story and design: [docs/story/03-night-shift.md](../../docs/story/03-night-shift.md).

All scripts run as the `openclaw` user inside the `OpenClawGateway` WSL distro. The Companion's distro does not mount the Windows drive, so the PowerShell helpers pipe each script in over stdin (stripping Windows line endings) instead of calling it by path.

## Files

| File | Runs where | Purpose |
|---|---|---|
| `night-shift.ps1` | Windows PowerShell 7 | Helper commands: `ns-add`, `ns-queue`, `ns-run`, `ns-status`, `ns-brief`, `ns-read`, `ns-setup`, `ns-diag`, `ns-fix`, `ns-tailnet`, `ns-gpu`, `ns-gpu-tune` |
| `night-shift-setup.sh` | Gateway distro | Idempotent install: queue folders, `NIGHT-SHIFT.md` procedure, 1:00 AM Central cron job |
| `fix-harden.sh` | Gateway distro | Points fallback and utility model at Granite 4.1 3B, sets exec policy to allowlist, limits the job to read/write/edit |
| `diag-tools.sh` | Gateway distro | Read-only check that the laptop model makes tool calls, plus current tool and agent policy |
| `run-now.sh` | Gateway distro | Triggers the night-shift job immediately |
| `status.sh` | Gateway distro | Recent runs, gateway clock, newest results folders |
| `brief.sh` | Gateway distro | Morning brief for a date or the newest results |
| `tailnet-routing.sh` | Gateway distro | `ns-tailnet`: Mac primary over Tailscale (`100.87.4.93`), Granite fallback and utility on the laptop GPU, backup first, stops if the tailnet is unreachable |
| `gpu-check.sh` | Gateway distro | `ns-gpu`: read-only GPU, Ollama settings, and `ollama ps` check |
| `gpu-tune.sh` | Gateway distro (root) | `ns-gpu-tune`: raises the laptop context and keep-alive, then re-runs `ns-tailnet` with the matching window |

## Install

```powershell
if (!(Test-Path $PROFILE)) { New-Item -ItemType File -Path $PROFILE -Force | Out-Null }
Add-Content -Path $PROFILE -Value '. "$env:USERPROFILE\OKH-Local\04_GitHub_Mirrors\infusing-a-soul\scripts\night-shift\night-shift.ps1"'
. $PROFILE
ns-setup
```

## Notes

- `ns-add` reads the raw typed line, so commas survive. Wrap tasks containing `( ) $ @ ; &` in single quotes.
- Scheduled runs need a shell policy other than `ask`; under `ask`, OpenClaw blocks all tools in scheduled sessions (openclaw/openclaw#138853).
- The laptop must be awake and plugged in at 1:00 AM while the gateway lives on the laptop.
