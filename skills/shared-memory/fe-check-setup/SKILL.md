---
name: fe-check-setup
description: Verify the MCP servers the fe- skills need are installed and available in the current agent/IDE — chiefly the Atlassian (Jira) MCP, and optionally a GitHub MCP. Use when onboarding, when a tracker-dependent skill (fe-to-prd, fe-to-issues, fe-to-review) can't reach Jira, or to troubleshoot MCP issues. Reports a status table and points to per-agent setup for anything missing.
---

# Check Setup

Confirm the MCP servers the fe- skills depend on are available before running tracker-dependent skills.

## What to check
- **Jira (Atlassian MCP)** — required for the tracker flow (`fe-to-prd`, `fe-to-issues`, `fe-to-review`).
- **GitHub MCP** — optional (PRs also work via the `gh` CLI).

## Check
For each server, search the agent's available tools for one known tool of that server — match **by function**, since the ID varies per agent (Claude Code: `mcp__atlassian__…`; Copilot: `mcp_com_atlassian_…`):
- Jira → a "search Jira issues by JQL" tool. Found → installed; not found → missing.
- GitHub → any tool from the GitHub MCP.

## Report
```
MCP               Status
────────────────  ──────
Jira (Atlassian)  ✅ / ❌
GitHub (optional) ✅ / ❌
```

## Fix anything missing
Point the user to their agent/IDE config in [../fe-setup/MCP-SETUP.md](../fe-setup/MCP-SETUP.md) (Claude Code / Copilot / Cursor snippets). For Jira, they authenticate with Atlassian on first use. Re-run this skill to confirm green.

Readiness-check pattern from rezolve-enrich-ai's `check-setup`.
