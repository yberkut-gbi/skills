---
name: fe-check-setup
description: Verify the Atlassian (Jira) MCP the fe- skills need is installed and available in the current agent/IDE. Use when onboarding, when a tracker-dependent skill (fe-to-prd, fe-to-issues, fe-to-review, fe-ship) can't reach Jira, or to troubleshoot MCP issues. Reports a status table and points to per-agent setup if it's missing.
model: sonnet
---

# Check Setup

Confirm the Atlassian (Jira) MCP the fe- skills depend on is available before running tracker-dependent skills. Jira is the only issue tracker the skills use; PRs go through the `gh` CLI, so no GitHub MCP is needed.

## What to check
- **Jira (Atlassian MCP)** — required for the whole tracker flow (`fe-to-prd`, `fe-to-issues`, `fe-tdd`, `fe-to-review`, `fe-ship`).

## Check
Search the agent's available tools for one known Atlassian tool — match **by function**, since the ID varies per agent (Claude Code: `mcp__atlassian__…`; Copilot: `mcp_com_atlassian_…`):
- Jira → a "search Jira issues by JQL" tool (`searchJiraIssuesUsingJql`). Found → installed; not found → missing.

Optionally confirm write access too by checking for `editJiraIssue` / `transitionJiraIssue` — the assignment and status moves in the ticket protocol need them.

## Report
```
MCP               Status
────────────────  ──────
Jira (Atlassian)  ✅ / ❌
```

## Fix anything missing
Point the user to their agent/IDE config in [../fe-setup/MCP-SETUP.md](../fe-setup/MCP-SETUP.md) (Claude Code / Copilot / Cursor snippets). For Jira, they authenticate with Atlassian on first use. Re-run this skill to confirm green.

A fast readiness check keeps tracker-dependent skills from failing partway through a run on a missing or unauthenticated MCP.
