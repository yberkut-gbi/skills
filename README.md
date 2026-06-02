# In the Loop

> Composable [agent skills](https://skills.sh) for human–AI software engineering. The human stays *in the loop* — and the loop gets sharper every cycle.

Two design commitments run through all of it:

1. **Shared memory is the backbone.** A small set of files in your repo — a domain glossary, decisions, and accumulated rules — is read and written by both you and every skill, so you stop talking past each other.
2. **You stay in control.** These are small, skippable, composable tools — not a process framework that owns your workflow.

## Install

Installed with [`npx skills`](https://www.npmjs.com/package/skills) (Vercel Labs). GitHub is the registry, so `owner/repo` maps to this repo.

```bash
# Browse and select skills from this set (pick skills + target agents)
npx skills add yberkut-gbi/skills

# Install a single skill by direct path
npx skills add https://github.com/yberkut-gbi/skills/tree/main/skills/implement/tdd-implement

# Target specific agents (Claude Code, Cursor, Codex, and many more)
npx skills add yberkut-gbi/skills --agent claude-code

# Install globally (user-level instead of project-level)
npx skills add yberkut-gbi/skills -g

# List what's installed
npx skills list
```

Skills install into your agent's skills directory (e.g. `.claude/skills/`). The CLI records what you installed in `.skills.json` and `skills-lock.json` in your project — commit those so your whole team and CI get the same skills:

```bash
# In CI, restore the exact set from the lock file
npx skills experimental_install
```

> Tip: `npx` can cache an old CLI. Use `npx skills@latest add …` to force the current version.

## Quick start

1. **Set up the substrate once per repo:** install and run `setup-skills`. It scaffolds the shared files the other skills read (`CONTEXT.md`, `docs/adr/`, `docs/agents/config.md`, `docs/agents/team-rules.md`, `docs/agents/coaching-notes/`).
2. **Drive a feature** with `orchestrate`, or invoke any skill directly. The orchestrator loads the substrate, then offers: align → implement → reflect.
3. **Let the loop run.** After a batch of PRs, run `rules-synthesis` to turn coaching notes into sharper team rules; every few days, run `improve-codebase-architecture`.

## The four layers

**0 · Shared memory** — the substrate everything reads from.
- `setup-skills` — scaffolds it once per repo.

**1 · Align (front of the cycle)** — reach shared understanding before building.
- `grill-with-docs` — stress-test the plan against the domain model; update the docs inline.
- `to-prd` — synthesize the aligned context into a PRD, with a team-rules-seeded gap-check.
- `to-issues` — slice the PRD into independently-grabbable vertical slices.

**2 · Implement** — build with discipline.
- `orchestrate` — thin conductor; loads the substrate, offers the path, keeps you steering.
- `tdd-implement` — vertical-slice red→green→refactor toward deep modules.
- `commit-and-pr` — reviewable commits, push, PR via `gh`.
- `diagnose` — disciplined bug / performance loop.
- `zoom-out` — on-demand altitude on unfamiliar code.

**3 · Improve (back of the cycle)** — reflect and compound.
- `pr-coaching-note` — growth-oriented note on the human–AI collaboration for each PR.
- `improve-codebase-architecture` — periodic deep-module hygiene.
- `rules-synthesis` — turns coaching notes into team rules.
- `handoff` — carry context across sessions, models, and people.

## The shared-memory substrate

| File | Purpose | Written by |
|------|---------|-----------|
| `CONTEXT.md` | Domain glossary + system map (ubiquitous language) | `setup-skills`, `grill-with-docs` |
| `docs/adr/` | Architecture decision records | `grill-with-docs`, `improve-codebase-architecture` |
| `docs/agents/config.md` | Issue tracker + triage labels + doc layout | `setup-skills` |
| `docs/agents/team-rules.md` | Collaboration rules | `rules-synthesis` |
| `docs/agents/coaching-notes/` | One note per PR | `pr-coaching-note` |

## The two improvement loops

```
                         ┌──────────── COLLABORATION LOOP ────────────┐
                         │                                            │
   team-rules.md ──► grill-with-docs / to-prd ──► tdd ──► PR ──► pr-coaching-note
        ▲    (seeds alignment with what the team keeps leaving implicit)   │
        │                                                                  │
        └────────────────────── rules-synthesis ◄──────────── coaching notes
                          (aggregates recurring gaps into rules)

                         ┌──────────── ARCHITECTURE LOOP ─────────────┐
   CONTEXT.md + ADRs ──► improve-codebase-architecture ──► updated ADRs / CONTEXT.md
                          (every few days, fights entropy)
```

The collaboration loop is the point: a gap caught at the **back** of the cycle (a coaching note) sharpens the alignment at the **front** of the next one. `handoff` stitches both loops across time.

## Credit & provenance

The align layer, the shared-memory idea, and several implement/improve skills are inspired by **[Matt Pocock's `skills` repository](https://github.com/mattpocock/skills)** — `grill-with-docs`, `to-prd`, `to-issues`, `tdd`, `diagnose`, `zoom-out`, `improve-codebase-architecture`, `handoff`, and the `setup` config pattern. These are original re-expressions built around widely-used engineering practices: domain-driven design and ubiquitous language (Evans), deep modules (Ousterhout), tracer bullets (Hunt & Thomas), and test-driven development (Beck). If you prefer his exact versions, install them from his repo alongside these.

The contributions original to this set are `pr-coaching-note`, `rules-synthesis`, and the thin `orchestrate` — plus the wiring that turns per-PR coaching into sharper team-wide alignment.

## License

MIT — see [LICENSE](./LICENSE).
