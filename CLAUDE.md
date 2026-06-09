# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A registry of composable agent skills for the `npx skills` CLI (Vercel Labs). Skills are Markdown-based prompt files installed into agent skill directories (e.g. `.claude/skills/`). There is no build system, test suite, or package.json — the "code" is the skill prompts themselves.

## Skill anatomy

Every skill lives under `skills/<category>/<skill-name>/` and has:
- `SKILL.md` — the core prompt; **must** have YAML frontmatter with `name:` and `description:` fields (used by the `npx skills` registry)
- Optional reference files (`RUNNER.md`, `TESTS.md`, `SLICING.md`, etc.) loaded by the skill on demand — these provide depth without bloating the base context

Skills marked ★ in the README are "rich" — a `SKILL.md` core plus companion reference files.

## Skill categories

| Category | Path | Purpose |
|---|---|---|
| `conduct` | `skills/conduct/` | The end-to-end conductor `fe-ship` — one recipe, two modes: interactive (checks in) or unattended/headless (autonomous) |
| `shared-memory` | `skills/shared-memory/` | Substrate setup (`fe-setup`) and verification (`fe-check-setup`) |
| `align` | `skills/align/` | Pre-build alignment: grilling, PRD, issue slicing |
| `implement` | `skills/implement/` | TDD loop, PR creation |
| `improve` | `skills/improve/` | Retrospection, deep-module hygiene, rule distillation |
| `anytime` | `skills/anytime/` | Cross-cutting lenses: zoom-out, diagnose, handoff |

## The shared-memory substrate

Skills are stateless prompts but read/write a small set of files in the **target repo** (not this repo):
- `CONTEXT.md` — domain glossary and system map
- `docs/adr/` — architecture decision records
- `docs/agents/config.md` — Jira config (cloud URL + project key, status map, ready-state, AFK label, triage labels)
- `docs/agents/team-rules.md` — distilled collaboration rules
- `docs/agents/coaching-notes/` — per-PR coaching notes + per-autonomous-run cost records

`fe-setup` scaffolds all of this once per target repo. Always load this substrate before running any other skill (the skill prompts say "always first").

## Jira/MCP integration

Jira is the **only** issue tracker the skills use (GitHub hosts code/PRs via the `gh` CLI but is not an issue tracker here — no GitHub MCP). Skills reference Atlassian MCP tools **by function** (e.g. `getJiraIssue`, `editJiraIssue`, `transitionJiraIssue`), never by hardcoded tool ID, so the same prompts work under any agent prefix (`mcp__atlassian__*` for Claude Code, `mcp_com_atlassian_*` for Copilot). The full tool map and per-IDE MCP config snippets live in `skills/shared-memory/fe-setup/MCP-SETUP.md`.

**The ticket protocol** (defined once in `MCP-SETUP.md`, referenced by the work skills `fe-tdd`/`fe-ship`/`fe-diagnose`): on starting an existing ticket, claim it — assign self if unassigned; if someone else's, report who+when and ask (interactive) or stop-and-escalate (autonomous `fe-ship`); transition status to match the work (In Progress → In Review, names from the `statuses:` map in `config.md`); `fe-ship` sets an `AFK` label for autonomous runs, cleared by `fe-to-review`.

## fe-ship headless runner

The canonical runner is a real file, `skills/conduct/fe-ship/fe-ship.sh`; `skills/conduct/fe-ship/RUNNER.md` documents it. `fe-setup` installs a copy into each *target repo* at `scripts/fe-ship.sh`. It runs `fe-ship` in a git worktree per Jira issue and captures token/cost JSON, and requires `claude`, `jq`, and `gh`. The runner's `--allowedTools` **must** include the Atlassian MCP tools (`mcp__atlassian__*`, or `mcp_com_atlassian_*` for Copilot) or the headless run can't read the ticket — keep `fe-ship.sh` the source of truth and edit it there, not in copies. The cost records land in `docs/agents/coaching-notes/<date>-<KEY>.cost.json` on the PR branch. A null-valued cost record means the cycle didn't run through this runner.

## Authoring a new skill

1. Create `skills/<category>/<skill-name>/SKILL.md` with YAML frontmatter (`name`, `description`, `model`).
2. Add reference files as needed; reference them by relative path from within `SKILL.md`.
3. Keep `name:` in frontmatter consistent with the directory name.
4. Set `model:` to match the work — **`opus`** for architectural/grilling/synthesis skills (align, deepen, coach, distill, zoom-out, the conductors' judgment), **`sonnet`** for development/mechanical skills (tdd, to-review, diagnose, handoff, setup, check-setup).
5. Update `README.md` — skills table and category section.

## Agent skills substrate (this repo)

This repo has its own `docs/agents/` substrate (set up by `fe-setup`). Before tracker-dependent skills run, confirm the Atlassian MCP is available with `fe-check-setup`.
