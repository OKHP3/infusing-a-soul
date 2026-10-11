# OpenClaw persona allowlists

Skill allowlists for the four OpenClaw personas, generated from one pack
manifest. Soul files set voice. These lists set capability.

**Status: generated, not applied.** Nothing here has been written to a live
`openclaw.json`. Applying it is an owner-run step on each host.

## Files

| File | Role |
|---|---|
| `persona-packs.json` | Source of truth: packs, persona-to-pack mapping, and per-host agent placement |
| `build_allowlists.py` | Standard-library generator. Validates every skill name against a local skillz checkout |
| `generated/<host>.agents.json` | `agents.entries` fragment per host. Do not hand-edit |
| `generated/PLAN.md` | Human-readable placement table and the skillz families each host must expose |

```bash
python3 build_allowlists.py --skillz ../../../skillz          # regenerate
python3 build_allowlists.py --skillz ../../../skillz --check  # verify generated files are current
```

## Why a generator

OpenClaw per-agent skill lists (`agents.entries.<id>.skills`) replace
`agents.defaults.skills`. They do not merge. Hand-maintained lists drift and
silently drop skills. Packs keep each persona's list complete and reviewable.

## Placement

Each persona has one home host with a live channel binding. The other host
may define the agent as a warm standby with no binding. Moving a binding is
the failover. See `generated/PLAN.md` for the current table.

AskJamie is pending. It sees private mail, so it gets no entry until an
owner-only home host and a draft-only mail policy are decided.

## Apply procedure (per host)

1. Snapshot first: `openclaw config get agents` and back up `openclaw.json`.
   Trust the CLI over any config editor.
2. Fill `packs.baseline.skills` from `openclaw skills list --agent <id>` for
   agents that already run (Larry on the Mac, Glee-fully on the laptop).
   Regenerate. Skipping this drops skills the agent uses today.
3. For a new agent: `openclaw agents add <id> --workspace <path>`, then copy
   that persona's `souls/<persona>/workspace/` files into the new workspace.
   Leave `agentDir` at its per-agent default; never share one between agents.
4. Expose the skillz families listed in `PLAN.md` to each workspace
   (symlinks under `<workspace>/skills`, allowed by
   `skills.load.allowSymlinkTargets`, matching Larry's existing pattern).
5. Merge the fragment's `skills` arrays into `agents.entries.<id>.skills`.
   Merge, don't replace other keys. Confirm exact `openclaw config set`
   syntax with `--help` before running it.
6. Verify: `openclaw skills check --agent <id>` for each agent, then one
   manual `/skill <name>` run per new skill.
7. Bind home agents only. One live binding per persona.

## Tool policy intents (not generated)

Allowlists control which skills load. They don't restrict tools. These
limits must be enforced in OpenClaw tool policy once its per-agent schema is
confirmed on each host:

| Persona | Must not have |
|---|---|
| AskJamie | Mail send, schedule, forward, delete, move, or rule changes |
| MurderBird | Any posting, publishing, email, or social API |
| Glee-fully (WWGD) | Write or exec tools during reception checks |
| All | Access to employer systems or data |

A rule written only in `SOUL.md` or `AGENTS.md` is a request, not a control.
