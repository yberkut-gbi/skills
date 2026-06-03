# Test Discipline

What makes a test honest. Applies to every `fe-tdd` loop.

- **Test behavior and contracts, not private internals.** If a test breaks when you refactor but behavior didn't change, it was testing the wrong thing. Over-coupled tests punish every future refactor.
- **Test at a seam, the highest sensible one.** Prefer existing seams. A test at the interface survives internal change; a test wired into internals doesn't.
- **Mock judiciously — at real boundaries, not everywhere.** Mock true externals (third-party APIs) and owned-remote dependencies; exercise in-process collaborators for real. Over-mocking just tests the mocks. (Dependency categories: `fe-deepen`/DEEPENING.md.)
- **One reason to fail per test.** A test that can fail five ways tells you little when it goes red. Narrow each to one behavior.
- **Assert on observable outcomes, not internal state** — the same contract a real caller depends on.
- **Keep the suite fast enough to run every loop.** Slow suites get skipped; skipped suites stop protecting you. Push slow dependencies behind seams.

Adapted from Matt Pocock's `tdd` test guidance.
