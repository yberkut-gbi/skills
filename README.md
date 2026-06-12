# fe — Frontend Standards Skills

> Composable [agent skills](https://skills.sh) for frontend engineering standards. The human stays *in the loop* — and the loop gets sharper every cycle.

Built for a mixed agent fleet (Claude Code, GitHub Copilot) and any IDE (VS Code, JetBrains, Cursor). Every skill is namespaced so it sits side-by-side with other teams' sets without collision: `core-` for the foundation, `fe-` for engineering, `pm-` for product.

Two design commitments run through all of it:

1. **Shared memory is the backbone.** A small set of files in your repo — a domain glossary, decisions, and accumulated rules — is read and written by both you and every skill, so you stop talking past each other.
2. **You stay in control.** These are small, skippable, composable tools — not a process framework that owns your workflow.

## Install

Installed with [`npx skills`](https://www.npmjs.com/package/skills) (Vercel Labs). Skills are organized into three installable groups; install core first (both other groups depend on it):

```bash
# Install all three groups
npx skills add yberkut-gbi/skills/tree/main/skills/core         # always — foundation
npx skills add yberkut-gbi/skills/tree/main/skills/engineering  # build a ship-ready issue → PR
npx skills add yberkut-gbi/skills/tree/main/skills/product      # decide what to build → issue

# Or browse and select individually
npx skills add yberkut-gbi/skills

# Install a single skill by direct path
npx skills add https://github.com/yberkut-gbi/skills/tree/main/skills/engineering/fe-tdd

# Target specific agents
npx skills add yberkut-gbi/skills/tree/main/skills/core --agent claude-code

# List what's installed
npx skills list
```

Skills install into your agent's skills directory (e.g. `.claude/skills/`).

## Quick start

1. **Set up the substrate once per repo:** run `core-setup`. It scaffolds the shared files (`CONTEXT.md`, `docs/adr/`, `docs/agents/config.md`, `team-rules.md`, `coaching-notes/`) and wires **Jira via the Atlassian MCP** — the only issue tracker the skills use (see [Jira](#jira-integration)). The autonomous runner needs no install: it ships with the `fe-flow` skill (`.claude/skills/fe-flow/fe-flow.sh`). Then run `core-check-setup` to confirm the MCP is reachable.
2. **Drive a feature** with `fe-flow`, or invoke any skill directly. The conductor loads the substrate, then walks align → implement → improve — checking in with you at each step (interactive), or unattended when run headless.
3. **Let the loop run.** After a batch of PRs, run `core-distill-rules` to turn coaching notes into sharper team rules; every few days, run `fe-deepen`.

**Going hands-off:** once an issue is spec-ready, `fe-flow` runs implement → green-gate → self-review → PR **unattended** — the only human step left is the PR review. Humans shape the spec (the `core` and `product` skills, interactive) and confirm the PR; AI owns everything between. Each autonomous run records its **token cost** beside the coaching note, so efficiency feeds the same learning loop. See [RUNNER.md](skills/engineering/fe-flow/RUNNER.md).

## The skills

**Core** — the foundation every other group builds on. *(rich: ★)*
- `core-setup` ★ — scaffolds the shared-memory substrate once per repo; wires Jira via the Atlassian MCP. Reference files: [`MCP-SETUP.md`](skills/core/core-setup/MCP-SETUP.md) (tool map, ticket protocol, MCP configs), [`orchestration-spine.md`](skills/core/core-setup/orchestration-spine.md) (shared conductor contract — checkpoint dial, mandatory-fork floor, verifier loop, resume-by-artifact, sub-agent degradation), [`facilitation.md`](skills/core/core-setup/facilitation.md) (AFCI + PDF-Loop patterns, reference only).
- `core-check-setup` — verifies the Atlassian (Jira) MCP is available.
- `core-grill` ★ — stress-test the plan against the domain model; update `CONTEXT.md`/ADRs inline.
- `core-diagnose` — disciplined bug / performance loop.
- `core-handoff` — carry context across sessions, models, and people.
- `core-zoom-out` — on-demand altitude on unfamiliar code.
- `core-distill-rules` — turns coaching notes into team rules.

**Engineering** — build a ship-ready issue into a PR. *(rich: ★)*
- `fe-flow` — drives a feature through the whole cycle (align → implement → green-gate → self-review → PR → coaching note). Run it **interactively** (default — checks in at each decision, you steer) or **unattended** (headless `claude -p` / CI / the bundled `.claude/skills/fe-flow/fe-flow.sh` runner — takes a ship-ready issue to a pre-reviewed PR with no human in the seat, holds a hard green gate, then stops for review). Same recipe, different posture. See [running it headless](skills/engineering/fe-flow/RUNNER.md).
- `fe-tdd` ★ — vertical-slice red→green→refactor toward deep modules.
- `fe-verify-ui` — Playwright arm on the green gate: launch app → screenshot key states → exercise interactions → assert values came from a real API (fail on placeholder/mock). Pure bash + Node; optional browser-MCP enrichment; never a hard dependency.
- `fe-to-review` — reviewable commits, push, PR via `gh`; thread the Jira ticket through and link it back.
- `fe-run` — launch the dev server (detect command, clear ports, tail output, common-failure playbook).
- `fe-deepen` ★ — periodic deep-module hygiene (controlled vocabulary + before/after report).
- `fe-coach` — growth-oriented note on the human–AI collaboration for each PR.

**Product** — decide what to build → a ship-ready issue. *(rich: ★)*
- `pm-discover-flow` — pre-ticket PM conductor: sequences discover (`pm-discover`) → frame (`pm-frame`) → **Decide** (`core-grill`). Decide is a mandatory fork — pauses for human confirmation (interactive) or stops-and-escalates (headless). Output: a direction-locked opportunity brief.
- `pm-discover` — explore the problem space before writing a ticket: surface user pain, stakeholder context, existing patterns, and opportunity signals; output a problem statement ready for `pm-frame`.
- `pm-frame` — shape a discovered problem into an opportunity frame: boundaries, success criteria, three solution bets (PDF-Loop), risks, and a recommended direction; output an opportunity brief ready for `core-grill` → `pm-to-prd`.
- `pm-to-prd` — synthesize the aligned context into a PRD with a team-rules-seeded gap-check; publish to the tracker.
- `pm-to-issues` ★ — slice the PRD into independently-grabbable vertical slices; create Jira stories/sub-tasks.

★ = rich multi-file skill (a self-sufficient `SKILL.md` core plus reference files for depth, loaded on demand).

## Jira integration

Jira is the **only** issue tracker the skills use. `core-setup` wires it through the official **Atlassian MCP server** (`https://mcp.atlassian.com/v1/mcp`, OAuth — no tokens in the repo). Your **cloud URL, project key, and status map live in `docs/agents/config.md`**, so the skills target *any* Jira project; nothing is hardcoded. `pm-to-prd` creates epics/stories, `pm-to-issues` creates stories/sub-tasks, and `fe-to-review` threads the ticket key and links the PR back — all by referencing Atlassian tools *by function*, so the same skills work whether tool IDs are prefixed `mcp__atlassian__` (Claude Code) or `mcp_com_atlassian_` (Copilot). (GitHub still hosts code and PRs — opened with the `gh` CLI — but it's not an issue tracker here, so no GitHub MCP is needed.)

**Publish convention.** The three publish skills share two behaviours defined **once** in `MCP-SETUP.md` and referenced, not duplicated, by each: a *prerequisite preflight* (checks that the substrate + MCP are in place before any Jira write) and a *publish & degraded-mode fallback* (writes a holding doc and emits hand-off steps when the MCP is unreachable). See `skills/core/core-setup/MCP-SETUP.md` §§ "Prerequisite preflight" and "Publish & degraded-mode fallback".

**The ticket protocol.** Whenever a work skill (`fe-tdd`, `fe-flow`, `core-diagnose`) begins on an existing ticket, it *claims* it: assign yourself if it's unassigned; if it's held by someone else, report **who and when** and ask before continuing — and on autonomous `fe-flow` runs, never steal it, just stop and escalate. It then moves the status to match the work (**In Progress** → **In Review**). Full protocol and tool map in `core-setup/MCP-SETUP.md`; `core-check-setup` verifies readiness.

**Model split.** Each skill pins a `model:` to match its work — **Opus** for the architectural and grilling skills (`core-grill`, `pm-discover`, `pm-frame`, `pm-discover-flow`, `pm-to-prd`, `pm-to-issues`, `fe-deepen`, `fe-coach`, `core-distill-rules`, `core-zoom-out`), **Sonnet** for the development and mechanical ones (`fe-tdd`, `fe-verify-ui`, `fe-to-review`, `fe-run`, `core-diagnose`, `core-handoff`, `core-setup`, `core-check-setup`, and `fe-flow`, which executes within an already-pinned spec — override to Opus via `FE_SHIP_MODEL=opus` for an architecturally heavy ticket).

## The shared-memory substrate

| File | Purpose | Written by |
|------|---------|-----------|
| `CONTEXT.md` | Domain glossary + system map (ubiquitous language) | `core-setup`, `core-grill` |
| `docs/adr/` | Architecture decision records | `core-grill`, `fe-deepen` |
| `docs/agents/config.md` | Jira project + status map + triage labels + doc layout | `core-setup` |
| `docs/agents/team-rules.md` | Collaboration rules | `core-distill-rules` |
| `docs/agents/coaching-notes/` | One note per PR (+ a token-cost record per autonomous run) | `fe-coach`, `fe-flow` runner |
| `docs/agents/holding/` | Degraded-mode fallback — holding docs when Atlassian MCP is unreachable | `pm-to-prd`, `pm-to-issues`, `fe-to-review` |

## The two improvement loops

```
                         ┌──────────── COLLABORATION LOOP ────────────┐
                         │                                            │
  team-rules.md ─► core-grill / pm-to-prd ─► fe-tdd ─► PR ─► fe-coach
        ▲   (seeds alignment with what the team keeps leaving implicit)   │
        │                                                                 │
        └────────────────────── core-distill-rules ◄──────────── coaching notes
                          (aggregates recurring gaps into rules)

                         ┌──────────── ARCHITECTURE LOOP ─────────────┐
   CONTEXT.md + ADRs ──► fe-deepen ──► updated ADRs / CONTEXT.md
                          (every few days, fights entropy)
```

The collaboration loop is the point: a gap caught at the **back** of the cycle (a coaching note) sharpens the alignment at the **front** of the next one. `core-handoff` stitches both loops across time.

## Credit & provenance

The align layer, the shared-memory idea, and several implement/improve skills are inspired by **[Matt Pocock's `skills` repository](https://github.com/mattpocock/skills)** — `core-grill`, `pm-to-prd`, `pm-to-issues`, `fe-tdd`, `fe-deepen`, `core-diagnose`, `core-zoom-out`, `core-handoff` are re-expressions of his, built around widely-used engineering practices: domain-driven design (Evans), deep modules (Ousterhout), tracer bullets (Hunt & Thomas), and TDD (Beck). Each derived skill carries a one-line credit.

The Jira/Atlassian-MCP wiring, the `core-check-setup` readiness pattern, ticket-key threading, and the vertical-slice splitting strategies follow established agile and tooling practices, refined through production use across frontend projects.

Original to this set: `fe-flow` (the two-mode conductor), `core-setup`, `fe-to-review`, `fe-coach`, `core-distill-rules`, and the wiring that turns per-PR coaching into sharper team-wide alignment.

## License

MIT — see [LICENSE](./LICENSE).
