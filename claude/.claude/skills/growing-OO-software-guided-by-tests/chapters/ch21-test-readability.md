# Ch 21: Test Readability

## Tests as Specifications

A test should read as a description of the behavior it verifies. If a reader can't understand what the test checks by scanning it, the test fails its primary purpose.

## Structure: Arrange, Act, Assert

Every test has three phases. Make them visually distinct:
1. **Arrange**: set up the context and expectations
2. **Act**: call the method under test (usually one line)
3. **Assert**: check the result

Blank lines between phases improve readability.

## Techniques for Readable Tests

### Expressive Test Names
Name tests after the behavior, not the method: `reportsSniperBiddingWhenNewPriceArrives()` not `testCurrentPrice()`.

### Literals in Context
Magic numbers hide meaning. Use named constants or builder methods: `SNIPER_ID` not `"sniper"`, `aPrice().withAmount(1098)` not `1098`.

### Test Data Builders
Replace complex constructors with builders that have sensible defaults. Only specify what matters for this test:
```
anItem().withStopPrice(200).build()
```
Everything else gets a default. Changes to the constructor signature only affect the builder, not all tests.

### Custom Matchers
When Hamcrest's built-in matchers don't express the assertion well, write a custom matcher. It provides both a readable assertion and a clear failure message.

### Helper Methods Named by Intent
Extract setup and assertion helpers named after what they do, not how: `hasReceivedBid(price, fromSniper)` not `checkMessage()`.

## Anti-patterns
- **Incidental details**: test shows unrelated setup that distracts from the point
- **Programmer language in test names**: "test_method_returns_null" vs "reports_no_result_when_empty"
- **Duplicated literal strings**: same value in setup and assertion should be a shared constant
