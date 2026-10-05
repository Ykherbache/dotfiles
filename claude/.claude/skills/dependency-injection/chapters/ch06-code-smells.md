# Chapter 6 — Code Smells

## Constructor Over-injection

**Signal:** A constructor with more than 4 parameters.
**Root cause:** Single Responsibility Principle violation — the class does too many things.
**Important:** Don't blame Constructor Injection. It's *revealing* the design problem, not causing it. Moving Dependencies to properties doesn't reduce complexity — it hides it.

### Fix 1: Facade Services
Identify natural clusters of interacting Dependencies and extract them behind a new Abstraction.

**Example:** `OrderService` with 5 Dependencies:
- `IOrderRepository` + `IMessageService` + `IBillingSystem` + `ILocationService` + `IInventoryManagement`
- `ILocationService` + `IInventoryManagement` → extract to `IOrderFulfillment` (Facade Service)
- `IMessageService` + `IBillingSystem` + `IOrderFulfillment` → all notify external systems → unify behind `INotificationService`
- Use **Composite pattern** to wrap multiple `INotificationService` implementations
- Result: `OrderService` depends on only `IOrderRepository` + `INotificationService`

**Key insight:** Facade Service refactoring often reveals hidden domain concepts. "Order fulfillment" is a business concept that was implicit and is now explicit.

### Fix 2: Domain Events
Promote events to first-class types (`OrderApproved`, `OrderCancelled`) and use generic `IEventHandler<TEvent>`:
- Each handler implements `IEventHandler<OrderApproved>`
- Composite dispatches to all registered handlers
- Adding new handlers requires zero changes to the consumer

## Abstract Factory Overuse

**Smell:** Using Abstract Factory when you could use Constructor Injection.
**Rule:** Only use Abstract Factory when you need to create instances at runtime with **runtime data** that can't be known at composition time. If the data is available at composition time, inject the product directly.

## Cyclic Dependencies

**Smell:** A → B → A (direct or indirect cycles).
**Fixes:**
1. Extract common interface to break the cycle
2. Use domain events to decouple
3. Redesign — cycles often indicate confused responsibilities
