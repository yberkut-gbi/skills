# Orchestration Spine

The shared contract all conductors implement. Documented once here in `core`; instantiated by `fe-flow` and the PM conductors. Five elements.

---

## 1. Checkpoint dial

Controls how chatty a conductor is — distinct from whether a human is present (two independent axes).

| Dial | Behaviour |
|---|---|
| `every-decision` | Pause and ask at every decision, even trivial ones |
| `decision-forks` **(default)** | Pause/ask only at mandatory forks (§2) and non-trivial choices |
| `autonomous` | Never asks; mandatory forks become stop-and-escalate instead of a question |

**Decoupled from human-presence.** A run can be `decision-forks` dial with no human (unattended CI), or `every-decision` dial with a human present. Dial = verbosity policy. Human-presence = whether there is anyone to answer a prompt. Neither axis determines the other.

---

## 2. Mandatory-fork floor

These always pause (human present) or stop-and-escalate (headless), regardless of the dial setting. No dial suppresses them.

- **Architecture** — changing how subsystems relate, introducing a new layer, or choosing a structural pattern
- **Data shape** — modifying a persisted schema, a public data contract, or an event payload
- **Public API** — adding, removing, or changing any interface consumed outside the current change
- **Scope sprawl** — the work has grown past what the issue specifies

PM conductors add three mandatory forks: **Decide** (direction locked before spec), **Prototype** (design approved before build), **Handoff** (issue is ship-ready before implementation starts).

When a mandatory fork fires headless, the conductor stops cleanly: comments on the ticket stating what it hit and what decision is needed, leaves any partial work on a draft branch or in a holding doc, and does not guess.

---

## 3. Independent verifier + bounded auto-fix loop

The implementing context cannot reliably grade its own output — bias and contamination from the writing process corrupt the review. The verifier must be independent.

**Verifier:** a **fresh sub-agent** spawned after implementation, with no memory of how the code was written. Its only job is to verify the artifact against the acceptance criteria. It is not a re-read by the same context.

**Bounded auto-fix loop:**
1. Verifier runs, returns a pass/fail verdict with findings.
2. On fail: implementing agent applies fixes, then re-spawns the verifier.
3. This repeats for at most **N attempts**, where **N is read from `config.md`** (`verifier.max_fix_attempts`; default if absent: 3). Never hardcoded.
4. If the gate is still red after N attempts → **escalate**: stop, comment on the ticket with what the verifier found, leave the branch in its current state.

The loop is bounded to prevent silent infinite churn. Escalation after N failures is not a failure mode — it is the designed outcome that surfaces work needing a human decision.

---

## 4. Resume-by-artifact

Conductors produce discrete phase outputs (PRD, slice list, implementation branch, verification report, PR). These outputs persist on disk.

**Rule:** if a phase's output artifact already exists, skip that phase — the work is done. Proceed from the first phase whose artifact is missing.

**Override:** pass `--redo <phase>` to force a phase to re-run even if its artifact exists.

This makes every conductor run idempotent and hot-resumable. A crashed or interrupted run picks up from the last persisted artifact, not from scratch. It also makes the output auditable: artifacts are the record of what each phase decided.

---

## 5. Sub-agents everywhere by default

Both Claude Code and GitHub Copilot support sub-agents. Use them by default for:
- **Per-phase isolation** — each phase runs in its own context, uncontaminated by prior phases
- **Independent verification** — the verifier (§3) must be a fresh sub-agent
- **Parallel slices** — independent implementation slices run concurrently

**Graceful degradation (never silent, never a hard stop).** If sub-agents are genuinely unavailable in the current runtime, degrade to single-context execution — but announce it:

- **Interactive:** emit an inline banner before proceeding:
  ```
  ⚠ Sub-agents unavailable — running in single-context mode.
    Verification posture is degraded: the implementing context is grading its own work.
  ```
- **Headless:** set `degraded: true` in the coaching note and cost record (see `fe-coach`/coaching note shape). Never omit this field when degraded — the changed verification posture must be auditable after the fact.

**Do not hard-stop on sub-agent unavailability.** Degraded single-context execution is weaker but valid. The announcement and the `degraded` flag are the safeguard.
