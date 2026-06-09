# Running `fe-ship` headless

`fe-ship` is just the recipe. This is the **runner** — how you execute that recipe with no human in the seat, against **Jira**, while accounting for token cost so efficiency becomes a coaching signal. Start local; the same prompt and skills graduate to CI or cloud later without change.

## The minimal invocation

From inside a target repo (one that has run `fe-setup`, with the tracker pointed at Jira in `docs/agents/config.md`):

```bash
claude -p "Use the fe-ship skill to take Jira issue ABC-123 to a pre-reviewed PR. \
Do not merge; stop at the PR for human review." \
  --model sonnet \
  --max-turns 60 \
  --permission-mode acceptEdits \
  --allowedTools "Read,Edit,Write,Bash(npm:*),Bash(pnpm:*),Bash(git:*),Bash(gh:*),mcp__atlassian__*" \
  --output-format stream-json --verbose
```

- `--model sonnet` — `fe-ship` is autonomous **development** within an already-pinned spec (it stops rather than make architectural calls), so Sonnet is the right default for cost and speed. Override to Opus for an architecturally heavy ticket: `FE_SHIP_MODEL=opus`.
- `--permission-mode acceptEdits` lets it edit files without prompting while still gating risky commands.
- `--allowedTools` is both the safety boundary **and the autonomy boundary**. A headless run has no human to approve a prompt, so any tool the recipe needs that isn't listed here is silently denied — and the run stalls or stops short. `fe-ship`'s very first step reads the Jira issue through the Atlassian MCP, and it needs those tools to claim the ticket, set the `AFK` label, and move the status, so **the MCP tools must be in the allowlist or the run can't even start** (`mcp__atlassian__*` for Claude Code, `mcp_com_atlassian_*` for Copilot — match yours).
- `--max-turns` caps a runaway loop. Tune to your largest realistic slice.

## The script — Jira-native, worktree-isolated, cost-accounted

The canonical runner ships with this skill as [`fe-ship.sh`](fe-ship.sh) — a real, executable file, not a snippet to retype. Each Jira issue runs in its own `git worktree`, so you can ship several at once with no collisions — the Boris Cherny parallel pattern — and each run records exactly what it cost.

**Install it once per product repo.** `fe-setup` does this for you (it copies the runner into `scripts/fe-ship.sh` and `chmod +x`es it). To install by hand:

```bash
# from your product repo, with the skills installed under your agent's skills dir:
cp "$(find ~/.claude ~/.config -path '*conduct/fe-ship/fe-ship.sh' 2>/dev/null | head -1)" scripts/fe-ship.sh
chmod +x scripts/fe-ship.sh        # needs: claude, jq, gh
```

It is parameterised by environment variable, so you rarely edit it:

| Env var | Default | Purpose |
|---|---|---|
| `FE_SHIP_MODEL` | `sonnet` | model for the headless run (override to `opus` for architecturally heavy tickets) |
| `FE_SHIP_MAX_TURNS` | `60` | runaway-loop cap |
| `FE_SHIP_MCP_PREFIX` | `mcp__atlassian__*` | Atlassian MCP tools (`mcp_com_atlassian_*` for Copilot) |
| `FE_SHIP_TOOLS` | derived | full `--allowedTools` override |

The runner already folds the Atlassian MCP prefix into `--allowedTools` — without it the headless run can't read the Jira issue and stalls at step 0 (see the autonomy-boundary note above). After `claude -p` exits it greps the `"type":"result"` object from the stream, transforms it with `jq` into `docs/agents/coaching-notes/<date>-<KEY>.cost.json`, and commits that record onto the PR branch.

`fe-ship` threads the ticket key through the branch and PR; the `feat/${key}` worktree branch is just the staging branch it builds on. Clean up finished worktrees with `git worktree prune` / `git worktree remove`.

## Across the Jira backlog (the `/loop` layer)

`/loop` is the conveyor belt, not the worker. Jira is your tracker, so "which issues are ready" is a **JQL** query — and JQL runs through the Atlassian MCP (the agent), not the shell. Two ways, both keyed off the ready-state convention in `docs/agents/config.md` (e.g. status `AI Ready` or a label):

