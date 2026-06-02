---
name: to-prd
description: Turn the aligned conversation context into a PRD and publish it to the project issue tracker. Use when the user wants to capture what's been discussed as a spec or PRD, ready to break into work. This version runs a short pre-flight gap-check first — surfacing the few unresolved decisions (acceptance criteria, error/edge cases, true out-of-scope), seeded by the team's recurring gaps — then synthesizes rather than re-interviewing. Acceptance criteria and edge cases are first-class fields, so the build and reflect layers can use them.
---

# To PRD

Synthesize the current understanding into a Product Requirements Document and publish it to the tracker. The base behavior is deliberately fast: **don't re-interview the user — synthesize what's already been discussed and explored.** The improvement over a naive version is a short gap-check at the front, so a thin upstream conversation doesn't silently become a thin PRD.

Inspired by Matt Pocock's `to-prd`, with a pre-flight alignment step added.

## 1. Pre-flight gap-check (the improvement)
Before writing, read `docs/agents/team-rules.md` and use it to seed a short checklist of the things *this team tends to leave implicit*. Then scan the conversation for whatever is still unresolved — typically:
- **Acceptance criteria** — is "done and correct" actually pinned down?
- **Error / edge cases** — are the unhappy paths specified?
- **Out of scope** — is the boundary explicit?

Surface only the genuine gaps and confirm them with the user in one pass. If `grill-with-docs` already ran, this is a quick confirmation, not a fresh interview. If there are no gaps, say so and move on. This single step is what keeps the PRD honest — and as the improve loop learns what the team forgets, the checklist gets sharper on its own.

## 2. Synthesize
Explore the repo if you haven't. Use the `CONTEXT.md` glossary throughout so the PRD speaks the project's language, and respect the ADRs in the area you're touching. Sketch the **testing seams** (prefer existing seams; use the highest sensible one) and the **major modules** you'll build or modify (aim for deep modules — simple interfaces over real depth).

## 3. Write it (template)
```
# PRD: <feature>

## Problem
<the user/business problem, in domain language>

## Solution
<the approach, at a high level>

## Acceptance criteria
- <concrete, testable statements of "done and correct">

## Error & edge cases
- <unhappy paths and how they behave>

## User stories (vertical slices)
- As a <role>, I can <thin end-to-end behavior> so that <value>

## Module boundaries
<the modules to build/modify and their interfaces>

## Testing seams
<where this gets tested; existing seams preferred>

## Out of scope
- <explicitly excluded>
```

## 4. Publish
Publish to the tracker named in `docs/agents/config.md` and apply the `needs-triage` label so it enters the normal flow. Hand off to `to-issues` to break it into vertical slices.
