---
name: fe-grill-with-docs
description: Before building, run an alignment session that stress-tests the plan against the project's domain model and documented decisions — challenging assumptions, sharpening terminology, surfacing the unresolved decisions that cause rework, and updating CONTEXT.md and ADRs inline. Use when the user has a plan, feature idea, or design and wants to get aligned before code, or says "grill me", "stress-test this", or "are we aligned".
---

# Grill With Docs

Interrogate the plan — collaboratively, in good faith — until you and the human agree on what's being built and why, and capture what you learn so the next session inherits it. The cheapest place to prevent rework.

## Load the shared memory first
Read `CONTEXT.md` (domain glossary), the relevant ADRs in `docs/adr/`, and `docs/agents/team-rules.md`. The team-rules file lists what this team habitually leaves implicit — probe those first; they're the highest-yield questions.

## What to grill
Resolve each open branch *with* the human — don't decide for them.
- **Acceptance criteria** — what does "done and correct" concretely mean?
- **Error & edge cases** — the unhappy paths the plan glosses over.
- **Scope boundaries** — what's explicitly *out*.
- **Terminology** — words that conflict with or are missing from `CONTEXT.md`. Sharpen them.
- **Testing seams** — where this gets tested; prefer existing seams, highest sensible level.
- **Consequential decisions** — anything expensive to reverse (a boundary, dependency, data shape).

## Capture as you go
- New or sharpened terms → `CONTEXT.md` ([CONTEXT-FORMAT.md](CONTEXT-FORMAT.md)).
- Any consequential, hard-to-reverse decision → a short ADR ([ADR-FORMAT.md](ADR-FORMAT.md)).

This is what makes the grilling compound instead of evaporating when the session ends.

## Know when to stop
Stop at shared understanding — alignment, not interrogation for its own sake. When the open branches are resolved and the terms are clean, hand to `fe-to-prd` (write it up) or straight to `fe-tdd`.

Adapted from Matt Pocock's `grill-with-docs`.
