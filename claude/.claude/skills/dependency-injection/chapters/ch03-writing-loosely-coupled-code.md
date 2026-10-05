# Chapter 3 — Writing Loosely Coupled Code

## Core Concepts

### Composition Root
Single logical location near the application's entry point where the entire object graph is composed. This is the **only place** where Volatile Dependencies should be instantiated.

**Rules:**
- One per application (not per library/module)
- As close to entry point as possible
- Only place that references all concrete implementations
- Libraries should **never** have a Composition Root

### Constructor Injection (Preview)
Statically declare required Dependencies as constructor parameters:
```
public ProductService(IProductRepository repository)
```

**Three rules:**
1. Guard Clause — reject null Dependencies immediately
2. Store in `readonly` field — guarantees immutability after construction
3. Single constructor — no ambiguity about how to create the object

### Dependency Inversion Principle (DIP)
Higher-level modules **own** their Abstractions. Lower-level modules implement them. The interface `IProductRepository` lives in the domain layer, not the data access layer. This inverts the traditional dependency direction.

**Layer structure:**
```
UI Layer → Domain Layer ← Data Access Layer
              ↑ IProductRepository defined here
              ↓ SqlProductRepository implements it there
```

### The Staircase Pattern
Object graph is composed by nesting constructors:
```csharp
new HomeController(
    new ProductService(
        new SqlProductRepository(connectionString),
        new AspNetUserContextAdapter()));
```

All `new` calls happen exclusively in the Composition Root.

## Key Insight

Loose coupling isn't about eliminating dependencies — it's about pushing the knowledge of concrete types to a single, well-known location (the Composition Root) while the rest of the application programs against Abstractions.
