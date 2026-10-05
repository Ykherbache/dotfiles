# Ch 6: Object-Oriented Style

## Two Core Design Principles

### Separation of Concerns
Each object should handle one clearly defined responsibility. When concerns are separated, changes to one area don't ripple through unrelated code. Higher-level objects compose lower-level ones to build complex behavior.

### Higher Levels of Abstraction
Build layers where each level hides the details of the level below. Well-designed code reads as a series of domain-level statements, not as implementation mechanics.

## Four Design Heuristics

### 1. Composite Simpler Than the Sum of Its Parts
The API of a composite object should be simpler than the combined APIs of its components. If combining objects makes the system harder to understand, the decomposition is wrong. The composite should hide how its components interact.

### 2. Context Independence
An object should have no built-in knowledge of the system it runs in. It receives everything it needs via its interface (constructor parameters, method arguments). This makes objects reusable and independently testable.

### 3. Encapsulation and Information Hiding
Objects communicate through narrow, well-defined interfaces. Internal state and implementation choices are private. "Tell, Don't Ask" — send commands, don't extract data.

### 4. Single Responsibility Principle
An object that's hard to name, hard to test, or hard to describe without "and" has too many responsibilities. Split it.

## Ports and Adapters (Hexagonal Architecture)
The domain model sits at the center, unaware of infrastructure. **Ports** define what the domain needs (interfaces). **Adapters** implement ports for specific technologies (database, HTTP, messaging). This makes the domain testable without infrastructure and allows swapping technologies.

## Value Types
Immutable objects representing quantities, measurements, or concepts. Break them out aggressively — they reduce complexity, are trivially testable, and often reveal domain concepts. Three discovery patterns:
- **Breaking out**: extract a value hidden inside a primitive
- **Budding off**: split a growing object into a value + behavior
- **Bundling up**: group related values into a named concept
