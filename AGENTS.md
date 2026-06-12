# AGENTS.md

## Purpose and scope
- This repo is a **skills registry** for `npx skills`; the primary artifacts are Markdown prompts under `skills/**`, not application source code.
- There is **no build system, package.json, or test suite** here; changes are usually edits to prompt files and docs.
- Core behavior is defined by `SKILL.md` files with YAML frontmatter (`name`, `description`, `model`).

## Big picture architecture
- Skills are organized into three installable groups: `core/` (`core-` prefix), `engineering/` (`fe-` prefix), `product/` (`pm-` prefix). The directory is the group — `npx skills add <repo>/tree/main/skills/core` installs only the core subtree. See `README.md` and `skills/*/*/SKILL.md`.
- **ADR 0001 (locked 2026-06-12)** defines this three-group layout and is now implemented. Read `docs/adr/0001-three-group-restructure-and-shared-spine.md` before authoring new skills or making structural changes.
- `engineering/fe-flow` is the end-to-end orchestrator (formerly `fe-ship`); it chains alignment → implementation → review/PR → reflection, **in two configurable modes**: interactive (default — checks in at each decision point, human steers) or unattended/headless (autonomous — takes a ship-ready issue to a PR with hard gates, no human in the loop until review).
- The system depends on a **shared-memory substrate in the target repo** (not this repo), read and written by both humans and skills:

| File | Purpose | Written by |
|------|---------|-----------|
| `CONTEXT.md` | Domain glossary + system map | `core-setup`, `core-grill` |
| `docs/adr/` | Architecture decision records | `core-grill`, `fe-deepen` |
| `docs/agents/config.md` | Jira project + status map + triage labels | `core-setup` |
| `docs/agents/team-rules.md` | Collaboration rules (distilled from coaching notes) | `core-distill-rules` |
| `docs/agents/coaching-notes/` | One note per PR + cost records per autonomous run | `fe-coach`, `fe-flow` runner |
| `docs/agents/holding/` | Degraded-mode fallback — holding docs when Atlassian MCP is unreachable | publish skills (`pm-to-prd`, `pm-to-issues`, `fe-to-review`) |

- Separation of concerns:
  - Strategic/architecture-heavy skills use `model: opus` (`core-grill`, `pm-to-prd`, `pm-to-issues`, `fe-deepen`, `fe-coach`, `core-distill-rules`, `core-zoom-out`).
  - Mechanical execution skills use `model: sonnet` (`fe-tdd`, `fe-to-review`, `core-diagnose`, `core-handoff`, `core-setup`, `core-check-setup`). `fe-flow` defaults to sonnet; override to opus via `FE_SHIP_MODEL=opus` for architecturally heavy tickets or complex specs.
- **Rich skills** — marked ★ in README — ship with a self-contained `SKILL.md` core plus companion reference files (`TESTS.md`, `RUNNER.md`, `SLICING.md`, etc., loaded on demand). Examples: `core-grill` (★), `pm-to-issues` (★), `fe-tdd` (★), `fe-deepen` (★).

## Critical workflows
- Authoring/updating a skill:
  - Edit `skills/<group>/<skill-name>/SKILL.md`.
  - Keep frontmatter `name` aligned with directory name.
  - Add optional companion docs (`TESTS.md`, `RUNNER.md`, etc.) and reference them from `SKILL.md`.
  - Update `README.md` skill tables when adding new skills.
- Headless autonomous execution uses the committed runner: `skills/engineering/fe-flow/fe-flow.sh`.
- Runner behavior to preserve: git worktree isolation, per-issue branches, and cost record output to `docs/agents/coaching-notes/<date>-<KEY>.cost.json`.

