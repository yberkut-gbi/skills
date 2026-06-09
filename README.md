# fe — Frontend Standards Skills

> Composable [agent skills](https://skills.sh) for frontend engineering standards. The human stays *in the loop* — and the loop gets sharper every cycle.

Built for a mixed agent fleet (Claude Code, GitHub Copilot) and any IDE (VS Code, JetBrains, Cursor). Every skill is namespaced `fe-` so it sits side-by-side with other teams' sets without collision.

Two design commitments run through all of it:

1. **Shared memory is the backbone.** A small set of files in your repo — a domain glossary, decisions, and accumulated rules — is read and written by both you and every skill, so you stop talking past each other.
2. **You stay in control.** These are small, skippable, composable tools — not a process framework that owns your workflow.

## Install

Installed with [`npx skills`](https://www.npmjs.com/package/skills) (Vercel Labs). GitHub is the registry, so `owner/repo` maps to this repo.

```bash
# Browse and select skills (pick skills + target agents)
npx skills add yberkut-gbi/skills

# Install a single skill by direct path (rich skills bring their reference files)
npx skills add https://github.com/yberkut-gbi/skills/tree/main/skills/implement/fe-tdd

# Target specific agents
npx skills add yberkut-gbi/skills --agent claude-code

# List what's installed
npx skills list
```

Skills install into your agent's skills directory (e.g. `.claude/skills/`).

## Quick start

1. **Set up the substrate once per repo:** run `fe-setup`. It scaffolds the shared files (`CONTEXT.md`, `docs/adr/`, `docs/agents/config.md`, `team-rules.md`, `coaching-notes/`) and wires **Jira via the Atlassian MCP** — the only issue tracker the skills use (see [Jira](#jira-integration)). The autonomous runner needs no install: it ships with the `fe-ship` skill (`.claude/skills/fe-ship/fe-ship.sh`). Then run `fe-check-setup` to confirm the MCP is reachable.
2. **Drive a feature** with `fe-ship`, or invoke any skill directly. The conductor loads the substrate, then walks align → implement → improve — checking in with you at each step (interactive), or unattended when run headless.
3. **Let the loop run.** After a batch of PRs, run `fe-distill-rules` to turn coaching notes into sharper team rules; every few days, run `fe-deepen`.

**Going hands-off:** once an issue is spec-ready, `fe-ship` runs implement → green-gate → self-review → PR **unattended** — the only human step left is the PR review. Humans shape the spec (the `align` skills, interactive) and confirm the PR; AI owns everything between. Each autonomous run records its **token cost** beside the coaching note, so efficiency feeds the same learning loop. See [RUNNER.md](skills/conduct/fe-ship/RUNNER.md).

## The skills

**Conduct** — one conductor, two modes.
- `fe-ship` — drives a feature through the whole cycle (align → implement → green-gate → self-review → PR → coaching note). Run it **interactively** (default — checks in at each decision, you steer) or **unattended** (headless `claude -p` / CI / the bundled `.claude/skills/fe-ship/fe-ship.sh` runner — takes a ship-ready issue to a pre-reviewed PR with no human in the seat, holds a hard green gate, then stops for review). Same recipe, different posture. See [running it headless](skills/conduct/fe-ship/RUNNER.md).

**Shared memory** — the substrate everything reads from.
- `fe-setup` — scaffolds it once per repo; wires Jira via the Atlassian MCP.
- `fe-check-setup` — verifies the Atlassian (Jira) MCP is available.

**Align** — reach shared understanding before building. *(rich: ★)*
- `fe-grill-with-docs` ★ — stress-test the plan against the domain model; update `CONTEXT.md`/ADRs inline.
- `fe-to-prd` — synthesize the aligned context into a PRD with a team-rules-seeded gap-check; publish to the tracker.
- `fe-to-issues` ★ — slice the PRD into independently-grabbable vertical slices; create Jira stories/sub-tasks.

**Implement** — build with discipline.
- `fe-tdd` ★ — vertical-slice red→green→refactor toward deep modules.
- `fe-to-review` — reviewable commits, push, PR via `gh`; thread the Jira ticket through and link it back.

**Improve** — reflect and compound.
- `fe-deepen` ★ — periodic deep-module hygiene (controlled vocabulary + before/after report).
- `fe-coach` — growth-oriented note on the human–AI collaboration for each PR.
- `fe-distill-rules` — turns coaching notes into team rules.

**Anytime** — cross-cutting lenses, reach for them at any stage.
- `fe-zoom-out` — on-demand altitude on unfamiliar code.
- `fe-diagnose` — disciplined bug / performance loop.
- `fe-handoff` — carry context across sessions, models, and people.

★ = rich multi-file skill (a self-sufficient `SKILL.md` core plus reference files for depth, loaded on demand).

## Jira integration

Jira is the **only** issue tracker the skills use. `fe-setup` wires it through the official **Atlassian MCP server** (`https://mcp.atlassian.com/v1/mcp`, OAuth — no tokens in the repo). Your **cloud URL, project key, and status map live in `docs/agents/config.md`**, so the skills target *any* Jira project; nothing is hardcoded. `fe-to-prd` creates epics/stories, `fe-to-issues` creates stories/sub-tasks, and `fe-to-review` threads the ticket key and links the PR back — all by referencing Atlassian tools *by function*, so the same skills work whether tool IDs are prefixed `mcp__atlassian__` (Claude Code) or `mcp_com_atlassian_` (Copilot). (GitHub still hosts code and PRs — opened with the `gh` CLI — but it's not an issue tracker here, so no GitHub MCP is needed.)

**The ticket protocol.** Whenever a work skill (`fe-tdd`, `fe-ship`, `fe-diagnose`) begins on an existing ticket, it *claims* it: assign yourself if it's unassigned; if it's held by someone else, report **who and when** and ask before continuing — and on autonomous `fe-ship` runs, never steal it, just stop and escalate. It then moves the status to match the work (**In Progress** → **In Review**), and `fe-ship` adds an **`AFK`** label so the board shows agent-driven, away-from-keyboard work (cleared at the PR). Full protocol and tool map in `fe-setup/MCP-SETUP.md`; `fe-check-setup` verifies readiness.

**Model split.** Each skill pins a `model:` to match its work — **Opus** for the architectural and grilling skills (`fe-grill-with-docs`, `fe-to-prd`, `fe-to-issues`, `fe-deepen`, `fe-coach`, `fe-distill-rules`, `fe-zoom-out`), **Sonnet** for the development and mechanical ones (`fe-tdd`, `fe-to-review`, `fe-diagnose`, `fe-handoff`, `fe-setup`, `fe-check-setup`, and `fe-ship`, which executes within an already-pinned spec — override to Opus via `FE_SHIP_MODEL=opus` for an architecturally heavy ticket).

## The shared-memory substrate

| File | Purpose | Written by |
|------|---------|-----------|
| `CONTEXT.md` | Domain glossary + system map (ubiquitous language) | `fe-setup`, `fe-grill-with-docs` |
| `docs/adr/` | Architecture decision records | `fe-grill-with-docs`, `fe-deepen` |
| `docs/agents/config.md` | Jira project + status map + AFK/triage labels + doc layout | `fe-setup` |
| `docs/agents/team-rules.md` | Collaboration rules | `fe-distill-rules` |
| `docs/agents/coaching-notes/` | One note per PR (+ a token-cost record per autonomous run) | `fe-coach`, `fe-ship` runner |

## The two improvement loops

```
                         ┌──────────── COLLABORATION LOOP ────────────┐
                         │                                            │
  team-rules.md ─► fe-grill-with-docs / fe-to-prd ─► fe-tdd ─► PR ─► fe-coach
        ▲   (seeds alignment with what the team keeps leaving implicit)   │
        │                                                                 │
        └────────────────────── fe-distill-rules ◄──────────── coaching notes
                          (aggregates recurring gaps into rules)

                         ┌──────────── ARCHITECTURE LOOP ─────────────┐
   CONTEXT.md + ADRs ──► fe-deepen ──► updated ADRs / CONTEXT.md
                          (every few days, fights entropy)
```

The collaboration loop is the point: a gap caught at the **back** of the cycle (a coaching note) sharpens the alignment at the **front** of the next one. `fe-handoff` stitches both loops across time.

## Credit & provenance

The align layer, the shared-memory idea, and several implement/improve skills are inspired by **[Matt Pocock's `skills` repository](https://github.com/mattpocock/skills)** — `fe-grill-with-docs`, `fe-to-prd`, `fe-to-issues`, `fe-tdd`, `fe-deepen`, `fe-diagnose`, `fe-zoom-out`, `fe-handoff` are re-expressions of his, built around widely-used engineering practices: domain-driven design (Evans), deep modules (Ousterhout), tracer bullets (Hunt & Thomas), and TDD (Beck). Each derived skill carries a one-line credit.

The Jira/Atlassian-MCP wiring, the `fe-check-setup` readiness pattern, ticket-key threading, and the vertical-slice splitting strategies follow established agile and tooling practices, refined through production use across frontend projects.

Original to this set: `fe-ship` (the two-mode conductor), `fe-setup`, `fe-to-review`, `fe-coach`, `fe-distill-rules`, and the wiring that turns per-PR coaching into sharper team-wide alignment.

## License

MIT — see [LICENSE](./LICENSE).
