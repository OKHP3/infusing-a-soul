# Larry the Lobster: Franchise-Wide Personality Research Prompt

## Purpose

This prompt is designed to be run against any frontier AI model (Claude, ChatGPT, Gemini, etc.) to produce a comprehensive personality research document for Larry the Lobster from the SpongeBob SquarePants franchise. The output will be used as source corpus to author SOUL.md, AGENTS.md, and supporting skill files for a local AI agent persona built on OpenClaw.

## The Prompt

---

You are conducting a comprehensive character study of **Larry the Lobster** from the SpongeBob SquarePants franchise. Your research must span every canonical source: the original Nickelodeon series (all 14 seasons through 2025), The SpongeBob SquarePants Movie (2004), The SpongeBob Movie: Sponge Out of Water (2015), The SpongeBob Movie: Sponge on the Run (2020), the spinoff series The Patrick Star Show (2021-2024), Kamp Koral: SpongeBob's Under Years (2021-2024), and any Nickelodeon shorts, specials, or crossover appearances.

Produce a structured research document covering the following sections. Be exhaustive. Cite specific episodes or films where possible. Do not generalize when specifics exist.

### Section 1: Core Identity
- Full character description: species, physical appearance, trademark visual details
- Where he lives and hangs out (Goo Lagoon, the gym, Bikini Bottom landmarks)
- His role in the social ecosystem of Bikini Bottom (is he central cast, recurring, background?)
- How his screen time and role evolved across the series run

### Section 2: Personality Profile
- Dominant personality traits with specific episode evidence
- His relationship to fitness, body image, and physical culture
- Confidence level: is he genuinely confident, performatively confident, or insecure underneath?
- How he handles failure, embarrassment, or being wrong
- His emotional range: what makes him happy, sad, angry, nervous, proud?
- Moments where he breaks character or shows unexpected depth

### Section 3: Relationships
- Larry and SpongeBob (dynamic, key interactions, how they regard each other)
- Larry and Sandy Cheeks (athletic rivalry? mutual respect? tension?)
- Larry and Patrick Star (how do they interact?)
- Larry and Squidward (any notable dynamics?)
- Larry and other recurring characters (lifeguard colleagues, gym buddies)
- Romantic interests or dating behavior (any episodes?)
- His social status in Bikini Bottom (popular? respected? tolerated?)

### Section 4: Speech Patterns and Voice
- How Larry talks: vocabulary level, slang, catchphrases
- Verbal tics, filler words, or recurring expressions
- Does he use fitness/gym metaphors in non-fitness contexts?
- Tone: bro-speak? motivational coach? laid-back surfer? How would you categorize his register?
- Examples of memorable Larry dialogue (paraphrased if needed, with episode context)

### Section 5: Values and Worldview
- What does Larry care about most? What motivates him?
- His attitude toward competition, winning, and losing
- Does he have a moral compass? When has he done the right thing vs. the selfish thing?
- His relationship to authority, rules, and social norms
- Does he value intelligence? Art? Culture? Or is he purely physical?

### Section 6: Behavioral Patterns
- How does Larry enter a scene? (Does he announce himself? Is he already there?)
- His body language and physical comedy patterns
- Recurring gags or running jokes associated with him
- Situations where Larry is the focus vs. where he is a supporting presence
- His default activity when not plot-relevant (what is Larry doing in the background?)

### Section 7: Character Arc and Evolution
- How did the writers use Larry differently in early seasons vs. later seasons?
- Did his personality flatten, deepen, or shift over 14 seasons?
- His treatment in the movies vs. the series
- His portrayal in Kamp Koral and The Patrick Star Show (younger/alternate versions)
- Any episodes that serve as definitive "Larry episodes" (where he is the primary focus or co-lead)

### Section 8: Cultural Resonance
- Larry as a "gym bro" archetype: how does the show use or subvert this trope?
- Fan reception and meme culture around Larry
- How does Larry compare to similar characters in other animated shows?
- What makes Larry distinct from a generic "buff character" stereotype?

### Section 9: Gaps and Contradictions
- Personality inconsistencies across episodes (different writers, different Larry)
- Things the show never explored about Larry that the character setup implies
- Moments where Larry seems out of character and why

### Section 10: Synthesis for AI Persona Design
Based on all of the above, produce:
1. A 150-word "elevator pitch" for Larry's personality (as if briefing a voice actor)
2. Five canonical Larry-isms (signature phrases or verbal patterns)
3. Three tone modes: his default register, his "pumped up" mode, and his rare vulnerable/serious mode
4. Five things Larry would never say or do (behavioral boundaries)
5. Three pop culture or real-world analogues that capture his energy (e.g., "Terry Crews meets..." or "If [X] were a lobster...")

---

## Usage Notes

- Run this prompt in a session with web search enabled for maximum episode coverage.
- If the model's training data is thin on later seasons (12-14) or the spinoffs, note the gaps explicitly rather than fabricating.
- Save the full output as `larry-research-corpus.md` and place it in `souls/larry-the-lobster/references/` in the infusing-a-soul repo.
- The Section 10 synthesis will serve as the primary input for drafting Larry's SOUL.md.

---

*Part of the [Infusing a Soul](https://github.com/OKHP3/infusing-a-soul) project.*
*© 2026 OverKill Hill P3. All rights reserved.*
