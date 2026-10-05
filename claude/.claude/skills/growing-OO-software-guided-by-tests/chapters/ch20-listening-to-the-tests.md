# Ch 20: Listening to the Tests

## Central Thesis

When tests are hard to write, the problem is the design, not the tests. Test difficulty is a **design signal** — listen to it.

## Test Smells and What They Tell You

### Too Many Dependencies (Long Constructor)
The object has too many collaborators → it has too many responsibilities. **Fix**: split the object. Extract a new collaborator that bundles some of the dependencies.

### Too Many Expectations
The test sets up many expectations → the object is managing too many interactions. **Fix**: introduce an intermediate object that handles coordination.

### Difficult to Construct
The object needs complex setup → it depends on concrete implementations rather than interfaces, or its dependencies have dependencies. **Fix**: inject interfaces, use factory methods, simplify the dependency graph.

### Hard to Name
You can't find a concise name → the object does too much. **Fix**: split until each piece has a clear, single-word-ish name.

### Bloated Test Setup
If `@Before` methods are long, every test pays for the most complex case. **Fix**: extract builders, or split the test class by scenario.

### Too Many Mock Expectations = Tell, Don't Ask Violation
If you're mocking getters and chaining return values, you're testing "ask" style. **Fix**: refactor toward "tell" — pass the data the object needs rather than having it pull from collaborators.

## The Fundamental Heuristic

**If writing a test is painful, the code is badly designed.** Don't suppress the pain with test tricks — fix the production code. The tests are your first client; if they struggle, real callers will too.
