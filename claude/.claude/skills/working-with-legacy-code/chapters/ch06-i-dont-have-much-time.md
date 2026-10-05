# Chapter 6: I Don't Have Much Time and I Have to Change It

## Four Techniques for Adding Code Without Full Test Coverage

### 1. Sprout Method
**When**: New code can be formulated as a distinct operation.

Steps:
1. Identify where you need to make the change
2. Write a call to a new method (comment it out)
3. Determine needed local variables → make them arguments
4. Determine return values needed by source method
5. **Develop the sprout method using TDD**
6. Uncomment the call

**Advantage**: New code is tested and clearly separated from old code.
**Disadvantage**: Source method remains untested; code can look odd.

### 2. Sprout Class
**When**: You can't even instantiate the class in a test harness.

Same idea as Sprout Method, but the new code lives in an entirely new class. Use when dependency problems make the original class impossible to test.

### 3. Wrap Method
**When**: New behavior must execute at the same time as existing behavior (before/after).

Two forms:
- **Rename and replace**: Rename `pay()` → `dispatchPayment()`, create new `pay()` that calls `logPayment()` + `dispatchPayment()`
- **New entry point**: Create `makeLoggedPayment()` that calls both

**Advantage**: Doesn't increase size of existing methods; keeps responsibilities separate.

### 4. Wrap Class (Decorator Pattern)
**When**: New behavior is independent and many callers need it.

Create a wrapper class with the same interface that delegates to the original and adds new behavior. Use Extract Implementer or Extract Interface to enable wrapping.

## Remember
> Code is your house, and you have to live in it.

These techniques add tested code without getting the original under test. They are a **pragmatic compromise**, not a permanent strategy. Over time, familiarity with the carcasses of old classes will motivate you to bring them under test too.
