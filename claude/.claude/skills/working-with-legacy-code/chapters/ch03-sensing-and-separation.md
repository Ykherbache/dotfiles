# Chapter 3: Sensing and Separation

## Two Reasons to Break Dependencies

1. **Sensing** — We break dependencies to *sense* when we can't access values our code computes
2. **Separation** — We break dependencies to *separate* when we can't get code into a test harness to run

## Fake Objects

A **fake object** impersonates a collaborator during testing. It has two sides:

- **Production side**: Implements the interface the production code expects (e.g., `showLine()`)
- **Test side**: Exposes methods for verification (e.g., `getLastLine()`)

### Pattern: Fake Object Construction
```
1. Extract an interface from the dependency
2. Create a fake implementing that interface
3. Inject the fake via constructor or parameter
4. Assert against the fake's test-side methods
```

## Mock Objects

**Mocks** are fakes that perform assertions internally:
```
mock.setExpectation("method", expectedArg);
// ... exercise code ...
mock.verify();
```

Use mocks when available; simple fakes suffice in most situations.

## Key Principle

> Fake objects support real tests. Testing through fakes tells us how our code affects its collaborators — that is valuable, non-trivial information.
