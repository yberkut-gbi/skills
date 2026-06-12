---
name: fe-deepen
description: Find and act on opportunities to deepen a codebase's design — turn shallow modules into deep ones (simple interfaces over real implementation depth), improving testability and AI-navigability. Use when the user wants to improve architecture, find refactoring opportunities, reduce coupling, simplify wide interfaces, or rescue a codebase drifting toward a ball of mud. Run periodically.
model: opus
---

# Deepen the Architecture

Surface architectural friction and propose **deepening opportunities** — refactors that turn shallow modules into deep ones (more behaviour behind a smaller interface). The payoff: leverage for callers, locality for maintainers, a more testable and AI-navigable codebase.

Use the architecture vocabulary in [LANGUAGE.md](LANGUAGE.md) **exactly** — don't drift into "component / service / API / boundary." The technique for deepening a cluster safely, given its dependencies, is in [DEEPENING.md](DEEPENING.md). Read both before proposing. (If your agent can't open linked files, the condensed terms and steps below are enough to run a solid pass.)

## Vocabulary (condensed — full list in LANGUAGE.md)
- **Module** — anything with an interface + implementation (function, class, package, slice).
- **Interface** — everything a caller must know: types, invariants, ordering, errors, config. Not just the signature.
- **Depth** — leverage at the interface. **Deep** = much behaviour behind a small interface; **shallow** = interface nearly as complex as the implementation.
- **Seam** — where an interface lives; where behaviour can be swapped without editing in place. (Use this, not "boundary.")
- **Deletion test** — delete the module in your head: if complexity vanishes it was a pass-through; if it reappears across callers, it earned its keep.

## Load the shared memory first
Read `CONTEXT.md` and the ADRs in `docs/adr/`. Speak the domain's language; don't re-litigate decided ADRs. If a candidate overturns an ADR, surface it only when the friction is real, and mark it clearly.

## Process

### 1. Explore
Walk the codebase for friction — not by rigid checklist. If your agent supports sub-agents, delegate the walk to one (Claude Code: the Explore agent; GitHub Copilot: sub-agent delegation); otherwise explore directly. Look for: understanding one concept requires bouncing between many small modules; **shallow** modules; pure functions extracted only for testability while the real bugs hide in how they're called; tightly-coupled modules leaking across seams; code hard to test through its current interface. Apply the **deletion test** to anything you suspect is shallow.

### 2. Present candidates
For each: **files** involved · **problem** (the friction) · **solution** (plain English) · **benefits** (in leverage + locality terms, and how tests improve) · **strength** (Strong / Worth exploring / Speculative). Use `CONTEXT.md` vocabulary for the domain and [LANGUAGE.md](LANGUAGE.md) vocabulary for the architecture. Don't propose interfaces yet. End with the one you'd tackle first, then ask which to explore.
Present this as a self-contained HTML report with before/after diagrams ([HTML-REPORT.md](HTML-REPORT.md)) — the diagrams carry the weight; fall back to inline markdown if no file can be opened.

### 3. Grilling loop
Once they pick one, walk the design tree: constraints, dependencies, the shape of the deepened module, what sits behind the seam, which tests survive. Classify dependencies and derive the testing strategy per [DEEPENING.md](DEEPENING.md). Side effects inline: a deepened module named for a new concept → add the term to `CONTEXT.md`; a candidate rejected for a load-bearing reason → offer an ADR so future passes don't re-suggest it. To explore alternative interfaces for the deepened module, design it twice — see [INTERFACE-DESIGN.md](INTERFACE-DESIGN.md). Make behavioural changes test-first (`fe-tdd`).

Adapted from Matt Pocock's `improve-codebase-architecture`.
