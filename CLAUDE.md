# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A registry of composable agent skills for the `npx skills` CLI (Vercel Labs). Skills are Markdown-based prompt files installed into agent skill directories (e.g. `.claude/skills/`). There is no build system, test suite, or package.json — the "code" is the skill prompts themselves.

## Skill anatomy

Every skill lives under `skills/<group>/<skill-name>/` and has:
- `SKILL.md` — the core prompt; **must** have YAML frontmatter with `name:` and `description:` fields (used by the `npx skills` registry)
- Optional reference files (`RUNNER.md`, `TESTS.md`, `SLICING.md`, etc.) loaded by the skill on demand — these provide depth without bloating the base context

Skills marked ★ in the README are "rich" — a `SKILL.md` core plus companion reference files.

## Skill groups

| Group | Path | Namespace | Purpose |
|---|---|---|---|
| `core` | `skills/core/` | `core-` | Foundation — substrate setup + cross-cutting lenses; install first |
| `engineering` | `skills/engineering/` | `fe-` | Build a ship-ready issue → PR |
| `product` | `skills/product/` | `pm-` | Decide what to build → ship-ready issue |

Install a whole group by pointing `npx skills add` at the subtree path (directory-as-group):
```bash
npx skills add yberkut-gbi/skills/tree/main/skills/core
npx skills add yberkut-gbi/skills/tree/main/skills/engineering
npx skills add yberkut-gbi/skills/tree/main/skills/product
```

## The shared-memory substrate

Skills are stateless prompts but read/write a small set of files in the **target repo** (not this repo):
- `CONTEXT.md` — domain glossary and system map
- `docs/adr/` — architecture decision records
- `docs/agents/config.md` — Jira config (cloud URL + project key, status map, ready-state, triage labels)
- `docs/agents/team-rules.md` — distilled collaboration rules
- `docs/agents/coaching-notes/` — per-PR coaching notes + per-autonomous-run cost records
- `docs/agents/holding/` — degraded-mode fallback holding docs (written when Atlassian MCP is unreachable)

`core-setup` scaffolds all of this once per target repo. Always load this substrate before running any other skill (the skill prompts say "always first").

## Jira/MCP integration

Jira is the **only** issue tracker the skills use (GitHub hosts code/PRs via the `gh` CLI but is not an issue tracker here — no GitHub MCP). Skills reference Atlassian MCP tools **by function** (e.g. `getJiraIssue`, `editJiraIssue`, `transitionJiraIssue`), never by hardcoded tool ID, so the same prompts work under any agent prefix (`mcp__atlassian__*` for Claude Code, `mcp_com_atlassian_*` for Copilot). The full tool map and per-IDE MCP config snippets live in `skills/core/core-setup/MCP-SETUP.md`.

**Always resolve cloudId first** — call `getAccessibleAtlassianResources` at the start of every session before any Jira read or write. Re-fetch transitions (`getTransitionsForJiraIssue`) before every status move.

**Publish convention (prereq preflight + fallback):** `MCP-SETUP.md` is also the **single definition point** for two shared behaviours used by the three publish skills (`pm-to-prd`, `pm-to-issues`, `fe-to-review`): the *prerequisite preflight* and the *publish & degraded-mode fallback*. Both are defined once in `MCP-SETUP.md` §§ "Prerequisite preflight" and "Publish & degraded-mode fallback" and **referenced, not duplicated**, by the individual skills.

**The ticket protocol** (defined once in `MCP-SETUP.md`, referenced by the work skills `fe-tdd`/`fe-flow`/`core-diagnose`): on starting an existing ticket, claim it — assign self if unassigned; if someone else's, report who+when and ask (interactive) or stop-and-escalate (autonomous `fe-flow`); transition status to match the work (In Progress → In Review, names from the `statuses:` map in `config.md`).

## fe-flow headless runner

The canonical runner is a real file, `skills/engineering/fe-flow/fe-flow.sh`; `skills/engineering/fe-flow/RUNNER.md` documents it. The runner **ships with the `fe-flow` skill** — wherever the skill installs, the runner is already on disk beside it: `.claude/skills/fe-flow/fe-flow.sh` for a project-local install, `~/.claude/skills/fe-flow/fe-flow.sh` for a user-level install. It computes the repo root with `git rev-parse`, so it runs from any cwd in the target repo — there is **no copy step**. `core-setup` confirms the runner is reachable rather than scaffolding it; a committed `scripts/fe-flow.sh` wrapper is optional, not required. It runs `fe-flow` in a git worktree per Jira issue and captures token/cost JSON, and requires `claude`, `jq`, and `gh`. The runner's `--allowedTools` **must** include the Atlassian MCP tools (`mcp__atlassian__*`, or `mcp_com_atlassian_*` for Copilot) or the headless run can't read the ticket — keep `fe-flow.sh` the source of truth and edit it there, not in any copy. The cost records land in `docs/agents/coaching-notes/<date>-<KEY>.cost.json` on the PR branch. A null-valued cost record means the cycle didn't run through this runner.

## Authoring a new skill

1. Create `skills/<group>/<skill-name>/SKILL.md` with YAML frontmatter (`name`, `description`, `model`).
2. Add reference files as needed; reference them by relative path from within `SKILL.md`.
3. Keep `name:` in frontmatter consistent with the directory name.
4. Set `model:` to match the work — **`opus`** for architectural/grilling/synthesis skills (core-grill, fe-deepen, fe-coach, core-distill-rules, core-zoom-out, the conductors' judgment), **`sonnet`** for development/mechanical skills (fe-tdd, fe-to-review, core-diagnose, core-handoff, core-setup, core-check-setup).
5. Update `README.md` — skills table and group section.

## Agent skills substrate (this repo)

This repo has its own `docs/agents/` substrate (set up by `core-setup`). Before tracker-dependent skills run, confirm the Atlassian MCP is available with `core-check-setup`.
