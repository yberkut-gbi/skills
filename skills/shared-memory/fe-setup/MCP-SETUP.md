# MCP Setup

Jira is the **only** issue tracker the fe- skills use, via an MCP server. Configure it once per agent/IDE. It's remote (HTTP) and authenticates via **OAuth on first use** — no tokens in the repo. (GitHub is still where code and PRs live, but a PR is opened with the `gh` CLI in `fe-to-review` — it isn't an issue tracker, so no GitHub MCP is needed.)

## Server
- **Jira** — Atlassian **Rovo** MCP Server, `https://mcp.atlassian.com/v1/mcp` (read + write: search, get, create, edit, assign, transition, comment). Tool IDs carry a per-agent prefix, so skills reference them by **function + canonical base name** (tool map below), never one hardcoded ID.

## Jira tool map
Per-agent prefix: Claude Code `mcp__atlassian__<tool>` · Copilot `mcp_com_atlassian_<tool>`. Base names are the Atlassian Rovo MCP tools the fe- skills use:

| Function | Tool (base name) | Used by |
|---|---|---|
| Who am I | `atlassianUserInfo` | claim a ticket — get my own account id |
| Look up an account id | `lookupJiraAccountId` | resolve an assignee by name/email |
| Search issues (JQL) | `searchJiraIssuesUsingJql` | fe-check-setup probe; fe-ship ready-queue sweep |
| Get an issue | `getJiraIssue` | fe-tdd, fe-ship (fetch ticket + assignee + change history) |
| List visible projects | `getVisibleJiraProjects` | validate `jira.project` from config.md |
| Project issue types | `getJiraProjectIssueTypesMetadata` | pick Epic/Story/Sub-task on create |
| Create an issue | `createJiraIssue` | fe-to-prd (epic/story), fe-to-issues (stories/sub-tasks) |
| Edit an issue | `editJiraIssue` | set the **assignee**; add/remove **labels** (e.g. `AFK`) |
| Get transitions | `getTransitionsForJiraIssue` | find the id for the target status |
| Transition an issue | `transitionJiraIssue` | move status: In Progress, In Review, ready |
| Comment on an issue | `addCommentToJiraIssue` | fe-to-review (link the PR); stop-and-escalate notes |

Verified available in practice: `getJiraIssue`, `searchJiraIssuesUsingJql`. The rest are documented Atlassian Rovo tools — confirm with `fe-check-setup` (Atlassian may add/rename tools).

## The ticket protocol (assignment · status · AFK)
Whenever a skill **begins work on an existing Jira issue**, claim it first — so the board reflects reality and two workers never collide. The work skills (`fe-tdd`, `fe-ship`, `fe-diagnose`) all run this:

1. **Identify yourself** — `atlassianUserInfo` for your own account id.
2. **Read the ticket** — `getJiraIssue`, including its change history, for the current `assignee` and *when it was last set*.
3. **Act on the assignee state:**
   - **Unassigned** → assign yourself (`editJiraIssue`, set `assignee` to your account id).
   - **Already you** → continue.
   - **Someone else** → report **who** holds it and **when** it was assigned (from the change history), then resolve before touching code:
     - *Interactive runs* (`fe-tdd`, `fe-diagnose`, or `fe-ship` run interactively) — **ask the human**: reassign to me, or stop? Act on the answer; never reassign silently.
     - *Autonomous `fe-ship`* (headless) — no human is present to decide, so **never steal the ticket**. Stop and escalate: comment noting the current owner and when they were assigned, then exit.
4. **Move the status to match the work** — `getTransitionsForJiraIssue` for the target id, then `transitionJiraIssue`. Map lifecycle → your project's status name via the `statuses:` block in `config.md`:
   - starting implementation → **In Progress**
   - PR opened → **In Review**
   - (fe-to-prd marks a fresh spec → **ready**)
5. **AFK label — autonomous runs only.** When `fe-ship` picks up a ticket, add the **`AFK`** label (`editJiraIssue`, name from `jira.afk_label` in `config.md`) so humans scanning the board see the work is being driven away-from-keyboard by an agent. `fe-to-review` removes it once the PR is up and the ticket is back in human hands.

## Config per agent / IDE

Single source of truth for where each agent/IDE places its MCP config. Referenced by the fallback + preflight protocol and the publish skills — define here, reference everywhere else.

| Agent / IDE | OS | Schema key | File path | Committable? |
|---|---|---|---|---|
| **Claude Code CLI** | all | `mcpServers` | `.mcp.json` (repo root) | Yes |
| **Claude Code CLI** | macOS / Linux / WSL2 | `mcpServers` | `~/.claude/mcp.json` | No — user-global |
| **Claude Code CLI** | Windows | `mcpServers` | `C:\Users\<user>\.claude\mcp.json` | No — user-global |
| **Claude Desktop** | macOS | `mcpServers` | `~/Library/Application Support/Claude/claude_desktop_config.json` | No — user-global |
| **Claude Desktop** | Windows | `mcpServers` | `%APPDATA%\Claude\claude_desktop_config.json` | No — user-global |
| **Claude Desktop** | Linux | `mcpServers` | `~/.config/claude/claude_desktop_config.json` | No — user-global |
| **Claude Desktop** | WSL2 | `mcpServers` | `~/.config/claude/claude_desktop_config.json` | No — user-global |
| **Copilot / VS Code** | all | `servers` | `.vscode/mcp.json` (workspace) | Yes |
| **Copilot / VS Code** | macOS | `servers` | `~/Library/Application Support/Code/User/mcp.json` | No — user-global |
| **Copilot / VS Code** | Windows | `servers` | `%APPDATA%\Code\User\mcp.json` | No — user-global |
| **Copilot / VS Code** | Linux / WSL2 | `servers` | `~/.config/Code/User/mcp.json` | No — user-global |
| **Copilot / WebStorm** | macOS | `servers` | `~/Library/Application Support/JetBrains/<product>/github-copilot/mcp.json` | No — user-global |
| **Copilot / WebStorm** | Windows | `servers` | `%APPDATA%\JetBrains\<product>\github-copilot\mcp.json` | No — user-global |
| **Copilot / WebStorm** | Linux / WSL2 | `servers` | `~/.config/JetBrains/<product>/github-copilot/mcp.json` | No — user-global |

`<product>` for WebStorm is the IDE + version directory (e.g. `WebStorm2024.3`). Claude Desktop has no committable config — all installs are user-global.

### Config snippets

**Claude Code CLI** — `.mcp.json` at repo root (or user-global path above):
```json
{ "mcpServers": {
  "atlassian": { "type": "http", "url": "https://mcp.atlassian.com/v1/mcp" }
} }
```

**Copilot / VS Code or WebStorm** — `.vscode/mcp.json` (workspace) or user-global path above:
```json
{ "servers": {
  "com.atlassian/atlassian-mcp-server": { "type": "http", "url": "https://mcp.atlassian.com/v1/mcp" }
} }
```

**Claude Desktop** — `claude_desktop_config.json` at the user-global path above:
```json
{ "mcpServers": {
  "atlassian": { "type": "http", "url": "https://mcp.atlassian.com/v1/mcp" }
} }
```

After adding the server, you'll be prompted to authenticate with your Atlassian account on first use.

## Verify
Run `fe-check-setup` to confirm the server is available before tracker-dependent skills (`fe-to-prd`, `fe-to-issues`, `fe-to-review`) run.

Each snippet is per agent/IDE — adapt the server key and URL to your setup; the function-based tool map keeps the skills portable across them.
