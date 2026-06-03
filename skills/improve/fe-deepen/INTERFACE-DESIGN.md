# Interface Design (Design It Twice)

When the user wants to explore alternative interfaces for a chosen deepening candidate. Your first design is rarely the best (Ousterhout, "Design It Twice"). Vocabulary: [LANGUAGE.md](LANGUAGE.md).

## 1. Frame the problem space
Before designing, write a short user-facing brief for the candidate:
- the constraints any new interface must satisfy
- its dependencies and their category (see [DEEPENING.md](DEEPENING.md))
- a rough code sketch to make the constraints concrete — not a proposal

Show it, then proceed — the user reads while the designs are produced.

## 2. Produce 3+ radically different designs
If your agent supports sub-agents (Claude Code: the Agent tool; GitHub Copilot: sub-agent delegation), spawn them in parallel — one per design. Otherwise produce the designs sequentially yourself. Give each a different constraint:
- **Minimal** — 1–3 entry points; maximise leverage per entry point.
- **Flexible** — support many use cases and extension.
- **Common-case** — make the default caller trivial.
- **Ports & adapters** — design around cross-seam dependencies (if applicable).

Brief each with file paths, coupling details, the dependency category, and what sits behind the seam. Include [LANGUAGE.md](LANGUAGE.md) + `CONTEXT.md` vocabulary so naming stays consistent.

Each design outputs:
1. **Interface** — types, methods, params, plus invariants, ordering, error modes.
2. **Usage example** — how callers use it.
3. **Behind the seam** — what the implementation hides.
4. **Dependency strategy + adapters** — see [DEEPENING.md](DEEPENING.md).
5. **Trade-offs** — where leverage is high, where it's thin.

## 3. Present and recommend
Present designs one at a time so the user absorbs each, then compare in prose by **depth** (leverage at the interface), **locality** (where change concentrates), and **seam placement**. Give an opinionated recommendation; propose a hybrid if elements combine well. The user wants a strong read, not a menu.

Adapted from Matt Pocock's `improve-codebase-architecture/INTERFACE-DESIGN.md`.
