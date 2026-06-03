---
name: fe-to-issues
description: Break a PRD or plan into independently-grabbable issues using vertical slices (tracer bullets), and create them on the tracker — Jira stories/sub-tasks via the Atlassian MCP, or GitHub/local per config.md. Use when the user wants to convert a spec or plan into implementation tickets, or split work an agent or teammate can pick up one at a time. Each issue is one thin end-to-end behavior with its own acceptance criteria, in the project's domain language.
---

# To Issues

Turn a plan into work items grabbable independently. The unit is the **vertical slice** (tracer bullet): a thin path through the whole stack delivering one observable behavior, not a horizontal layer that delivers nothing alone. Sliced this way each issue ships without waiting on the others — which is what lets a human and an agent work in parallel.

## How to run it
- Work from the PRD/plan in context. If given an issue/Jira reference, fetch it first (Atlassian `getJiraIssue` — tool map in `fe-setup`/MCP-SETUP.md) and read its full body + comments.
- Explore the codebase to ground slices in the real current state.
- Read `CONTEXT.md` + relevant ADRs; use the glossary in titles and descriptions.
- If a slice is too big or multi-branch, split it — see [SLICING.md](SLICING.md).

## Each issue
- A title naming the **one vertical slice** it delivers.
- **Acceptance criteria** carried from the PRD (concrete, testable).
- A link to the parent PRD/epic.
- Labels per `docs/agents/config.md`.

## Create on the tracker (per config.md)
- **Jira** — one Story per slice (sub-tasks for steps within a slice) via Atlassian `createJiraIssue`, under the configured project key and parent epic; resolve issue-type ids with `getJiraProjectIssueTypesMetadata`. Thread the parent key.
- **GitHub / local** — issues or markdown files per `config.md`.

Keep slices small enough to finish in a sitting; order them so the earliest prove the riskiest end-to-end path first.

Adapted from Matt Pocock's `to-issues`; Jira flow + slicing from rezolve-enrich-ai.
