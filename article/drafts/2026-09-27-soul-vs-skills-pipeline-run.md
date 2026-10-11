---
title: "Pipeline Run: Soul vs Skills Article"
project: infusing-a-soul
brand: OverKill Hill P3
status: record
rag_eligible: false
last_updated: 2026-09-27
---

# Pipeline Run: Soul vs Skills Article

First end-to-end test of the persona article pipeline, run on 2026-09-27.

**Evidence class: analytical dry run.** The skill contracts were executed in a
Claude Cowork session, not by the OpenClaw agents. Nothing here proves how
Larry, MurderBird, or Glee-fully perform on their own models. Every search and
fetch below was real.

**Idea (owner-stated):** souls provide tone and style; capability comes from
skills, tools, and plugins.

**Output:** [`2026-09-27-soul-decides-how-it-sounds.md`](2026-09-27-soul-decides-how-it-sounds.md)

## Stage 0: `okhp3-openclaw-persona-route` (Larry)

- No persona named. Classified as long-form argument, starting from nothing.
- First stage owner: Larry (research). Pipeline: Larry, MurderBird, voice pass, Glee-fully, owner.
- Delivery: no agent-to-agent tool in this environment, so the packet was carried forward in-session. Reported, not claimed as delivered.

```text
[HANDOFF]
to: larry
from: larry (router)
task: Build a research packet for a LinkedIn article arguing that agent souls set tone while skills, tools, and models set capability.
context: owner idea from 2026-09-27 session; OpenClaw multi-agent lab with four personas
result-so-far: none
open-questions: none
return-to: murderbird
```

## Stage 1: `okhp3-openclaw-research-packet` (Larry)

Searches: 2 distinct queries (persona-prompt performance research; Agent Skills specification). Fetched: 4 pages.

```text
[RESEARCH PACKET]
question: Does evidence support separating agent identity (soul) from capability (skills, tools, model)?
retrieved: 2026-09-27
findings:
  - claim: Across 162 personas, 4 LLM families, and 2,410 factual questions, adding a persona to the system prompt did not improve performance versus no persona; per-question best personas helped but automatic selection was often no better than random.
    tier: confirmed
    source: https://aclanthology.org/2024.findings-emnlp.888/
  - claim: An Agent Skill is a folder with SKILL.md (name, description, instructions); agents load name and description at startup and full instructions on activation (progressive disclosure). Originally developed by Anthropic, released as an open standard.
    tier: confirmed
    source: https://agentskills.io/home
  - claim: OpenClaw runs multiple isolated agents in one gateway, each with its own workspace (AGENTS.md, SOUL.md, USER.md), state directory, and sessions; bindings route channel accounts to agents.
    tier: confirmed
    source: https://docs.openclaw.ai/concepts/multi-agent
  - claim: OpenClaw per-agent skill allowlists replace defaults rather than merging.
    tier: confirmed
    source: https://docs.openclaw.ai/concepts/multi-agent ; https://docs.openclaw.ai/tools/skills
  - claim: The owner retired a model on the Glee-fully agent after it fabricated tool results.
    tier: confirmed (owner lab record, not public)
    source: infusing-a-soul/souls/glee-fully/README.md
conflicts:
  - none found
gaps:
  - [VERIFY: peer-reviewed evidence on persona prompts in agentic or tool-use tasks; the cited study covers factual questions only]
suggested-next: okhp3-murderbird-thesis-forge
```

**Finding for the skill:** the packet format had no field for a finding's
scope. The factual-questions-only limit surfaced as a gap, but a downstream
writer could still miss it. The contract was amended (v0.1.1) to add
`applies-to` per finding.

## Stage 2: `okhp3-murderbird-thesis-forge` (MurderBird)

1. **Thesis:** An agent's soul decides how it sounds; its skills, tools, and model decide what it can do, so stop tuning personas to fix capability problems.
2. **Why it matters:** people burn hours rewriting role prompts when the fix is a skill, a tool policy, or a model swap.
3. **Load-bearing claims:**

   | # | Claim | Evidence | Tier |
   |---|---|---|---|
   | 1 | Persona prompts don't reliably improve task accuracy | Zheng et al. 2024 | confirmed (factual QA); inferred for agent work |
   | 2 | Skills carry method and load on demand | agentskills.io | confirmed |
   | 3 | The model is a hard ceiling no soul can raise | Owner's retired model | confirmed (one case) |
   | 4 | Runtimes already separate the layers | OpenClaw docs | confirmed |
   | 5 | Souls still matter for judgment and adoption | Owner doctrine | proposal |

