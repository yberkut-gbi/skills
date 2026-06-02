---
name: pr-coaching-note
description: After a feature reaches a pull request, write a growth-oriented coaching note about the developer's human–AI collaboration during the cycle — how clearly they framed the work, what context they supplied, and where ambiguity caused rework. Use at the end of every feature/PR cycle, or whenever the user asks for a coaching note, a collaboration retro, or feedback on how a PR was driven. Produces a short markdown note plus a structured signals block that rules-synthesis aggregates into team rules. This is a coaching tool, not a code review or a performance evaluation.
---

# PR Coaching Note (Human–AI Collaboration)

At the end of a feature cycle, write the developer a short note about **how they collaborated with the AI** to get this PR built — so they get more out of AI next time, and so the team's shared rules improve. Write it as if they will read it, because they should.

This is explicitly **not** a code review and **not** a performance appraisal. You're coaching a collaboration skill, the way a pair-programming partner reflects on how a session went.

## What you're analyzing
The human–AI collaboration during *this* cycle. Draw on three sources:
1. **Your own first-hand experience of the session** — you were the AI, so you know directly where instructions were crisp, where you had to ask, and where you went down a wrong path. Your best evidence.
2. **The diff / PR** — what was built.
3. **The branch commit history** — commits, amends, and reversals hint at how smoothly it went.

## The one rule that keeps this fair
Separate *developer-side* opportunities from *AI-side* mistakes. If you misunderstood something stated clearly, that's your error, not their gap — don't charge it to them. If you erred and the developer caught it, that's a **strength** (good verification), and say so. A note that blames the human for the AI's mistakes erodes trust and teaches the wrong lesson, defeating the purpose.

## Collaboration lens (these double as tags for aggregation)
- **spec-clarity** — was the goal, with acceptance criteria, clear up front, or did it emerge through back-and-forth?
- **context-provision** — did they point you to the right files, conventions, and `CONTEXT.md` terms, or did you have to guess?
- **scope-management** — right-sized requests, or so large/vague they invited drift?
- **decision-ownership** — did they make the consequential calls, or leave them to you?
- **verification** — did they review and test your output and catch issues?
- **iteration-efficiency** — how many clarification rounds and how much rework came from avoidable ambiguity?

When a gap maps to something the align layer would have caught (e.g. spec-clarity), the most useful suggestion is often concrete and skill-shaped: "next time, run `grill-with-docs` before building."

## How to write it
- **Lead with real strengths**, specifically.
- Give **one to three concrete opportunities**: observation (with evidence) → why it matters → a concrete "next time, try…". Specific beats generic ("the spec didn't say what to do on a duplicate email, so we built it twice" beats "be clearer").
- **Don't manufacture gaps.** If collaboration was strong, say so and keep it short. Padding noise makes people stop reading.
- Keep the tone encouraging and peer-to-peer.

## Output
Save to `docs/agents/coaching-notes/<YYYY-MM-DD>-pr-<number>-<author>.md`. Use this structure:
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
  - dimension: verification
    rating: strong
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
The `signals` block is what makes the loop work — `rules-synthesis` reads `growth_area` entries across notes. Tag honestly; padding corrupts the team rules downstream.

## A note on trust
These notes are for the developer's growth and should be visible to them. Don't write anything you wouldn't say to the person directly and kindly. The aim is to help people learn from their own experience — not to build a file on them.
