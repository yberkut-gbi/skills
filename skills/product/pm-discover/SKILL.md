---
name: pm-discover
description: Explore the problem space before writing a single ticket — surface user pain, stakeholder context, existing patterns, and opportunity signals. The output is a structured problem statement ready to hand to pm-frame. Use at the start of any new feature, initiative, or fuzzy idea, especially when "what we should build" is still open. Judgment-heavy; model: opus.
model: opus
---

# Discover

Explore the problem space before writing a single ticket. The output is a **problem statement** — grounded enough that `pm-frame` can shape it into an opportunity and `core-grill` can stress-test it.

## Facilitation reference

Cite [`core/facilitation.md`](../../core/core-setup/facilitation.md) — **AFCI** (read all attached artifacts before asking any question) and **PDF-Loop** (one question at a time, three options, recommended first) apply naturally here but are not enforced. Deviate when context calls for it.

## 0. Load context

Read `CONTEXT.md` (domain glossary) and `docs/agents/team-rules.md` if they exist. Use the domain language throughout — do not invent terminology.

## 1. Artifacts first (AFCI)

If the human has attached documents, specs, user research, transcripts, or prior threads — **read every one before asking anything**. Treat them as the source of truth for what is already established. Do not ask a question whose answer is already in an artifact.

## 2. Identify genuine gaps (≤3 questions)

After reading all artifacts, identify what is genuinely unknown. Ask at most three questions — prioritise the one whose answer unblocks the most downstream work. Typical discovery gaps:

- Who is the user and what is their actual pain (not the symptom)?
- What has the team already tried or learned?
- What is the rough scale / urgency of the problem?

If the artifacts already answer the gaps, skip to step 3.

## 3. Map the problem space

Synthesize what you know into a **problem map**:

```
## Problem map: <working title>

### User
<who they are, what they care about, what they cannot do today>

### Pain
<the concrete friction — what breaks, slows, confuses, or costs them>

### Context
<system, process, or organizational context; why this is hard to solve>

### Existing patterns
<what the team has tried, adjacent solutions, known constraints>

### Opportunity signal
<why now — the trigger, the urgency, the market or user shift>
```

Keep it tight. The goal is enough signal to frame, not a full analysis.

## 4. Problem statement

Write one crisp problem statement in the project's domain language:

> **For** [user / role], **the problem is** [pain] **in the context of** [system / process]. **This matters because** [impact or urgency]. **We believe** [rough hypothesis of what would help], **but we need to validate** [key open question].

The hypothesis is provisional — `pm-frame` sharpens it, `core-grill` stress-tests it.

## 5. Hand off

Surface the problem map and problem statement to the human. Ask: proceed to `pm-frame` to shape this into an opportunity? If alignment looks off, offer one round of refinement first.

Called by `pm-discover-flow` (discover → frame → decide) and `pm-flow` (end-to-end PM conductor). Can run standalone for pre-ticket exploration without a conductor.
