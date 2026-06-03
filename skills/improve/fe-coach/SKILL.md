---
name: fe-coach
description: After a feature reaches a PR, write a growth-oriented coaching note on the developer's human–AI collaboration during the cycle — how clearly they framed the work, what context they supplied, where ambiguity caused rework. Use at the end of every feature/PR cycle, or when the user asks for a coaching note, a collaboration retro, or feedback on how a PR was driven. Produces a markdown note plus a structured signals block that fe-distill-rules aggregates into team rules. A coaching tool, not a code review or performance evaluation.
---

# PR Coaching Note (Human–AI Collaboration)

Write the developer a short note on **how they collaborated with the AI** this cycle — so they get more from AI next time and the team's rules improve. Write it as if they'll read it; they should. Not a code review, not an appraisal.

## What you're analyzing
The human–AI collaboration this cycle, from three sources:
1. **Your own first-hand experience** — where instructions were crisp, where you had to ask, where you went wrong. Best evidence.
2. **The diff / PR** — what was built.
3. **The commit history** — amends and reversals hint at how smoothly it went.

## The fairness rule
Separate *developer-side* opportunities from *AI-side* mistakes. If you misunderstood something stated clearly, that's your error, not their gap. If you erred and they caught it, that's a **strength** (verification) — say so. Blaming the human for the AI's mistakes erodes trust and defeats the purpose.

## Collaboration lens (these double as aggregation tags)
- **spec-clarity** — goal + acceptance criteria clear up front, or emerged through back-and-forth?
- **context-provision** — pointed you to the right files/conventions/`CONTEXT.md` terms, or did you guess?
- **scope-management** — right-sized requests, or large/vague enough to invite drift?
- **decision-ownership** — made the consequential calls, or left them to you?
- **verification** — reviewed and tested your output, caught issues?
- **iteration-efficiency** — clarification rounds and rework from avoidable ambiguity?

When a gap maps to the align layer (e.g. spec-clarity), make the suggestion skill-shaped: "next time, run `fe-grill-with-docs` before building."

## How to write it
Lead with real, specific strengths. Give 1–3 concrete opportunities: observation (with evidence) → why it matters → a concrete "next time, try…". Don't manufacture gaps — if collaboration was strong, say so and keep it short. Encouraging, peer-to-peer.

## Output
Save to `docs/agents/coaching-notes/<YYYY-MM-DD>-pr-<number>-<author>.md`:
```
---
author: <github-username>
pr: <url or number>
date: <YYYY-MM-DD>
cycle_summary: <one line — what was built>
signals:
  - dimension: spec-clarity
    rating: growth_area        # strong | solid | growth_area
    evidence: <short, specific>
  # include only the dimensions that came up
---

# Coaching note — <feature>

**What went well**
- <specific strength>

**Opportunities for next time**
1. **<observation>.** <why it matters>. Next time, try <concrete action>.

**Bottom line**
<one or two encouraging sentences>
```
The `signals` block makes the loop work — `fe-distill-rules` reads `growth_area` entries across notes. Tag honestly; padding corrupts the team rules.

## Trust
These notes are for the developer's growth and visible to them. Don't write anything you wouldn't say to them directly and kindly.
