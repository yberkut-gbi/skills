---
name: commit-and-pr
description: Commit work with clear messages, push the branch, and open a pull request on GitHub via the gh CLI. Use after implementing a change when the user wants to commit, push, "open a PR", or ship the work, especially as the tail of the lifecycle. Ensures work is on a feature branch, writes conventional reviewable commit messages, links the issue/slice and PRD, and creates a PR with a useful title and body.
---

# Commit, Push & Pull Request

Turn finished work into a clean, reviewable pull request. Good messages and a clear PR body aren't bureaucracy — they let a reviewer (human or AI) understand intent without re-deriving it, and they make the change easy to revert or bisect later.

## 1. Land on a feature branch
Never commit feature work directly to `main`/`master`. If that's the current branch, create a descriptive one first (`feat/...`, `fix/...`, `chore/...`). Match the repo's existing branch-naming style.

## 2. Commit in reviewable pieces
- Stage related changes together; avoid one giant catch-all commit when the work has distinct parts.
- Conventional-commits style: a `type(scope): summary` subject in the imperative mood, then a body explaining *why* when it isn't obvious from the diff.
- Never commit secrets, credentials, or large generated artifacts. Respect existing hooks; if one fails, fix the cause rather than bypass it.

**Example**
Change: added retry-with-backoff to the payments client after a flaky-timeout incident.
Subject: `fix(payments): retry transient timeouts with exponential backoff`
Body: one or two lines on the incident and why backoff beats a fixed retry.

## 3. Push
`git push -u origin <branch>`.

## 4. Open the PR
Create it with `gh pr create`:
- A clear title (the headline change).
- A body covering what changed and why, how it was tested, and the linked issue (`Closes #123`) and PRD. Keep it scannable.

Surface the PR URL once it's created. Report CI/check status if any run. Don't merge unless the developer asks — opening the PR is where this skill stops.
