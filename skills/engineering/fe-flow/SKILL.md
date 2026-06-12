---
name: fe-flow
description: The engineering conductor — loads the shared memory, claims the Jira ticket, then drives one recipe end to end: align → implement test-first → green-gate (independent verifier + bounded fix loop) → self-review → PR → coaching note. Implements the shared orchestration spine (core-setup/orchestration-spine.md): checkpoint dial + mandatory-fork floor, resume-by-artifact, sub-agents everywhere. Default dial: `decision-forks` (pauses at forks + non-trivial choices). Dial `autonomous` for headless/CI. Refuses to invent scope or steal a ticket; sequences the other skills, never reimplements them.
model: sonnet
---

# Flow — the feature conductor

`fe-flow` loads the shared memory, claims the ticket, then conducts a feature through **align → implement → verify → self-review → PR → reflect** — sequencing the other skills, never reimplementing them.

It implements the **shared orchestration spine** (`core-setup/orchestration-spine.md`). Read that spec first; this skill instantiates it without re-specifying every invariant.

## Checkpoint dial + human-presence axis

Two independent axes govern a run:

**Checkpoint dial** (verbosity policy — spine §1):

| Dial | Behaviour |
|---|---|
| `every-decision` | Pause and ask at every decision, even trivial ones |
| `decision-forks` **(default)** | Pause/ask only at mandatory forks (§ below) and non-trivial choices |
| `autonomous` | Never asks; mandatory forks become stop-and-escalate instead of a question |

**Human-presence axis** (who is in the seat):

| Human present | Headless (no human) |
|---|---|
| You steer | Runner drives; spec was set, PR will be reviewed |
| Rough idea or ticket as starting point | Ship-ready issue required — else stops |
| Alignment stages offered (grill/PRD/slice) | Alignment out of scope — the human's half |
| Contested ticket → ask the human | Contested ticket → never steal it, stop and escalate |

Neither axis determines the other. Set the dial explicitly. Infer human-presence from whether there is someone to answer a prompt.

**Default:** `decision-forks` + human present. Switch to headless when invoked via `claude -p`, CI, or `.claude/skills/fe-flow/fe-flow.sh`.

## Mandatory-fork floor (spine §2 — no dial setting skips these)

These always pause (human present) or stop-and-escalate (headless):

- **Architecture** — changing how subsystems relate, introducing a new layer, or choosing a structural pattern
- **Data shape** — modifying a persisted schema, a public data contract, or an event payload
- **Public API** — adding, removing, or changing any interface consumed outside the current change
- **Scope sprawl** — the work has grown past what the issue specifies

When a mandatory fork fires headless: comment on the ticket with what was hit and what decision is needed, leave any partial work on a draft branch or in a holding doc, stop cleanly — no guess.

## How to trigger it

**Human present** — in a normal session:
- "Use fe-flow to take EN-1234 to a PR" / "let's build the login form" / "take this from idea to PR".
- Loads the substrate, offers alignment for anything non-trivial, then drives implement → PR, pausing at mandatory forks and non-trivial choices.

**Headless** — run it via the runner. One issue, or a fleet:
```bash
# one issue:
claude -p "Use the fe-flow skill to take Jira issue EN-1234 to a pre-reviewed PR. \
Do not merge; stop at the PR for human review." \
  --model sonnet --max-turns 120 --permission-mode acceptEdits \
  --allowedTools "Read,Edit,Write,Bash(npm:*),Bash(git:*),Bash(gh:*),mcp__atlassian__*" \
  --output-format stream-json --verbose

# a fleet, worktree-isolated + cost-accounted:
.claude/skills/fe-flow/fe-flow.sh EN-1234 EN-1235 EN-1236
```
See **[RUNNER.md](RUNNER.md)** for parallel/backlog patterns, cost accounting, model choice, and safety boundary.

## 0. Load the shared memory (always first)
Read `CONTEXT.md`, the relevant ADRs in `docs/adr/`, `docs/agents/team-rules.md`, and the spine spec at `core-setup/orchestration-spine.md` — past lessons reach this cycle through team-rules; apply what it says. Fetch the ticket from Jira (Atlassian `getJiraIssue`; cloud URL and project key in `docs/agents/config.md`, tool map in `core-setup/MCP-SETUP.md`).
- *Human present:* if `core-setup` hasn't run, offer it; if the Jira MCP is unconfirmed, run `core-check-setup`.
- *Headless:* if `core-setup` hasn't run or the Jira MCP is unconfirmed, **stop and say so** — a headless run can't configure itself, and guessing the substrate corrupts the shared memory.

