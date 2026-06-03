# ADR Format

An Architecture Decision Record captures one consequential, hard-to-reverse decision so future sessions don't re-litigate it. One file per decision: `docs/adr/NNNN-short-title.md`.

## Template
```
# NNNN. <short title>

- **Status:** proposed | accepted | superseded by NNNN
- **Date:** YYYY-MM-DD

## Context
<the forces: what's true, the constraints, what's in tension. Use CONTEXT.md terms.>

## Decision
<what we decided, in active voice: "We will …">

## Consequences
<what gets easier, what gets harder, what we're now committed to.>
```

## Rules
- Record only consequential, hard-to-reverse choices (a boundary, dependency, data shape) — not every preference.
- Number sequentially; never renumber. Supersede rather than edit a decided ADR.
- Keep it short. The value is the decision and the *why*, captured once.

Adapted from Matt Pocock's `grill-with-docs/ADR-FORMAT.md`.
