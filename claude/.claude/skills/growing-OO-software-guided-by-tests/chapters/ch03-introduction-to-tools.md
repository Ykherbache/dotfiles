# Ch 3: An Introduction to the Tools

## Tools in This Book

### JUnit 4
xUnit-family test framework. Tests are methods annotated `@Test` in classes. Assertions via `assertThat()` with Hamcrest matchers for readable failure messages.

### Hamcrest Matchers
Composable matcher library for expressive assertions. Key advantage: failure messages describe both expectation and actual value. Matchers compose with `allOf()`, `anyOf()`, `not()`. Custom matchers extend `TypeSafeMatcher<T>`.

### jMock2
Mock object framework built around the `Mockery` context. Key concepts:
- **Mockery**: creates mocks, collects expectations, verifies them
- **Expectations block**: `context.checking(new Expectations() {{ ... }})` — the double-brace idiom
- **Invocation counts**: `oneOf`, `exactly(n).of`, `atLeast(n).of`, `allowing`, `ignoring`, `never`
- **Actions**: `will(returnValue(...))`, `will(throwException(...))`
- **Sequences**: enforce ordering between expectations
- **States**: constrain expectations to state machine conditions

### Key Principle: Allow Queries, Expect Commands
- Use `allowing` for queries (stubs) — methods that return values without side effects
- Use `oneOf`/`exactly` for commands (expectations) — methods that change state or trigger actions
- This distinction keeps tests focused on behavior, not implementation

## Workflow Pattern
1. Create `Mockery` in test fixture
2. Create mock collaborators from the mockery
3. Write expectations in `checking()` block
4. Exercise the object under test
5. Assert on results; mockery auto-verifies expectations
