# Generated OpenClaw allowlist plan

Do not hand-edit. Regenerate with `build_allowlists.py`.

> **Baseline pack is empty.** Per-agent lists replace defaults. Fill `packs.baseline.skills` from `openclaw skills list --agent <id>` on each host before applying, or currently used skills will stop loading.

## mac-studio

Mac Studio M4 Max, native macOS OpenClaw.

| Persona | Agent id | Role | Workspace | Skills | Binding |
|---|---|---|---|---|---|
| larry | `main` | home | `~/.openclaw/workspace` | 11 | bind channel account |
| murderbird | `murderbird` | home | `~/.openclaw/workspace-murderbird` | 8 | bind channel account |
| glee-fully | `glee-fully` | standby | `~/.openclaw/workspace-glee-fully` | 3 | none (standby) |

Skillz family folders this host must expose to its agents: `context-extraction/`, `glee-fully/`, `knowledge-operations/`, `murderbird/`, `openclaw/`, `social-posting/`

## gjs-laptop

ASUS Vivobook, OpenClaw Windows Companion with a managed WSL gateway.

| Persona | Agent id | Role | Workspace | Skills | Binding |
|---|---|---|---|---|---|
| glee-fully | `main` | home | `~/.openclaw/workspace` | 3 | bind channel account |
| larry | `larry` | standby | `~/.openclaw/workspace-larry` | 11 | none (standby) |
| murderbird | `murderbird` | standby | `~/.openclaw/workspace-murderbird` | 8 | none (standby) |

Skillz family folders this host must expose to its agents: `context-extraction/`, `glee-fully/`, `knowledge-operations/`, `murderbird/`, `openclaw/`, `social-posting/`

**Pending:** `askjamie`: Home host undecided. It sees private mail, so it needs an owner-only host and a draft-only mail tool policy before any entry is generated.
