---
title: "Project Page Brief: Infusing a Soul"
artifact_type: "page_brief"
created_date: "2026-09-24"
updated_date: "2026-09-24"
project: "Infusing a Soul"
target_site: "overkillhill.com"
target_route: "/projects/infusing-a-soul/"
target_repo: "OKHP3/overkill-hill"
---

# Project Page Brief: Infusing a Soul

Hand this brief, plus docs 00 through 05 in this folder, to whoever builds the page in the overkill-hill repo. It follows the pattern of the existing Mac Studio Local AI Workbench page.

## Identity

| Field | Value |
|---|---|
| Title | Infusing a Soul |
| Route | `/projects/infusing-a-soul/` |
| Tagline | Local AI is generic until you feed it your thinking. |
| One-line description (meta and OG) | A dated build journal for giving a local OpenClaw agent a real voice, honest tools, and an overnight job, running entirely on home hardware. |
| Page type | Build journal (detail page) |
| Brand scope | OKH, with a Glee-fully accent block for the persona section |
| Related pages | Mac Studio Local AI Workbench; Glee-fully tools |

## Section outline

| # | Section | Source | Notes |
|---|---|---|---|
| 1 | Hero | 00 Thesis | Tagline plus two standalone lines: "It is not prompt engineering." / "It is persona architecture." |
| 2 | About this build journal | 00, 05 | Dated boundary statement: what is live, what is configured, what is pending, as of 2026-09-24 |
| 3 | Why it matters | 00 | The stranger problem. Five-bullet list |
| 4 | Status board | 05 | Table with Live / Configured / Pending / Not started |
| 5 | Timeline | 01 | Table plus the 9/23 outage story told in short beats |
| 6 | Meet Glee-fully | souls/glee-fully/README.md, SOUL.md | Voice and personality only. No infrastructure details. Mark "voice not yet loaded in the live agent" |
| 7 | Model honesty | 02 | Centerpiece. The test, the results table, the lesson: tool cards are truth, model prose is a claim |
| 8 | The Night Shift | 03 | How it works, the ns-* command table, the guardrail table, first-run results |
| 9 | How it's built | 04 | Mermaid topology diagram (use mermaid-init.js), model routing table, policy table |
| 10 | Key decisions | 01, 02, 04 | Mac serves, laptop visits. Config over installs. Evidence over assurance. Narrow tools for unattended work |
| 11 | What's next | 05 | Ordered list, framed as planned, not promised |

## Claims boundary

Allowed, because they are verified and dated:

- Night Shift smoke test passed on 2026-09-24 (83 seconds, file written, queue updated, brief written)
- The honesty test results in doc 02, labeled as one day on one setup, not a benchmark
- The outage root cause and fix
- The model roles in doc 04

Not allowed:

- Any claim that Glee-fully's voice is live in the agent
- Any claim that automatic failover to the laptop has been exercised
- Any claim that semantic memory recall works end to end
- Performance numbers beyond the single 83-second run
- Anything about Discord, web search, or the gateway moving to the Mac beyond "planned"

## Redaction rules (public page)

Do not publish: LAN addresses or hostnames, ports, gateway or device tokens, job or session IDs, Discord server or user IDs, Notion URLs, file paths under a user profile, or any employer reference. Model names, vendor names, and hardware models are fine.

## Style

- No em dashes. US English.
- Short paragraphs. Punchy standalone lines kept as their own paragraphs.
- Tables for comparisons.
- Ends hard on its last line. No reader question appended.

## overkill-hill implementation checklist

- [ ] `site-src/pages/projects/infusing-a-soul/index.main.html` (content) and `index.extras.html` (scripts: `mermaid-init.js`, JSON-LD `CreativeWork` or `SoftwareApplication`)
- [ ] `site-src/pages.json` entry: title `Infusing a Soul | OverKill Hill P³™`, description and OG fields from the Identity table, canonical URL `https://overkillhill.com/projects/infusing-a-soul/`, default brand OG image unless a page-specific one is made
- [ ] `site-src/project-status.json` entry (proposed below)
- [ ] Card on the projects index and entry in the Our Projects menu
- [ ] Regenerate: `scripts/build-site.py`, `scripts/build-search-index.py`, `scripts/sync-universe-map.py`
- [ ] Locale pages through the exact-pair translation skills, then `scripts/check-locale-links.py`
- [ ] Gates: `scripts/build-site.py --check`, `scripts/build-search-index.py --check`, `scripts/validate-site.py`

## Proposed project-status entry

```json
{
  "id": "infusing-a-soul",
  "title": "Infusing a Soul",
  "route": "/projects/infusing-a-soul/",
  "kind": "detail",
  "availability": "Published build journal",
  "maturity": "Agent online; Night Shift live; persona voice pending",
  "reviewed": "2026-09-24",
  "shelf": true,
  "shelf_exception": null,
  "evidence": {
    "tier": "source-described",
    "summary": "Night Shift smoke test passed 2026-09-24 on a home-hosted model; persona files not yet loaded into the live workspace.",
    "source": "site-src/pages/projects/infusing-a-soul/index.main.html",
    "delivery": "unknown",
    "revision": "<commit sha of the published source record>",
    "url": "<public URL of the source record, pinned to that sha>"
  }
}
```

## Decision needed before publishing

The infusing-a-soul repository is private. Every project-status entry links to a public source record pinned to a commit.

| Option | Tradeoff |
|---|---|
| Publish only `docs/story/` to a public location (for example a public mirror or the overkill-hill repo itself) | Keeps the corpus and soul files private. Recommended |
| Make the whole repository public | Simplest, but exposes proprietary persona files |
| Link no source record | Breaks the site's evidence convention |
