---
name: to-issues
description: Break a PRD or plan into independently-grabbable issues on the project tracker, using vertical slices (tracer bullets). Use when the user wants to convert a spec or plan into implementation tickets, or break work down into issues an agent or teammate can pick up one at a time. Each issue is one thin end-to-end behavior with its own acceptance criteria, written in the project's domain language.
---

# To Issues

Turn a plan into work items that can be grabbed independently. The unit is the **vertical slice** (a tracer bullet): a thin path through the whole stack that delivers one observable behavior, rather than a horizontal layer that delivers nothing on its own. Sliced this way, each issue can be implemented, tested, and shipped without waiting on the others — which is exactly what lets a human and an agent work in parallel.

Inspired by Matt Pocock's `to-issues`; tracer bullets come from Hunt & Thomas, *The Pragmatic Programmer*.

## How to run it
- Work from the PRD or plan already in context. If the user passes an issue reference, fetch it and read its full body and comments first.
- Explore the codebase if you haven't, to ground the slices in the real current state.
- Read `CONTEXT.md` and the relevant ADRs; use the glossary in issue titles and descriptions so tickets speak the project's language.

## Each issue should have
- A title naming the **one vertical slice** it delivers.
- **Acceptance criteria** carried down from the PRD (concrete and testable).
- A link back to the PRD/parent issue.
- Labels per `docs/agents/config.md`.

Keep slices small enough to finish in a sitting and ordered so the earliest ones prove the riskiest end-to-end path first.
