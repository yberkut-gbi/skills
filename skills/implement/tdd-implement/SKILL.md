---
name: tdd-implement
description: Implement features or fix bugs test-first, one vertical slice at a time — red (failing test at the right seam) → green (minimal code) → refactor (toward deep, simple-interface modules). Use whenever writing code to satisfy a requirement and tests are expected, especially inside the lifecycle. Detects the project's test framework, captures the acceptance criteria it's building to, and logs any test-first escape hatch so the coaching note stays accurate. Prefer this over writing implementation code first whenever a behavior can be expressed as a test.
---

# Test-First Implementation

Write the test before the code, and build in **vertical slices** — one thin end-to-end behavior at a time, not a horizontal layer that does nothing on its own. A failing test forces you to state precisely what "working" means before building it; vertical slices keep each step shippable; and the discipline leaves a regression net behind.

Merges Matt Pocock's `tdd` (vertical slices, testing seams, deep modules) with two additions that feed the learning loop: capturing acceptance criteria, and logging escape hatches.

## Detect, don't assume
Look at the repo to learn how it tests — language, framework, runner, where tests live, naming. Match what's there. Don't introduce a new framework unless the project has none and the user agrees on one.

## Capture what you're building to
Before the loop, restate the acceptance criteria for this slice (from the PRD/issue if one exists, otherwise agree them with the user). Keeping them explicit is what lets the coaching note later tell whether the work was well-specified up front.

## The loop (per slice)
1. **Name the slice.** The smallest useful end-to-end behavior. If it's vague, pin the acceptance criterion before writing the test — guessing here is the most common source of rework.
2. **Red.** Write one focused test at the right **seam** — prefer an existing seam, and the highest sensible one (it's more stable than testing deep internals). Run it; confirm it fails for the *expected* reason.
3. **Green.** Minimal code to pass — no more. Run; confirm green.
4. **Refactor.** With the test green, improve names, structure, and duplication, pushing toward **deep modules**: simple interfaces hiding real implementation depth (Ousterhout, *A Philosophy of Software Design*). Re-run to stay green. Refactor what you touched, not the whole repo.

Repeat until the slice's acceptance criteria are met, then move to the next slice.

## Keep tests honest
- Test behavior and contracts, not private internals — over-coupled tests punish every future refactor.
- Mock judiciously: at real boundaries, not everywhere.
- Aim for one reason to fail per test; keep the suite fast enough to run every loop.

## Escape hatch
Sometimes test-first genuinely fights the work — spikes, hard-to-test glue, throwaway exploration. When so, say it explicitly, do the spike, then cover the kept code with tests. Make the skip **visible** so it can be reflected in the coaching record, rather than silently dropping the discipline. Strict by default, pragmatic when reality demands it.
