---
name: fe-tdd
description: Implement features or fix bugs test-first, one vertical slice at a time — red (failing test at the right seam) → green (minimal code) → refactor (toward deep, simple-interface modules). Use whenever writing code to satisfy a requirement and tests are expected, especially inside the lifecycle. Detects the test framework, captures the acceptance criteria, claims the Jira ticket and moves it to In Progress when a key is given, and logs any test-first escape hatch.
model: sonnet
---

# Test-First Implementation

Write the test before the code, in **vertical slices** — one thin end-to-end behavior at a time, not a horizontal layer that does nothing alone. The failing test states what "working" means before you build it; slices stay shippable; the suite is a regression net.

## Detect, don't assume
Learn how the repo tests — language, framework, runner, where tests live, naming. Match it. Don't add a framework unless there's none and the user agrees.

## Capture what you're building to
  Restate the slice's acceptance criteria before the loop. If given a Jira key, fetch the ticket (Atlassian `getJiraIssue` — tool map in `core-setup`/MCP-SETUP.md) and read its title/description/AC; otherwise agree them with the user. Thread the ticket key through branch and commits.

  **Claim the ticket first.** Before writing the first test, run the ticket protocol (`core-setup`/MCP-SETUP.md): assign yourself if it's unassigned; if it's held by someone else, report who and when and ask the human before continuing; then move it to **In Progress** (`statuses.in_progress` in `config.md`) so the board shows the work is live.

## The loop (per slice)
1. **Name the slice.** Smallest useful end-to-end behavior. If vague, pin the acceptance criterion before the test — guessing here is the top source of rework.
2. **Red.** One focused test at the right **seam** — prefer an existing one, the highest sensible level (more stable than testing internals). Run it; confirm it fails for the *expected* reason.
3. **Green.** Minimal code to pass. Run; confirm green.
4. **Refactor.** Keep it green while improving names, structure, duplication — toward **deep modules** (simple interfaces over real depth; Ousterhout). For a non-trivial interface or coupling, use `fe-deepen`. Refactor what you touched, not the repo.

Repeat until the slice's acceptance criteria are met, then the next slice. What makes a test honest: [TESTS.md](TESTS.md).

## Escape hatch
When test-first genuinely fights the work — spikes, hard-to-test glue, throwaway exploration — say so explicitly, do the spike, then cover the kept code with tests. Make the skip **visible** for the coaching record. Strict by default, pragmatic when reality demands.

Adapted from Matt Pocock's `tdd`.
