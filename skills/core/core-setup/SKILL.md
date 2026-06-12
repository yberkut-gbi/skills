---
name: core-setup
description: Scaffold the shared-memory substrate every skill reads from — a canonical AGENTS.md instruction-tree root, thin pointer files (CLAUDE.md, .github/copilot-instructions.md), the domain glossary (CONTEXT.md), tech-stack summary (stack.md), architecture decision records (docs/adr/), agent patterns (docs/agents/patterns/), the agent config (Jira project + status map + triage labels + doc layout), the team-rules file, and the coaching-notes folder — and wire Jira via the Atlassian MCP (the only issue tracker the skills use). Use once per repo before the align/implement/improve skills, or whenever those skills are missing context about Jira, domain language, or team rules.
model: sonnet
---

# Setup

Every other skill reads a small amount of shared state from the repo. This skill creates it and wires the issue tracker. Run it once, early. Prompt-driven: explore, show what you found, confirm each decision, then write. Assume the user doesn't know these terms — define each in a sentence before asking.

## What it creates

### Instruction tree (cross-agent grounding)
- **`AGENTS.md`** (repo root, canonical) — the instruction-tree root. References all substrate below; is the single source of truth for agent instructions in this repo. Shape:
  ```
  AGENTS.md (canonical)
    → CONTEXT.md, stack.md
    → docs/agents/patterns/*.md
    → docs/agents/team-rules.md, docs/adr/*
    → [Agent skills section — points at installed skills]
  ```
- **`CLAUDE.md`** (repo root, thin pointer) — contains only a pointer to `AGENTS.md`; zero content. Created if absent; if already present with content, a pointer section is prepended without touching the rest.
- **`.github/copilot-instructions.md`** (thin pointer) — identical purpose: points Copilot at `AGENTS.md`. Created if absent; `.github/` directory created as needed.

### Substrate (read by skills + referenced from AGENTS.md)
- **`CONTEXT.md`** (root) — domain glossary + short system map (ubiquitous language; Evans).
- **`stack.md`** (root) — tech-stack snapshot: languages, frameworks, key dependencies, toolchain. One short block per layer; the agent reads this instead of re-inferring the stack on every run.
- **`docs/adr/`** — architecture decision records, one per consequential decision (`NNNN-title.md`).
- **`docs/agents/config.md`** — Jira project + status map + triage labels + doc layout (shape below).
- **`docs/agents/team-rules.md`** — collaboration rules; starts empty, `core-distill-rules` fills it.
- **`docs/agents/patterns/`** — pattern files written by `core-distill-rules` as the team accumulates reusable decisions. Starts empty; AGENTS.md references it so agents discover patterns automatically.
- **`docs/agents/coaching-notes/`** — one note per PR (`fe-coach`) + a token-cost record per autonomous run.

### MCP config
- **`.mcp.json`** (repo root) — committable Atlassian MCP config for Claude Code CLI users (written when the team uses Claude Code CLI).
- **`.vscode/mcp.json`** — committable Atlassian MCP config for Copilot/VS Code users (written when the team uses Copilot/VS Code).

### Autonomous runner
*(nothing to scaffold)* — `fe-flow.sh` already ships with the `fe-flow` skill (`.claude/skills/fe-flow/fe-flow.sh` when the skill is installed in the repo, `~/.claude/skills/fe-flow/fe-flow.sh` at user level). `core-setup` doesn't copy it anywhere — it just confirms the runner is reachable. Without a working runner, autonomous cycles get run interactively and the cost record is empty.

## How to run it
1. **Survey first.** Does `AGENTS.md` exist at the repo root? Does `CLAUDE.md` exist? Does `.github/copilot-instructions.md` exist? Is `stack.md` present? Existing docs/ADRs/glossary? Summarise what's present and missing before changing anything.
2. **Walk the decisions one at a time:**
   - **Jira project** — the issue tracker is Jira (via the Atlassian MCP); record the **cloud URL** and **project key** in `config.md`. The skills target *that* project — nothing is hardcoded.
   - **MCP config** — ask which agents/IDEs the team uses (Claude Code CLI, Claude Desktop, Copilot/VS Code, Copilot/WebStorm — can be multiple). Detect the OS (macOS, Windows, WSL2, Linux). Use the config-location matrix in [MCP-SETUP.md](MCP-SETUP.md) § "Config per agent / IDE" for all paths and snippets — do not duplicate them here:
     - *Committable configs* (write to the repo): `.mcp.json` for Claude Code CLI; `.vscode/mcp.json` for Copilot/VS Code. Use the snippets from MCP-SETUP.md.
     - *User-global configs* (developer must paste manually — never write these yourself, they live outside the repo): for Claude Desktop and Copilot/WebStorm, emit the OS-correct file path and the full config content from MCP-SETUP.md for the developer to paste.
   - **Status map** — the names this project uses for *In Progress*, *In Review*, *Done*, and the **ready state** (status or label) that marks an issue picked-up-able by `fe-flow`. Status names vary per board; the skills transition by these mapped names ([MCP-SETUP.md](MCP-SETUP.md) ticket protocol). Confirm the names by inspecting an existing issue's available transitions.
   - **Triage labels** — the short vocabulary for sorting incoming work (e.g. `needs-triage`, `ready`, `blocked`, `wontfix`). `pm-to-prd`/`pm-to-issues` use these.
   - **Doc layout** — confirm the paths above, or adapt to the repo's conventions.
3. **Bootstrap `CONTEXT.md`** by exploring the codebase and pulling recurring domain terms from the conversation. Define each plainly. `core-grill` sharpens it later.
4. **Bootstrap `stack.md`** by reading `package.json` / lock files / build config and summarising the actual stack — language version, framework(s), test runner, key libraries. One short block per layer. Never infer or guess; read the files.
5. **Write the instruction tree:**
   - Write `AGENTS.md` as the canonical root: a brief repo-purpose header, then `→` pointer lines to each substrate file (`CONTEXT.md`, `stack.md`, `docs/agents/patterns/*.md`, `docs/agents/team-rules.md`, `docs/adr/*`), then an `## Agent skills` section listing the installed skills and which files each one reads. MCP tools are referenced **by function name**, never by tool-ID (e.g. `getJiraIssue`, not `mcp__atlassian__getJiraIssue`).
   - Write (or prepend to) `CLAUDE.md` as a thin pointer: one sentence pointing the agent at `AGENTS.md` and the substrate it references. No content beyond the pointer.
   - Write (or prepend to) `.github/copilot-instructions.md` as an identical thin pointer.
6. **Confirm the autonomous runner is reachable — don't copy it.** `fe-flow.sh` ships with the `fe-flow` skill, so it's already on disk: `.claude/skills/fe-flow/fe-flow.sh` when the skill is installed in this repo, or `~/.claude/skills/fe-flow/fe-flow.sh` at user level (locate it with `find .claude ~/.claude ~/.config -path '*fe-flow/fe-flow.sh'`). It computes the repo root itself, so it runs from any cwd in the repo — `ls` it to confirm it's present, then tell the user the invocation. It's the only path that produces real token-cost records; without it `fe-coach` can only write a null-valued cost stub. A committed `scripts/fe-flow.sh` wrapper is **optional**, not a default step (see `fe-flow`/RUNNER.md). Don't edit the script — it's parameterised by env var (`FE_SHIP_MODEL`, `FE_SHIP_MAX_TURNS`, `FE_SHIP_MCP_PREFIX`).
7. **Run `core-check-setup`** to confirm the Atlassian MCP is reachable and the setup is green. Then tell the user setup is complete and which skills now read these files.

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
