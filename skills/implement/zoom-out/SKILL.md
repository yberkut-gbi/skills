---
name: zoom-out
description: Give a higher-level, big-picture perspective on a section of code instead of diving into line-by-line detail. Use when you (or the user) are unfamiliar with an area and need to understand what it does, how it fits the wider system, and where its boundaries are — before changing it. Triggered by "zoom out", "give me the big picture", "how does this fit together", or general unfamiliarity with a part of the codebase.
---

# Zoom Out

Not a lifecycle stage — an on-demand lens. When you're dropped into an unfamiliar slab of code, the instinct is to read it line by line and drown in detail. Zooming out first is faster: understand the shape before the specifics.

Inspired by Matt Pocock's `zoom-out`.

## What to produce
A short, high-altitude map — not an exhaustive walkthrough:
- **Purpose** — what this area is responsible for, in one or two sentences.
- **Key abstractions** — the main modules/types and what each is for.
- **Boundaries** — how it connects to the rest of the system (its inputs, outputs, and the seams where it could be tested or changed).
- **Where to look** — the few files that matter most for the task at hand.

Ground the terms in `CONTEXT.md` so the explanation uses the project's language. Once the shape is clear, drop back down to the specific change — often with a much better idea of which seam to work at.
