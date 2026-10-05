# Chapter 4 — DI Patterns

## Pattern Catalog

### 1. Composition Root (Primary)
**When:** Always. Every application needs one.
**Where:** As close to the entry point as possible.
**What:** The single location that composes the full object graph.

Framework-specific locations:
- ASP.NET Core → `Startup.ConfigureServices`
- Console app → `Program.Main`
- WPF → `App.OnStartup`

**Rule:** Only the Composition Root should reference concrete implementations of Volatile Dependencies. The rest of the application only knows Abstractions.

### 2. Constructor Injection (Default Pattern)
**When:** For all required Dependencies (the vast majority of cases).
**How:**
1. Declare Dependency as constructor parameter
2. Guard Clause: throw `ArgumentNullException` if null
3. Store in `private readonly` field
4. Use **one constructor only** — multiple constructors cause ambiguity

**Why default:** Dependencies are statically declared, compiler-enforced, immutable after construction. The class communicates its needs honestly.

### 3. Method Injection (Situational)
**When:** The Dependency varies per operation, or the consumer's lifetime differs from the Dependency's.
**How:** Pass the Dependency as a method parameter.
**Example:** A long-lived Singleton that needs per-request context — inject the context into the method, not the constructor.

### 4. Property Injection (Rare)
**When:** There's a good Local Default, and the Dependency is truly optional.
**How:** Expose a writable property with a sensible default value.
**Warning:** Overuse creates temporal coupling. If the Dependency is required, use Constructor Injection instead.

## Decision Flowchart

```
Is the Dependency required? 
  → YES: Is it available at construction time?
      → YES: Constructor Injection ✓
      → NO: Method Injection ✓
  → NO: Does a good Local Default exist?
      → YES: Property Injection ✓
      → NO: Constructor Injection ✓ (make it required)
```

## Key Principle

**Constructor Injection is the default.** Only deviate when you have a specific reason. Method Injection is for runtime-varying Dependencies. Property Injection is for truly optional Dependencies with Local Defaults.
