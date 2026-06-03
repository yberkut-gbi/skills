---
name: fe-to-review
description: Commit work in reviewable pieces, push the branch, and open a pull request via the gh CLI — threading the Jira ticket through the branch, commits, and PR, and linking the PR back to the ticket. Use after implementing a change when the user wants to commit, push, "open a PR", or get work up for review, especially as the tail of the lifecycle.
---

# Open for Review

Turn finished work into a clean, reviewable pull request. Clear messages and body let a reviewer (human or AI) understand intent without re-deriving it, and make the change easy to revert or bisect.

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
- Body: what changed and why, how it was tested, and links — `Closes #123` for a GitHub issue, plus the Jira ticket URL.
- **Link back to Jira** — comment the PR URL on the ticket (Atlassian `addCommentToJiraIssue`; tool map in `fe-setup`/MCP-SETUP.md) so ticket and PR cross-reference.

Surface the PR URL. Report CI/check status if any run. Don't merge unless the developer asks — opening the PR is where this skill stops.

Ticket-threading pattern from rezolve-enrich-ai.