4. **Counterargument:** "Role prompts clearly change output." Response: concede. They change voice and style, which is exactly the soul's job. Tone isn't capability.
5. **Outline:** hook; the persona myth (1); what does the work (2, 4); the ceiling (3); what souls are for (5 + counter); the split; close.
6. **Hooks:** Concrete: "I'm writing souls for four local AI agents." Claim: "A persona prompt is a costume, not a résumé." Turn: "The fastest way to make an agent better at a job is to stop telling it who it is."
7. **Ending:** "The soul decides how it sounds. Everything else decides whether it works."
8. **Evidence gaps:** [VERIFY: agentic-task persona research]
9. `[HANDOFF] [thesis skeleton for soul-vs-skills article] [skeleton complete] [draft needed; agentic evidence gap open]`

## Stage 3: Draft

Written from the skeleton (drafting sits outside the MurderBird skills by design).

## Stage 4: `okhp3-murderbird-argument-audit` (MurderBird, Sentinel mode)

1. **Verdict:** `HOLDS WITH REPAIRS`. The argument is sound; one claim outruns its evidence.
2. **Thesis:** clear, one sentence, disagreeable.
3. **Load-bearing claims (top 5):**

   | Claim | Tier | Risk if false | Fix |
   |---|---|---|---|
   | Hook: "Not one of those files will make an agent smarter" | inferred | Overclaim; souls shape judgment, which can change outcomes | Reword to "None of those files is where the capability lives" |
   | Persona study result | confirmed | Low | Keep the "factual questions" qualifier |
   | "Picking it in advance performed about as well as random" | confirmed, paraphrased too strongly | Misquote | Use "often no better than random" |
   | Study generalizes to agents | inferred | Readers who know the paper call it out | Add one line naming the study's scope |
   | "A tool policy is a control" | proposal | Low, framed as opinion | Keep |

4. **What breaks first:** the jump from a factual-QA study to agent work.
5. **Damage or history:** keep "That's the wrong wrench.", "a costume. Not a résumé.", and the four standalone split lines. They carry voice. Keep "building toward": it's honest about pending work.
6. **Hook and ending:** strongest opening is the concrete one. Ending lands hard on the thesis with no question.
7. **Salvage list:** the four-layer split, the retired-model anecdote, the ending line.

All four repairs applied.

## Stage 5: `okhp3-murderbird-hook-and-close` (companion short post)

Point: souls set voice; skills, tools, and the model set capability.

| Option | Type | Honest | Specific | Tension | Lands | Fit | Total |
|---|---|---|---|---|---|---|---|
| "I'm writing souls for four local AI agents." | Concrete | 5 | 5 | 4 | 4 | 5 | 23 |
| "A persona prompt is a costume, not a résumé." | Claim | 4 | 3 | 4 | 5 | 5 | 21 |
| "Stop telling your agent who it is." | Turn | 3 | 2 | 5 | 3 | 5 | 18 |
| Close: "The soul decides how it sounds. Everything else decides whether it works." | Callback | 5 | 5 | 4 | 5 | 5 | 24 |
| Close: "Fix the layer that's actually broken." | Verdict | 5 | 3 | 3 | 4 | 5 | 20 |
| Close: "Costume. Not capability." | Standalone | 4 | 3 | 4 | 4 | 5 | 20 |

**Pick:** concrete hook (true, specific, survives truncation); callback close (lands exactly on the point). The "Turn" hook was discarded because the post doesn't support "stop" as advice.

## Stage 6: `okhp3-linkedin-voice` (final filter)

Change log:

- Em dashes: none found.
- Contractions: "isn't" for "is not" in the adoption line.
- Paragraphing: double line breaks confirmed for LinkedIn rendering; the four split lines kept as separate paragraphs.
- Closing line: hard, no engagement question.
- Facts: no new facts, links, or hashtags added. Study scope qualifier preserved.
- Judgment call: kept the one-word bold labels (Skills, Tools, The model) as scannable anchors.

## Stage 7: `okhp3-glee-fully-wwgd-review`

Persona lens only; not any real person's view.

| Dimension | Score | Line |
|---|---|---|
| Warmth | 3 then 4 | "That's the wrong wrench." read as scolding readers; fixed with "I've swung it plenty." |
| Kindness | 4 | "costume" targets a prompt habit, not people |
| Clarity | 5 | The four-line split |
| Joy | 4 | "The soul was fine. The brain wasn't." |
| Author-true | 5 | Standalone rhythm, dry wit, hard close |

**Verdict:** `SEND WITH TWEAKS` (tweak applied). Gut check: it's sharp without being smug once it admits you've made the same mistake.

## Skill findings from this run

| Skill | Result | Change |
|---|---|---|
| persona-route | Routed correctly; honest about delivery | none |
| research-packet | Surfaced the scope gap, but not per finding | Added `applies-to` field (v0.1.1) |
| thesis-forge | Skeleton usable as written | none |
| argument-audit | Caught the overclaim and the paraphrase drift | none |
| hook-and-close | Scores discriminated; discarded an unsupported hook | none |
| wwgd-review | Found a warmth dip the audit didn't | none |
| linkedin-voice | Clean pass; one contraction | none |

`okhp3-askjamie-email-draft` was not exercised; the article pipeline doesn't use it.
