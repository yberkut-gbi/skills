---
name: pm-frame
description: Shape a discovered problem into a framed opportunity — define boundaries, success criteria, solution bets, risks, and a recommended direction. The output is an opportunity brief ready for core-grill (the Decide phase) and eventually pm-to-prd. Use after pm-discover (or when the problem is understood but the solution space is still open). Judgment-heavy; model: opus.
model: opus
---

# Frame

Shape a discovered problem into an opportunity frame. The output is an **opportunity brief** — boundaries, success criteria, solution bets, and a recommended direction — ready to hand to `core-grill` (the Decide phase) and eventually `pm-to-prd`.

## Facilitation reference

Cite [`core/facilitation.md`](../../core/core-setup/facilitation.md) — **PDF-Loop** (one question at a time, three options, recommended first) applies directly to presenting solution bets (step 4); **AFCI** applies if the human attaches new artifacts. Not enforced — deviate when context calls for it.

## 0. Load context

Read `CONTEXT.md`, relevant ADRs in `docs/adr/`, and `docs/agents/team-rules.md` if they exist. Respect decisions already locked — do not re-open what an ADR has settled.

## 1. Receive the problem

Start from the problem map and problem statement produced by `pm-discover` (or the equivalent already in context). If running standalone, ask the human to describe the problem — apply AFCI for any attached artifacts, then ask ≤3 targeted gaps (who is the user, what is the pain, what is the boundary of this initiative). Do not re-derive what is already established.

## 2. Define boundaries

Nail the **in-scope / out-of-scope** split before proposing any solution. Scope ambiguity is the most common source of wasted design work.

```
### Boundaries
In scope:      <what this initiative covers>
Out of scope:  <what is explicitly excluded and why>
Adjacent / defer: <things that are related but belong in a later slice>
```

## 3. Success criteria

Define what "solved" looks like — concrete, observable, and testable. These become the acceptance-criteria seed for `pm-to-prd`.

```
### Success criteria
- <observable outcome, not an activity>
- <metric or threshold that proves it is working>
- <the signal that would break confidence — shows it is not working>
```

Prefer outcomes over outputs. "User can complete checkout in ≤2 steps" > "build a checkout flow."

## 4. Solution bets (PDF-Loop)

Generate **three distinct solution bets** — the recommended one first (per PDF-Loop: persona match + clearly right for most situations), two credible alternatives. Each bet must be genuinely different in scope, cost, risk, or approach — not variants of the same idea.

> **Which direction fits best for this problem?**
> 1. [Recommended] **\<Name\>** — \<one-line description\>. \<trade-off or why this fits\>.
> 2. **\<Name\>** — \<one-line description\>. \<trade-off\>.
> 3. **\<Name\>** — \<one-line description\>. \<trade-off\>.

Present these to the human and ask them to pick one or redirect. Do not proceed until a direction is confirmed.

## 5. Risks and open questions

Surface the top risks and design questions that `core-grill` will need to stress-test:

```
### Risks
- <risk — what could go wrong and what it would cost>

### Open questions
- <decision the team hasn't pinned — what core-grill needs to resolve>
```

## 6. Opportunity brief

Synthesize into a single output document:

```
# Opportunity brief: <title>

## Problem statement
<from pm-discover or step 1>

## Boundaries
<in / out / defer>

## Success criteria
<concrete, observable>

## Recommended direction
<the chosen bet, confirmed by the human in step 4>

## Risks
<top 2–3>

## Open questions
<what core-grill should resolve before pm-to-prd>
```

## 7. Hand off

Surface the brief. If the human confirmed a direction in step 4, mark it in the brief. Ask: proceed to `core-grill` to stress-test this direction? A grill is strongly recommended when there are open questions or architectural implications; it is mandatory before `pm-to-prd` if any open question touches data shape, a public API, or a cross-team dependency.

Called by `pm-discover-flow` (discover → frame → decide) and `pm-flow` (end-to-end PM conductor). Can run standalone when the problem is already understood and the team needs a structured framing step.
