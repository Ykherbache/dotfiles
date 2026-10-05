# Appendix A: jMock2 Cheat Sheet

## Test Fixture Setup
```java
@RunWith(JMock.class)
public class MyTest {
    private final Mockery context = new JUnit4Mockery();
    private final Collaborator mock = context.mock(Collaborator.class);
}
```

## Invocation Counts
| Clause | Meaning |
|--------|---------|
| `oneOf(mock)` | Exactly once |
| `exactly(n).of(mock)` | Exactly n times |
| `atLeast(n).of(mock)` | At least n times |
| `atMost(n).of(mock)` | At most n times |
| `between(min,max).of(mock)` | Between min and max |
| `allowing(mock)` | Any number (stub) |
| `ignoring(mock)` | Any calls allowed |
| `never(mock)` | Must not be called |

## Argument Matchers
`equal(o)`, `same(o)`, `any(Type.class)`, `a(Type.class)`, `aNull(Type.class)`, `aNonNull(Type.class)`, `not(m)`, `anyOf(m1,m2)`, `allOf(m1,m2)`

## Actions
`will(returnValue(v))`, `will(returnIterator(c))`, `will(throwException(e))`, `will(doAll(a1,a2))`

## Ordering: Sequences
```java
final Sequence s = context.sequence("name");
oneOf(mock).first(); inSequence(s);
oneOf(mock).second(); inSequence(s);
```

## Ordering: States
```java
final States pen = context.states("pen").startsAs("up");
allowing(mock).penDown(); then(pen.is("down"));
oneOf(mock).draw();       when(pen.is("down"));
```

## Key Rule
**Allow queries, expect commands.** Use `allowing` for methods that return values; use `oneOf`/`exactly` for methods that cause side effects.
