---
name: grill-with-docs
description: Before building, run an alignment session that stress-tests the plan against the project's domain model and documented decisions — challenging assumptions, sharpening terminology, surfacing the unresolved decisions that cause rework, and updating CONTEXT.md and ADRs inline as things crystallise. Use when the user has a plan, feature idea, or design and wants to get genuinely aligned before any code is written, or mentions "grill me", "stress-test this", or "are we aligned". This is where human–AI synergy is won or lost; it is far cheaper than discovering the gaps mid-implementation.
---

# Grill With Docs

Most wasted effort in AI-assisted development traces back to building before there was shared understanding. This skill front-loads that understanding. You interrogate the plan — collaboratively, in good faith — until you and the human genuinely agree on what's being built and why, and you capture what you learn in the repo so the next session inherits it.

Inspired by Matt Pocock's `grill-with-docs`; the underlying ideas (ubiquitous language, documenting decisions) come from domain-driven design.

## Load the shared memory first
Read `CONTEXT.md` (the domain glossary), the relevant ADRs in `docs/adr/`, and `docs/agents/team-rules.md`. The team-rules file is important: it lists the kinds of things *this team habitually leaves implicit*. Probe those first — they're your highest-yield questions.

## What to grill
Work through the plan and resolve each open branch with the human. Don't decide these for them; that's the point of the exercise.
- **Acceptance criteria** — what does "done and correct" actually mean? Get it concrete.
- **Error and edge cases** — what happens on the unhappy paths the plan glosses over?
- **Scope boundaries** — what is explicitly *out* of scope?
- **Terminology** — does the plan use words that conflict with, or are missing from, `CONTEXT.md`? Sharpen them. A shared word is worth a paragraph of explanation later.
- **Testing seams** — where will this be tested? Prefer existing seams; if a new one is needed, propose it at the highest sensible level.
- **Consequential decisions** — any choice that's expensive to reverse (a boundary, a dependency, a data shape).

## Capture as you go
As decisions crystallise, update the shared memory inline:
- New or sharpened terms → `CONTEXT.md`.
- Any consequential, hard-to-reverse decision → a short ADR in `docs/adr/`.

This is what makes the grilling compound instead of evaporating when the session ends.

## Know when to stop
Grill until you've reached shared understanding, then stop. The goal is alignment, not interrogation for its own sake. When the open branches are resolved and the terms are clean, hand off to `to-prd` (to write it up) or straight to the build layer.
