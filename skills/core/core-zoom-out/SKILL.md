---
name: core-zoom-out
description: Give a higher-level, big-picture perspective on a section of code instead of diving line-by-line. Use when you or the user are unfamiliar with an area and need to understand what it does, how it fits the wider system, and where its boundaries are before changing it. Triggered by "zoom out", "give me the big picture", "how does this fit together", or general unfamiliarity with part of the codebase.
model: opus
---

# Zoom Out

An on-demand lens, not a lifecycle stage. Dropped into unfamiliar code, understand the shape before the specifics — faster than reading line by line.

## What to produce
A short, high-altitude map — not an exhaustive walkthrough:
- **Purpose** — what this area is responsible for, in a sentence or two.
- **Key abstractions** — the main modules/types and what each is for.
- **Boundaries** — how it connects to the rest (inputs, outputs, and the seams where it could be tested or changed).
- **Where to look** — the few files that matter most for the task.

Ground the terms in `CONTEXT.md`. Once the shape is clear, drop back to the specific change — often with a better idea of which seam to work at.

Adapted from Matt Pocock's `zoom-out`.
