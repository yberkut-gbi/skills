---
name: fe-setup
description: Scaffold the shared-memory substrate every fe- skill reads from — the domain glossary (CONTEXT.md), architecture decision records (docs/adr/), the agent config (Jira project + status map + triage labels + doc layout), the team-rules file, and the coaching-notes folder — and wire Jira via the Atlassian MCP (the only issue tracker the skills use). Use once per repo before the align/implement/improve skills, or whenever those skills are missing context about Jira, domain language, or team rules.
model: sonnet
---

# Setup

Every other fe- skill reads a small amount of shared state from the repo. This skill creates it and wires the issue tracker. Run it once, early. Prompt-driven: explore, show what you found, confirm each decision, then write. Assume the user doesn't know these terms — define each in a sentence before asking.

## What it creates
- **`CONTEXT.md`** (root) — domain glossary + short system map (ubiquitous language; Evans).
- **`docs/adr/`** — architecture decision records, one per consequential decision (`NNNN-title.md`).
- **`docs/agents/config.md`** — Jira project + status map + triage labels + doc layout (shape below).
- **`docs/agents/team-rules.md`** — collaboration rules; starts empty, `fe-distill-rules` fills it.
- **`docs/agents/coaching-notes/`** — one note per PR (`fe-coach`) + a token-cost record per autonomous run.
- **`scripts/fe-ship.sh`** — the autonomous runner (`fe-ship`'s headless, worktree-isolated, cost-accounting wrapper). Without it, autonomous cycles get run interactively and the cost record is empty.
- An **`## Agent skills`** block in `AGENTS.md`/`CLAUDE.md` pointing future sessions at the above.

## How to run it
1. **Survey first.** Does `AGENTS.md`/`CLAUDE.md` exist? An `## Agent skills` section? Existing docs/ADRs/glossary? Summarise what's present and missing before changing anything.
2. **Walk the decisions one at a time:**
   - **Jira project** — the issue tracker is Jira (via the Atlassian MCP); record the **cloud URL** and **project key** in `config.md`. The skills target *that* project — nothing is hardcoded. Confirm the Atlassian MCP is available by running `fe-check-setup`; if missing, walk the user through their agent/IDE config in [MCP-SETUP.md](MCP-SETUP.md).
   - **Status map** — the names this project uses for *In Progress*, *In Review*, *Done*, and the **ready state** (status or label) that marks an issue picked-up-able by `fe-ship`. Status names vary per board; the skills transition by these mapped names ([MCP-SETUP.md](MCP-SETUP.md) ticket protocol). Confirm the names by inspecting an existing issue's available transitions.
   - **AFK label** — the label `fe-ship` sets while it drives a ticket autonomously (default `AFK`), so humans can see agent-owned work on the board.
   - **Triage labels** — the short vocabulary for sorting incoming work (e.g. `needs-triage`, `ready`, `blocked`, `wontfix`). `fe-to-prd`/`fe-to-issues` use these.
   - **Doc layout** — confirm the paths above, or adapt to the repo's conventions.
3. **Bootstrap `CONTEXT.md`** by exploring the codebase and pulling recurring domain terms from the conversation. Define each plainly. `fe-grill-with-docs` sharpens it later.
4. **Install the autonomous runner.** Copy the `fe-ship` skill's canonical `fe-ship.sh` into this repo's `scripts/fe-ship.sh` and `chmod +x` it — locate it with `find ~/.claude ~/.config -path '*conduct/fe-ship/fe-ship.sh'` (it sits beside `fe-ship/RUNNER.md` in the installed skills dir; if you can't find it, RUNNER.md carries the install steps). This is the only path that produces real token-cost records; skipping it means `fe-coach` can only write a null-valued cost stub. Don't edit the script — it's parameterised by env var (`FE_SHIP_MODEL`, `FE_SHIP_MAX_TURNS`, `FE_SHIP_MCP_PREFIX`).
5. Tell the user setup is complete and which skills now read these files.

## config.md shape
```
# Agent config
tracker: jira                 # Jira is the only issue tracker the skills use
jira:
  cloud: https://<your>.atlassian.net
  project: <KEY>              # the skills target this project
  statuses:                   # lifecycle stage → this project's status name
    in_progress: In Progress
    in_review: In Review
    done: Done
  ready_state: ready          # status or label marking an issue ready for fe-ship to pick up
  afk_label: AFK              # label fe-ship sets while driving a ticket autonomously
triage_labels: [needs-triage, ready, blocked, wontfix]
docs:
  adr: docs/adr/
  rules: docs/agents/team-rules.md
  coaching: docs/agents/coaching-notes/
```

Keep it light. A thin, accurate substrate the team maintains beats an elaborate one nobody touches.
