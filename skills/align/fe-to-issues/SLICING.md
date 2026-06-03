# Slicing Strategies

When a story/slice is too big or has too many branches, split it into 2–4 smaller, independent, testable slices. Pick the strategy that fits; each output is still a full vertical slice with its own acceptance criteria.

1. **By workflow step** — split along the steps of the user's task. *(Best for a multi-step flow.)*
2. **By data / variation** — by input/output type (org-level vs tenant-level; read path vs write path).
3. **By rule / edge case** — happy path as slice 1; edge cases as follow-up slices.
4. **By interface / surface** — API slice vs UI slice vs notification slice.
5. **By capability level** — walking skeleton first, then enhancements.

## Rules
- 2–4 slices per split. If you need more, the parent was an epic — make it one.
- Each slice independently shippable and testable; order by risk (riskiest end-to-end path first).
- Each slice carries its own concrete acceptance criteria, not "see parent."

Slicing strategies from rezolve-enrich-ai's `split-user-story`.
