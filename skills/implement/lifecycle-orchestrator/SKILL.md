---
name: lifecycle-orchestrator
description: Conduct a feature from aligned idea to merged-ready PR, then to a learning signal — loading the shared memory first, then moving through alignment, implementation, PR, and a coaching note, checking in with the human at each decision. Use when the user wants to take a piece of work through the full cycle, or says "let's build X" / "take this from start to PR" in a repo. Stays deliberately thin: it sequences and offers the other skills, it does not own the process or remove the human's control.
---

# Lifecycle Orchestrator

This is the conductor for the whole set. Its single most important property is restraint: heavyweight process frameworks fail because they take control away from the developer and make process bugs hard to fix. This skill does the opposite — it offers the next step, keeps the shared state coherent, and lets the human steer. You sequence the other skills; you don't reimplement them.

## 0. Load the shared memory (always first)
Read `CONTEXT.md`, the relevant ADRs in `docs/adr/`, and `docs/agents/team-rules.md`. The team-rules file is how past lessons reach this cycle — it may tell you, for instance, to align harder on acceptance criteria before building. Apply what it says. If `setup-skills` hasn't run, offer to run it first.

## The path (offer it; let the human skip steps)
Present the cycle and adapt to what the work needs. Not every feature needs every stage — a one-line fix doesn't need a PRD.

1. **Align** — for anything non-trivial, run `grill-with-docs` to reach shared understanding and update the docs. This is the cheapest place to prevent rework.
2. **Spec (optional)** — `to-prd` to write it up, `to-issues` to slice it. Skip for small changes.
3. **Implement** — `tdd-implement`, working one vertical slice at a time. Keep the acceptance criteria in view.
4. **Ship** — `commit-and-pr`. Surface the PR URL.
5. **Reflect** — `pr-coaching-note`, every cycle. The loop only compounds if this is consistent.

## Offer the right tool at the right moment
- Stuck in unfamiliar code? → `zoom-out`.
- A real bug or perf regression appears? → `diagnose`.
- Wrapping up mid-stream, or handing to another session/person? → `handoff`.
- After a batch of PRs → suggest `rules-synthesis` (turns coaching notes into updated team rules).
- Every few days → suggest `improve-codebase-architecture` (keeps the codebase deep and navigable).

## Keep the human in the loop
Pause at consequential decisions (architecture, tradeoffs, scope) and let the developer make the call — the coaching note rewards them for it, and your job is to support that, not to quietly decide on their behalf. Note any stage the user chooses to skip rather than pretending it ran.