## Integrations and boundaries
- **Jira is the only issue tracker**; do not model workflow around GitHub Issues (`CLAUDE.md`, `skills/core/core-setup/MCP-SETUP.md`).
- Use Atlassian MCP Jira functions by capability (`getJiraIssue`, `editJiraIssue`, `transitionJiraIssue`, etc.); avoid hardcoding vendor-specific tool IDs in skill text so prompts stay portable across `mcp__atlassian__*` (Claude) and `mcp_com_atlassian_*` (Copilot).
- **Always resolve cloudId first** — call `getAccessibleAtlassianResources` at the start of every session before any Jira read or write; pick the site whose `url` matches `jira.cloud_url` in `config.md`. Never guess or hardcode a cloudId. Re-fetch transitions (`getTransitionsForJiraIssue`) before every status move — available transitions change with each status.
- GitHub (`gh`) is for repository/PR operations only.
- Ticket protocol used across work skills (`fe-tdd`, `fe-flow`, `core-diagnose`):
  - Claim ticket when starting: assign self if unassigned; if owned by someone else, report who+when and ask before continuing (interactive) or stop-and-escalate (autonomous `fe-flow`).
  - Move status using `docs/agents/config.md` status mapping (typically In Progress -> In Review).

## The two improvement loops
Skills coordinate two reinforcing loops:
- **Collaboration loop**: `team-rules.md` → alignment skills → implementation → PR → `fe-coach` notes → `core-distill-rules` aggregates into rules. Gaps caught at the back of the cycle (coaching notes) sharpen alignment at the front of the next one.
- **Architecture loop**: `CONTEXT.md` + `docs/adr/` → `fe-deepen` (periodic hygiene) → updated ADRs + `CONTEXT.md`. Runs every few days to fight entropy.
When authoring skills, keep these loops visible: coaching notes carry structured `signals` and `dimension` tags (spec-clarity, context-provision, scope-management, iteration-efficiency) so `core-distill-rules` can aggregate them into team rules, and `fe-deepen` output updates ADRs in machine-readable form.

## Project-specific conventions
- Prefer concise, operational prompt language; this repo stores instructions for other agents, not executable app logic.
- Keep skill docs composable: put core behavior in `SKILL.md`, move depth to companion files to control context size.
- Treat `skills/engineering/fe-flow/fe-flow.sh` as source of truth for autonomous mode; edit the runner there, not in copied wrappers.
- Preserve cross-agent portability: wording should work for both Claude and Copilot environments.
- **Coaching notes** (in `docs/agents/coaching-notes/`) carry frontmatter with author, ticket key, PR link, and **structured signals** (dimension + rating + evidence). Use these standard dimensions: `spec-clarity`, `context-provision`, `scope-management`, `iteration-efficiency`. Autonomous runs append token-cost records (JSON) to track efficiency across the learning loop.
- **Headless runner output**: `fe-flow.sh` captures cost and metadata in `docs/agents/coaching-notes/<date>-<KEY>.cost.json` for post-analysis; the coaching note follows on the PR branch (human writes this, not the runner).

## Practical command examples
```bash
# Install all three skill groups into a target project
npx skills add yberkut-gbi/skills/tree/main/skills/core
npx skills add yberkut-gbi/skills/tree/main/skills/engineering
npx skills add yberkut-gbi/skills/tree/main/skills/product

# Install a single skill by direct path
npx skills add https://github.com/yberkut-gbi/skills/tree/main/skills/engineering/fe-tdd

# Run autonomous conductor for one or more Jira tickets (from target repo)
.claude/skills/fe-flow/fe-flow.sh ABC-123 ABC-124

# Override defaults for heavy architectural work or cost tuning
FE_SHIP_MODEL=opus .claude/skills/fe-flow/fe-flow.sh ABC-123
FE_SHIP_MAX_TURNS=150 .claude/skills/fe-flow/fe-flow.sh ABC-124

# Override MCP tool prefix for Copilot environments (default: mcp__atlassian__*)
FE_SHIP_MCP_PREFIX="mcp_com_atlassian_*" .claude/skills/fe-flow/fe-flow.sh ABC-123

# Override the full --allowedTools list (rarely needed)
FE_SHIP_TOOLS="Read,Edit,Write,Bash(npm:*),Bash(git:*),Bash(gh:*),mcp_com_atlassian_*" .claude/skills/fe-flow/fe-flow.sh ABC-123
```

## Key files to read first
- `README.md`
- `CLAUDE.md`
- `docs/adr/0001-three-group-restructure-and-shared-spine.md` — three-group layout, renames, new skills, orchestration spine
- `skills/core/core-setup/MCP-SETUP.md`
- `skills/engineering/fe-flow/SKILL.md`
- `skills/engineering/fe-flow/fe-flow.sh`
