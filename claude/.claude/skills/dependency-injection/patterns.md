# Patterns & Anti-Patterns — Quick Reference

## DI Patterns (Do This)

### Composition Root
- **One per application**, near the entry point
- Only location that references concrete Volatile Dependency implementations
- Libraries never have a Composition Root
- Prefer code-based over config-based composition

### Constructor Injection (Default)
- Declare Dependencies as constructor parameters
- Guard Clause → `readonly` field → single constructor
- Use for all **required** Dependencies
- Compiler enforces completeness — missing Dependencies = compile error

### Method Injection (Situational)
- Pass Dependency as method parameter
- Use when: Dependency varies per call, or consumer outlives the Dependency
- Common for: Singleton consuming per-request context

### Property Injection (Rare)
- Writable property with Local Default value
- Only for truly optional Dependencies
- Overuse creates temporal coupling

## DI Anti-Patterns (Don't Do This)

### Control Freak
- `new VolatileDependency()` outside Composition Root
- Static Factories, Foreign Defaults, concrete factories
- **Fix:** Move instantiation to Composition Root, use Constructor Injection

### Service Locator
- `Locator.GetService<T>()` — pulling Dependencies instead of receiving them
- Hides Dependencies, runtime errors, couples everything to the locator
- **Fix:** Replace with constructor parameters

### Ambient Context
- `SomeService.Current` — static global accessor
- Hidden dependency, untestable, assumes single global implementation
- **Fix:** Inject through constructor

### Constrained Construction
- Forcing specific constructor signatures on implementations
- **Fix:** Let implementations define their own constructors; compose in Composition Root

## Design Patterns Used with DI

### Decorator
- Wraps an Abstraction, implements the same Abstraction
- Adds one Cross-Cutting Concern per layer
- Decorators stack: `Auditing(Caching(Actual))`

### Composite
- Wraps a collection of an Abstraction, implements the same Abstraction
- Dispatches to all wrapped instances
- Use with `IEventHandler<T>`, `INotificationService`

### Adapter
- Converts one interface to another
- Bridges between your Abstractions and third-party APIs

### Null Object
- No-op implementation of an Abstraction
- Use as Local Default for Property Injection

### Facade Service
- Hides a cluster of Dependencies behind one Abstraction
- Reveals implicit domain concepts
- Fix for Constructor Over-injection

## Lifestyle Rules

```
Singleton  → can depend on → Singleton only
Scoped     → can depend on → Scoped, Singleton
Transient  → can depend on → anything
```

Violating this causes **Captive Dependencies** — silent bugs where scoped/transient objects become effectively singleton.
