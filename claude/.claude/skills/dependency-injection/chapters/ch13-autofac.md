# Chapter 13 — Autofac

## Overview

Autofac is a mature, feature-rich DI Container for .NET. This chapter covers its API as a reference implementation of DI Container concepts from Chapter 12.

## Key Features

- **Module-based registration** — group related registrations into `Module` classes for organization
- **Lambda registration** — register factories as lambdas for complex creation logic
- **Lifetime scopes** — `InstancePerLifetimeScope` maps to Scoped lifestyle, supports nested scopes
- **Auto-Wiring** — automatic constructor parameter resolution via reflection
- **Decorator support** — built-in `RegisterDecorator<TService, TDecorator>()` for interception
- **Composite support** — register multiple implementations and resolve as `IEnumerable<T>`

## Registration Patterns

```csharp
var builder = new ContainerBuilder();
builder.RegisterType<SqlProductRepository>().As<IProductRepository>();
builder.RegisterType<ProductService>().As<IProductService>();
builder.RegisterDecorator<CachingRepository, IProductRepository>();
var container = builder.Build();
```

## When to Choose Autofac

- Need sophisticated lifetime scoping (nested scopes, owned instances)
- Want built-in Decorator/Composite support without manual wiring
- Large application with module-based organization needs
- Already using Autofac in the codebase

## General Container Guidance

The specific container matters less than applying DI principles correctly. All containers from chapters 13–15 implement the same concepts. Choose based on team familiarity and specific feature needs.
