---
name: fe-check-setup
description: Verify the Atlassian (Jira) MCP the fe- skills need is installed and available in the current agent/IDE, detect the current agent/IDE/OS to name the exact config file to create or edit, and confirm the shared-memory substrate is in place. Use when onboarding, when a tracker-dependent skill (fe-to-prd, fe-to-issues, fe-to-review, fe-ship) can't reach Jira, or to troubleshoot MCP issues. Reports a status table, names the precise file to fix for the detected environment, and offers to re-verify once the user has made the change.
model: sonnet
---

# Check Setup

Confirm the shared-memory substrate is scaffolded and the Atlassian (Jira) MCP is available before running tracker-dependent skills. Jira is the only issue tracker the skills use; PRs go through the `gh` CLI, so no GitHub MCP is needed.

## What to check

Run both checks; collect all findings before reporting.

### 1. Shared-memory substrate

Check whether `fe-setup` has been run in this repo:
- Does `CONTEXT.md` exist at the repo root?
- Does `docs/agents/config.md` exist?

If either file is absent, the substrate has not been scaffolded yet.

### 2. Jira (Atlassian MCP)

Search the agent's available tools for one known Atlassian tool — match **by function**, since the ID varies per agent (Claude Code: `mcp__atlassian__…`; Copilot: `mcp_com_atlassian_…`):
- Jira → a "search Jira issues by JQL" tool (`searchJiraIssuesUsingJql`). Found → installed; not found → missing.

Optionally confirm write access too by checking for `editJiraIssue` / `transitionJiraIssue` — the assignment and status moves in the ticket protocol need them.

## Report

```
Check                           Status
──────────────────────────────  ──────
Shared-memory substrate         ✅ / ❌  (CONTEXT.md + docs/agents/config.md)
Jira (Atlassian MCP)            ✅ / ❌
```

## Fix anything missing

### Missing substrate

If `CONTEXT.md` or `docs/agents/config.md` are absent, report:

```
Shared-memory substrate not found (CONTEXT.md and/or docs/agents/config.md are missing).

Run fe-setup first to scaffold CONTEXT.md, docs/agents/config.md, team-rules.md,
and the coaching-notes folder that the fe- skills read from.
```

### Missing Jira MCP

Detect the current **agent**, **IDE**, and **OS**, then look up the precise config file path from the matrix in `../fe-setup/MCP-SETUP.md` § *"Config per agent / IDE"* — **do not duplicate the matrix here; reference that section as the source of truth**.

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
