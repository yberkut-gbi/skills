# MCP Setup

Jira is the **only** issue tracker the fe- skills use, via an MCP server. Configure it once per agent/IDE. It's remote (HTTP) and authenticates via **OAuth on first use** — no tokens in the repo. (GitHub is still where code and PRs live, but a PR is opened with the `gh` CLI in `fe-to-review` — it isn't an issue tracker, so no GitHub MCP is needed.)

## Server
- **Jira** — Atlassian **Rovo** MCP Server, `https://mcp.atlassian.com/v1/mcp` (read + write: search, get, create, edit, assign, transition, comment). Tool IDs carry a per-agent prefix, so skills reference them by **function + canonical base name** (tool map below), never one hardcoded ID.

## Jira tool map
Per-agent prefix: Claude Code `mcp__atlassian__<tool>` · Copilot `mcp_com_atlassian_<tool>`. Base names are the Atlassian Rovo MCP tools the fe- skills use:

| Function | Tool (base name) | Used by |
|---|---|---|
| Who am I | `atlassianUserInfo` | claim a ticket — get my own account id |
| List accessible sites (resolve cloudId) | `getAccessibleAtlassianResources` | **first call of any session** — resolve the cloudId before any Jira read/write |
| Look up an account id | `lookupJiraAccountId` | resolve an assignee by name/email |
| Search issues (JQL) | `searchJiraIssuesUsingJql` | fe-check-setup probe; fe-ship ready-queue sweep |
| Get an issue | `getJiraIssue` | fe-tdd, fe-ship (fetch ticket + assignee + change history) |
| List visible projects | `getVisibleJiraProjects` | validate `jira.project` from config.md |
| Project issue types | `getJiraProjectIssueTypesMetadata` | pick Epic/Story/Sub-task on create |
| Create an issue | `createJiraIssue` | fe-to-prd (epic/story), fe-to-issues (stories/sub-tasks) |
| Edit an issue | `editJiraIssue` | set the **assignee**; add/remove **labels** |
| Get transitions | `getTransitionsForJiraIssue` | find the id for the target status |
| Transition an issue | `transitionJiraIssue` | move status: In Progress, In Review, ready |
| Comment on an issue | `addCommentToJiraIssue` | fe-to-review (link the PR); stop-and-escalate notes |

Verified available in practice: `getJiraIssue`, `searchJiraIssuesUsingJql`, `getAccessibleAtlassianResources`. The rest are documented Atlassian Rovo tools — confirm with `fe-check-setup` (Atlassian may add/rename tools).

## Resolving the cloudId (do this first — never guess the site)

Every Jira/Confluence tool needs a **cloudId**. The Rovo MCP only honours a cloudId the OAuth grant **explicitly** covers. Inferring one from the project key or a familiar company name fails hard:

```
Cloud id: <uuid> isn't explicitly granted by the user.
```

So before the first Jira read or write in a session, resolve the cloudId — don't hardcode or guess it:

1. **Call `getAccessibleAtlassianResources`** — it returns every site the current OAuth token can reach, each with its `id` (the cloudId, a UUID) and `url` (e.g. `https://your-org.atlassian.net`).
2. **Pick the site** whose `url` matches `jira.cloud_url` in `docs/agents/config.md`. If `config.md` stores a hostname rather than a UUID, you may pass that hostname as `cloudId` directly — the tools accept either a UUID **or** a site URL — but if that 401s, fall back to the UUID from step 1.
3. **Reuse that cloudId** for every subsequent call in the session.

If `getAccessibleAtlassianResources` returns **zero** sites, the OAuth scope never completed — re-run the IDE's MCP auth (see *Config per agent / IDE*). If it returns a site but **not** the one in `config.md`, the signed-in account lacks access to that org — surface this to the human rather than silently using the wrong site.

> **Keep `config.md` honest.** After resolving, make sure `jira.cloud_url` holds the exact `url` (or its UUID) returned by `getAccessibleAtlassianResources`, so later runs resolve on the first try.

