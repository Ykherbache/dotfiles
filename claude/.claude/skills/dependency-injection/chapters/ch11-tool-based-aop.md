# Chapter 11 — Tool-Based AOP

## When Design-Based AOP Isn't Enough

Chapter 10's Decorator approach works when all operations share a common Abstraction. Tool-based AOP handles cases where:
- You can't change the code to conform to a uniform interface
- Cross-Cutting Concerns must apply to diverse, pre-existing interfaces
- The number of distinct interfaces makes manual Decorator creation impractical

## Dynamic Interception

AOP tools (Castle DynamicProxy, Unity Interception) generate Decorator-like proxies at runtime:

```csharp
// Instead of writing a Decorator class manually:
container.RegisterInterceptor<IProductService>(
    new LoggingInterceptor(),
    new CachingInterceptor());
```

The tool generates a proxy class that wraps `IProductService` and calls interceptors before/after each method.

## Trade-offs

| Aspect | Design-Based (Ch 10) | Tool-Based (Ch 11) |
|---|---|---|
| Compile-time safety | Full | Partial (runtime proxy) |
| Debugging | Clear stack traces | Proxy layers obscure |
| Performance | Direct calls | Reflection overhead |
| Flexibility | Requires uniform interfaces | Works on any interface |
| Complexity | Simple concept | Framework dependency |

## Recommendation

**Prefer design-based AOP** (SOLID + Decorators) whenever possible. It's simpler, safer, and framework-independent. Fall back to tool-based AOP only when:
1. Legacy code with diverse interfaces that can't be unified
2. Applying concerns retroactively to a large existing codebase
3. The cost of writing individual Decorators exceeds the cost of the tool's complexity

## Key Insight

Tool-based AOP is a tactical tool, not a strategic choice. If you're designing a new system, invest in SOLID-conforming Abstractions and use Decorators. The small upfront cost pays enormous dividends in clarity and maintainability.
