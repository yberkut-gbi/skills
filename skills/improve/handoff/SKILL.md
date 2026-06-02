---
name: handoff
description: Compact the current session into a handoff document so a fresh agent — or another person — can pick up the work without losing context. Use when wrapping up mid-task, switching models or threads, or passing work to a teammate, or when the user says "hand this off", "write a handoff", or "save the context". References existing artifacts by path instead of duplicating them, suggests which skills to run next, and redacts anything sensitive.
---

# Handoff

Context dies when a session ends. This skill captures just enough of it — state, decisions, and what's next — so the work continues cleanly in a new session, a different model, or someone else's hands. It's how synergy survives across time, not just within one conversation.

Inspired by Matt Pocock's `handoff`.

## Where to save
Write the handoff to the operating system's temporary directory, **not** the workspace — it's a transient continuation aid, not a project artifact.

## What to include
- **Goal & current state** — what we're doing and where it stands right now.
- **Next steps** — the concrete actions the next agent should take.
- **Decisions made** — link to ADRs and the PRD rather than restating them.
- **Open questions** — what's still unresolved.
- **Suggested skills** — which skills the next agent should invoke to continue (e.g. `tdd-implement` to keep building the current slice, `diagnose` for the open bug).

## What not to do
- **Don't duplicate** content that already lives in artifacts — PRDs, plans, ADRs, issues, commits, diffs. Reference them by path or URL. Duplication goes stale immediately.
- **Redact sensitive information** — API keys, passwords, personal data. A handoff often travels between machines and people.

Keep it compact and high-signal. The reader is an agent or colleague starting cold; give them the shortest path back to productive work.
