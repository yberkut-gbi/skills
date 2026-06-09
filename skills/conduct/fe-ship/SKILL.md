---
name: fe-ship
description: The conductor for a feature — loads the shared memory, then runs one recipe end to end: align → implement test-first → hard green gate (typecheck, lint, tests, build) → self-review → open a PR → coaching note. Drives two ways from the same recipe. INTERACTIVE (default) — checks in at each decision, can start from a rough idea, the human steers. UNATTENDED — headless (`claude -p`), CI, or `scripts/fe-ship.sh`; takes a ship-ready issue to a pre-reviewed PR with no human in the seat, then stops for review, escalating instead of guessing. Use when the user says "let's build X" / "take this to a PR" (interactive), or "ship <ISSUE> autonomously" / "unattended" / "no human until PR review", or whenever invoked headless. Refuses to invent scope; sequences the other skills, never reimplements them.
---

# Ship — the feature conductor

One recipe, two postures. `fe-ship` loads the shared memory, then conducts a feature through **align → implement → green-gate → self-review → PR → reflect** — sequencing the other skills, never reimplementing them. What changes between modes is *how it treats the human*, not the path it walks.

## Two modes

| | **Interactive** (default) | **Unattended** (autonomous) |
|---|---|---|
| Human in the seat? | Yes — you steer | No — spec was set, PR will be reviewed |
| Starting point | a rough idea or a ticket | a **ship-ready** issue (else it stops) |
| Alignment (grill/PRD/slice) | offered, in scope | out of scope — planning is the human's half |
| At a hard decision | **pauses and asks** | **stops and escalates** (clean note, no guess) |
| Token-cost record | no | yes — written by the runner |

**Which mode am I in?** Default to **interactive**. Switch to **unattended** when you're invoked headless (`claude -p`, CI, or via `scripts/fe-ship.sh` — there is no human to answer a prompt), or when the user says "autonomously" / "unattended" / "no human until PR review".

## How to trigger it

**Interactive** — just ask, in a normal session:
- "Use fe-ship to take EN-1234 to a PR" / "let's build the login form" / "take this from idea to PR".
- It loads the substrate, offers the alignment stages for anything non-trivial, then drives implement → PR, checking in with you at each consequential decision.

**Unattended** — run it headless. One issue, or a fleet, or a backlog sweep:
```bash
# one issue, headless (note the Atlassian MCP must be in --allowedTools, or it can't read the ticket):
claude -p "Use the fe-ship skill to take Jira issue EN-1234 to a pre-reviewed PR. \
Do not merge; stop at the PR for human review." \
  --model opus --max-turns 60 --permission-mode acceptEdits \
  --allowedTools "Read,Edit,Write,Bash(npm:*),Bash(git:*),Bash(gh:*),mcp__atlassian" \
  --output-format stream-json --verbose

# a fleet, worktree-isolated + cost-accounted (the runner fe-setup installs):
scripts/fe-ship.sh EN-1234 EN-1235 EN-1236
```
The runner, the parallel/backlog patterns, the cost accounting, and the safety boundary all live in **[RUNNER.md](RUNNER.md)** — read it before running unattended.

## 0. Load the shared memory (always first)
Read `CONTEXT.md`, the relevant ADRs in `docs/adr/`, and `docs/agents/team-rules.md` — past lessons reach this cycle through team-rules; apply what it says. Fetch the ticket from Jira (Atlassian `getJiraIssue`; cloud URL and project key in `docs/agents/config.md`, tool map in `fe-setup`/MCP-SETUP.md) and follow the ticket protocol — claim it, transition its status.
- *Interactive:* if `fe-setup` hasn't run, offer it; if a tracker step is coming and the Jira MCP is unconfirmed, run `fe-check-setup`.
- *Unattended:* if `fe-setup` hasn't run or the Jira MCP is unconfirmed, **stop and say so** — a headless run can't configure itself, and guessing the substrate corrupts the shared memory.

## The recipe

**1. Align.**
- *Interactive:* for anything non-trivial, offer `fe-grill-with-docs` to reach shared understanding and update the docs, then `fe-to-prd` / `fe-to-issues` to write and slice it. Let the human skip stages — a one-line fix doesn't need a PRD.
- *Unattended:* alignment is the human's half of the split and is **out of scope**. The issue is ship-ready only if it has clear acceptance criteria and unambiguous scope. If it's vague, carries open design questions, or needs a tradeoff not pinned by the issue or an ADR — **stop** (§ stop-and-escalate). Comment on the ticket with exactly what's missing and that it needs `fe-grill-with-docs` / `fe-to-issues` first. Never plan silently.

**2. Implement — `fe-tdd`, slice by slice.** Run `fe-tdd` against the acceptance criteria, one vertical slice at a time, ticket key threaded through branch and commits. Stay in scope: build what the issue asks, not what you wish it asked. New scope that surfaces mid-run is a reason to check in (interactive) or stop (unattended) — not to quietly expand the change.

**3. The green gate (hard, non-skippable).** This is what makes "no human until the PR" safe in unattended mode — and good hygiene in interactive. Discover the repo's checks from its `package.json` scripts / CI config — typecheck, lint, tests, build — and run **all** of them. Every one must pass before a PR opens. If anything is red, keep working: fix the cause. Never bypass a hook, never weaken or delete a test to go green, never open the PR on red. A red branch is not a deliverable.

**4. Self-review (the pre-review half of the gate).** Before opening the PR, read your own diff as a skeptical reviewer would and run the review skills over it — `/code-review` and `/security-review` (or `/review`). Address what they surface; if you deliberately don't, say why in the PR body. The human should open an **already-vetted** PR and spend their attention on judgment, not lint and obvious bugs.

**5. Open the PR — `fe-to-review` — then STOP.** Hand off to `fe-to-review`: reviewable commits, push, `gh pr create`, ticket key threaded through, PR linked back to Jira, the `AFK` label cleared. Then stop. **Never merge** — the PR is the human's gate, the one place a person decides. Surface the PR URL and the green-gate results as the last lines of your output so a script or CI step can capture them.

**6. Reflect — `fe-coach`.** Write the per-PR coaching note every cycle — the loop only compounds if reflection is consistent, and `fe-distill-rules` has nothing to learn from otherwise. On an **unattended** run the token cost is also measured: the runner attaches a `<date>-<KEY>.cost.json` record beside the note (see [RUNNER.md](RUNNER.md)). Reflect on efficiency honestly — churned turns, a stop-and-escalate, rework from a thin spec — so `fe-distill-rules` can tie cost back to cause.

## At a consequential decision
A consequential decision is architecture, a data shape, a public API, a real tradeoff, or scope sprawling past the issue. Guessing on these is the one thing neither mode does.
- *Interactive:* **pause and let the developer make the call.** Restraint is the point — don't take control away from them. Note any stage they skip rather than pretending it ran.
- *Unattended:* you have no human to ask, so a **clean stop replaces the check-in.** Comment on the ticket, leave a draft PR or none, state plainly what blocked you — when the issue turns out underspecified, a consequential decision isn't pinned by the issue or an ADR, the green gate won't go green honestly, or the change sprawls past scope. A clear stop with a note, not a question.

---

The conductor sequences the set; it doesn't own it. Interactive keeps the human at every decision; unattended keeps them at the two ends — the spec and the PR — and runs everything between. To run it unattended (worktree-isolated, parallel, or across a backlog), see **[RUNNER.md](RUNNER.md)**.
