# Chapter 18: My Test Code Is in the Way

## Class Naming Conventions

| Type | Convention | Example |
|------|-----------|---------|
| Test class | Suffix `Test` | `DBEngineTest` |
| Fake object | Prefix `Fake` | `FakeAccountOwner` |
| Testing subclass | Prefix `Testing` | `TestingCheckingAccount` |

This alphabetical grouping keeps production classes next to their tests, fakes together, and testing subclasses together.

## Test Location

**Same directory** (simplest):
- Easy navigation between code and tests
- Doubles deployment size

**Parallel directory tree** (when size matters):
- Mirror the package structure under a `test/` root
- In Java, tests can share the same package across directories

## Key Advice
- Ergonomics matters — optimize for easy navigation between code and tests
- Don't let test code organization become a barrier to writing tests
- Conventions aren't dogma — adapt to your project's needs
