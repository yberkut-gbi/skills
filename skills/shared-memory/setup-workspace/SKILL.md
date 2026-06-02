---
name: setup-workspace
description: Scaffold the shared-memory substrate that every other skill in this set reads from — the domain glossary (CONTEXT.md), architecture decision records (docs/adr/), the agent config (issue tracker + triage labels), the collaboration rules file (team-rules.md), and the coaching-notes folder. Run this once per repository before using the align, build, or improve skills, or any time those skills seem to be missing context about the issue tracker, domain language, or team rules. This is the foundation that makes human and AI work from one source of truth.
---

# Setup Workspace

Everything else in this set depends on a small amount of shared state living in the repo. That shared state is the whole point: when the human and the AI read and write the same glossary, the same decisions, and the same accumulated lessons, they stop talking past each other. This skill creates that substrate. Run it once, early.

This is prompt-driven, not a script. Explore the repo, show the user what you found, confirm each decision with them, then write. Assume the user does not know these terms — explain each one in a sentence before asking.

## What it creates
- **`CONTEXT.md`** (repo root) — the domain glossary and a short map of the system. A shared language so the agent stops guessing at jargon. (See *ubiquitous language*, Evans, *Domain-Driven Design*.)
- **`docs/adr/`** — architecture decision records, one file per consequential decision (`NNNN-short-title.md`).
- **`docs/agents/config.md`** — the agent config: which issue tracker (GitHub, Linear, or local markdown under `docs/agents/issues/`), the triage label vocabulary, and where the docs above live.
- **`docs/agents/team-rules.md`** — collaboration rules distilled from coaching notes. Starts empty; the improve layer fills it.
- **`docs/agents/coaching-notes/`** — one note per PR, written by the coaching skill.
- An **`## Agent skills`** block in `AGENTS.md`/`CLAUDE.md` pointing future sessions at all of the above.

## How to run it
1. **Survey first.** Does `AGENTS.md`/`CLAUDE.md` exist? Is there already an `## Agent skills` section? Any existing docs, ADRs, or glossary? Summarise what's present and what's missing before changing anything.
2. **Walk the decisions one at a time** — present one, get the answer, move on. Don't dump all of them at once.
   - *Issue tracker* — where work items live. GitHub and local markdown both work out of the box; describe any other tracker in your own words in `config.md`.
   - *Triage labels* — the short vocabulary used to sort incoming work (e.g. `needs-triage`, `needs-info`, `ready`, `blocked`, `wontfix`). The to-prd and triage flows use these.
   - *Doc layout* — confirm the paths above, or adapt to the repo's conventions.
3. **Bootstrap `CONTEXT.md`** by exploring the codebase and pulling the recurring domain terms out of the conversation. Define each term plainly. This file is meant to grow — grill-with-docs sharpens it as decisions are made.
4. Tell the user setup is complete and which skills now read from these files.

Keep it light. A thin, accurate substrate that the team actually maintains beats an elaborate one nobody touches.
