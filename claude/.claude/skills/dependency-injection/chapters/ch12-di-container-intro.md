# Chapter 12 — DI Container Introduction

## What Is a DI Container?

A library that automates object composition. It handles:
- **Registration** — mapping Abstractions to implementations
- **Resolution** — building complete object graphs via Auto-Wiring
- **Lifetime management** — controlling when instances are created and disposed

## Auto-Wiring

The container inspects constructor parameters via reflection and automatically resolves Dependencies:

```csharp
// Registration
services.AddTransient<IProductService, ProductService>();
services.AddTransient<IProductRepository, SqlProductRepository>();

// Resolution — container sees ProductService needs IProductRepository,
// finds SqlProductRepository is registered, creates both
var service = container.Resolve<IProductService>();
```

No explicit wiring code needed for the object graph.

## Pure DI vs. DI Container

### Pure DI (Manual Composition)
```csharp
var svc = new ProductService(new SqlProductRepository(connStr));
```
- **Pros:** Compile-time verification, no library dependency, simple to understand, easy debugging
- **Cons:** Verbose for large graphs, manual lifetime management, repetitive code
- **Best for:** Small-to-medium applications, learning DI, when you want maximum control

### DI Container
```csharp
services.AddScoped<IProductService, ProductService>();
```
- **Pros:** Less boilerplate, automatic lifetime management, convention-based batch registration
- **Cons:** Runtime errors for misconfiguration, implicit behavior, learning curve
- **Best for:** Large applications with many registrations, when convention-based registration saves significant effort

## The Authors' Recommendation

**Start with Pure DI.** Only switch to a container when:
1. The Composition Root becomes unwieldy (hundreds of manual wirings)
2. You need sophisticated lifetime management that Pure DI makes tedious
3. Convention-based registration would eliminate significant repetition

A DI Container is a **tool**, not a requirement. DI the principle works perfectly without one.

## Container Pitfalls

- **Don't let the container leak** outside the Composition Root — that's Service Locator
- **Don't use the container for service location** — `container.Resolve<T>()` outside Composition Root = anti-pattern
- **Register explicitly** rather than relying on auto-discovery magic you don't understand
