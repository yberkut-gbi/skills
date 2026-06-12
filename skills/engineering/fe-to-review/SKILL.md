---
name: fe-to-review
description: Commit work in reviewable pieces, push the branch, and open a pull request via the gh CLI — threading the Jira ticket through the branch, commits, and PR, linking the PR back to the ticket, and moving the ticket to In Review. Use after implementing a change when the user wants to commit, push, "open a PR", or get work up for review, especially as the tail of the lifecycle.
model: sonnet
---

# Open for Review

Turn finished work into a clean, reviewable pull request. Clear messages and body let a reviewer (human or AI) understand intent without re-deriving it, and make the change easy to revert or bisect.

## 0. Prerequisite preflight
Run the preflight defined in `core-setup`/MCP-SETUP.md (§ "Prerequisite preflight — referenced by the publish skills"): verify `docs/agents/config.md` exists with `jira.cloud_url`, `jira.project`, and `statuses:`; confirm at least one substrate file is present (`CONTEXT.md` or `docs/agents/team-rules.md`); call `atlassianUserInfo` to confirm the MCP is reachable; call `getAccessibleAtlassianResources` and match the result against `jira.cloud_url`. If any check fails, emit the exact notice from that section and stop. *Standalone shorthand (MCP-SETUP.md not in context): confirm `docs/agents/config.md` exists and `atlassianUserInfo` is callable; if either fails, tell the user to run `core-setup` first.*

## 1. Land on a feature branch
Never commit feature work to `main`/`master`. If that's the branch, create one first. If a Jira ticket is in play, name the branch for its key (`feat/<KEY>-short-desc`, e.g. `feat/ABC-123-retry-backoff`); match the repo's branch-naming style.

## 2. Commit in reviewable pieces
- Stage related changes together; avoid one giant catch-all commit.
- Conventional-commits: `type(scope): summary` subject in the imperative; body explains *why* when not obvious from the diff. Reference the ticket key for traceability.
- Never commit secrets or large generated artifacts. Respect hooks; if one fails, fix the cause, don't bypass.

## 3. Push
`git push -u origin <branch>`.

## 4. Open the PR
`gh pr create`:
- Clear title (the headline change), carrying the ticket key.
- Body: what changed and why, how it was tested, and the **Jira ticket URL** (the ticket is the source of truth — there are no GitHub issues to close).

## 5. Update Jira (close the loop)
  - **Link back** — comment the PR URL on the ticket (Atlassian `addCommentToJiraIssue`; tool map in `core-setup`/MCP-SETUP.md) so ticket and PR cross-reference.
  - **Move the status** — transition the ticket to **In Review** (`statuses.in_review` in `config.md`) via `getTransitionsForJiraIssue` + `transitionJiraIssue`, so the board shows it's waiting on a human.
  - If the Atlassian MCP is unreachable, follow the fallback in `core-setup`/MCP-SETUP.md (§ "Publish & degraded-mode fallback"): save the Jira update payload to `docs/agents/holding/<date>-fe-to-review-<KEY>.md` and emit the manual hand-off steps. *Standalone shorthand: write a holding doc and surface the `addCommentToJiraIssue` + `transitionJiraIssue` calls for the human to run. The PR branch and commit are unaffected — only the Jira update is deferred.*

Surface the PR URL. Report CI/check status if any run. Don't merge unless the developer asks — opening the PR is where this skill stops.

Threading the ticket key through branch, commits, and PR is a standard traceability practice.
