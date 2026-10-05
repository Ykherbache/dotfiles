# Ch 26: Testing Asynchronous Code

## The Problem

Async code introduces timing uncertainty. Tests can't just call a method and check the result — the result arrives later, on a different thread.

## Two Strategies

### 1. Sampling (Polling with Probes)
Repeatedly check a condition until it becomes true or a timeout expires. Use a `Poller` that runs a `Probe` at intervals.

**Probe interface**:
- `sample()` — check the current state
- `isSatisfied()` — does the state meet the condition?
- `describeFailureTo()` — explain what was expected vs. actual

**Usage**: `assertEventually(new HasMessageMatching(expected))`

Best for: testing observable state changes (UI updates, database records, queue messages).

### 2. Listening (Notifications)
Register a listener that captures events as they arrive. The test waits for the expected event with a timeout.

**NotificationTrace**: collects notifications and provides `containsNotification(matcher)` with blocking wait.

Best for: testing event-driven interactions where you care about specific events, not just final state.

## Separating Functionality from Concurrency Policy

### The Executor Pattern
Domain logic should be synchronous and deterministic. Concurrency is a separate concern handled by an `Executor` (or `ScheduledExecutor`). In tests, use a `DeterministicExecutor` that runs tasks synchronously on demand.

This lets you:
- Unit-test domain logic without threading
- Unit-test scheduling logic without real time
- Integration-test the combination

## Timeout Guidelines

- Timeouts must be long enough for slow CI servers
- Timeouts must be short enough that failing tests don't block the suite
- Use a configurable timeout constant, not magic numbers
- A timeout failure is a diagnostic failure — the message should explain what didn't happen

## Anti-patterns
- `Thread.sleep()` in tests — fragile, slow, and non-diagnostic
- Testing thread safety by running many threads and hoping — use a `DeterministicExecutor` or stress tests with observable invariants
