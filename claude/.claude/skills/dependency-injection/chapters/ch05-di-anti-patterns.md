# Chapter 5 — DI Anti-Patterns

## Anti-Pattern Catalog

### 1. Control Freak (Most Common)
**What:** Creating Volatile Dependencies anywhere outside the Composition Root — typically via `new`.
**Why it's bad:** Prevents interception, replacement, and testing. Creates transitive coupling to all concrete implementations.
**Variations:**
- Direct `new` on Volatile Dependencies
- Concrete Factories (just moves the problem)
- Abstract Factories (turtles all the way down — who creates the factory?)
- Static Factories with config switches (circular module dependencies, drags all implementations)
- Foreign Default constructors (parameterless constructor that news up a concrete type from another module)

**Fix:** Refactor to Constructor Injection. Move all `new` calls on Volatile Dependencies to the Composition Root.

### 2. Service Locator (Most Dangerous)
**What:** A global registry that supplies Dependencies on demand — classes pull Dependencies instead of receiving them.
**Pattern:** `var service = Locator.GetService<IService>()`
**Why it's dangerous:** It *looks* like it solves the problem. Code compiles, runs, and appears loosely coupled. But:
- Dependencies are **hidden** — not visible in the constructor signature
- Runtime errors instead of compile-time errors when Dependencies are missing
- Every class depends on the Locator itself (tight coupling to infrastructure)
- Drags the Locator as a transitive dependency into every module

**Fix:** Replace `Locator.GetService<T>()` calls with constructor parameters.

### 3. Ambient Context
**What:** A static accessor exposing a single Dependency (e.g., `TimeProvider.Current`, `Logger.Instance`).
**Why it's bad:** Hidden dependency, hard to test, assumes single implementation globally, spreads through the codebase virally.
**Fix:** Inject the Dependency through the constructor instead.

### 4. Constrained Construction
**What:** Assuming or forcing all implementations to have a specific constructor signature (e.g., parameterless, or matching a base class).
**Why it's bad:** Prevents implementations from declaring their own Dependencies. Forces lowest-common-denominator constructors.
**Fix:** Let each implementation define whatever constructor it needs; compose in the Composition Root.

## Priority

Fix **Control Freak** first (it blocks everything else), then **Service Locator** (it's the most deceptive). Ambient Context and Constrained Construction are less common but still harmful.
