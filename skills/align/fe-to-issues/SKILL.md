---
name: fe-to-issues
description: Break a PRD or plan into independently-grabbable issues using vertical slices (tracer bullets), and create them in Jira as stories/sub-tasks via the Atlassian MCP per config.md. Use when the user wants to convert a spec or plan into implementation tickets, or split work an agent or teammate can pick up one at a time. Each issue is one thin end-to-end behavior with its own acceptance criteria, in the project's domain language.
model: opus
---

# To Issues

Turn a plan into work items grabbable independently. The unit is the **vertical slice** (tracer bullet): a thin path through the whole stack delivering one observable behavior, not a horizontal layer that delivers nothing alone. Sliced this way each issue ships without waiting on the others — which is what lets a human and an agent work in parallel.

## 0. Prerequisite preflight
Run the preflight defined in `fe-setup`/MCP-SETUP.md (§ "Prerequisite preflight — referenced by the publish skills"): verify `docs/agents/config.md` exists with `jira.cloud_url`, `jira.project`, and `statuses:`; confirm at least one substrate file is present (`CONTEXT.md` or `docs/agents/team-rules.md`); call `atlassianUserInfo` to confirm the MCP is reachable; call `getAccessibleAtlassianResources` and match the result against `jira.cloud_url`. If any check fails, emit the exact notice from that section and stop. *Standalone shorthand (MCP-SETUP.md not in context): confirm `docs/agents/config.md` exists and `atlassianUserInfo` is callable; if either fails, tell the user to run `fe-setup` first.*

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

## Create in Jira (per config.md)
One Story per slice (sub-tasks for steps within a slice) via Atlassian `createJiraIssue`, under the configured project key and parent epic; resolve issue-type ids with `getJiraProjectIssueTypesMetadata`. Thread the parent key. Leave each **unassigned** so a human or `fe-ship` claims it via the ticket protocol; mark ready slices with the `ready` label (or `ready_state` status) so `fe-ship` can find them.

If the Atlassian MCP is unreachable, follow the fallback in `fe-setup`/MCP-SETUP.md (§ "Publish & degraded-mode fallback"): save each slice's payload to `docs/agents/holding/<date>-fe-to-issues-<KEY>.md` and emit the manual hand-off steps. *Standalone shorthand: write a holding doc per slice and surface the `createJiraIssue` calls for the human to run.*

Keep slices small enough to finish in a sitting; order them so the earliest prove the riskiest end-to-end path first.

Adapted from Matt Pocock's `to-issues`; the Jira creation flow and slicing patterns follow standard agile practice.
