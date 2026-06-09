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
- `--allowedTools` is the safety boundary — scope it to the build tools your repos actually use. **Include the Atlassian MCP tools** (`mcp__atlassian__*`, or your agent's prefix) — a headless run can't answer a permission prompt, and it needs them to claim the ticket, set the AFK label, and move the status.
- `--max-turns` caps a runaway loop. Tune to your largest realistic slice.

## The script — Jira-native, worktree-isolated, cost-accounted

Drop this in your **product** repos (e.g. `scripts/fe-ship.sh`, `chmod +x`; needs `jq`). Each Jira issue runs in its own `git worktree`, so you can ship several at once with no collisions — the Boris Cherny parallel pattern — and each run records exactly what it cost.

```bash
#!/usr/bin/env bash
# fe-ship — run one or more ready Jira issues to pre-reviewed PRs, unattended,
# with per-run token/cost accounting fed into the coaching loop.
# Usage: scripts/fe-ship.sh ABC-123 ABC-124 ...   (requires: claude, jq, gh)
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
NAME="$(basename "$REPO_ROOT")"
MODEL="${FE_SHIP_MODEL:-sonnet}"   # Sonnet for dev; FE_SHIP_MODEL=opus for architecturally heavy tickets
MAX_TURNS="${FE_SHIP_MAX_TURNS:-60}"
TOOLS="Read,Edit,Write,Bash(npm:*),Bash(pnpm:*),Bash(yarn:*),Bash(git:*),Bash(gh:*),mcp__atlassian__*"
COSTLOG="${REPO_ROOT}/.fe-ship-cost.log"; : > "$COSTLOG"

ship_one() {
  local key="$1"
  local wt="${REPO_ROOT}/../${NAME}-${key}"
  echo "▶ ${key} → ${wt}"
  git -C "$REPO_ROOT" worktree add -q "$wt" -b "feat/${key}" 2>/dev/null \
    || git -C "$REPO_ROOT" worktree add -q "$wt" "feat/${key}"

  ( cd "$wt"
    claude -p "Use the fe-ship skill to take Jira issue ${key} to a pre-reviewed PR. Do not merge; stop at the PR for human review." \
      --model "$MODEL" --max-turns "$MAX_TURNS" \
      --permission-mode acceptEdits --allowedTools "$TOOLS" \
      --output-format stream-json --verbose \
      2>&1 | tee "fe-ship-${key}.log"

    # --- cost accounting: pull the final result object from the stream ---
    local res; res="$(grep '"type":"result"' "fe-ship-${key}.log" | tail -1 || true)"
    if [ -z "$res" ]; then printf '%s\tNO-RESULT\t-\t-\n' "$key" >> "$COSTLOG"; return; fi

    local rec
    rec="$(printf '%s' "$res" | jq -c --arg t "$key" --arg d "$(date +%F)" '{
      ticket: $t, date: $d,
      outcome: (if .is_error then "error" else .terminal_reason end),
      cost_usd: .total_cost_usd, num_turns: .num_turns, duration_ms: .duration_ms,
      session_id: .session_id,
      tokens: { input: .usage.input_tokens, output: .usage.output_tokens,
                cache_read: .usage.cache_read_input_tokens,
                cache_creation: .usage.cache_creation_input_tokens },
      model_usage: ( .modelUsage // {} | to_entries
                     | map({ (.key): { cost_usd: .value.costUSD,
                                       in: .value.inputTokens, out: .value.outputTokens } })
                     | add )
    }' || true)"

    # land the cost record beside the coaching note, on the PR branch
    local notes="docs/agents/coaching-notes"; mkdir -p "$notes"
    local f="${notes}/$(date +%F)-${key}.cost.json"
    printf '%s\n' "$rec" | jq . > "$f"
    git add "$f" >/dev/null 2>&1 \
      && git commit -q -m "chore(${key}): autonomous run cost record" >/dev/null 2>&1 \
      && git push -q >/dev/null 2>&1 || true

    printf '%s\t$%s\t%s turns\t%s\n' \
      "$key" "$(printf '%s' "$rec" | jq -r '.cost_usd')" \
      "$(printf '%s' "$rec" | jq -r '.num_turns')" \
      "$(printf '%s' "$rec" | jq -r '.outcome')" >> "$COSTLOG"
  )
}

for key in "$@"; do ship_one "$key" & done
wait

echo; echo "── fleet cost summary ──"
column -t -s "$(printf '\t')" "$COSTLOG" 2>/dev/null || cat "$COSTLOG"
awk -F'\t' '{gsub(/\$/,"",$2); s+=$2} END{printf "TOTAL: $%.4f across %d run(s)\n", s, NR}' "$COSTLOG"
echo "Per-run detail: docs/agents/coaching-notes/<date>-<KEY>.cost.json (on each PR branch)"
echo "✓ Review the PRs (the one human gate)."
```

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

Every autonomous run emits a result object the runner mines (verified fields, CLI 2.1.x):

| Field | Meaning |
|---|---|
| `total_cost_usd` | dollar cost of the whole run |
| `usage.input_tokens` / `output_tokens` | billed tokens |
| `usage.cache_read_input_tokens` / `cache_creation_input_tokens` | cache hits vs. fresh context (cache reads are cheap — high creation, low reads = wasteful re-priming) |
| `num_turns` | agentic iterations (churn signal) |
| `terminal_reason` / `is_error` | did it `complete`, or stop-and-escalate? |
| `modelUsage` | per-model spend (e.g. Opus doing work Haiku could) |

The runner writes these to `docs/agents/coaching-notes/<date>-<KEY>.cost.json` and commits it onto the PR branch. That puts the number next to the qualitative note `fe-coach` wrote during the run, so **`fe-distill-rules` can join cost to cause** — e.g. high `num_turns` + a `spec-clarity` growth_area = "this issue was too thin; run `fe-grill-with-docs` first." Cost stops being a bill and becomes a coaching signal.

## Permissions & safety, briefly

- **Default:** scoped `--allowedTools` + `--permission-mode acceptEdits`, run in a worktree. Unattended and bounded.
- **Fire-and-forget in a sandbox/container only:** `--dangerously-skip-permissions` removes every gate. Never on a dev machine with credentials or against `main` — only in a throwaway, isolated environment.
- The real safety net is **the green gate inside `fe-ship`**: no PR opens on a red build. Keep your `typecheck`/`lint`/`test`/`build` scripts honest and fast, and the autonomy stays safe.

## Graduating to CI or cloud (later, same recipe)

When local proves out, the *same* `fe-ship` skill and prompt move up the stack — only the runner and trigger change:

- **GitHub Action** — `anthropics/claude-code-action@v1`, triggered on a Jira→GitHub bridge or a label; pass the same prompt. The same result JSON is available in the Action logs for cost accounting. Auth via Anthropic API key, or Bedrock/Vertex if data residency requires it.
- **Cloud (Claude Code on the web + Routines)** — schedule a routine that runs the JQL sweep and ships each ready issue on Anthropic-hosted infra, and can auto-fix on CI/review-comment events.

Debug autonomy locally first — it's far harder to diagnose a headless loop you can't watch.
