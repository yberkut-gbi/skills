---
name: fe-orchestrate
description: Conduct a feature from aligned idea to merged-ready PR to a learning signal — load the shared memory first, then move through alignment, implementation, PR, and a coaching note, checking in with the human at each decision. Use when the user wants to take work through the full cycle, or says "let's build X" / "take this from start to PR" in a repo. Stays deliberately thin — sequences and offers the other skills, doesn't own the process or remove the human's control.
---

# Orchestrate

The conductor for the set. Offer the next step, keep the shared state coherent, let the human steer — sequence the other skills, don't reimplement them. Restraint is the point: don't take control away from the developer.

## 0. Load the shared memory (always first)
Read `CONTEXT.md`, the relevant ADRs in `docs/adr/`, and `docs/agents/team-rules.md` — past lessons reach this cycle through team-rules; apply what it says. If `fe-setup` hasn't run, offer it first; if a tracker step is coming and the Jira MCP is unconfirmed, run `fe-check-setup`.

## The path (offer it; let the human skip steps)
Not every feature needs every stage — a one-line fix doesn't need a PRD.
1. **Align** — for anything non-trivial, `fe-grill-with-docs` to reach shared understanding and update the docs.
2. **Spec (optional)** — `fe-to-prd` to write it up, `fe-to-issues` to slice it.
3. **Implement** — `fe-tdd`, one vertical slice at a time, acceptance criteria in view.
4. **Review** — `fe-to-review`. Surface the PR URL.
5. **Reflect** — `fe-coach`, every cycle. The loop only compounds if this is consistent.

## Offer the right tool at the right moment
- Stuck in unfamiliar code → `fe-zoom-out`.
- A real bug or perf regression → `fe-diagnose`.
- Wrapping up mid-stream, or handing off → `fe-handoff`.
- After a batch of PRs → `fe-distill-rules` (coaching notes → team rules).
- Every few days → `fe-deepen` (keep the codebase deep and navigable).

## Keep the human in the loop
Pause at consequential decisions (architecture, tradeoffs, scope) and let the developer make the call. Note any stage they skip rather than pretending it ran.
