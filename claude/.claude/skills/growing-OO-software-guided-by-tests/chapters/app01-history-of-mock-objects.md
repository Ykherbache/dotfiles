# Afterword: A Brief History of Mock Objects

## Origins (1999)

Born from a London architecture group discussion about TDD and "no getters" — the tension between testability and OO purity. The key insight: use **composition and dependency injection** instead of adding getters to inspect state.

## Evolution

1. **Connextra team** (Mackinnon, Mac, Cooke): discovered patterns of `expectedX`/`actualX` variables in test doubles. Refactored into `ExpectationValue`, `ExpectationList`, `ExpectationSet`, `ExpectationCounter`. Peter Marks named it "mock."

2. **XP2000 paper**: mixed reception — Java's poor reflection made setup manual and verbose.

3. **Nat Pryce's contribution**: reimplemented in Ruby using reflection, then ported to Java using `Proxy`. Shifted emphasis from asserting parameter values to asserting **messages between objects**.

4. **Dynamock → jMock → jMock2**: successive refinements. Steve Freeman introduced cascading interfaces to guide IDE code completion. They realized they were writing a **language in Java** for expressing expectations.

## Key Conceptual Shifts

- From "test helper" → "design tool"
- From asserting values → asserting **communication protocols**
- From mocking implementations → mocking **roles** (interfaces)
- Joe Walnes's insight: "Only mock types you own"
- Paper: "Mock Roles, Not Objects" (2004) — the technique is about **roles objects play**, not implementation details

## Legacy

The Hamcrest matcher library (extracted by Joe Walnes, adopted by JUnit), jMock2, and the conceptual framework of this book all trace back to that 1999 conversation about the tension between testing and OO design.
