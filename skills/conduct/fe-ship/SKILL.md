---
name: fe-ship
description: Take a ship-ready issue end to end without a human in the seat — implement test-first, hold a hard green gate (typecheck, lint, tests, build), self-review the diff, and open a pull request, then stop for human review. The autonomous sibling of fe-orchestrate — same recipe, no per-step check-ins. Use when invoked headless (`claude -p`), in CI, or when the user says "ship <ISSUE> autonomously" / "take this issue to a PR unattended" / "no human until PR review". Refuses to invent scope — if the issue isn't spec-ready it stops and sends it back to planning rather than guessing.
---

# Ship

The autonomous conductor. A human shaped the spec and a human will review the PR; everything between those two points is yours to run unattended. Quality is held by a hard verification gate and a refusal to guess — not by someone watching the screen. Sequence the other skills; don't reimplement them.

## Precondition: the issue must be ship-ready
Before any code, fetch the issue from the configured tracker — **Jira by default** (Atlassian `getJiraIssue`; cloud URL and project key live in `docs/agents/config.md`, tool map in `fe-setup`/MCP-SETUP.md), or GitHub/local if `config.md` says so. It is ship-ready only if it has clear acceptance criteria and an unambiguous scope. If it's vague, carries open design questions, or needs a tradeoff that isn't already pinned by the issue or an ADR — **stop**. Don't guess. Comment on the ticket with exactly what's missing and that it needs `fe-grill-with-docs` / `fe-to-issues` first. Planning is the human's half of the split; never do it silently.

## 0. Load the shared memory (always first)
Same as `fe-orchestrate`: read `CONTEXT.md`, the relevant ADRs in `docs/adr/`, and `docs/agents/team-rules.md`. team-rules carries past lessons into this run — apply what it says. If `fe-setup` hasn't run or the Jira MCP is unconfirmed, stop and say so: a headless run can't configure itself, and guessing the substrate corrupts the shared memory.

## 1. Implement — `fe-tdd`, slice by slice
Run `fe-tdd` against the acceptance criteria, one vertical slice at a time, ticket key threaded through branch and commits. Stay in scope: build what the issue asks, not what you wish it asked. New scope that surfaces mid-run is a reason to stop (§5), not to expand the change.

## 2. The green gate (hard, non-skippable)
This is what makes "no human until the PR" safe. Discover the repo's checks from its `package.json` scripts / CI config — typecheck, lint, tests, build — and run **all** of them. Every one must pass before a PR opens. If anything is red, keep working: fix the cause. Never bypass a hook, never weaken or delete a test to go green, never open the PR on red. If you can't reach green after honest effort, stop and escalate (§5). A red branch is not a deliverable.

## 3. Self-review (the pre-review half of the gate)
Before opening the PR, read your own diff as a skeptical reviewer would and run the review skills over it — `/code-review` and `/security-review` (or `/review`). Address what they surface; if you deliberately don't, say why in the PR body. The point of the split is that the human opens an **already-vetted** PR and spends their attention on judgment, not on lint and obvious bugs.

## 4. Open the PR — `fe-to-review` — then STOP
Hand off to `fe-to-review`: reviewable commits, push, `gh pr create`, ticket key threaded through, PR linked back to Jira. Then stop. **Never merge** — the PR is the human's gate, the one place in this loop a person decides. Surface the PR URL and the green-gate results as the last lines of your output so a script or CI step can capture them.

## 5. When to stop instead of ship (the autonomous safety valve)
You have no human to check in with mid-run, so a clean stop replaces the check-in. Stop and escalate — comment on the ticket, leave a draft PR or none at all, state plainly what blocked you — when:
- the issue turns out underspecified once you're in the code;
- a consequential decision (architecture, data shape, a public API, a real tradeoff) isn't pinned by the issue or an ADR;
- the green gate won't go green honestly;
- the change is sprawling well past the issue's scope.

Guessing on any of these is worse than stopping. Restraint is still the point — here it looks like a clean stop with a clear note, not a question.

## 6. Reflect — `fe-coach`
Write the per-PR coaching note (`fe-coach`) even though no human drove the run. The collaboration loop only compounds if reflection is consistent; an autonomous cycle that skips it stops teaching the system, and `fe-distill-rules` has nothing to learn from. Because this run is autonomous, its **token cost is also measured**: the runner attaches a `<date>-<KEY>.cost.json` record beside the note (see [RUNNER.md](RUNNER.md)). Reflect on efficiency honestly — churned turns, a stop-and-escalate, rework from a thin spec — so `fe-distill-rules` can tie the cost back to its cause and turn it into a rule.

---

The autonomous sibling of `fe-orchestrate` — same path, with the human at the spec and the PR instead of at every step. To run it unattended (worktree-isolated, parallel, or across a backlog), see [RUNNER.md](RUNNER.md).
