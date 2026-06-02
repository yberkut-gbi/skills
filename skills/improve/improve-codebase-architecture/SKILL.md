---
name: improve-codebase-architecture
description: Find and act on opportunities to deepen a codebase's design — consolidating tightly-coupled modules, simplifying wide interfaces, and improving testability and AI-navigability — informed by the domain language in CONTEXT.md and the decisions in docs/adr/. Use when the user wants to improve architecture, find refactoring opportunities, reduce coupling, or rescue a codebase that's drifting toward a ball of mud. Best run periodically (every few days), because agents accelerate both features and entropy.
---

# Improve Codebase Architecture

Agents make it cheap to add code, which makes it cheap to accumulate complexity. Left untended, a codebase gets harder to change and harder for both humans and agents to navigate. This skill is the counter-pressure: regularly look for places where the design can be made *deeper* — more capability behind simpler interfaces.

Inspired by Matt Pocock's `improve-codebase-architecture`; the design philosophy is Ousterhout's *A Philosophy of Software Design*.

## Read the shared memory first
Read `CONTEXT.md` (the domain model) and the ADRs in `docs/adr/`. Improvements should respect existing decisions and speak the domain's language; if a change overturns an ADR, that's a new decision to record.

## What to look for
- **Shallow modules** — a wide, complex interface hiding little real work. Candidates to merge, hide, or redesign.
- **Information leakage** — the same design decision smeared across several modules, so changing it means touching all of them.
- **Tight coupling** — modules that must change together. Look for a deeper abstraction that absorbs the variation.
- **Poor seams** — places that are hard to test because the boundaries are in the wrong spot.
- **Duplication** — the same logic re-expressed, a sign a missing abstraction wants to exist.

## How to act
- Propose the highest-leverage deepening opportunities, with the reasoning, and confirm with the user before large changes — this is their codebase, not yours to rearrange unilaterally.
- Make changes test-first where behavior is involved (lean on `tdd-implement`).
- Record consequential structural decisions as ADRs, and update `CONTEXT.md` if terms shift.

Run this on a cadence (every few days, or after a burst of feature work), not just when something already hurts.
