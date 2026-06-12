---
name: fe-run
description: Launch and troubleshoot the dev server — detect the dev command from the repo, clear occupied ports, start the server, tail its output, and work through a common-failure playbook when it doesn't come up clean. Use when asked to run, start, or launch the app, or to debug "it won't start" issues.
model: sonnet
---

# Launch the Dev Server

Start the dev server and watch it come up. Every decision — which command, which port, which package manager — is derived from the repo. Nothing is hardcoded.

## 1. Detect the dev command

Read `package.json` `scripts` and pick the first that exists, in priority order:

1. `dev`
2. `start` (only if `dev` is absent)
3. `develop` / `serve` (fallback)
4. None found → check `Makefile` or `Taskfile.yml` for a `dev` target; if still nothing, ask the user

Cross-check `CONTEXT.md` (if present in the repo) for any noted dev-server entry point before falling back.

**Package manager:** lockfile wins — `pnpm-lock.yaml` → pnpm, `yarn.lock` → yarn, otherwise npm.

## 2. Detect and clear the port

Determine the expected port before starting:

1. Framework config (`vite.config.*`, `next.config.*`, `webpack.config.*`) — look for an explicit `port` field.
2. `.env` / `.env.local` — `PORT`, `VITE_PORT`, `NEXT_PUBLIC_PORT`, or similar.
3. Framework defaults — Vite: 5173 · Next.js: 3000 · Create React App: 3000 · Webpack dev-server: 8080.

If anything is listening on that port, identify the process and kill it:
- macOS / Linux: `lsof -ti:<port> | xargs kill -9`
- Windows: `netstat -ano | findstr :<port>` → `taskkill /PID <pid> /F`

Report what was cleared before starting.

## 3. Start and tail

Run the dev command and stream its output. Watch for the ready signal — most frameworks print a local URL when the server is up (e.g. `Local: http://localhost:5173`). Surface that URL as soon as it appears.

If no ready signal appears within ~30 seconds, surface the raw output and enter the failure playbook.

## 4. Common-failure playbook

Work through failures in order; stop at the first that resolves the issue.

| Symptom | Recovery |
|---|---|
| `EADDRINUSE` — port still in use after clear | Re-identify the PID (`lsof -ti:<port>`), kill it, then restart |
| `Cannot find module` / `MODULE_NOT_FOUND` | Run the install command (`npm install` / `pnpm install` / `yarn`) then retry |
| Missing `.env` / undefined required env var | Check `.env.example`; list each missing variable from the error; ask the user to fill them before retrying |
| Wrong Node version | Read `.nvmrc` / `.node-version`; report the required version; suggest `nvm use` |
| Type errors at startup | Surface the full type-check output verbatim; do not auto-fix — these require a human decision |
| Compilation / build error | Surface the error with file and line number; do not guess at fixes without user confirmation |
| Process exits immediately (non-zero exit code) | Capture exit code + last 50 lines of output; report them; ask before retrying |

After each recovery action, restart the server and re-enter step 3. If the same failure recurs after a recovery attempt, stop — report what was tried and what remains, then ask the user before continuing.

Surface the server URL and process ID when the server is up.
