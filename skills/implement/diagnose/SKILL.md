---
name: diagnose
description: Work a hard bug or performance regression with a disciplined loop instead of guess-and-check — reproduce, minimise, hypothesise, instrument, fix, then add a regression test. Use when the user is stuck on a bug, a flaky failure, or a slowdown, or says "diagnose", "why is this failing", or "track down this regression". Grounds its understanding in CONTEXT.md and leaves a test behind so the bug can't return silently.
---

# Diagnose

Hard bugs reward discipline, not intuition-led poking. This skill runs a tight loop that keeps you honest about what you actually know versus what you're assuming.

Inspired by Matt Pocock's `diagnose`.

## The loop
1. **Reproduce.** Get a reliable, ideally automated repro. If you can't reproduce it, you can't claim to have fixed it.
2. **Minimise.** Cut the repro down to the smallest case that still shows the problem. Most of the diagnosis happens here.
3. **Hypothesise.** State a specific, falsifiable hypothesis about the cause — not "something with the cache" but "the entry is evicted before the read because the TTL is set in seconds, not ms".
4. **Instrument.** Add logging, asserts, or a probe that will *confirm or kill* the hypothesis. Don't fix yet — first prove the cause.
5. **Fix.** Once the cause is proven, make the smallest correct change.
6. **Regression-test.** Capture the minimised repro as a test (hand to `tdd-implement` discipline) so the bug stays dead.

## Notes
- Read `CONTEXT.md` to use the right domain terms and to understand the area you're in.
- Change one thing at a time; if you change several, you've learned nothing about which mattered.
- If the cause turns out to be a design problem rather than a one-off, note it for `improve-codebase-architecture`.
