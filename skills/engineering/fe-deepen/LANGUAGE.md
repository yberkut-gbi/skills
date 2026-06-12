# Architecture Language

Use these terms exactly in every suggestion `fe-deepen` makes. Consistent language is the point — don't substitute "component," "service," "API," or "boundary."

## Terms

**Module** — anything with an interface and an implementation. Scale-agnostic: a function, class, package, or tier-spanning slice. *Avoid:* unit, component, service.

**Interface** — everything a caller must know to use the module correctly: the type signature plus invariants, ordering constraints, error modes, required config, performance characteristics. *Avoid:* API, signature (too narrow — those are only the type-level surface).

**Implementation** — the code inside the module.

**Depth** — leverage at the interface: how much behaviour a caller (or test) can exercise per unit of interface they must learn. **Deep** = a lot of behaviour behind a small interface. **Shallow** = interface nearly as complex as the implementation.

**Seam** *(Michael Feathers)* — a place where behaviour can be altered without editing in that place; where a module's interface lives. Choosing where the seam goes is its own design decision. *Avoid:* boundary (overloaded with DDD's bounded context).

**Adapter** — a concrete thing that satisfies an interface at a seam. Names a *role*, not its substance.

**Leverage** — what callers get from depth: more capability per unit of interface learned; one implementation pays back across N call sites and M tests.

**Locality** — what maintainers get from depth: change, bugs, knowledge, and verification concentrate in one place. Fix once, fixed everywhere.

## Principles

- **Depth is a property of the interface, not the implementation.** A deep module can be internally composed of small, swappable parts — they just aren't part of its interface. A module can have **internal seams** (private, used by its own tests) as well as the **external seam** at its interface.
- **Deletion test.** Delete the module in your head. Complexity vanishes → it was a pass-through. Complexity reappears across N callers → it earned its keep.
- **The interface is the test surface.** Callers and tests cross the same seam. Wanting to test *past* the interface means the module is the wrong shape.
- **One adapter = a hypothetical seam. Two = a real one.** Don't add a seam unless something actually varies across it (typically prod + test).

## Don't say
- component / service / unit → **module**
- API / signature → **interface**
- boundary → **seam**
- layer / wrapper → **module** (when you mean a module)

Adapted from Matt Pocock's `improve-codebase-architecture/LANGUAGE.md`.
