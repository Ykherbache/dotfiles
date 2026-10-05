# Glossary — Dependency Injection Principles, Practices, and Patterns

**Abstraction** — Interface or abstract class defining a contract. The seam between components.

**Ambient Context** — Anti-pattern. Static accessor exposing a single Dependency globally (e.g., `TimeProvider.Current`).

**Auto-Wiring** — Container feature that resolves constructor parameters via reflection automatically.

**Captive Dependency** — Bug where a long-lived component captures a shorter-lived Dependency, keeping it alive beyond its intended scope. Singleton → Scoped = captive.

**Composition Root** — The single location near the app entry point where the entire object graph is composed. Only place Volatile Dependencies are instantiated.

**Constrained Construction** — Anti-pattern. Forcing all implementations to share a specific constructor signature.

**Constructor Injection** — Default DI pattern. Declare required Dependencies as constructor parameters with Guard Clauses and readonly fields.

**Constructor Over-injection** — Code smell. Constructor with >4 parameters, indicating SRP violation. Fix with Facade Services or domain events.

**Control Freak** — Anti-pattern. Creating Volatile Dependencies outside the Composition Root (typically via `new`).

**Cross-Cutting Concern** — Behavior spanning multiple components: logging, caching, security, auditing, transactions, error handling.

**Decorator** — Design pattern wrapping an Abstraction to add behavior without modifying the original. Primary interception mechanism in DI.

**Dependency Inversion Principle (DIP)** — High-level modules define Abstractions; low-level modules implement them. Interfaces live with the consumer, not the implementor.

**Domain Event** — A type representing a business-significant action (e.g., `OrderApproved`). Enables `IEventHandler<T>` generalization.

**Facade Service** — Abstraction hiding a natural cluster of interacting Dependencies behind a single interface. Refactoring for Constructor Over-injection.

**Foreign Default** — Default implementation from a different module — creates unwanted cross-module coupling.

**Interception** — Adding behavior between consumer and Dependency, typically via Decorators.

**Local Default** — Default implementation in the same module as the consumer — safe for Property Injection.

**Method Injection** — Pass Dependencies as method parameters. For runtime-varying Dependencies or lifetime mismatches.

**Property Injection** — Expose optional Dependencies as writable properties with Local Defaults. Rarely needed.

**Pure DI** — Composing object graphs manually without a DI Container. Start here.

**Register-Resolve-Release** — Container lifecycle: register mappings, resolve root object once, release when done.

**Scoped** — One instance per scope (typically per web request).

**Seam** — Point where the application is assembled from parts. Program against Abstractions at seams.

**Service Locator** — Anti-pattern. Global registry supplying Dependencies on demand. Hides Dependencies, causes runtime errors.

**Singleton** — One instance for the entire application lifetime. Must be thread-safe.

**Stable Dependency** — Deterministic, already deployed, no special setup. Safe to `new` anywhere.

**Transient** — New instance on every request.

**Volatile Dependency** — Requires runtime environment, nondeterministic, or under development. Must be injected.
