# Deepening Technique

How to deepen a cluster of shallow modules safely, given its dependencies. Vocabulary: [LANGUAGE.md](LANGUAGE.md) — **module**, **interface**, **seam**, **adapter**.

## Classify the dependencies
The category decides how the deepened module is tested across its seam.

1. **In-process** — pure computation, in-memory state, no I/O. Always deepenable: merge the modules and test through the new interface directly. No adapter needed.
2. **Local-substitutable** — has a local test stand-in (PGLite for Postgres, in-memory filesystem). Deepenable if the stand-in exists; test with it running in the suite. The seam is internal — no port at the external interface.
3. **Remote but owned (ports & adapters)** — your own services across a network boundary. Define a **port** at the seam; the deep module owns the logic, the transport is an injected **adapter** (HTTP/gRPC/queue in prod, in-memory in tests).
4. **True external (mock)** — third-party services you don't control (Stripe, Twilio). Inject as a port; tests provide a mock adapter.

## Seam discipline
- One adapter = a hypothetical seam; two = a real one. Don't introduce a port without ≥2 justified adapters (usually prod + test) — a single-adapter seam is just indirection.
- A deep module can have **internal seams** (private, for its own tests) *and* an **external seam** at its interface. Don't expose internal seams through the interface just because tests use them.

## Testing strategy: replace, don't layer
- Old unit tests on the shallow pieces become waste once tests exist at the deepened interface — delete them.
- Write new tests at the deepened module's **interface** (the test surface). Assert on observable outcomes, not internal state.
- Tests should survive internal refactors. If a test must change when the implementation changes, it's testing past the interface.

Adapted from Matt Pocock's `improve-codebase-architecture/DEEPENING.md`.
