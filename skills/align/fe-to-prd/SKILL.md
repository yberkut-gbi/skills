---
name: fe-to-prd
description: Turn the aligned conversation context into a PRD and publish it to Jira (an epic/story via the Atlassian MCP) per config.md. Use when the user wants to capture what's been discussed as a spec or PRD, ready to break into work. Runs a short pre-flight gap-check (acceptance criteria, error/edge cases, true out-of-scope) seeded by the team's recurring gaps, then synthesizes rather than re-interviewing. Acceptance criteria and edge cases are first-class fields.
model: opus
---

# To PRD

Synthesize the current understanding into a PRD and publish it. Deliberately fast: **don't re-interview — synthesize what's already been discussed and explored.** The one addition over a naive version is a gap-check up front, so a thin conversation doesn't silently become a thin PRD.

## 1. Pre-flight gap-check
Read `docs/agents/team-rules.md` and use it to seed a short checklist of what this team tends to leave implicit. Then scan the conversation for what's still unresolved — typically acceptance criteria, error/edge cases, out-of-scope. Surface only the genuine gaps and confirm in one pass. If `fe-grill-with-docs` already ran, this is a quick confirmation, not a fresh interview. No gaps → say so and move on.

## 2. Synthesize
Explore the repo if you haven't. Use the `CONTEXT.md` glossary so the PRD speaks the project's language; respect the ADRs you're touching. Sketch the **testing seams** (prefer existing, highest sensible) and the **major modules** (aim for deep modules — see `fe-deepen`).

## 3. Write it
```
# PRD: <feature>
## Problem            <the user/business problem, in domain language>
## Solution           <the approach, high level>
## Acceptance criteria   - <concrete, testable "done and correct">
## Error & edge cases    - <unhappy paths and how they behave>
## User stories          - As a <role>, I can <thin end-to-end behavior> so that <value>
## Module boundaries     <modules to build/modify and their interfaces>
## Testing seams         <where tested; existing seams preferred>
## Out of scope          - <explicitly excluded>
```

## 4. Publish
Create an Epic (or Story) in Jira via Atlassian `createJiraIssue` under the project key in `docs/agents/config.md`, mapping the fields above. Mark it **ready** — set the `ready` triage label, or transition to the `ready_state` status if `config.md` defines one (`getTransitionsForJiraIssue` + `transitionJiraIssue`). Leave it **unassigned** so a human or `fe-ship` can claim it via the ticket protocol.

Hand to `fe-to-issues` to break it into vertical slices.

Adapted from Matt Pocock's `to-prd`.
