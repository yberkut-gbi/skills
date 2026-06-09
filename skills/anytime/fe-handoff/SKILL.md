---
name: fe-handoff
description: Compact the current session into a handoff document so a fresh agent — or another person — can pick up the work without losing context. Use when wrapping up mid-task, switching models or threads, or passing work to a teammate, or when the user says "hand this off", "write a handoff", or "save the context". References existing artifacts by path instead of duplicating them, suggests which skills to run next, and redacts anything sensitive.
model: sonnet
---

# Handoff

Capture just enough of the session — state, decisions, what's next — so the work continues cleanly in a new session, a different model, or someone else's hands.

## Where to save
Write to the OS temporary directory, **not** the workspace — it's a transient continuation aid, not a project artifact.

## What to include
- **Goal & current state** — what we're doing and where it stands now.
- **Next steps** — the concrete actions the next agent should take.
- **Decisions made** — link to ADRs and the PRD; don't restate them.
- **Open questions** — what's unresolved.
- **Suggested skills** — what to invoke next (e.g. `fe-tdd` to keep building the slice, `fe-diagnose` for the open bug).

## What not to do
- **Don't duplicate** content that lives in artifacts (PRDs, ADRs, issues, commits, diffs) — reference by path/URL; duplication goes stale immediately.
- **Redact sensitive info** — keys, passwords, personal data. A handoff travels between machines and people.

Keep it compact and high-signal — the shortest path back to productive work for someone starting cold.

Adapted from Matt Pocock's `handoff`.
