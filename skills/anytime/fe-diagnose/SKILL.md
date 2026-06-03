---
name: fe-diagnose
description: Work a hard bug or performance regression with a disciplined loop instead of guess-and-check — reproduce, minimise, hypothesise, instrument, fix, then add a regression test. Use when the user is stuck on a bug, a flaky failure, or a slowdown, or says "diagnose", "why is this failing", or "track down this regression". Grounds understanding in CONTEXT.md and leaves a test behind so the bug can't return silently.
---

# Diagnose

Hard bugs reward discipline, not intuition-led poking. A tight loop that keeps you honest about what you know versus what you're assuming.

## The loop
1. **Reproduce.** Get a reliable, ideally automated repro. Can't reproduce → can't claim to have fixed it.
2. **Minimise.** Cut to the smallest case that still shows the problem. Most of the diagnosis happens here.
3. **Hypothesise.** A specific, falsifiable cause — not "something with the cache" but "the entry is evicted before the read because the TTL is in seconds, not ms".
4. **Instrument.** Add logging/asserts/a probe that will *confirm or kill* the hypothesis. Prove the cause before fixing.
5. **Fix.** Once proven, the smallest correct change.
6. **Regression-test.** Capture the minimised repro as a test (`fe-tdd` discipline) so the bug stays dead.

## Notes
- Read `CONTEXT.md` for the right domain terms and the area you're in.
- Change one thing at a time — change several and you've learned nothing about which mattered.
- If the cause is a design problem, not a one-off, note it for `fe-deepen`.

Adapted from Matt Pocock's `diagnose`.
