---
name: pm-discover-flow
description: The pre-ticket PM conductor — loads the shared memory then sequences discover (pm-discover) → frame (pm-frame) → Decide (core-grill). Decide is a mandatory fork; it always pauses for human confirmation (human present) or stops-and-escalates (headless). Implements the shared orchestration spine (core-setup/orchestration-spine.md): checkpoint dial, mandatory-fork floor, resume-by-artifact, graceful degradation. Sequences the PM skills; never reimplements them. Use at the start of any new feature or initiative when "what to build" is still open.
model: opus
---

# Discover-Flow — the pre-ticket PM conductor

`pm-discover-flow` loads the shared memory, then conducts a problem space from raw idea to a grilled, direction-locked opportunity brief — ready to hand to `pm-spec-flow` or `pm-flow` for PRD and stories.

It implements the **shared orchestration spine** (`core-setup/orchestration-spine.md`). Read that spec first; this skill instantiates it without re-specifying every invariant.

## Checkpoint dial + human-presence axis

Two independent axes govern a run:

**Checkpoint dial** (verbosity policy — spine §1):

| Dial | Behaviour |
|---|---|
| `every-decision` | Pause and ask at every decision, even trivial ones |
| `decision-forks` **(default)** | Pause/ask only at mandatory forks (§ below) and non-trivial choices |
| `autonomous` | Never asks; mandatory forks become stop-and-escalate instead of a question |

**Human-presence axis** (who is in the seat):

| Human present | Headless (no human) |
|---|---|
| Collaborative discovery and framing | Problem must be pre-described (ticket, doc, or passed context) |
| Decide fork → pause; human confirms direction | Decide fork → stop-and-escalate; do not guess direction |

Neither axis determines the other. Set the dial explicitly. Infer human-presence from whether there is someone to answer a prompt.

**Default:** `decision-forks` + human present.

## Mandatory-fork floor (spine §2 — no dial setting skips these)

Base forks (all conductors):
- **Architecture** — changing how subsystems relate, introducing a new layer, or choosing a structural pattern
- **Data shape** — modifying a persisted schema, a public data contract, or an event payload
- **Public API** — adding, removing, or changing any interface consumed outside the current change
- **Scope sprawl** — the work has grown past what the issue specifies

PM-conductor additional forks:
- **Decide** — direction must be confirmed by the human before the brief is locked and handed forward. This is the exit gate of this conductor.

When a mandatory fork fires headless: comment on the ticket with what was hit and what decision is needed, write any partial output to `docs/agents/holding/`, stop cleanly — no guess.

## How to trigger it

**Human present** — in a normal session:
- "Use pm-discover-flow on this idea" / "Let's figure out what to build for X" / "Take this from raw idea to a grilled brief".
- Loads the substrate, runs discover → frame → Decide, pausing at the Decide fork.

**Headless** — pass a ticket key, doc path, or inline description as the starting problem. The conductor runs discover → frame, then stops at Decide (stop-and-escalate).

## 0. Load the shared memory (always first)

Read `CONTEXT.md`, the relevant ADRs in `docs/adr/`, `docs/agents/team-rules.md`, and the spine spec at `core-setup/orchestration-spine.md`. Apply the domain language throughout. If `core-setup` hasn't run:
- *Human present:* offer to run it.
- *Headless:* stop and say so.

## Sub-agents + graceful degradation (spine §5)

Use sub-agents by default for per-phase isolation — each phase (discover, frame, Decide) runs in its own context, uncontaminated by prior phases.

If sub-agents are genuinely unavailable:
- **Human present:** emit an inline banner before proceeding:
  ```
  ⚠ Sub-agents unavailable — running in single-context mode.
    Phase isolation is degraded: each phase shares context with prior phases.
  ```
- **Headless:** set `degraded: true` in any output artifacts. Never omit when degraded.

Do not hard-stop on sub-agent unavailability. Degraded single-context execution is weaker but valid.

## Resume-by-artifact (spine §4)

Phase outputs persist on disk under `docs/agents/holding/` named by a slug derived from the initiative title:

| Phase | Artifact |
|---|---|
| Discover | `pm-discover-flow-<slug>-problem-statement.md` |
| Frame | `pm-discover-flow-<slug>-opportunity-brief.md` |
| Decide | `pm-discover-flow-<slug>-direction-locked.md` (written after human confirms) |

If a phase's artifact already exists, skip that phase — proceed from the first missing artifact. Pass `--redo <phase>` to force a re-run of a completed phase.

## The recipe

**1. Discover — `pm-discover`.**

Run `pm-discover` to explore the problem space. Its output is a **problem map** and a crisp **problem statement**.

- Apply AFCI: read all attached artifacts before asking anything.
- Ask at most three targeted questions to fill genuine gaps.
- Produce the problem statement; write it to `docs/agents/holding/pm-discover-flow-<slug>-problem-statement.md`.
- *Human present:* surface the problem map and statement; offer one round of refinement before moving forward.
- *Headless:* if the problem description is vague or has design questions not answered by the ticket or an ADR → stop (mandatory fork). Comment on the ticket with exactly what's missing.

**2. Frame — `pm-frame`.**

Run `pm-frame` with the problem statement from step 1.

- Define boundaries (in / out / defer).
- Define success criteria (concrete, observable, testable).
- Generate three distinct solution bets (PDF-Loop: recommended first, two credible alternatives).
- *Human present:* present the bets; ask the human to pick a direction or redirect. Do not proceed until a direction is nominated (even tentatively). Write the opportunity brief to `docs/agents/holding/pm-discover-flow-<slug>-opportunity-brief.md`.
- *Headless:* if a clear recommended direction exists and no architectural ambiguity is present, write the brief with the recommended direction flagged — then surface it at the Decide fork (stop-and-escalate). Do not silently lock the direction.

**3. Decide — `core-grill` — mandatory fork.**

This is the exit gate of the conductor. No dial setting skips it.

- Run `core-grill` to stress-test the framed direction against the domain model, ADRs, and team-rules.
- Core-grill resolves open branches **with** the human; it captures new terms into `CONTEXT.md` and consequential decisions into ADRs.
- *Human present:* **pause**. Present the grilled brief and ask: "Direction confirmed? Shall we lock this and hand to `pm-spec-flow` for PRD and stories?" The human must confirm or redirect before the conductor writes the direction-locked artifact and exits.
- *Headless:* **stop-and-escalate**. Comment on the ticket with: the opportunity brief, the grill findings, and the specific direction decision that needs a human. Write partial artifacts to `docs/agents/holding/`. Do not guess the direction.

On confirmation, write `docs/agents/holding/pm-discover-flow-<slug>-direction-locked.md` — a short summary of the confirmed direction, grill outcomes, and any new ADRs or CONTEXT.md entries made. This is the handoff artifact for `pm-spec-flow` or `pm-flow`.

## At a consequential decision

Architecture, a data shape, a public API, a real tradeoff, scope sprawling past the initiative, or the Decide fork. No dial setting skips these.
- *Human present:* **pause and let the human make the call.** Note any stage they skip.
- *Headless:* **clean stop.** Comment on the ticket, leave artifacts in `docs/agents/holding/`, state plainly what blocked you.

---

Called by `pm-flow` (end-to-end superset). Can run standalone for pre-ticket exploration when the goal is reaching a direction-locked brief before committing to PRD and stories. Sequences `pm-discover` and `pm-frame` and `core-grill`; never reimplements them.
