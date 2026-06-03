# HTML Report Format

The architecture review renders as one self-contained HTML file in the OS temp dir (nothing lands in the repo). Resolve the temp dir from `$TMPDIR` (fallback `/tmp`, or `%TEMP%` on Windows); write `<tmpdir>/architecture-review-<timestamp>.html`. Open it with the OS opener (`open` on macOS, `xdg-open` on Linux, `start` on Windows) and tell the user the absolute path.

Tailwind (CDN) for layout, Mermaid (CDN) for graph-shaped diagrams. Mix Mermaid with hand-built divs/SVG for editorial visuals (mass diagrams, cross-sections) — don't let everything look like generic Mermaid.

## Scaffold
```html
<!doctype html><html lang="en"><head>
<meta charset="utf-8"/><title>Architecture review — {repo}</title>
<script src="https://cdn.tailwindcss.com"></script>
<script type="module">
 import mermaid from "https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs";
 mermaid.initialize({ startOnLoad:true, theme:"neutral", securityLevel:"loose" });
</script>
<style>.seam{stroke-dasharray:4 4}.leak{stroke:#dc2626}.deep{background:linear-gradient(135deg,#0f172a,#1e293b)}</style>
</head><body class="bg-stone-50 text-slate-900 font-sans">
<main class="max-w-5xl mx-auto px-6 py-12 space-y-12">
 <header><!-- repo · date · legend --></header>
 <section id="candidates" class="space-y-10"><!-- cards --></section>
 <section id="top-recommendation"><!-- pick --></section>
</main></body></html>
```

## Header
Repo, date, compact legend: solid box = module, dashed = seam, red = leakage, thick dark box = deep module. No intro paragraph.

## Candidate card (one `<article>` each)
- **Title** — names the deepening ("Collapse the Order intake pipeline").
- **Badges** — strength (`Strong` emerald / `Worth exploring` amber / `Speculative` slate) + dependency category (in-process / local-substitutable / ports & adapters / mock).
- **Files** — `font-mono text-sm`.
- **Before / After diagram** — the centrepiece, two columns. Patterns below.
- **Problem** — one sentence. **Solution** — one sentence.
- **Wins** — bullets ≤6 words, in glossary terms ("locality: bugs in one module", "leverage: one interface, N call sites").
- **ADR callout** — one amber line if it touches an ADR.

No paragraphs. If a diagram needs a paragraph to read, redraw it.

## Diagram patterns (mix them)
- **Mermaid flowchart/graph** — dependency / call flow; `classDef` to colour leakage red and the deep module dark.
- **Hand-built boxes + SVG arrows** — when the "after" should read as one thick deep module with greyed-out internals.
- **Cross-section** — stacked bands for layered shallowness; before: N thin layers, after: 1 thick band.
- **Mass diagram** — interface-rect vs implementation-rect; shallow = tall interface, deep = short interface over tall implementation.
- **Call-graph collapse** — before: nested call boxes; after: collapsed into one, internals faded.

## Style
Editorial, not corporate-dashboard. Generous whitespace; one accent (emerald/indigo) + red (leakage) + amber (warnings). Diagrams ~320px tall. Module labels `text-xs uppercase tracking-wider`. Only scripts: the Tailwind and Mermaid CDNs.

## Top recommendation
One larger card: candidate name, one sentence why, anchor link to its card.

## Tone
Plain English; the architecture nouns come straight from [LANGUAGE.md](LANGUAGE.md). Use exactly: module, interface, implementation, depth, deep, shallow, seam, adapter, leverage, locality. Never: component/service (→ module), API/signature (→ interface), boundary (→ seam). No hedging — if a sentence could be a bullet, make it one.

Adapted from Matt Pocock's `improve-codebase-architecture/HTML-REPORT.md`.
