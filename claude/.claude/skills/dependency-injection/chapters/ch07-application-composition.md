# Chapter 7 — Application Composition

## Composition Root by Framework

Each application type has a natural place for its Composition Root:

| Framework | Composition Root Location |
|---|---|
| ASP.NET Core | `Startup.ConfigureServices` / `Program.cs` |
| Console app | `Main` method |
| WPF | `App.OnStartup` |
| UWP | `App.OnLaunched` |

## Composing Object Graphs

The Composition Root builds the entire object graph at startup (or lazily on first request for web apps). Two approaches:

### Pure DI (No Container)
Manually nest constructor calls:
```csharp
new HomeController(
    new ProductService(
        new SqlProductRepository(connStr),
        new AspNetUserContextAdapter()));
```

**Pros:** Compile-time verification, no magic, easy to debug, no library dependency.
**Cons:** Repetitive for large graphs, manual lifetime management.

### DI Container
Use a container's Auto-Wiring to resolve the graph automatically:
```csharp
services.AddTransient<IProductService, ProductService>();
services.AddTransient<IProductRepository, SqlProductRepository>();
```

**Pros:** Less boilerplate, automatic lifetime management, convention-based registration.
**Cons:** Runtime errors if misconfigured, implicit behavior, learning curve.

## The Register-Resolve-Release Pattern

When using a container:
1. **Register** — map Abstractions to implementations (in Composition Root)
2. **Resolve** — ask the container for the root object (once, at entry point)
3. **Release** — dispose the resolved graph when done

**Critical rule:** Only call Resolve **once** per request/operation. Multiple Resolve calls indicate Service Locator creeping in.

## Composition vs. Configuration

Keep Composition Root code-based by default. Only externalize to config files when you genuinely need post-deployment flexibility (rare). Code-based composition gives compile-time safety.
