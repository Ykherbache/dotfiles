# Chapter 1 — The Right Introduction to DI

## Core Argument

DI is a set of software design principles and patterns that enable loosely coupled code. Loose coupling makes code more maintainable, extensible, and testable. DI is not a technology or library — it's a mindset shift in how you compose objects.

## Four Benefits of Loose Coupling

1. **Late binding** — swap implementations without recompilation (e.g., switch data store)
2. **Extensibility** — add new features by composing new implementations of existing Abstractions
3. **Parallel development** — teams work against interfaces independently
4. **Testability** — replace Dependencies with Test Doubles for isolated unit tests

## Key Concepts

- **Dependency**: any object another object needs to function
- **Stable Dependency**: deterministic, already exists, no setup needed (e.g., `String`, `Math`) — safe to `new` anywhere
- **Volatile Dependency**: requires runtime environment (DB, filesystem, network), nondeterministic, or under active development — must be injected
- **Abstraction**: interface or abstract class defining a contract without implementation
- **Seam**: point where an application is assembled from its constituent parts — always program against Abstractions at seams

## The Three Dimensions of DI

| Dimension | Question | Chapter |
|---|---|---|
| Object Composition | How are object graphs built? | 7–8 |
| Lifetime Management | When are Dependencies created/released? | 8 |
| Interception | How to add Cross-Cutting Concerns? | 9–10 |

## Decision Heuristic

Use DI when a Dependency is **Volatile**. If it's Stable, direct instantiation is fine. Ask: does this Dependency involve I/O, nondeterminism, or active development? If yes → inject it.
