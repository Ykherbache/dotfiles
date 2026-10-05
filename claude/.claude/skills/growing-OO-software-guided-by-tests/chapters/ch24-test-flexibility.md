# Ch 24: Test Flexibility

## The Goal: Tests That Survive Refactoring

Tests should fail when behavior changes, not when implementation changes. Brittle tests that break on refactoring destroy confidence and slow development.

## Precision in Expectations

### Specify Exactly What Matters
Don't over-specify. If the test cares about one argument, use `with(equalTo(value))` for that argument and `with(any(Type.class))` for others. Testing every argument when only one matters creates false coupling.

### Allow Queries, Expect Commands
- **Allow** (stub) methods that return values — the test doesn't care how often they're called
- **Expect** methods that cause side effects — these are the behavior being tested
- This is the single most important rule for mock-based testing

## Techniques for Flexible Tests

### Ignore Uninteresting Interactions
Use `ignoring(collaborator)` for objects that must exist but aren't part of this test's concern. Don't set up expectations on them.

### Test Behavior, Not Methods
A test should verify one coherent behavior, which might touch multiple methods. Don't write one test per method — write one test per scenario.

### Avoid Literals in Multiple Places
If the same value appears in setup and assertion, extract it to a named constant. This shows the connection and makes changes safe.

### Don't Mock Values
Never mock value objects — use real instances. Mocks are for objects with behavior (dependencies, notifications). Values are data — just construct them.

## When Tests Are Hard to Change

If every refactoring breaks many tests, the tests are coupled to structure rather than behavior. Common fixes:
- Replace specific expectations with `allowing`
- Extract test helpers that hide structural details
- Mock interfaces, not concrete classes
- Use builders to insulate tests from constructor changes