```bash
# A. Let the agent pick and dispatch (simplest) — wrap in /loop to keep draining the queue:
claude -p "Find Jira issues in project <KEY> that are AI-ready (JQL via the Atlassian MCP). \
For each, use the fe-ship skill to take it to a pre-reviewed PR. One at a time; stop each at the PR." \
  --permission-mode acceptEdits \
  --allowedTools "Read,Edit,Write,Bash(npm:*),Bash(git:*),Bash(gh:*),mcp__atlassian__*"

# B. Ask the agent once for the ready keys, then fan out for parallelism + per-run cost:
scripts/fe-ship.sh ABC-123 ABC-124 ABC-125
```

Path A is hands-off but serial; path B parallelizes and gives you the per-issue cost records and fleet summary. Either way, `fe-to-review` links each PR back to its Jira ticket.

## Cost & efficiency accounting

Every autonomous run emits a `"type":"result"` object the runner mines (fields verified against CLI 2.x `--output-format stream-json`):

| Field | Meaning |
|---|---|
| `total_cost_usd` | dollar cost of the whole run |
| `usage.input_tokens` / `output_tokens` | billed tokens |
| `usage.cache_read_input_tokens` / `cache_creation_input_tokens` | cache hits vs. fresh context (cache reads are cheap — high creation, low reads = wasteful re-priming) |
| `num_turns` | agentic iterations (churn signal) |
| `terminal_reason` (e.g. `completed`) / `is_error` | did it finish, or stop-and-escalate? |
| `modelUsage` | per-model spend (`costUSD`, `inputTokens`, `outputTokens` per model — e.g. Opus doing work Sonnet could) |

The runner writes these to `docs/agents/coaching-notes/<date>-<KEY>.cost.json` and commits it onto the PR branch. That puts the number next to the qualitative note `fe-coach` wrote during the run, so **`fe-distill-rules` can join cost to cause** — e.g. high `num_turns` + a `spec-clarity` growth_area = "this issue was too thin; run `fe-grill-with-docs` first." Cost stops being a bill and becomes a coaching signal.

### Which model? (`FE_SHIP_MODEL`)

The default is **`sonnet`** — `fe-ship` runs autonomous *development* against an already-pinned spec, stopping rather than making architectural calls, so Sonnet's balance of cost and speed fits the bulk of the queue. The price gap is real (Opus 4.8 is ~1.67× Sonnet 4.6 per token — $5/$25 vs $3/$15 per 1M), so reserve Opus for tickets where it earns its keep. Override per-run for an architecturally heavy or unusually ambiguous ticket:

```bash
FE_SHIP_MODEL=opus scripts/fe-ship.sh ABC-123
```

Don't drop below Sonnet for shipping — Haiku isn't sized for the green-gate-and-self-review loop. And `fe-distill-rules` reads the per-model spend in the cost records, so a miscalibrated default (Opus routinely doing work Sonnet could, or Sonnet churning turns on work that wanted Opus) shows up as a signal to retune.

## Permissions & safety, briefly

- **Default:** scoped `--allowedTools` + `--permission-mode acceptEdits`, run in a worktree. Unattended and bounded.
- **Fire-and-forget in a sandbox/container only:** `--dangerously-skip-permissions` removes every gate. Never on a dev machine with credentials or against `main` — only in a throwaway, isolated environment.
- The real safety net is **the green gate inside `fe-ship`**: no PR opens on a red build. Keep your `typecheck`/`lint`/`test`/`build` scripts honest and fast, and the autonomy stays safe.

## Graduating to CI or cloud (later, same recipe)

When local proves out, the *same* `fe-ship` skill and prompt move up the stack — only the runner and trigger change:

- **GitHub Action** — `anthropics/claude-code-action@v1`, triggered on a Jira→GitHub bridge or a label; pass the same prompt. The same result JSON is available in the Action logs for cost accounting. Auth via Anthropic API key, or Bedrock/Vertex if data residency requires it.
- **Cloud (Claude Code on the web + Routines)** — schedule a routine that runs the JQL sweep and ships each ready issue on Anthropic-hosted infra, and can auto-fix on CI/review-comment events.

Debug autonomy locally first — it's far harder to diagnose a headless loop you can't watch.
