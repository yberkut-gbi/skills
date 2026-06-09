#!/usr/bin/env bash
# fe-ship — run one or more ready Jira issues to pre-reviewed PRs, unattended,
# with per-run token/cost accounting fed into the coaching loop.
#
# This is the CANONICAL runner. `fe-setup` installs a copy into each product
# repo at scripts/fe-ship.sh; RUNNER.md documents it. Keep this file the source
# of truth — edit here, not in copies.
#
# Usage:   scripts/fe-ship.sh ABC-123 ABC-124 ...
# Needs:   claude, jq, gh   (and git)
# Env:     FE_SHIP_MODEL      (default: sonnet — see RUNNER.md "Which model?";
#                              override to opus for architecturally heavy tickets)
#          FE_SHIP_MAX_TURNS  (default: 60)
#          FE_SHIP_TOOLS      (override the --allowedTools allowlist)
#          FE_SHIP_MCP_PREFIX (Atlassian MCP tools; default: mcp__atlassian__*)
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
NAME="$(basename "$REPO_ROOT")"
MODEL="${FE_SHIP_MODEL:-sonnet}"   # Sonnet for dev; FE_SHIP_MODEL=opus for architecturally heavy tickets
MAX_TURNS="${FE_SHIP_MAX_TURNS:-60}"

# The allowlist IS the autonomy boundary. A headless run has no human to approve
# a prompt, so any tool the recipe needs that is NOT listed here is silently
# denied — and the run stalls. fe-ship's very first step reads the Jira issue
# through the Atlassian MCP, so the MCP tools MUST be allowed or the run can't
# even start. The MCP tool glob depends on how your agent wires the server
# (Claude Code: mcp__atlassian__*; Copilot: mcp_com_atlassian_*); override it if needed.
MCP_PREFIX="${FE_SHIP_MCP_PREFIX:-mcp__atlassian__*}"
TOOLS="${FE_SHIP_TOOLS:-Read,Edit,Write,Bash(npm:*),Bash(pnpm:*),Bash(yarn:*),Bash(git:*),Bash(gh:*),${MCP_PREFIX}}"

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
      outcome: (if .is_error then "error" else (.terminal_reason // .subtype) end),
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
