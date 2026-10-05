# Dependency Injection — Principles, Practices, and Patterns

> Based on: Mark Seemann & Steven van Deursen, *Dependency Injection Principles, Practices, and Patterns* (Manning, 2019)

## When to Activate

Use this skill when:
- Designing how objects are composed and wired together
- Reviewing code for coupling issues or DI anti-patterns
- Deciding between injection patterns (constructor, method, property)
- Implementing Cross-Cutting Concerns (logging, caching, auth, audit)
- Choosing or configuring a DI Container
- Refactoring tightly coupled code toward loose coupling

## Core Framework: The Three Pillars

### 1. Object Composition
Assemble object graphs in a **Composition Root** — a single location near the entry point. The rest of the application programs against Abstractions (interfaces), never instantiating Volatile Dependencies directly.

### 2. Lifetime Management
Three lifestyles: **Singleton** (one instance, app lifetime), **Scoped** (one per request/scope), **Transient** (new each time). Rule: a component's lifestyle must be ≥ its Dependencies' lifestyles. Violating this creates **Captive Dependencies**.

### 3. Interception
Use **Decorators** to add Cross-Cutting Concerns (logging, caching, security) without modifying consumers or implementations. Decorators stack and compose freely.

## Decision Heuristic: Stable vs. Volatile

- **Stable** (String, Math, DTOs, framework types) → `new` anywhere, no injection needed
- **Volatile** (DB, filesystem, network, nondeterministic, under development) → must be injected

## Pattern Selection

| Situation | Pattern |
|---|---|
| Required Dependency, available at construction | **Constructor Injection** (default) |
| Dependency varies per call or outlives consumer | **Method Injection** |
| Truly optional, good Local Default exists | **Property Injection** |

**Constructor Injection** is the default for ~95% of cases. Guard Clause + readonly field + single constructor.

## Anti-Pattern Detection

| Code Smell | Anti-Pattern | Fix |
|---|---|---|
| `new VolatileDep()` outside Composition Root | **Control Freak** | Move to Composition Root |
| `Locator.GetService<T>()` | **Service Locator** | Constructor Injection |
| `SomeService.Current` static accessor | **Ambient Context** | Constructor Injection |
| Forced constructor signatures | **Constrained Construction** | Free constructors, compose in root |
| Constructor >4 parameters | **Over-injection** (SRP violation) | Facade Service or Domain Events |

## SOLID Connection to DI

- **SRP** → One class, one responsibility → prevents Constructor Over-injection
- **OCP** → Extend via Decorators, not modification
- **LSP** → Decorators are substitutable for the interface they wrap
- **ISP** → Small interfaces (`ICommandHandler<T>`) enable generic Decorators
- **DIP** → High-level modules own Abstractions; low-level modules implement them

## AOP by Design (No Framework Needed)

When operations conform to uniform Abstractions (`ICommandHandler<T>`, `IQueryHandler<T,R>`), a single generic Decorator applies a concern to **all** operations:

```
AuditingHandler<T>(AuthHandler<T>(TransactionHandler<T>(ConcreteHandler)))
```

## Pure DI vs. Container

**Start with Pure DI** (manual composition). Switch to a container when:
- Composition Root exceeds ~100 registrations
- You need convention-based batch registration
- Sophisticated lifetime scoping is required

Containers: **MS.Extensions.DI** (built-in, simple), **Simple Injector** (diagnostics, Decorator support), **Autofac** (modules, scoping).

## Chapter Index

| # | Topic | File |
|---|---|---|
| 1 | Introduction to DI | [ch01](chapters/ch01-the-right-introduction.md) |
| 2 | Tightly coupled code | [ch02](chapters/ch02-writing-tightly-coupled-code.md) |
| 3 | Loosely coupled code | [ch03](chapters/ch03-writing-loosely-coupled-code.md) |
| 4 | DI patterns catalog | [ch04](chapters/ch04-di-patterns.md) |
| 5 | DI anti-patterns | [ch05](chapters/ch05-di-anti-patterns.md) |
| 6 | Code smells | [ch06](chapters/ch06-code-smells.md) |
| 7 | Application composition | [ch07](chapters/ch07-application-composition.md) |
| 8 | Object lifetime | [ch08](chapters/ch08-object-lifetime.md) |
| 9 | Interception | [ch09](chapters/ch09-interception.md) |
| 10 | AOP by design (SOLID) | [ch10](chapters/ch10-solid-as-driver-for-aop.md) |
| 11 | Tool-based AOP | [ch11](chapters/ch11-tool-based-aop.md) |
| 12 | DI Containers intro | [ch12](chapters/ch12-di-container-intro.md) |
| 13 | Autofac | [ch13](chapters/ch13-autofac.md) |
| 14 | Simple Injector | [ch14](chapters/ch14-simple-injector.md) |
| 15 | MS.Extensions.DI | [ch15](chapters/ch15-ms-di.md) |

## Supporting Files

- [glossary.md](glossary.md) — Term definitions
- [patterns.md](patterns.md) — Patterns & anti-patterns quick reference
- [cheatsheet.md](cheatsheet.md) — Decision trees & rules of thumb
