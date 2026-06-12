# Facilitation Patterns

Reference patterns for structured conversation and decision-making. Skills may cite these; they are not enforced. Using them improves grilling and alignment sessions, but deviating when context calls for it is fine.

---

## AFCI — Artifacts First, Clarifying questions, Iterate

A discipline for opening any session where the human has attached documents, specs, or prior work.

1. **Artifacts First.** Before asking *any* question, read every attached artifact in full. Treat it as the source of truth for what the human already said. Questions whose answers are in the artifact waste the human's time and signal you didn't read it.
2. **Clarifying questions (≤3).** After reading, identify the genuine gaps — things the artifact doesn't answer and that you need to proceed. Ask at most three targeted questions. Prioritise: which single answer would unblock the most downstream work?
3. **Iterate.** Incorporate the answers and proceed. If more gaps surface, repeat — one short round of questions, then action.

The constraint on question count is intentional. A long interrogation before producing anything shifts burden to the human. Three questions is enough to unblock the first meaningful output; more can be asked after showing work.

---

## PDF-Loop — Persona first, Default first

A structure for presenting choices during alignment or grilling sessions.

- **One question at a time.** Never bundle multiple decisions into one prompt. Each question is a single binary or short-list choice.
- **Persona first.** Lead with the option most aligned with the human's likely role, goal, or frame — not the one you find most interesting.
- **Default first (recommended first).** When one option is clearly the right call for most situations, list it first and mark it as recommended. The human should be able to accept the default without deliberating.
- **Three options.** Offer exactly three options when the choice is non-binary. More than three creates decision paralysis; fewer than three (when alternatives exist) forecloses legitimate paths.

The PDF-Loop maps onto the recommended-first option style: the first option is both the persona match and the recommended default; options two and three are credible alternatives worth considering, not filler.

**Example structure:**
> Which direction fits best?
> 1. [Recommended] Option A — short description (the default for most situations)
> 2. Option B — short description
> 3. Option C — short description

---

Both patterns share a root principle: **reduce friction at the decision point**. AFCI eliminates redundant questions; PDF-Loop eliminates decision paralysis at choice points. Together they keep grilling and alignment sessions moving toward a locked decision rather than cycling.