## Claim the ticket (assignment · status)
Before any code, claim the Jira ticket so the board reflects reality and two workers never collide (full protocol in `core-setup/MCP-SETUP.md`):
- **Check the assignee** (`getJiraIssue` + change history). Unassigned → assign yourself (`editJiraIssue`). Already you → continue. **Held by someone else** → *human present:* report who holds it and when it was assigned, and ask before continuing (never reassign silently); *headless:* **never steal it** — stop and escalate with a comment naming the owner.
- **Move it to In Progress** (`statuses.in_progress` in `config.md`) so the board shows the run is live.

## Sub-agents + graceful degradation (spine §5)

Use sub-agents by default for per-phase isolation, the independent verifier (step 3 below), and parallel slices.

If sub-agents are genuinely unavailable:
- **Human present:** emit an inline banner before proceeding:
  ```
  ⚠ Sub-agents unavailable — running in single-context mode.
    Verification posture is degraded: the implementing context is grading its own work.
  ```
- **Headless:** set `degraded: true` in the coaching note frontmatter and cost record. Never omit when degraded — the changed verification posture must be auditable.

Do not hard-stop on sub-agent unavailability. Degraded single-context execution is weaker but valid.

## The recipe

**1. Align.**
- *Human present:* for anything non-trivial, offer `core-grill` to reach shared understanding and update the docs, then `pm-to-prd` / `pm-to-issues` to write and slice it. Let the human skip stages — a one-line fix doesn't need a PRD.
- *Headless:* alignment is the human's half. The issue is ship-ready only if it has clear acceptance criteria and unambiguous scope. If vague, open design questions, or a tradeoff not pinned by the issue or an ADR — **stop** (mandatory fork). Comment on the ticket with exactly what's missing and that it needs `core-grill` / `pm-to-issues` first.

**2. Implement — `fe-tdd`, slice by slice.** Run `fe-tdd` against the acceptance criteria, one vertical slice at a time, ticket key threaded through branch and commits. Stay in scope. New scope surfacing mid-run → check in (human present) or stop (headless), not quietly expand.

**3. Green gate (hard, non-skippable) + independent verifier + bounded fix loop (spine §3).**

Discover the repo's checks (typecheck, lint, tests, build) from `package.json` scripts / CI config and run **all** of them. Then spawn an **independent verifier** — a fresh sub-agent with no memory of how the code was written — to verify the implementation against the acceptance criteria.

**Bounded fix loop** (N from `config.md` `verifier.max_fix_attempts`; default 3 if absent):
1. Verifier runs — returns pass/fail with findings.
2. On fail: apply fixes, re-spawn verifier.
3. After N failed attempts → **escalate**: stop, comment on the ticket with what the verifier found, leave the branch as-is.

Never bypass a check, weaken or delete a test, or open the PR on red. Escalation after N attempts is the designed outcome — it surfaces work needing a human.

**4. Resume-by-artifact (spine §4).** Phase outputs (slice list, implementation branch, verification report, PR URL) persist on disk. If a phase's output artifact already exists, skip that phase. Start from the first missing artifact. Pass `--redo <phase>` to force a re-run.

**5. Self-review.** Before opening the PR, read the diff as a skeptical reviewer and run `/code-review` and `/security-review` (or `/review`). Address what they surface; if you deliberately don't, say why in the PR body.

**6. Open the PR — `fe-to-review` — then STOP.** Hand off to `fe-to-review`: reviewable commits, push, `gh pr create`, ticket key threaded through, PR linked back to Jira, ticket moved to **In Review**. Then stop. **Never merge.** Surface the PR URL and green-gate results as the last lines of output.

**7. Reflect — `fe-coach`.** Write the per-PR coaching note every cycle. On a **headless** run: set `degraded: true` in the coaching note if the run was degraded; the runner attaches the cost record — do not pre-create it. Reflect on efficiency honestly so `core-distill-rules` can tie cost to cause.

## At a consequential decision
Architecture, a data shape, a public API, a real tradeoff, or scope sprawling past the issue. No dial setting skips these.
- *Human present:* **pause and let the developer make the call.** Note any stage they skip.
- *Headless:* **clean stop.** Comment on the ticket, leave a draft PR or none, state plainly what blocked you.

---

The conductor sequences the set; it doesn't own it. For headless runs (worktree-isolated, parallel, or across a backlog), see **[RUNNER.md](RUNNER.md)**.
