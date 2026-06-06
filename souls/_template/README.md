# _template

Blank scaffold for creating new souls. Copy this directory, rename it, and fill in the workspace files.

## Quick Start

```bash
cp -r souls/_template souls/your-persona-name
cd souls/your-persona-name
# Edit workspace/SOUL.md, AGENTS.md, TOOLS.md
# Add source material to references/
# Build skills in skills/
```

## Directory Layout

```
workspace/          Deployable files. Copy to ~/.openclaw/workspace/
  SOUL.md           Who the persona is. ~300 words max.
  AGENTS.md         How the persona operates. Numbered procedures.
  TOOLS.md          What services the persona connects to.

references/         Full source material loaded on demand by skills.
                    Too heavy for bootstrap, too valuable to lose.

skills/             AgentSkill directories. Each skill gets a folder
                    with its own SKILL.md and supporting files.
```

## Constraints

- SOUL.md: ~300 words. Distilled essence only.
- AGENTS.md: Numbered workflows. No prose paragraphs.
- TOOLS.md: One section per connected service.
- Combined workspace files: under 1,500 words total.
- Leave 80%+ of model context window for conversation.
