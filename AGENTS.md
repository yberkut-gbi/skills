# AGENTS.md

## Purpose and scope
- This repo is a **skills registry** for `npx skills`; the primary artifacts are Markdown prompts under `skills/**`, not application source code.
- There is **no build system, package.json, or test suite** here; changes are usually edits to prompt files and docs.
- Core behavior is defined by `SKILL.md` files with YAML frontmatter (`name`, `description`, `model`).

## Big picture architecture
- Skills are organized by lifecycle stage: `align`, `implement`, `conduct`, `improve`, `shared-memory`, `anytime` (see `README.md` and `skills/*/*/SKILL.md`).
- **Planned restructure (ADR 0001, locked 2026-06-12):** the directory layout will change to three installable groups — `skills/{core,engineering,product}/` — with skill renames (`fe-ship`→`fe-flow`, `fe-grill-with-docs`→`core-grill`, `fe-setup`→`core-setup`, `fe-to-prd`→`pm-to-prd`, etc.) and new skills (`fe-verify-ui`, `fe-run`, PM conductors). The current `skills/<category>/` layout is pre-migration; read `docs/adr/0001-three-group-restructure-and-shared-spine.md` before authoring new skills.
- `conduct/fe-ship` is the end-to-end orchestrator; it chains alignment -> implementation -> review/PR -> reflection, **in two configurable modes**: interactive (default — checks in at each decision point, human steers) or unattended/headless (autonomous — takes a ship-ready issue to a PR with hard gates, no human in the loop until review).
- The system depends on a **shared-memory substrate in the target repo** (not this repo), read and written by both humans and skills:

| File | Purpose | Written by |
|------|---------|-----------|
| `CONTEXT.md` | Domain glossary + system map | `fe-setup`, `fe-grill-with-docs` |
| `docs/adr/` | Architecture decision records | `fe-grill-with-docs`, `fe-deepen` |
| `docs/agents/config.md` | Jira project + status map + triage labels | `fe-setup` |
| `docs/agents/team-rules.md` | Collaboration rules (distilled from coaching notes) | `fe-distill-rules` |
| `docs/agents/coaching-notes/` | One note per PR + cost records per autonomous run | `fe-coach`, `fe-ship` runner |
| `docs/agents/holding/` | Degraded-mode fallback — holding docs when Atlassian MCP is unreachable | publish skills (`fe-to-prd`, `fe-to-issues`, `fe-to-review`) |

- Separation of concerns:
  - Strategic/architecture-heavy skills use `model: opus` (`fe-grill-with-docs`, `fe-to-prd`, `fe-to-issues`, `fe-deepen`, `fe-coach`, `fe-distill-rules`, `fe-zoom-out`).
  - Mechanical execution skills use `model: sonnet` (`fe-tdd`, `fe-to-review`, `fe-diagnose`, `fe-handoff`, `fe-setup`, `fe-check-setup`). `fe-ship` defaults to sonnet; override to opus via `FE_SHIP_MODEL=opus` for architecturally heavy tickets or complex specs.
- **Rich skills** — marked ★ in README — ship with a self-contained `SKILL.md` core plus companion reference files (`TESTS.md`, `RUNNER.md`, `SLICING.md`, etc., loaded on demand). This keeps base context bounded while providing depth for complex workflows. Examples: `fe-grill-with-docs` (★), `fe-to-issues` (★), `fe-tdd` (★), `fe-deepen` (★).

## Critical workflows
- Authoring/updating a skill:
  - Edit `skills/<category>/<skill-name>/SKILL.md`.
  - Keep frontmatter `name` aligned with directory name.
  - Add optional companion docs (`TESTS.md`, `RUNNER.md`, etc.) and reference them from `SKILL.md`.
  - Update `README.md` skill tables when adding new skills.
- Headless autonomous execution uses the committed runner: `skills/conduct/fe-ship/fe-ship.sh`.
- Runner behavior to preserve: git worktree isolation, per-issue branches, and cost record output to `docs/agents/coaching-notes/<date>-<KEY>.cost.json`.

