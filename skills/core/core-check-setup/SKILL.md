---
name: core-check-setup
description: Verify the Atlassian (Jira) MCP the fe- skills need is installed and available in the current agent/IDE, detect the current agent/IDE/OS to name the exact config file to create or edit, and confirm the shared-memory substrate is in place — including the canonical AGENTS.md instruction-tree root, thin pointer files (CLAUDE.md, .github/copilot-instructions.md), stack.md, and docs/agents/patterns/. Use when onboarding, when a tracker-dependent skill (pm-to-prd, pm-to-issues, fe-to-review, fe-flow) can't reach Jira, or to troubleshoot MCP issues. Reports a status table, names the precise file to fix for the detected environment, and offers to re-verify once the user has made the change.
model: sonnet
---

# Check Setup

Confirm the shared-memory substrate is scaffolded and the Atlassian (Jira) MCP is available before running tracker-dependent skills. Jira is the only issue tracker the skills use; PRs go through the `gh` CLI, so no GitHub MCP is needed.

## What to check

Run both checks; collect all findings before reporting.

### 1. Shared-memory substrate

Check whether `core-setup` has been run in this repo:

| File / directory | Purpose |
|---|---|
| `AGENTS.md` | Canonical instruction-tree root — must exist at repo root |
| `CLAUDE.md` | Thin pointer to `AGENTS.md` — must exist; must not duplicate content |
| `.github/copilot-instructions.md` | Thin pointer to `AGENTS.md` for Copilot — must exist |
| `CONTEXT.md` | Domain glossary |
| `stack.md` | Tech-stack snapshot |
| `docs/agents/config.md` | Jira config |
| `docs/agents/patterns/` | Patterns directory (may be empty — presence is what matters) |

A **thin pointer** file passes if it exists and contains a reference to `AGENTS.md`. It fails if it contains full agent instructions instead of (or in addition to) the pointer — that indicates content duplication, not a pointer.

If any file is absent or a pointer file contains duplicated content, the substrate check fails.

### 2. Jira (Atlassian MCP)

Search the agent's available tools for one known Atlassian tool — match **by function**, since the ID varies per agent (Claude Code: `mcp__atlassian__…`; Copilot: `mcp_com_atlassian_…`):
- Jira → a "search Jira issues by JQL" tool (`searchJiraIssuesUsingJql`). Found → installed; not found → missing.

Optionally confirm write access too by checking for `editJiraIssue` / `transitionJiraIssue` — the assignment and status moves in the ticket protocol need them.

## Report

```
Check                                    Status
───────────────────────────────────────  ──────
AGENTS.md (canonical root)               ✅ / ❌
CLAUDE.md (thin pointer)                 ✅ / ❌
.github/copilot-instructions.md (thin)   ✅ / ❌
CONTEXT.md                               ✅ / ❌
stack.md                                 ✅ / ❌
docs/agents/config.md                    ✅ / ❌
docs/agents/patterns/                    ✅ / ❌
Jira (Atlassian MCP)                     ✅ / ❌
```

## Fix anything missing

### Missing substrate

If any substrate file is absent, report exactly which files are missing and recommend `core-setup`:

```
Shared-memory substrate incomplete. Missing:
  - <list each missing file>

Run core-setup to scaffold the full instruction tree: AGENTS.md (canonical root),
CLAUDE.md + .github/copilot-instructions.md (thin pointers), CONTEXT.md, stack.md,
docs/agents/config.md, docs/agents/team-rules.md, docs/agents/patterns/, and
the coaching-notes folder.
```

If a pointer file exists but contains duplicated content rather than a pointer, report:

```
<file> exists but contains agent instructions instead of a thin pointer to AGENTS.md.
Run core-setup to rewrite it as a pointer — content belongs in AGENTS.md only.
```

### Missing Jira MCP

Detect the current **agent**, **IDE**, and **OS**, then look up the precise config file path from the matrix in `../core-setup/MCP-SETUP.md` § *"Config per agent / IDE"* — **do not duplicate the matrix here; reference that section as the source of truth**.

**How to detect the environment:**
- **Agent** — infer from the tool prefix present in your available tool list (`mcp__atlassian__` = Claude Code; `mcp_com_atlassian_` = Copilot). If the tools are absent, infer from the IDE context or ask the user.
- **IDE** — infer from the editor context: VS Code shell variables, `.vscode/` directory, IntelliJ/WebStorm project files, or from the user's session context (e.g. running inside Claude Code CLI vs Claude Desktop).
- **OS** — infer from the shell environment (`uname`, `$OS`, path separators, or home-directory conventions).

Then emit a targeted message:

```
Jira (Atlassian MCP) is not configured.

For <Agent> on <IDE> / <OS>, add the MCP server to:
  <precise file path from the MCP-SETUP.md matrix>

See MCP-SETUP.md § "Config per agent / IDE" for the config snippet and
the full matrix of all supported agent/IDE/OS combinations.
```

If the agent/IDE/OS cannot be determined with confidence, give the two most likely paths and ask the user to confirm before continuing.

## Re-verify

After reporting any missing item, offer:

> "Say the word when you've made the fix and I'll re-run the checks to confirm everything is green."

Wait for the user to confirm readiness, then repeat both checks from the top and show an updated report.

A fast readiness check keeps tracker-dependent skills from failing partway through a run on a missing or unauthenticated MCP.
