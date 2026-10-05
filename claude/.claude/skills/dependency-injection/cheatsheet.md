# DI Cheatsheet

## The 5 Rules

1. **Program against Abstractions**, not concrete types
2. **Inject Volatile Dependencies** through constructors (default)
3. **Compose in the Composition Root** — one place, near the entry point
4. **Never use Service Locator** — Dependencies are received, not requested
5. **Start with Pure DI** — add a container only when manual composition becomes painful

## Decision Tree: Which Pattern?

```
Required Dependency?
├─ YES → Available at construction? → YES → Constructor Injection
│                                    → NO  → Method Injection
└─ NO  → Good Local Default? → YES → Property Injection
                               → NO → Constructor Injection (make it required)
```

## Smell Check

| Smell | Likely Problem | Fix |
|---|---|---|
| `new VolatileDep()` outside Composition Root | Control Freak | Move to Composition Root |
| `Locator.Get<T>()` | Service Locator | Constructor Injection |
| `SomeService.Current` | Ambient Context | Constructor Injection |
| Constructor >4 params | SRP violation | Facade Service or Domain Events |
| Singleton → Scoped dep | Captive Dependency | Fix lifestyles |

## Volatile vs. Stable

| Volatile (inject it) | Stable (new is fine) |
|---|---|
| Database access | String, DateTime, Math |
| File system, network | Collections, DTOs |
| Non-deterministic (time, random) | Framework base types |
| Under active development | Stable library types |
| Requires runtime config | Value objects |

## Decorator Stacking

```
new Auditing(           // 3. Log the call
    new Caching(        // 2. Check cache first
        new SqlRepo())) // 1. Actual implementation
```

Read bottom-up for execution order: SqlRepo → Caching → Auditing.

## Container Choice

| Need | Container |
|---|---|
| ASP.NET Core default, simple apps | MS.Extensions.DI |
| Decorator/Composite support, diagnostics | Simple Injector |
| Lifetime scoping, modules | Autofac |
| Maximum control, learning | Pure DI (no container) |
