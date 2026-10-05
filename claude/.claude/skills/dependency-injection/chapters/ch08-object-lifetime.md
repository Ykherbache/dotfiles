# Chapter 8 — Object Lifetime

## Lifestyle Catalog

### Singleton
- **One instance** for the entire application lifetime
- Created on first request, never released until app shutdown
- Use for: stateless services, thread-safe caches, configuration objects
- **Danger:** Must be thread-safe. Singleton depending on Transient/Scoped = **Captive Dependency** bug

### Transient
- **New instance** every time it's requested
- Use for: lightweight stateless services, objects with no shared state
- **Danger:** If expensive to create or holds resources, can cause performance issues or memory leaks

### Scoped
- **One instance per scope** (typically per web request)
- Created on first request within the scope, disposed when scope ends
- Use for: DbContext, unit-of-work objects, per-request state
- **Most common** lifestyle for data access components in web apps

## The Captive Dependency Problem

**Definition:** A component with a long lifestyle captures a Dependency with a shorter lifestyle, keeping it alive beyond its intended lifetime.

```
Singleton → depends on → Scoped service ← BUG!
```

The Scoped service is now effectively a Singleton, which can cause:
- Stale data (DbContext reused across requests)
- Thread-safety issues
- Memory leaks

**Rule:** A component's lifestyle must be **equal to or shorter than** its Dependencies' lifestyles.

```
Singleton → Singleton     ✓
Scoped    → Singleton     ✓
Scoped    → Scoped        ✓
Transient → anything      ✓
Singleton → Scoped        ✗ CAPTIVE DEPENDENCY
Singleton → Transient     ✗ CAPTIVE DEPENDENCY
```

## Lifestyle Mismatches — Detection

- **Pure DI:** Visible in code — you see the nesting
- **DI Containers:** Some containers detect this at runtime and throw; others silently allow it
- **Best practice:** Verify the lifestyle graph manually or use container diagnostics

## Disposal

The component that creates an object is responsible for disposing it. In DI, the **Composer** (Composition Root or Container) creates objects, so it must manage disposal. Consumers should **never** dispose injected Dependencies.
