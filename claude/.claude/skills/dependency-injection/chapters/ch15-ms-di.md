# Chapter 15 — Microsoft.Extensions.DependencyInjection

## Overview

The built-in DI Container for ASP.NET Core. Minimalist by design — covers the 80% case without advanced features.

## Key Features

- **Built into ASP.NET Core** — no additional packages needed
- **Three lifestyles** — `AddSingleton`, `AddScoped`, `AddTransient`
- **IServiceCollection** — registration API, separate from resolution
- **IServiceProvider** — resolution API, injected where needed by the framework
- **Framework integration** — controllers, middleware, and other framework types are automatically resolved

## Registration Patterns

```csharp
services.AddTransient<IProductService, ProductService>();
services.AddScoped<IProductRepository, SqlProductRepository>();
services.AddSingleton<ICache, InMemoryCache>();
```

## Limitations

- **No built-in Decorator support** — must use Scrutor or manual registration
- **No diagnostic verification** — won't catch Captive Dependencies automatically
- **No Auto-Registration** — each type must be registered explicitly (or use Scrutor)
- **Limited lifestyle options** — no per-graph, no hybrid lifestyles

## When to Use

- Default choice for ASP.NET Core applications
- Small-to-medium applications where advanced features aren't needed
- When you want zero additional dependencies
- As a starting point — can be replaced with Autofac or Simple Injector later via the conforming container adapter

## When to Upgrade

Consider switching to Autofac or Simple Injector when:
- You need Decorator/Composite support for AOP
- Captive Dependency detection is important
- Convention-based batch registration would save significant effort
