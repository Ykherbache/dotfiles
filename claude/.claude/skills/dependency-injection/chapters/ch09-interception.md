# Chapter 9 — Interception

## What Is Interception?

Intercepting calls between a consumer and its Dependency to add behavior (Cross-Cutting Concerns) without modifying either.

## The Decorator Pattern

The primary mechanism for interception in DI. A Decorator wraps an Abstraction and implements the same Abstraction:

```csharp
public class AuditingRepository : IProductRepository
{
    private readonly IProductRepository inner;
    private readonly IAuditTrail audit;

    public AuditingRepository(IProductRepository inner, IAuditTrail audit)
    {
        this.inner = inner;
        this.audit = audit;
    }

    public Product GetById(Guid id)
    {
        this.audit.Log($"GetById({id})");    // Before
        var result = this.inner.GetById(id); // Delegate
        this.audit.Log($"Returned {result}"); // After
        return result;
    }
}
```

**Composition Root wiring:**
```csharp
new ProductService(
    new AuditingRepository(           // Decorator
        new CachingRepository(        // Decorator
            new SqlProductRepository(connStr))));  // Real impl
```

Decorators **stack** — each layer adds one concern. Order matters.

## Cross-Cutting Concerns

Behaviors that span multiple components:
- **Auditing** — who did what, when
- **Logging** — diagnostic information
- **Security** — authorization checks
- **Caching** — avoid repeated expensive operations
- **Validation** — input correctness
- **Error handling** — retry, circuit breaker
- **Transaction management** — unit of work boundaries

## Why Decorators Over Inheritance

- **Single Responsibility** — each Decorator handles one concern
- **Open/Closed** — add behavior without modifying existing classes
- **Composable** — mix and match Decorators freely
- **Testable** — test each Decorator in isolation

## Key Insight

With DI + Decorator, you get Aspect-Oriented Programming (AOP) without any special framework or tooling. SOLID principles naturally enable this.
