---
name: core-setup
description: Scaffold the shared-memory substrate every skill reads from — the domain glossary (CONTEXT.md), architecture decision records (docs/adr/), the agent config (Jira project + status map + triage labels + doc layout), the team-rules file, and the coaching-notes folder — and wire Jira via the Atlassian MCP (the only issue tracker the skills use). Use once per repo before the align/implement/improve skills, or whenever those skills are missing context about Jira, domain language, or team rules.
model: sonnet
---

# Setup

Every other skill reads a small amount of shared state from the repo. This skill creates it and wires the issue tracker. Run it once, early. Prompt-driven: explore, show what you found, confirm each decision, then write. Assume the user doesn't know these terms — define each in a sentence before asking.

## What it creates
- **`CONTEXT.md`** (root) — domain glossary + short system map (ubiquitous language; Evans).
- **`docs/adr/`** — architecture decision records, one per consequential decision (`NNNN-title.md`).
- **`docs/agents/config.md`** — Jira project + status map + triage labels + doc layout (shape below).
- **`docs/agents/team-rules.md`** — collaboration rules; starts empty, `core-distill-rules` fills it.
- **`docs/agents/coaching-notes/`** — one note per PR (`fe-coach`) + a token-cost record per autonomous run.
- **`.mcp.json`** (repo root) — committable Atlassian MCP config for Claude Code CLI users (written when the team uses Claude Code CLI).
- **`.vscode/mcp.json`** — committable Atlassian MCP config for Copilot/VS Code users (written when the team uses Copilot/VS Code).
- *(nothing to scaffold)* **the autonomous runner** — `fe-flow.sh` already ships with the `fe-flow` skill (`.claude/skills/fe-flow/fe-flow.sh` when the skill is installed in the repo, `~/.claude/skills/fe-flow/fe-flow.sh` at user level). `core-setup` doesn't copy it anywhere — it just confirms the runner is reachable. Without a working runner, autonomous cycles get run interactively and the cost record is empty.
- An **`## Agent skills`** block in `AGENTS.md`/`CLAUDE.md` pointing future sessions at the above.

## How to run it
1. **Survey first.** Does `AGENTS.md`/`CLAUDE.md` exist? An `## Agent skills` section? Existing docs/ADRs/glossary? Summarise what's present and missing before changing anything.
2. **Walk the decisions one at a time:**
   - **Jira project** — the issue tracker is Jira (via the Atlassian MCP); record the **cloud URL** and **project key** in `config.md`. The skills target *that* project — nothing is hardcoded.
   - **MCP config** — ask which agents/IDEs the team uses (Claude Code CLI, Claude Desktop, Copilot/VS Code, Copilot/WebStorm — can be multiple). Detect the OS (macOS, Windows, WSL2, Linux). Use the config-location matrix in [MCP-SETUP.md](MCP-SETUP.md) § "Config per agent / IDE" for all paths and snippets — do not duplicate them here:
     - *Committable configs* (write to the repo): `.mcp.json` for Claude Code CLI; `.vscode/mcp.json` for Copilot/VS Code. Use the snippets from MCP-SETUP.md.
     - *User-global configs* (developer must paste manually — never write these yourself, they live outside the repo): for Claude Desktop and Copilot/WebStorm, emit the OS-correct file path and the full config content from MCP-SETUP.md for the developer to paste.
   - **Status map** — the names this project uses for *In Progress*, *In Review*, *Done*, and the **ready state** (status or label) that marks an issue picked-up-able by `fe-flow`. Status names vary per board; the skills transition by these mapped names ([MCP-SETUP.md](MCP-SETUP.md) ticket protocol). Confirm the names by inspecting an existing issue's available transitions.
   - **Triage labels** — the short vocabulary for sorting incoming work (e.g. `needs-triage`, `ready`, `blocked`, `wontfix`). `pm-to-prd`/`pm-to-issues` use these.
   - **Doc layout** — confirm the paths above, or adapt to the repo's conventions.
3. **Bootstrap `CONTEXT.md`** by exploring the codebase and pulling recurring domain terms from the conversation. Define each plainly. `core-grill` sharpens it later.
4. **Confirm the autonomous runner is reachable — don't copy it.** `fe-flow.sh` ships with the `fe-flow` skill, so it's already on disk: `.claude/skills/fe-flow/fe-flow.sh` when the skill is installed in this repo, or `~/.claude/skills/fe-flow/fe-flow.sh` at user level (locate it with `find .claude ~/.claude ~/.config -path '*fe-flow/fe-flow.sh'`). It computes the repo root itself, so it runs from any cwd in the repo — `ls` it to confirm it's present, then tell the user the invocation. It's the only path that produces real token-cost records; without it `fe-coach` can only write a null-valued cost stub. A committed `scripts/fe-flow.sh` wrapper is **optional**, not a default step (see `fe-flow`/RUNNER.md). Don't edit the script — it's parameterised by env var (`FE_SHIP_MODEL`, `FE_SHIP_MAX_TURNS`, `FE_SHIP_MCP_PREFIX`).
5. **Run `core-check-setup`** to confirm the Atlassian MCP is reachable and the setup is green. Then tell the user setup is complete and which skills now read these files.

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
  ready_state: ready          # status or label marking an issue ready for fe-flow to pick up
triage_labels: [needs-triage, ready, blocked, wontfix]
docs:
  adr: docs/adr/
  rules: docs/agents/team-rules.md
  coaching: docs/agents/coaching-notes/
```

Keep it light. A thin, accurate substrate the team maintains beats an elaborate one nobody touches.
