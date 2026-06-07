# Methodology: Infusing a Soul

## The Problem

Local AI models ship with no identity. They respond to everything the same way: generic, cautious, personality-free. The result is technically competent but emotionally flat. Users who have spent months building custom GPTs, fine-tuned prompts, or brand voices face a cold restart when they move to local inference.

## The Approach

Soul infusion is a three-layer compression pipeline:

### Layer 1: Corpus Collection
Gather everything that defines the persona: tone guides, vernacular documents, governance frameworks, sample interactions, cultural references, and behavioral rules. For Glee-fully, this was ~20,000+ words across three primary documents built over months of Custom GPT development on ChatGPT.

### Layer 2: Distillation
Compress the corpus into three files that fit inside a local model's system prompt budget. The target is under 1,500 words combined. This is not summarization. It is architectural compression: extracting the load-bearing walls and discarding the drywall.

### Layer 3: Deployment
Place the distilled files in OpenClaw's workspace directory. The agent reads them at boot and carries the persona into every session. Full source documents live in a `references/` directory, loadable on demand through the skill system.

## Key Constraint

The model's context window is the ceiling. A 24B parameter model running on consumer hardware typically has 32K-128K tokens of context. The system prompt (all workspace files combined) should consume no more than 20% of that budget. Every word in SOUL.md is a word the user can't use for their own conversation.

## Flywheel

The more the agent is used, the more session data flows into Qdrant (vector search), creating a semantic memory layer that supplements the static soul files. The soul defines who the agent is. Memory teaches it what it has learned.
