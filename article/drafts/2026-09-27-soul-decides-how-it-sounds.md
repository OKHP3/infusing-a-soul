---
title: "The Soul Decides How It Sounds"
project: infusing-a-soul
brand: OverKill Hill P3
status: draft
rag_eligible: false
last_updated: 2026-09-27
surface: LinkedIn article
pipeline_record: 2026-09-27-soul-vs-skills-pipeline-run.md
---

# The Soul Decides How It Sounds

I'm writing souls for four local AI agents.

None of those files is where the capability lives.

A soul file (`SOUL.md`, in OpenClaw) holds identity: voice, tone, what the agent cares about, what it refuses. It's the part people fall in love with. It's also the part people keep rewriting when the agent can't do the job.

That's the wrong wrench. I've swung it plenty.

A 2024 study tested 162 personas across four model families on 2,410 factual questions. Adding a persona to the system prompt didn't improve performance compared with no persona at all. The best persona for a given question sometimes helped, but picking it in advance was often no better than random.

That study measured factual questions, not agent work. It's still the cleanest evidence I know of that identity isn't capability.

"You are a world-class architect" is a costume. Not a résumé.

So what does the work?

**Skills.** An Agent Skill is a folder with a `SKILL.md` file: a name, a description, and the procedure. Agents load the name and description up front and pull the full instructions only when a task calls for them. That's where method lives.

**Tools.** What the agent can actually touch. A rule in a soul file is a request. A tool policy is a control.

**The model.** The hard ceiling. I retired a model on one of my agents after it fabricated tool results. The soul was fine. The brain wasn't.

The runtimes already know this. OpenClaw runs multiple isolated agents in one gateway, each with its own workspace and soul, and each can carry its own skill allowlist. The layers are separate on purpose.

So souls still matter. Just not for capability.

A soul sets judgment defaults: when to ask, when to act, how much risk to tolerate, how to deliver bad news. It decides whether the people using the agent come back. That's adoption, and adoption isn't fluff.

Here's the split I'm building toward:

Soul: who it is and how it sounds.

Skills: how it does the job.

Tools: what it's allowed to touch.

Model: whether it can pull it off.

Fix the layer that's actually broken.

The soul decides how it sounds. Everything else decides whether it works.

---

## Companion short post (to share the article)

I'm writing souls for four local AI agents.

None of those files is where the capability lives.

Persona prompts shape voice and judgment. Skills, tools, and the model decide capability. A 2024 study of 162 personas found adding one to the system prompt didn't improve factual accuracy.

I wrote up the four-layer split I'm building toward, and why I stopped rewriting souls to fix capability problems.

The soul decides how it sounds. Everything else decides whether it works.

---

## Sources (for the article footer or first comment)

- Zheng, Pei, Logeswaran, Lee, Jurgens. "When 'A Helpful Assistant' Is Not Really Helpful: Personas in System Prompts Do Not Improve Performances of Large Language Models." Findings of EMNLP 2024. https://aclanthology.org/2024.findings-emnlp.888/
- Agent Skills overview. https://agentskills.io/home
- OpenClaw multi-agent routing. https://docs.openclaw.ai/concepts/multi-agent
- OpenClaw skills. https://docs.openclaw.ai/tools/skills
