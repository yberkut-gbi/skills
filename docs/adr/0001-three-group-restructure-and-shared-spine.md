# ADR 0001 — Three-group restructure, shared orchestration spine, and cross-agent grounding

- **Status:** Accepted (design locked via grill session 2026-06-12)
- **Context source:** Analysis of `rezolved/rezolve-enrich-ai`'s agent-instruction architecture, mapped onto this portable `fe-` skills set.
- **Decision owner:** FE architect (repo owner).

## Problem

`rezolve-enrich-ai` has a deep, effective agent-instruction system, but it is **bespoke and non-portable**: every skill hardcodes `AIEN-` keys, `rezolvetech.atlassian.net`, exact commands, and project-specific rules. This set is the opposite design point — **portable, substrate-driven skills installable into any frontend repo via `npx skills`, runnable from both Claude Code and GitHub Copilot, on an AI-first → AI-only trajectory.**

The question this ADR answers: **which rezolve patterns survive being made portable, and in what form?**

The governing filter: a pattern is imported only if its *grounding* can live in per-repo **substrate** (scaffolded per project) rather than baked into a skill body.

## Decisions

### 1. Governing principle — strict externalization
Every skill ships project-agnostic. All grounding lives in per-repo substrate, upgraded from flat (`CONTEXT.md` + ADRs) to a layered **instruction tree**. Nothing project-specific ever appears in a skill body. The lever that recovers rezolve's "deep grounding" is a *richer substrate*, not hardcoding.

### 2. Three installable groups
The `skills` CLI has **no group/namespace concept** — but a direct path to a parent directory installs the whole subtree (`findSkillMdPaths(tree, subpath)` filters to the subtree). So the **directory is the group**.

```
skills/
  core/         core-*   the foundation — install first; both groups depend on it
  engineering/  fe-*     build a ship-ready issue → PR
  product/      pm-*     decide what to build → ship-ready issue
```

Install (honest: foundation + group, not strictly one command):
```bash
npx skills add <owner>/skills/tree/main/skills/core         # always
npx skills add <owner>/skills/tree/main/skills/engineering  # the build half
npx skills add <owner>/skills/tree/main/skills/product      # the spec half (either or both)
```

### 3. Skill placement (full map)

