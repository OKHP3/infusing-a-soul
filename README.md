# Infusing a Soul

**Local AI is generic until you feed it your thinking.**

This repo documents the architecture, corpus design, and build process behind giving local AI models distinct, persistent personalities that run on your own hardware, privately, permanently, subscription-free.

## What This Is

A crypt of AI souls built for [OpenClaw](https://openclaw.ai) agents, each with its own voice, operational rules, connected tools, and modular skills. Every soul is distilled from a real human corpus (writing samples, tone frameworks, cultural reference libraries) into the compact workspace files that OpenClaw reads at boot.

This is not prompt engineering. It is persona architecture.

## Souls

| Soul | Platform | Model | Voice | Status |
|------|----------|-------|-------|--------|
| **Glee-fully** | OpenClaw on GJS-LAPTOP (WSL2) | lfm2-24b via LM Studio | Warm, sassy, retro-PNW sparkle | Active |
| **Larry the Lobster** | OpenClaw on Mac Studio | TBD | Technical, ROY-principled, ForgeDialect | Planned |
| **AskJamie** | TBD | TBD | Helpdesk clarity, peer-level directness | Planned |

## Repo Structure

```
infusing-a-soul/
├── souls/                    # The crypt. One directory per persona.
│   ├── glee-fully/
│   │   ├── workspace/        # SOUL.md, AGENTS.md, TOOLS.md (deployable)
│   │   ├── references/       # Full vernacular, codex, inventory (loadable on demand)
│   │   └── skills/           # AgentSkill directories (SKILL.md per skill)
│   ├── larry-the-lobster/    # Mac Studio power-user persona
│   ├── askjamie/             # Helpdesk/conversational persona
│   └── _template/            # Blank scaffold for new souls
├── corpus/                   # Raw source material archive
│   ├── vernacular/           # Tone frameworks, Glee-isms, cultural DNA
│   ├── governance/           # Cathedral Codex, Canon, entity models
│   └── templates/            # FrankenTemplates, PromptChain, Pulsebooks
├── docs/                     # Build journal and methodology
└── article/                  # LinkedIn/blog content drafts
```

## The Method

1. **Corpus assembly.** Gather everything that defines the voice: writing samples, tone guides, cultural references, catchphrases, emotional calibration rules.
2. **Distillation.** Compress thousands of words of source material into a ~300-word SOUL.md that captures the essence without burning context window budget.
3. **Decomposition.** Separate persona (SOUL.md) from procedures (AGENTS.md) from infrastructure (TOOLS.md). OpenClaw's file separation enforces this discipline.
4. **Layered depth.** Full source material moves to `references/` for on-demand loading. Skills get their own directories. The soul boots lean and loads deep.
5. **Validation.** Test the voice in live conversation. Does it sound like them? Would someone who knows the source persona recognize the output?

## Hardware Stack

- **Mac Studio M4 Max** (36GB): LM Studio + Ollama host, Qdrant vector DB, SearXNG search
- **ASUS Vivobook Pro 15** (GJS-LAPTOP): OpenClaw gateway (WSL2/Ubuntu), Discord channel
- **Network**: Local LAN at 10.10.1.x, all inference stays on-premises

## Brand Context

This project lives under **OverKill Hill P3** (Precision, Protocol, Promptcraft). The souls serve the OKHP3 ecosystem:
- **Glee-fully** powers Glee-fully Personalizable Tools (named for and influenced by Glee Hill)
- **Larry the Lobster** is the technical operator persona (Council of AIs orchestrator)
- **AskJamie** is the public-facing conversational AI helpdesk

## License

Source corpus and persona files are proprietary to Jamie Hill / OverKill Hill P3.
Structural patterns, templates, and methodology documentation are shared for educational purposes.

---

*Built by Jamie Hill | [OverKill Hill P3](https://overkillhill.com) | [Glee-fully Tools](https://glee-fully.tools) | [AskJamie](https://askjamie.bot)*
