# Chapter 10 — Aspect-Oriented Programming by Design

## SOLID Enables AOP Without Tools

When your code follows SOLID principles, Cross-Cutting Concerns can be applied through Decorators and Composites — no special AOP framework needed.

## The Key Abstractions

### ICommandHandler<TCommand>
```csharp
public interface ICommandHandler<TCommand>
{
    void Handle(TCommand command);
}
```
Every business operation becomes a class implementing this interface. This gives a uniform shape to all write operations.

### IQueryHandler<TQuery, TResult>
```csharp
public interface IQueryHandler<TQuery, TResult> where TQuery : IQuery<TResult>
{
    TResult Handle(TQuery query);
}
```
Same principle for read operations.

## Applying Cross-Cutting Concerns

Because all operations share the same shape, one Decorator handles the concern for **all** operations:

```csharp
public class AuditingCommandHandler<TCommand> : ICommandHandler<TCommand>
{
    private readonly ICommandHandler<TCommand> inner;
    public void Handle(TCommand cmd)
    {
        Log(cmd);           // Cross-cutting
        this.inner.Handle(cmd); // Delegate
    }
}
```

**Stacking concerns in Composition Root:**
```csharp
new AuditingCommandHandler<ApproveOrder>(
    new AuthorizationCommandHandler<ApproveOrder>(
        new TransactionCommandHandler<ApproveOrder>(
            new ApproveOrderHandler(repo))));
```

## SOLID Connection

| Principle | How It Enables AOP |
|---|---|
| **SRP** | Each handler = one operation, each Decorator = one concern |
| **OCP** | Add behavior via Decorator wrapping, no modification |
| **LSP** | Decorators are substitutable for the interface they wrap |
| **ISP** | `ICommandHandler<T>` has exactly one method — minimal interface |
| **DIP** | Consumers depend on the Abstraction, not concrete handlers |

## When to Use

Use generic Abstractions (`ICommandHandler<T>`, `IQueryHandler<T,R>`) when:
- You have many operations with similar cross-cutting needs
- You want to apply concerns uniformly without repetition
- The system is large enough that the abstraction overhead pays off

For small systems, direct Decorator application per-interface is sufficient.
