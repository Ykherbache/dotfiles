# Ch 5: Maintaining the Test-Driven Development Cycle

## Incremental Development Practices

### Start Each Feature with an Acceptance Test
Write a failing end-to-end test before touching production code. This test defines "done" for the feature and stays red until the feature is complete. It anchors the inner TDD loop.

### Separate Tests That Measure Progress from Tests That Catch Regressions
- **New acceptance tests** = progress markers (currently failing, expected)
- **Passing tests** = regression suite (must never go red)
- Keep them visibly distinct in your test runner.

### Start Testing with the Simplest Success Case
Pick the smallest, most representative scenario that proves the feature works. Avoid error handling and edge cases until the happy path passes. This gives early structural feedback.

### Write the Test You'd Want to Read
Start from the test — write the assertion first, then work backward to the setup. The test should read as a specification of behavior. If it's hard to read, the design needs work.

### Watch the Test Fail
Always see the test fail before making it pass. A test that passes immediately either tests nothing or was written after the code. The failure message must clearly describe what went wrong — invest in diagnostic quality.

### Develop from the Inputs to the Outputs
Start with the triggering event and work through the system toward the observable outcome. This mirrors how users experience the feature and drives outside-in design.

## Refactoring Discipline

### Refactor on Green
Only refactor when all tests pass. Refactoring on red mixes two concerns: fixing behavior and improving structure.

### Keep Changes Small
Each TDD step should be small enough that if something breaks, the cause is obvious. If you can't find the bug in a few minutes, **revert and try smaller steps**.

## Unit Test Scope
A unit test tests one object's behavior in isolation from its peers. Use mock objects for collaborators. The object under test is real; everything it talks to is mocked.
