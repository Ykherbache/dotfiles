# Ch 22: Constructing Complex Test Data

## The Problem

As domain objects grow, constructing valid test instances becomes painful. Tests fill up with irrelevant setup that obscures intent. Constructor changes break dozens of tests.

## Test Data Builders

A builder for each domain type provides:
- **Sensible defaults** for every field
- **Chainable setters** for overriding specific values
- A `build()` method that produces a valid instance

```java
anItem().withId("item-123").withStopPrice(200).build()
```

Only specify what matters for this test. Defaults handle the rest.

## Builder Benefits

### Resilience to Change
When a constructor adds a parameter, update the builder once. All existing tests keep working because they rely on defaults.

### Readability
The test shows exactly which values matter: `aSniperSnapshot().winning(price)` says more than `new SniperSnapshot("item", 100, 110, WINNING)`.

### Composition
Builders can nest: `anItem().withSniper(aSniper().winning())`. Complex object graphs become readable.

## Combining Builders with Matchers

Builders create test inputs; matchers verify outputs. Together they form a vocabulary for tests:
- **Input**: `aSniperSnapshot().bidding().build()`
- **Output**: `assertThat(result, is(aSniperThatIs(bidding())))`

## Practical Guidelines

- One builder per domain type (or value object)
- Factory methods in a shared class: `SniperSnapshotBuilder.aSniperSnapshot()`
- Default values should be valid and distinguishable (not empty strings)
- Make the "happy path" default — override for error/edge cases
- Builders are test code, not production code — keep them in test packages
