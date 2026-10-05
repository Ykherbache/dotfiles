# Chapter 14 — Simple Injector

## Overview

Simple Injector is a fast, opinionated DI Container that enforces best practices by design.

## Key Features

- **Verification API** — `container.Verify()` checks the entire registration at startup, catching misconfiguration early
- **Diagnostic warnings** — detects Captive Dependencies, Short-Circuited Dependencies, ambiguous lifestyles
- **Decorator pipeline** — first-class `RegisterDecorator()` with predicate-based conditional decoration
- **Collection registration** — `RegisterCollection<T>()` for Composite patterns
- **Strict by default** — rejects common mistakes (e.g., resolving unregistered types)

## Why Simple Injector Stands Out

Its diagnostic system catches lifestyle mismatches (Captive Dependencies) that other containers silently allow. The `Verify()` call at startup acts as a compile-time check for your object graph.

## Registration Patterns

```csharp
var container = new Container();
container.Register<IProductRepository, SqlProductRepository>(Lifestyle.Scoped);
container.RegisterDecorator<IProductRepository, CachingRepository>();
container.Collection.Register<IEventHandler<OrderApproved>>(assemblies);
container.Verify(); // Catches issues at startup
```

## When to Choose Simple Injector

- Want maximum safety and early error detection
- Building systems with heavy Decorator/Composite usage (SOLID-driven AOP from Ch 10)
- Value opinionated defaults that prevent common mistakes
- Performance-sensitive scenarios (one of the fastest containers)
