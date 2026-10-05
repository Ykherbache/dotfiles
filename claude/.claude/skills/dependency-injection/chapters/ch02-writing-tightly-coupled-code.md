# Chapter 2 — Writing Tightly Coupled Code

## Purpose

Demonstrates what happens without DI through Mary Rowan's e-commerce application. Shows how tightly coupled code accumulates hidden costs.

## The Problem

Mary builds an e-commerce site using direct instantiation everywhere:
- `ProductService` creates `SqlProductRepository` directly
- `HomeController` creates `ProductService` directly
- Every class controls its own Dependencies

## Consequences of Tight Coupling

1. **Extensibility blocked** — adding a caching layer requires modifying `ProductService` internals
2. **Parallel development impossible** — can't work on `ProductService` without a database
3. **Testability destroyed** — unit testing `HomeController` requires a live database
4. **Late binding impossible** — can't switch from SQL Server to Azure without recompilation

## The Coupling Chain

```
HomeController → ProductService → SqlProductRepository → Database
```

Each `→` is a compile-time dependency. Change at any point ripples through the chain.

## Key Lesson

Tight coupling isn't always visible. Code can appear clean and well-organized while being deeply coupled. The `new` keyword on Volatile Dependencies is the primary indicator. The cost of tight coupling grows exponentially with codebase size — what feels manageable at 5 classes becomes unworkable at 500.

## Contrast with Chapter 3

Same requirements, same features, but composed with DI — resulting in code that's extensible, testable, and maintainable without any additional frameworks.
