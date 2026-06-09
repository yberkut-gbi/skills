# MCP Setup

The Jira integration is an MCP server. Configure it once per agent/IDE. It's remote (HTTP) and authenticates via **OAuth on first use** — no tokens in the repo.

## Server
- **Jira** — Atlassian **Rovo** MCP Server, `https://mcp.atlassian.com/v1/mcp` (read + write: search, get, create, transition, comment). Tool IDs carry a per-agent prefix, so skills reference them by **function + canonical base name** (tool map below), never one hardcoded ID.
- **GitHub** *(optional)* — a GitHub MCP server. PRs also work through the `gh` CLI (`fe-to-review`), so only needed if you prefer MCP-driven GitHub actions.

## Jira tool map
Per-agent prefix: Claude Code `mcp__atlassian__<tool>` · Copilot `mcp_com_atlassian_<tool>`. Base names are the Atlassian Rovo MCP tools the fe- skills use:

| Function | Tool (base name) | Used by |
|---|---|---|
| Search issues (JQL) | `searchJiraIssuesUsingJql` | fe-check-setup probe; lookups |
| Get an issue | `getJiraIssue` | fe-to-review, fe-tdd, fe-ship (fetch ticket) |
| List visible projects | `getVisibleJiraProjects` | validate `jira.project` from config.md |
| Project issue types | `getJiraProjectIssueTypesMetadata` | pick Epic/Story/Sub-task on create |
| Create an issue | `createJiraIssue` | fe-to-prd (epic/story), fe-to-issues (stories/sub-tasks) |
| Get transitions | `getTransitionsForJiraIssue` | find the id for the target status |
| Transition an issue | `transitionJiraIssue` | fe-to-prd → ready; fe-to-review status moves |
| Comment on an issue | `addCommentToJiraIssue` | fe-to-review (link the PR) |

Confirmed in the rezolve repo: `getJiraIssue`, `searchJiraIssuesUsingJql`. The rest are documented Atlassian Rovo tools — confirm with `fe-check-setup` (Atlassian may add/rename tools).

## Config per agent / IDE
The schema differs: Claude Code and Cursor use `mcpServers`; VS Code / GitHub Copilot use `servers`.

**Claude Code** — `.mcp.json` at repo root (or user settings):
```json
{ "mcpServers": {
  "atlassian": { "type": "http", "url": "https://mcp.atlassian.com/v1/mcp" }
} }
```

**GitHub Copilot (VS Code / JetBrains / Visual Studio)** — `mcp.json` / workspace MCP settings:
```json
{ "servers": {
  "com.atlassian/atlassian-mcp-server": { "type": "http", "url": "https://mcp.atlassian.com/v1/mcp" }
} }
```

**Cursor** — `.cursor/mcp.json`:
```json
{ "mcpServers": {
  "atlassian": { "url": "https://mcp.atlassian.com/v1/mcp" }
} }
```

After adding the server, you'll be prompted to authenticate with your Atlassian account on first use.

## Verify
Run `fe-check-setup` to confirm the server is available before tracker-dependent skills (`fe-to-prd`, `fe-to-issues`, `fe-to-review`) run.

Config patterns from rezolve-enrich-ai's `mcp.example.json` / `check-setup`.
