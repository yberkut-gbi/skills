---
name: fe-setup
description: Scaffold the shared-memory substrate every fe- skill reads from — the domain glossary (CONTEXT.md), architecture decision records (docs/adr/), the agent config (issue tracker + triage labels + doc layout), the team-rules file, and the coaching-notes folder — and wire the issue tracker (Jira via the Atlassian MCP, or GitHub/local). Use once per repo before the align/implement/improve skills, or whenever those skills are missing context about the tracker, domain language, or team rules.
---

# Setup

Every other fe- skill reads a small amount of shared state from the repo. This skill creates it and wires the issue tracker. Run it once, early. Prompt-driven: explore, show what you found, confirm each decision, then write. Assume the user doesn't know these terms — define each in a sentence before asking.

## What it creates
- **`CONTEXT.md`** (root) — domain glossary + short system map (ubiquitous language; Evans).
- **`docs/adr/`** — architecture decision records, one per consequential decision (`NNNN-title.md`).
- **`docs/agents/config.md`** — issue tracker + triage labels + doc layout (shape below).
- **`docs/agents/team-rules.md`** — collaboration rules; starts empty, `fe-distill-rules` fills it.
- **`docs/agents/coaching-notes/`** — one note per PR (`fe-coach`).
- An **`## Agent skills`** block in `AGENTS.md`/`CLAUDE.md` pointing future sessions at the above.

## How to run it
1. **Survey first.** Does `AGENTS.md`/`CLAUDE.md` exist? An `## Agent skills` section? Existing docs/ADRs/glossary? Summarise what's present and missing before changing anything.
2. **Walk the decisions one at a time:**
   - **Issue tracker** — Jira (default, via the Atlassian MCP), GitHub, or local markdown under `docs/agents/issues/`. For Jira, record the **cloud URL** and **project key** in `config.md`; the skills target *that* project — nothing is hardcoded. Confirm the Atlassian MCP is available by running `fe-check-setup`; if missing, walk the user through their agent/IDE config in [MCP-SETUP.md](MCP-SETUP.md).
   - **Triage labels** — the short vocabulary for sorting incoming work (e.g. `needs-triage`, `ready`, `blocked`, `wontfix`). `fe-to-prd`/`fe-to-issues` use these.
   - **Doc layout** — confirm the paths above, or adapt to the repo's conventions.
3. **Bootstrap `CONTEXT.md`** by exploring the codebase and pulling recurring domain terms from the conversation. Define each plainly. `fe-grill-with-docs` sharpens it later.
4. Tell the user setup is complete and which skills now read these files.

## config.md shape
```
# Agent config
tracker: jira                 # jira | github | local
jira:
  cloud: https://<your>.atlassian.net
  project: <KEY>              # the skills target this project
triage_labels: [needs-triage, ready, blocked, wontfix]
docs:
  adr: docs/adr/
  rules: docs/agents/team-rules.md
  coaching: docs/agents/coaching-notes/
```

Keep it light. A thin, accurate substrate the team maintains beats an elaborate one nobody touches.
