# Ch 7: Achieving Object-Oriented Design

## How TDD Drives Design

TDD doesn't just verify code — it shapes it. Starting from tests forces you to think about how an object is used before how it works. This naturally produces clean interfaces and loose coupling.

## Three Techniques for Introducing Value Types

### Breaking Out
A value buried inside a complex method or embedded in a primitive (String, int) is extracted into its own type. Example: extracting a `Money` type from raw `BigDecimal` amounts.

### Budding Off
When an object starts accumulating responsibilities, bud off a new collaborator. Create an interface for the new role, mock it in tests, implement it later. The test drives you to discover the interface.

### Bundling Up
Group related values that always travel together into a named type. If three parameters always appear together, they're a concept waiting to be named.

## Interface Discovery Through Mocking

When writing a test, you need the object under test to talk to collaborators. Instead of building real collaborators, **define the interface** the object needs and mock it. This discovers:
- What methods the collaborator needs
- What parameters flow between objects
- What return values are expected

The mock is a specification of the relationship.

## Building Up to Higher-Level Programming

### Compose, Don't Inherit
Favor delegation over inheritance. Objects should be assembled from small, focused collaborators. Inheritance couples subclass to superclass internals.

### Domain Language in Code
Layer objects so that high-level code reads like domain prose. Each layer translates between its abstraction level and the one below. The DSL emerges from the object structure — no framework required.

### Builder Pattern for Complex Construction
When object creation is complex, extract a Builder. Builders are especially useful in tests (Test Data Builders) for creating valid objects with sensible defaults and only specifying what matters for this test.
