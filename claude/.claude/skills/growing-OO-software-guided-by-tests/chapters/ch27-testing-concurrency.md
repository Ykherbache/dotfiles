# Ch 27: Testing Persistence and Concurrency

## Stress Testing Concurrent Code

Unit tests verify logic; stress tests verify thread safety. They complement each other — neither replaces the other.

## Observable Invariants

Define properties that must hold regardless of thread interleaving:
- Counts are consistent
- No duplicate processing
- Final state is valid

Write stress tests that run many threads performing concurrent operations, then check invariants. The tests don't verify specific interleavings — they verify that all interleavings preserve correctness.

## Stress Test Structure

1. **Setup**: create the object under test
2. **Blast**: launch N threads doing M operations each, concurrently
3. **Wait**: join all threads (with timeout)
4. **Check**: assert invariants on the final state

## Synchronization Testing

### DeterministicExecutor
For unit testing scheduling logic without real threads. You control exactly when tasks run, making tests deterministic.

### Blitz Pattern
For stress testing: flood an object with concurrent calls and verify it survives. Use `CountDownLatch` to ensure all threads start simultaneously.

## Separating Concerns (Reinforced)

The key to testable concurrent code: **pure functional logic + separate concurrency policy**.
- Domain logic: synchronous, single-threaded, tested with unit tests
- Concurrency: executors, schedulers, tested with stress tests
- Integration: wire them together, tested end-to-end

## Thread Safety Traps
- Tests that pass 999/1000 times — the 1 failure is the bug
- Tests that depend on timing (sleeps) are unreliable
- Deadlocks only show as timeouts — set test timeouts and investigate
- Logging in concurrent tests can hide race conditions (logging adds synchronization)
