# CONTEXT.md Format

`CONTEXT.md` is the project's domain glossary plus a short system map — the shared language (ubiquitous language; Evans) so humans and agents stop guessing at jargon. Keep it thin and accurate; it grows as `fe-grill-with-docs` sharpens terms.

## Shape
```
# Context

## Domain glossary
- **<Term>** — one-sentence plain-language definition. Note synonyms to avoid.
- **<Term>** — …

## System map
- <Area/module> — what it's responsible for, in a line.
- The main flows and how the areas connect, briefly.
```

## Rules
- One canonical term per concept. List synonyms only to say "don't use these."
- Define a term the first time the team disagrees about it, not speculatively.
- Use the same terms in issues, PRDs, code, and ADRs. A shared word is worth a paragraph later.
- Keep each definition to a sentence; link an ADR for the *why* behind a decision.

Adapted from Matt Pocock's `grill-with-docs/CONTEXT-FORMAT.md`.