| Group | Skills |
|---|---|
| **core/** (`core-`) | `core-setup`, `core-check-setup`, `core-grill` (← `fe-grill-with-docs`), `core-diagnose` (← `fe-diagnose`), `core-handoff` (← `fe-handoff`), `core-zoom-out` (← `fe-zoom-out`), `core-distill-rules` (← `fe-distill-rules`) + reference docs: the orchestration-spine spec, `core/facilitation.md` |
| **engineering/** (`fe-`) | `fe-flow` (conductor — renamed from `fe-ship`), `fe-tdd`, `fe-verify-ui` (new), `fe-to-review`, `fe-run` (new), `fe-deepen`, `fe-coach` |
| **product/** (`pm-`) | `pm-discover` (new), `pm-frame` (new), `pm-to-prd` (← `fe-to-prd`), `pm-to-issues` (← `fe-to-issues`), `pm-design` (new — was provisionally `fe-design`), `pm-discover-flow` (new), `pm-spec-flow` (new), `pm-flow` (new) |

**Boundary principle:** the handoff artifact is a **ship-ready Jira issue**. PM owns deciding *what* + slicing it; engineering owns building it right; core = substrate/setup + cross-cutting lenses used by both.

**The seam:** `pm-to-issues` emits the ship-ready issue → `fe-flow` consumes it. AI-first → AI-only spans **both** halves, not just the build half.

**Learning-loop split:** `fe-coach` stays engineering (per-PR note); `core-distill-rules` lives in core (writes shared `team-rules.md`, fed by both halves).

### 4. Cross-agent grounding — canonical `AGENTS.md` + thin pointers
`core-setup` scaffolds, in the **target repo**, one canonical `AGENTS.md` as the root of the instruction tree:
```
AGENTS.md (canonical)
  → CONTEXT.md, stack.md
  → docs/agents/patterns/*.md
  → team-rules.md, docs/adr/*
```
`CLAUDE.md` and `.github/copilot-instructions.md` are **thin pointers** ("read AGENTS.md and the substrate it references"). One source of truth, zero content duplication — mirrors rezolve's instruction tree but kills its three-file drift. Skills continue to reference MCP **by function**, never by tool-ID, so the same prompts work under any agent prefix.

### 5. Shared orchestration spine
Documented once in `core` (the spine spec); instantiated by `fe-flow` and the PM conductors. Five elements:

- **Checkpoint dial** — `every-decision` / `decision-forks` (default) / `autonomous`. **Decoupled** from "is a human present" (two independent axes: how-chatty vs human-present).
- **Mandatory-fork floor** — architecture / data-shape / public-API / scope-sprawl (plus *Decide / Prototype / Handoff* in the PM conductors) **always** pause (human present) or stop-and-escalate (headless). No dial setting skips them.
- **Verify → fix loop** — an **independent** verifier (fresh sub-agent, not the implementing context grading its own work) + bounded auto-fix (N attempts, N from `config.md`) → escalate. Replaces fe-flow's current unbounded "keep working."
- **Resume-by-artifact** — phase outputs persist on disk; an existing artifact is skipped unless `redo`.
- **Sub-agents everywhere by default** — both Claude Code and Copilot support them (per-phase isolation, independent verifier, parallel slices). If genuinely unavailable, **degrade to single-context — announced, never silent, never a hard stop**: inline banner (interactive) **and** a `degraded:true` flag in the coaching note / cost record (headless), so the changed verification posture is always auditable.

### 6. New engineering capabilities
- **`fe-verify-ui`** — a headless **Playwright** arm on the green gate: launch app → screenshot key states → exercise interactions → assert values came from a **real API** (fail on placeholder/mock). Pure bash+node → identical on Claude Code, Copilot, and CI. Optional browser-MCP enrichment when present; never a dependency. Closes the classic FE failure: green tests ≠ working UI.
- **`fe-run`** — launch/troubleshoot the dev server (clear ports, detect dev command, tail, common-failure playbook).

### 7. `pm-design` — design artifacts, not code
Produces **mockup artifacts** via a design-tool MCP (Figma), **design-only**, **pre-build**, for human approval; then hands an approved direction to `fe-tdd`. Portable invariants kept from rezolve's `create-design`: **derive tokens from the repo's real theme (never guess colors)** and the **screenshot-audit loop** — applied to the *mockup*, not source. Adds an optional design-tool MCP to setup/check-setup wiring, cross-agent.

### 8. PM conductors (three, rezolve-style)
- `pm-discover-flow` — pre-ticket (discover → frame → decide).
- `pm-spec-flow` — post-decision (PRD → prototype → stories → handoff).
- `pm-flow` — end-to-end superset: discover (`pm-discover`) → frame (`pm-frame`) → **Decide** (`core-grill`) → PRD (`pm-to-prd`) → **Prototype** (`pm-design`) → stories/issues (`pm-to-issues`) → **Handoff** (→ `fe-flow`). Starred phases are mandatory forks; the dial's `--skip`/`--start-at` trim per run.

### 9. Facilitation patterns — reference, not enforced
`core/facilitation.md` documents **AFCI** (read attached artifacts first, then ≤3 targeted questions) and the **PDF-Loop** (one question at a time, 3 persona-first options, recommended-first). Skills **may** cite them; not mandatory. (The PDF-Loop maps directly onto the recommended-first option style used to grill this very design.)

### 10. PM run parity — full
Autonomous `pm-flow` runs write a `cost.json` beside the artifacts (same as the `fe-flow` runner) **and** a brief inline reflection step feeding `core-distill-rules` → `team-rules.md`. The efficiency + learning loop spans both halves. (No separate `pm-coach` skill; the reflection is a step in the conductor.)

### 11. MCP set per group
- **Atlassian (Jira + Confluence)** — always; wired by `core-setup`, referenced by function.
- **Figma (design-tool)** — optional, for the `product` group (`pm-design`).
- **Browser MCP** — optional enrichment for `fe-verify-ui`; Playwright is the spine.
- **GitHub** — via the `gh` CLI, **not** MCP (unchanged; GitHub is not an issue tracker here).

## Rejected alternatives (notable)
- **Hybrid / stack-specific skills** (baking FE defaults or React/Vue variants into skill bodies) — rejected; violates strict externalization.
- **Two discrete modes only** (keep interactive/unattended binary) — superseded by the three-position dial + decoupled human-presence axis.
- **Design → code generation** (`fe-design` generating components) — rejected in favor of design-only mockup artifacts for pre-build approval.
- **Full fan-out that hard-stops without sub-agents** (rezolve's gate) — rejected; breaks the cross-agent promise. Replaced by announced graceful degradation.
- **Per-group duplicated setup** / **separate shared *installable* group** — superseded by the `core` group holding setup once.
- **Enforced facilitation patterns** — softened to reference docs.

## Migration / rename list (for the rollout)
- Restructure `skills/<category>/` → `skills/{core,engineering,product}/<category>/`.
- Renames: `fe-grill-with-docs`→`core-grill`; `fe-setup`→`core-setup`; `fe-check-setup`→`core-check-setup`; `fe-diagnose`→`core-diagnose`; `fe-handoff`→`core-handoff`; `fe-zoom-out`→`core-zoom-out`; `fe-distill-rules`→`core-distill-rules`; `fe-to-prd`→`pm-to-prd`; `fe-to-issues`→`pm-to-issues`; `fe-ship`→`fe-flow` (engineering conductor; also rename runner `fe-ship.sh`→`fe-flow.sh` and the `scripts/fe-ship.sh` wrapper if present).
- New skills: `fe-verify-ui`, `fe-run`, `pm-discover`, `pm-frame`, `pm-design`, `pm-discover-flow`, `pm-spec-flow`, `pm-flow`.
- Extract the orchestration-spine spec + `core/facilitation.md` into `core`.
- `core-setup` scaffolds canonical `AGENTS.md` + thin `CLAUDE.md` / `.github/copilot-instructions.md` pointers + the richer substrate tree (`stack.md`, `docs/agents/patterns/`).
- Update `fe-flow` align step + PM conductors to reference `core-grill` and the spine spec.
- Update `README.md` (three-group install model) and root `CLAUDE.md` (group structure, spine, MCP set).
- Keep `name:` frontmatter consistent with each renamed directory; keep `model:` per existing convention (opus for grill/synthesis/conductor judgment, sonnet for mechanical skills).
