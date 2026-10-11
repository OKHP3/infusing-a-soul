#!/usr/bin/env python3
"""Generate per-host OpenClaw agent skill allowlists from persona-packs.json.

Standard library only. Read-only against the skillz checkout. Writes JSON
fragments and a plan file under generated/. It never edits a live
openclaw.json; applying the result is a separate, owner-run step.

Usage:
  python3 build_allowlists.py --skillz ../../../skillz
  python3 build_allowlists.py --skillz ../../../skillz --check
"""
import argparse
import json
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
SKIP = {"node_modules", ".git", ".agents", "docs", "artifacts", "archive"}


def index_skillz(root: Path) -> dict:
    """Map skill name -> family directory for every root-family SKILL.md."""
    found = {}
    for family in sorted(p for p in root.iterdir() if p.is_dir()):
        if family.name in SKIP or family.name.startswith(".") or not (family / "FAMILY.md").exists():
            continue
        for pkg in sorted(p for p in family.iterdir() if p.is_dir()):
            if (pkg / "SKILL.md").exists():
                found[pkg.name] = family.name
    return found


def resolve(persona: str, cfg: dict) -> list:
    skills = []
    for pack in cfg["personas"][persona]["packs"]:
        for name in cfg["packs"][pack]["skills"]:
            if name not in skills:
                skills.append(name)
    return skills


def build(cfg: dict, index: dict):
    problems, fragments, plan = [], {}, []
    for host, hcfg in cfg["hosts"].items():
        entries, families_needed = {}, set()
        plan.append(f"## {host}\n\n{hcfg['description']}\n")
        plan.append("| Persona | Agent id | Role | Workspace | Skills | Binding |")
        plan.append("|---|---|---|---|---|---|")
        for persona, a in hcfg["agents"].items():
            skills = resolve(persona, cfg)
            for name in skills:
                if name not in index:
                    problems.append(f"{host}/{persona}: skill '{name}' not found in skillz")
                else:
                    families_needed.add(index[name])
            entries[a["agent_id"]] = {"workspace": a["workspace"], "skills": skills}
            binding = "bind channel account" if a["role"] == "home" else "none (standby)"
            plan.append(f"| {persona} | `{a['agent_id']}` | {a['role']} | `{a['workspace']}` | {len(skills)} | {binding} |")
        fragments[host] = {"agents": {"entries": entries}}
        plan.append("\nSkillz family folders this host must expose to its agents: "
                    + ", ".join(f"`{f}/`" for f in sorted(families_needed)) + "\n")
    baseline = cfg["packs"].get("baseline", {}).get("skills", [])
    if not baseline:
        plan.insert(0, "> **Baseline pack is empty.** Per-agent lists replace defaults. Fill `packs.baseline.skills` "
                       "from `openclaw skills list --agent <id>` on each host before applying, or currently used "
                       "skills will stop loading.\n")
    for persona, why in cfg.get("pending", {}).items():
        plan.append(f"**Pending:** `{persona}`: {why}\n")
    return problems, fragments, plan


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--skillz", required=True, help="Path to a local skillz checkout")
    ap.add_argument("--check", action="store_true", help="Validate and compare without writing")
    args = ap.parse_args()

    cfg = json.loads((HERE / "persona-packs.json").read_text(encoding="utf-8"))
    index = index_skillz(Path(args.skillz).resolve())
    problems, fragments, plan = build(cfg, index)
    for p in problems:
        print(f"ERROR {p}", file=sys.stderr)
    if problems:
        return 1

    out = HERE / "generated"
    rendered = {f"{h}.agents.json": json.dumps(frag, indent=2) + "\n" for h, frag in fragments.items()}
    rendered["PLAN.md"] = "# Generated OpenClaw allowlist plan\n\nDo not hand-edit. Regenerate with `build_allowlists.py`.\n\n" + "\n".join(plan).rstrip() + "\n"
    if args.check:
        stale = [n for n, body in rendered.items() if not (out / n).exists() or (out / n).read_text(encoding="utf-8") != body]
        if stale:
            print("Stale generated files: " + ", ".join(stale))
            return 1
        print(f"Check passed. {len(index)} skillz skills indexed; all persona skills resolved.")
        return 0
    out.mkdir(exist_ok=True)
    for name, body in rendered.items():
        (out / name).write_text(body, encoding="utf-8")
        print(f"Wrote generated/{name}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