## Integrations and boundaries
- **Jira is the only issue tracker**; do not model workflow around GitHub Issues (`CLAUDE.md`, `skills/shared-memory/fe-setup/MCP-SETUP.md`).
- Use Atlassian MCP Jira functions by capability (`getJiraIssue`, `editJiraIssue`, `transitionJiraIssue`, etc.); avoid hardcoding vendor-specific tool IDs in skill text so prompts stay portable across `mcp__atlassian__*` (Claude) and `mcp_com_atlassian_*` (Copilot).
- **Always resolve cloudId first** — call `getAccessibleAtlassianResources` at the start of every session before any Jira read or write; pick the site whose `url` matches `jira.cloud_url` in `config.md`. Never guess or hardcode a cloudId. Re-fetch transitions (`getTransitionsForJiraIssue`) before every status move — available transitions change with each status.
- GitHub (`gh`) is for repository/PR operations only.
- Ticket protocol used across work skills (`fe-tdd`, `fe-ship`, `fe-diagnose`):
  - Claim ticket when starting: assign self if unassigned; if owned by someone else, report who+when and ask before continuing (interactive) or stop-and-escalate (autonomous `fe-ship`).
  - Move status using `docs/agents/config.md` status mapping (typically In Progress -> In Review).

## The two improvement loops
Skills coordinate two reinforcing loops:
- **Collaboration loop**: `team-rules.md` → alignment skills → implementation → PR → `fe-coach` notes → `fe-distill-rules` aggregates into rules. Gaps caught at the back of the cycle (coaching notes) sharpen alignment at the front of the next one.
- **Architecture loop**: `CONTEXT.md` + `docs/adr/` → `fe-deepen` (periodic hygiene) → updated ADRs + `CONTEXT.md`. Runs every few days to fight entropy.
When authoring skills, keep these loops visible: coaching notes carry structured `signals` and `dimension` tags (spec-clarity, context-provision, scope-management, iteration-efficiency) so `fe-distill-rules` can aggregate them into team rules, and `fe-deepen` output updates ADRs in machine-readable form.

## Project-specific conventions
- Prefer concise, operational prompt language; this repo stores instructions for other agents, not executable app logic.
- Keep skill docs composable: put core behavior in `SKILL.md`, move depth to companion files to control context size.
- Treat `skills/conduct/fe-ship/fe-ship.sh` as source of truth for autonomous mode; edit the runner there, not in copied wrappers.
- Preserve cross-agent portability: wording should work for both Claude and Copilot environments.
- **Coaching notes** (in `docs/agents/coaching-notes/`) carry frontmatter with author, ticket key, PR link, and **structured signals** (dimension + rating + evidence). Use these standard dimensions: `spec-clarity`, `context-provision`, `scope-management`, `iteration-efficiency`. Autonomous runs append token-cost records (JSON) to track efficiency across the learning loop.
- **Headless runner output**: `fe-ship.sh` captures cost and metadata in `docs/agents/coaching-notes/<date>-<KEY>.cost.json` for post-analysis; the coaching note follows on the PR branch (human writes this, not the runner).

## Practical command examples
```bash
# Use skills from this registry in a target project
npx skills add yberkut-gbi/skills

# Install a single skill by direct path
npx skills add https://github.com/yberkut-gbi/skills/tree/main/skills/implement/fe-tdd

# Run autonomous conductor for one or more Jira tickets (from target repo)
.claude/skills/fe-ship/fe-ship.sh ABC-123 ABC-124

# Override defaults for heavy architectural work or cost tuning
FE_SHIP_MODEL=opus .claude/skills/fe-ship/fe-ship.sh ABC-123
FE_SHIP_MAX_TURNS=150 .claude/skills/fe-ship/fe-ship.sh ABC-124

# Override MCP tool prefix for Copilot environments (default: mcp__atlassian__*)
FE_SHIP_MCP_PREFIX="mcp_com_atlassian_*" .claude/skills/fe-ship/fe-ship.sh ABC-123

# Override the full --allowedTools list (rarely needed)
FE_SHIP_TOOLS="Read,Edit,Write,Bash(npm:*),Bash(git:*),Bash(gh:*),mcp_com_atlassian_*" .claude/skills/fe-ship/fe-ship.sh ABC-123
```

## Key files to read first
- `README.md`
- `CLAUDE.md`
- `docs/adr/0001-three-group-restructure-and-shared-spine.md` — locked redesign: three-group layout, renames, new skills, orchestration spine
- `skills/shared-memory/fe-setup/MCP-SETUP.md`
- `skills/conduct/fe-ship/SKILL.md`
- `skills/conduct/fe-ship/fe-ship.sh`

