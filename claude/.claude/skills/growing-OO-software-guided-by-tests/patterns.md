# Patterns & Anti-Patterns

## Design Patterns

### Walking Skeleton
**When**: Starting a new project or major feature.
**Do**: Build the thinnest end-to-end slice first. Automated build, deploy, test. Prove the stack works before adding features.
**Why**: Integration risks compound. The skeleton flushes them out day one.

### Ports and Adapters (Hexagonal)
**When**: Domain logic touches infrastructure (DB, HTTP, messaging).
**Do**: Define ports (interfaces) in domain terms. Implement adapters for each technology. Domain depends only on ports.
**Why**: Domain stays testable without infrastructure. Technologies become swappable.

### Interface Discovery via Mocks
**When**: Building an object that needs collaborators.
**Do**: Mock the collaborator interface before it exists. Let the test define what methods, parameters, and return values are needed. Implement the interface after.
**Why**: The mock is a specification. The test drives the API design.

### Test Data Builder
**When**: Domain objects need complex construction for tests.
**Do**: Builder with sensible defaults and chainable setters. Tests override only relevant fields.
**Why**: Resilient to constructor changes. Readable tests. One place to update.

### Sampling (Poller/Probe)
**When**: Testing async state changes.
**Do**: Poll a `Probe` at intervals until satisfied or timed out. Probe describes the expected state and the mismatch.
**Why**: Deterministic timeout behavior with clear failure diagnostics.

### Listening (NotificationTrace)
**When**: Testing async events.
**Do**: Collect notifications in a thread-safe trace. Assert with blocking wait + matcher.
**Why**: Captures event order and content without polling.

### Separate Functionality from Concurrency
**When**: Code mixes business logic with threading.
**Do**: Pure synchronous domain logic + injected `Executor` for concurrency. Use `DeterministicExecutor` in tests.
**Why**: Domain logic becomes trivially testable. Concurrency tested separately.

### Object Peer Stereotypes
**When**: Designing an object's collaborators.
**Do**: Classify each peer as Dependency (constructor-injected), Notification (fire-and-forget), or Adjustment (policy/strategy).
**Why**: Clear classification drives clean injection and test setup.

## Anti-Patterns

### Mock Types You Don't Own
**Symptom**: Mocking JDBC, Servlet API, or framework classes directly.
**Fix**: Write an adapter. Mock the adapter interface. Integration-test the adapter against the real library.

### Test-After (Test-Last)
**Symptom**: Writing code first, then tests. Tests struggle to cover the code.
**Fix**: Write the test first. It shapes the design and guarantees coverage.

### Ignoring Test Pain
**Symptom**: Complex test setup, many mocks, hard-to-name tests. Response: "tests are just hard."
**Fix**: The pain is a design signal. Refactor the production code until the tests are easy.

### Mocking Values
**Symptom**: `mock(Money.class)` or `mock(String.class)`.
**Fix**: Use real value objects. Only mock objects with behavior (services, listeners).

### Thread.sleep() in Tests
**Symptom**: `sleep(500)` to wait for async results.
**Fix**: Use Poller/Probe or NotificationTrace with explicit timeouts and diagnostics.

### Over-Specifying Expectations
**Symptom**: Every mock method has a strict `oneOf` expectation. Tests break on any refactoring.
**Fix**: Use `allowing` for queries. Only `expect` commands that are the point of the test.

### God Test Setup
**Symptom**: `@Before` method is 50+ lines. Every test pays for the most complex case.
**Fix**: Split test class by scenario. Use builders. Extract setup helpers by intent.

### Testing the Framework
**Symptom**: Tests that verify Hibernate, Spring, or JUnit behavior rather than your code.
**Fix**: Trust the framework. Test your usage of it (mappings, queries, configuration).
