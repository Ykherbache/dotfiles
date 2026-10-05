# Ch 1: What Is the Point of Test-Driven Development?

## Core Argument

Software development is a learning process — working code is a side effect. TDD sustains this learning by giving constant feedback on design quality and correctness.

## Key Frameworks

### Nested Feedback Loops
Development operates in concentric feedback loops from seconds (unit tests) to months (releases). Shorter loops catch errors cheaper. TDD adds the tightest loops: compile → unit test → integration test → acceptance test → deploy.

### The Golden Rule
**Never write new functionality without a failing test.** This applies at every scale — acceptance tests for features, unit tests for objects.

### Inner and Outer TDD Loops
- **Outer loop**: Write a failing acceptance test for the next feature. It stays red while you build.
- **Inner loop**: Write failing unit tests, make them pass, refactor. Repeat until the acceptance test passes.
- The outer loop ensures you build the right thing; the inner loop ensures you build it right.

## Qualities of Good Tests

Tests should be **readable** (communicate intent), **resilient** (survive refactoring), and **precise** (fail only for relevant reasons). Overly coupled tests are as bad as no tests — they freeze the design.

## Design Benefit

TDD pressures code toward small, composable, loosely coupled objects. If a test is hard to write, the design is telling you something — **listen to the tests**.

## Anti-patterns
- Writing tests after the code (test-last) — misses the design feedback
- Testing implementation details — creates brittle tests that break on refactoring
- Ignoring test pain — the difficulty IS the signal