## The ticket protocol (assignment · status)
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
   - PR opened → **In Review** (some projects call this **Code Review** — always use the name from `config.md`)
   - (fe-to-prd marks a fresh spec → **ready**)
   - **Re-fetch transitions after every status move.** The available transitions change with each status — for example, "Code Review" is only offered from In Progress, not from Opened. Never reuse a transition list across two consecutive moves; always call `getTransitionsForJiraIssue` again before the next transition.

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
| **Copilot / WebStorm** | macOS | `servers` | `~/.config/github-copilot/intellij/mcp.json` | No — user-global |
| **Copilot / WebStorm** | Windows | `servers` | `%APPDATA%\github-copilot\intellij\mcp.json` | No — user-global |
| **Copilot / WebStorm** | Linux / WSL2 | `servers` | `~/.config/github-copilot/intellij/mcp.json` | No — user-global |

Claude Desktop has no committable config — all installs are user-global.

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

---

## Prerequisite preflight — referenced by the publish skills

> **Defined here, referenced by `fe-to-prd`, `fe-to-issues`, and `fe-to-review`. Do not duplicate this logic in individual skills.**

Before doing any Jira work, every publish skill checks that the shared-memory substrate is in place and that the Atlassian MCP is reachable:

**What to check:**
1. `docs/agents/config.md` exists and is non-empty — contains `jira.cloud_url`, `jira.project`, and the `statuses:` block.
2. At least one substrate file is present (`CONTEXT.md` or `docs/agents/team-rules.md`) — confirms `fe-setup` has run.
3. The Atlassian MCP is reachable — call `atlassianUserInfo`; if it throws or returns an error, the server is down or not configured.
4. The target site is granted — call `getAccessibleAtlassianResources` and confirm a site matching `jira.cloud_url` is returned (see *Resolving the cloudId*). A reachable server that doesn't grant the configured site is still a failed preflight.

**If any check fails, emit this exact notice and stop:**

```
fe-setup has not been run, or the Atlassian MCP is not configured.

Run fe-setup first to scaffold the shared-memory substrate and configure
the Jira MCP connection, then retry this skill.

Missing: <list the specific file or tool that failed the check>
```

Do not guess or proceed past a failed preflight. A corrupted substrate is harder to recover than a clean stop.

---

## Publish & degraded-mode fallback — referenced by the publish skills

> **Defined here, referenced by `fe-to-prd`, `fe-to-issues`, and `fe-to-review`. Do not duplicate this logic in individual skills.**

When the Atlassian MCP tools are not callable (network error, auth failure, tool not found), a publish skill **must not silently discard its output**. Instead:

**1. Save a holding doc.**
Write the full intended Jira payload to `docs/agents/holding/<YYYY-MM-DD>-<SKILL>-<KEY>.md` (e.g. `docs/agents/holding/2025-06-10-fe-to-prd-EN-1234.md`). The file must contain everything needed to reproduce the call manually: the issue type, summary, description (in full), parent link, labels, and any other fields the skill would have set.

**2. Emit the exact hand-off steps for the user.**
Print these steps verbatim (substituting real values):

```
Atlassian MCP is unreachable — Jira was not updated automatically.

To complete this step manually:

  createJiraIssue:
    cloudId: <value from docs/agents/config.md jira.cloud_url>
    projectKey: <value from docs/agents/config.md jira.project>
    issueType: <Story | Epic | Sub-task>
    summary: "<summary>"
    description: "<description>"
    parent: <parent issue key, if applicable>
    labels: [<labels>]

  After creating the issue, link it back:
  editJiraIssue:
    issueIdOrKey: <new issue key>
    fields:
      <any additional fields the skill would have set>

The holding doc is at: docs/agents/holding/<filename>
```

**3. Do not retry silently.** If the call fails, fall through to the holding doc immediately. Do not loop or swallow the error. Surface it to the human and stop.

**Scope:** This fallback covers the *Jira write* leg only. If the skill writes files to the repo (a PRD doc, a coaching note, a PR branch), it should still complete those steps — the fallback is for the tracker update, not the whole skill.
