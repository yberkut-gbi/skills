---
name: fe-verify-ui
description: Headless Playwright arm on the fe-flow green gate — launch the app, screenshot key states, exercise interactions, and assert that values came from a real API (fail on placeholder or mock data). Pure bash + Node so it runs identically on Claude Code, Copilot, and CI. Optional browser-MCP enrichment when present; never a hard dependency. Use after unit tests pass to close the classic gap between green tests and a working UI.
model: sonnet
---

# UI Verification — Playwright Green Gate

`fe-verify-ui` closes the gap between "all tests pass" and "the UI actually works." It launches the app, drives it with Playwright, screenshots key states, and asserts that the data on screen came from a **real API call** — not a stub or a hardcoded placeholder.

It is the Playwright arm wired into step 3 of `fe-flow`'s green gate. It can also run standalone when you want a UI smoke-check without a full cycle.

## Wiring onto fe-flow

`fe-flow` step 3 (green gate) spawns `fe-verify-ui` **after** the repo's standard checks (typecheck, lint, unit tests, build) pass. If the skill is not installed (`.claude/skills/fe-verify-ui/SKILL.md` absent), the green gate continues without the Playwright arm — no hard stop. When present, a Playwright failure is a gate failure: the PR does not open until it passes or N bounded-fix attempts are exhausted.

## The recipe

### 1. Detect the dev server

Read `package.json` for a `dev` / `start` / `preview` script. Fallback order: `vite`, `next dev`, `react-scripts start`, `serve`. Record the port (`5173`, `3000`, `8080` — try in that order). If the port is already occupied, check whether it is the right app before reusing it.

### 2. Launch the app (if not running)

Start the dev server in the background (`npm run dev &`), tail stdout until a "ready" / "listening" line appears, or 30 s — whichever comes first. Record the base URL. On exit, kill the process unless it was already running on entry.

### 3. Ensure Playwright is available

```bash
npx playwright install --with-deps chromium 2>/dev/null || true
```

Run headlessly. No global install required; `npx` resolves it per-project.

### 4. Identify key states and interactions

Derive from the **acceptance criteria** of the current ticket (passed in from `fe-flow`, or agreed with the user on standalone invocations):

- **Key states** — each screen or component state that the AC calls out as the expected output (e.g. "dashboard shows enriched records", "modal renders with live prices").
- **Interactions** — user actions the AC describes (form submit, button click, navigation).
- **Data assertions** — values that must come from the API, not be hardcoded.

If AC is vague about the UI, ask (interactive) or default to: screenshot the landing page + any routes mentioned in the diff.

### 5. Write and run the Playwright script

Generate a Node script (`/tmp/fe-verify-ui-<KEY>.mjs`) that does the following for each key state:

```js
import { chromium } from 'playwright';

const browser = await chromium.launch({ headless: true });
const context = await browser.newContext();
const page = await context.newPage();

// Capture all outbound requests
const apiCalls = [];
page.on('request', req => {
  if (['xhr', 'fetch'].includes(req.resourceType())) apiCalls.push(req.url());
});

await page.goto(BASE_URL + route);
await page.waitForLoadState('networkidle');

// Screenshot
await page.screenshot({ path: `screenshots/${KEY}-${stateName}.png`, fullPage: true });

// Interaction (if any)
// ... generated per AC

// Real-API assertion (see §6)

await browser.close();
```

Run with `node /tmp/fe-verify-ui-<KEY>.mjs`. Capture stdout + stderr. Screenshots land in `docs/agents/coaching-notes/screenshots/` so they persist on the branch.

### 6. Assert real API calls (the key check)

After each page load and interaction cycle, verify:

1. **At least one API call was made.** If `apiCalls.length === 0` for a data-bearing page, **fail** — the UI rendered with no network activity. Either it is static/mocked, or the app failed silently.

2. **No obvious mock patterns in visible text.** Using `page.textContent('body')`, reject if the content matches any of:
   - `lorem ipsum` (case-insensitive)
   - Placeholder sequences: `000-000-0000`, `example@example.com`, `John Doe` / `Jane Doe` (configurable)
   - Hardcoded fixture strings from common test fixtures (e.g. `"name": "Acme Corp"` repeated identically across all rows — flag if the same value appears in > 80% of list items)

3. **Response bodies look real.** Intercept responses for the API calls found above. If all responses return identical or near-identical JSON across multiple list items, flag it. One unique-field value per item passes this heuristic.

Failing any of these three checks fails the Playwright arm. Report exactly which check failed and the first offending URL or text excerpt.

### 7. Optional browser-MCP enrichment

If a browser-MCP tool is available in the current agent context (detected by calling it and checking for a non-error response), use it for richer snapshots — accessibility trees, form state, active element. This is **additive only**: the Playwright script must already pass or fail cleanly without it. Never gate success/failure on browser-MCP availability.

### 8. Report

Emit a structured summary:

```
fe-verify-ui result: PASS | FAIL
  Routes tested:     N
  API calls observed: N
  Screenshots:       docs/agents/coaching-notes/screenshots/<KEY>-*.png
  Failures:
    - [check name] [route] — [excerpt]
```

Surface the screenshot paths so `fe-coach` can include them in the coaching note. On failure, include the full Playwright error and the first failing assertion.

## Bounded fix loop (when invoked from fe-flow)

`fe-flow` owns the bounded loop (N attempts from `config.md`). `fe-verify-ui` just runs and reports; it does not loop itself. On a standalone invocation the user drives the loop.

## Escape hatch

When Playwright cannot reach the app after 30 s, or `npx playwright install` fails in a network-restricted environment, **report the blocker explicitly** and skip rather than fail the whole gate. Log `fe-verify-ui: skipped (Playwright unavailable) — reason: <message>`. This keeps CI from hard-failing in environments where the Playwright arm cannot run; the unit tests still gate the PR.
