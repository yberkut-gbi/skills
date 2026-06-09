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
| `conduct` | `skills/conduct/` | End-to-end conductors: `fe-orchestrate` (interactive) and `fe-ship` (autonomous headless) |
| `shared-memory` | `skills/shared-memory/` | Substrate setup (`fe-setup`) and verification (`fe-check-setup`) |
| `align` | `skills/align/` | Pre-build alignment: grilling, PRD, issue slicing |
| `implement` | `skills/implement/` | TDD loop, PR creation |
| `improve` | `skills/improve/` | Retrospection, deep-module hygiene, rule distillation |
| `anytime` | `skills/anytime/` | Cross-cutting lenses: zoom-out, diagnose, handoff |

## The shared-memory substrate

Skills are stateless prompts but read/write a small set of files in the **target repo** (not this repo):
- `CONTEXT.md` — domain glossary and system map
- `docs/adr/` — architecture decision records
- `docs/agents/config.md` — issue tracker config (Jira cloud URL + project key, triage labels)
- `docs/agents/team-rules.md` — distilled collaboration rules
- `docs/agents/coaching-notes/` — per-PR coaching notes + per-autonomous-run cost records

`fe-setup` scaffolds all of this once per target repo. Always load this substrate before running any other skill (the skill prompts say "always first").

## Jira/MCP integration

Skills reference Atlassian MCP tools **by function** (e.g. `getJiraIssue`, `createJiraIssue`), never by hardcoded tool ID, so the same prompts work under any agent prefix (`mcp__atlassian__*` for Claude Code, `mcp_com_atlassian_*` for Copilot). The full tool map and per-IDE MCP config snippets live in `skills/shared-memory/fe-setup/MCP-SETUP.md`.

## fe-ship headless runner

`skills/conduct/fe-ship/RUNNER.md` documents the `scripts/fe-ship.sh` script (meant to be placed in *target repos*) that runs `fe-ship` in a git worktree per Jira issue and captures token/cost JSON. It requires `claude`, `jq`, and `gh`. The cost records land in `docs/agents/coaching-notes/<date>-<KEY>.cost.json` on the PR branch.

## Authoring a new skill

1. Create `skills/<category>/<skill-name>/SKILL.md` with YAML frontmatter (`name`, `description`).
2. Add reference files as needed; reference them by relative path from within `SKILL.md`.
3. Keep `name:` in frontmatter consistent with the directory name.
4. Update `README.md` — skills table and category section.

## Agent skills substrate (this repo)

This repo has its own `docs/agents/` substrate (set up by `fe-setup`). Before tracker-dependent skills run, confirm the Atlassian MCP is available with `fe-check-setup`.
