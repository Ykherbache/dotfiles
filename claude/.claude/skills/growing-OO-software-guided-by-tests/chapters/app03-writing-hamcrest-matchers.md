# Appendix B: Writing a Hamcrest Matcher

## When to Write Custom Matchers

When built-in Hamcrest matchers can't express your assertion precisely enough, or when failure messages don't describe the mismatch clearly.

## Structure

Extend `TypeSafeMatcher<T>` and implement three methods:

1. **`matchesSafely(T actual)`** — return true if the value matches
2. **`describeTo(Description d)`** — describe what was expected
3. **`describeMismatchSafely(T actual, Description d)`** — describe what was received

## Grammar Convention

Descriptions must complete the sentence: "expected *description* but it *mismatch-description*"

Example: "expected **a string starting with "http"** but it **started with "ftp"**"

## Factory Method

Write a static factory for readability at the call site:
```java
public static Matcher<String> aStringStartingWith(String prefix) {
    return new StringStartsWithMatcher(prefix);
}
```

The factory method name matters — it's what appears in the test. Choose names that read naturally in `assertThat()` and `with()` clauses.

## Key Rule: Matchers Must Be Stateless

jMock may call matchers many times, in any order. A stateful matcher produces unpredictable results. If you need state, write a custom jMock `Action`, not a `Matcher`.

## Composability

Custom matchers compose with `allOf()`, `anyOf()`, `not()` just like built-in matchers. This is the power of the matcher abstraction — small matchers combine into precise assertions.
