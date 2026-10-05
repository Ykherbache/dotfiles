# Ch 23: Test Diagnostics

## Why Diagnostics Matter

When a test fails, you should understand why from the failure message alone, without stepping through a debugger. Time spent improving diagnostics saves multiples in debugging time.

## Levels of Diagnostic Quality

1. **Bad**: `AssertionError` (no message)
2. **Okay**: `expected true but was false`
3. **Good**: `expected a string starting with "http" but was "ftp.domain.com"`
4. **Great**: includes context about which object, what state, what operation

## Hamcrest Matchers for Better Messages

`assertThat(result, is(equalTo(expected)))` produces `expected <X> but was <Y>` — both values shown. The matcher's `describeTo()` and `describeMismatch()` methods generate the message.

Custom matchers should describe the expectation and the mismatch independently:
- `describeTo`: "a sniper that is bidding"
- `describeMismatch`: "was a sniper that is winning with price 120"

## jMock Expectation Diagnostics

When a mock expectation fails, jMock reports:
- **What happened**: the unexpected invocation with arguments
- **What was expected**: all expectations and their match status
- **What did match**: which expectations have been satisfied

This tells you whether the call was unexpected entirely or just had wrong arguments.

## Self-Describing Values

Override `toString()` on domain objects to include their state. When a test fails and the object appears in the message, you want to see its content, not `SniperSnapshot@3f2a`.

## Tracer Bullets

When debugging test infrastructure, add logging to trace the flow of messages through the system. Remove once the infrastructure stabilizes.

## Key Rule
**Never let a test fail silently.** Every assertion should explain what was expected, what was received, and enough context to locate the problem without re-running under a debugger.
