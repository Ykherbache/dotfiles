# Chapter 5: Tools

## Essential Tools for Legacy Code Work

### Automated Refactoring Tools
- Verify the tool checks behavior preservation (not all do)
- Test the tool: Does extracting a method with a duplicate name flag an error?
- Even with tool support, **have tests** — tools can miss side-effect bugs (e.g., inlining a variable that has side effects in its initializer)

### Mock Object Frameworks
- Use when you need many fake objects
- Mocks assert expectations internally: `mock.setExpectation()` → exercise → `mock.verify()`
- Simple hand-written fakes suffice in most situations

### xUnit Test Harnesses (JUnit, CppUnitLite, NUnit, etc.)
Key features:
1. Tests written in the language you develop in
2. All tests run in isolation (separate object per test method)
3. Tests grouped into suites for on-demand execution

### FIT / Fitnesse
- Acceptance tests embedded in HTML documents/wiki pages
- Bridge communication between developers and specifiers
- Tables define inputs/outputs; framework runs them as tests

## Key Advice
- Don't trust expensive GUI-based testing tools as primary strategy
- Free xUnit frameworks are the most effective testing tools
- Use refactoring tool support for extract method as a starting wedge, even without full test coverage
