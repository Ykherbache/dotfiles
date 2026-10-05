# Glossary

**Acceptance Test** — End-to-end test that defines "done" for a feature. Exercises the full stack. Stays red until the feature is complete.

**Adapter** — Thin wrapper translating between your domain interfaces and a third-party API. Keeps domain code free of external types.

**Allow Queries, Expect Commands** — Stub methods that return values (`allowing`); set expectations on methods that cause side effects (`oneOf`). The cardinal rule of mock-based testing.

**Budding Off** — Extracting a new collaborator from a growing object. Create the interface first (via mocking), implement later.

**Breaking Out** — Extracting a value type hidden inside a primitive (String, int) into its own named type.

**Bundling Up** — Grouping related values that travel together into a single named concept.

**Builder Pattern (Test Data)** — Chainable object that creates valid domain instances with sensible defaults. Tests override only what matters.

**Composite Simpler Than Sum of Parts** — A composed object's API should be simpler than the combined APIs of its components.

**Context Independence** — An object has no built-in knowledge of the system it runs in. Everything arrives via its interface.

**DeterministicExecutor** — Test double that runs scheduled tasks synchronously on demand, eliminating threading from unit tests.

**Golden Rule** — Never write new functionality without a failing test.

**Hamcrest Matcher** — Composable assertion object that reports both expectation and mismatch. Extends `TypeSafeMatcher<T>`.

**Inner Loop (Unit TDD)** — Red-green-refactor cycle for individual objects. Runs in seconds.

**Interface Discovery** — Using mock objects in tests to discover the interfaces an object needs from its collaborators.

**Listen to the Tests** — When tests are hard to write, the design is telling you something. Test pain = design smell.

**Mockery** — jMock's test context. Creates mocks, collects expectations, verifies them.

**Notification** — A peer that needs to know about changes but doesn't influence the sender's behavior. Fire-and-forget.

**NotificationTrace** — Async test helper that collects events and provides blocking `containsNotification(matcher)`.

**Object Peer Stereotypes** — Three kinds of collaborators: Dependencies (needed to work), Notifications (informed of changes), Adjustments (tune behavior).

**Only Mock Types You Own** — Never mock third-party APIs directly. Write an adapter; mock the adapter interface.

**Outer Loop (Acceptance TDD)** — Write a failing acceptance test for each feature. It stays red while inner-loop TDD builds the implementation.

**Poller/Probe** — Async test pattern: repeatedly sample a condition until satisfied or timed out. Probe checks state; Poller drives timing.

**Ports and Adapters** — Architecture where the domain sits at the center, unaware of infrastructure. Ports are interfaces; adapters are implementations.

**SniperSnapshot** — Value object bundling an auction sniper's current state (item, price, bid, status). Flows from domain to UI.

**Tell, Don't Ask** — Send commands rather than querying state and deciding for other objects. Keeps behavior with data.

**Walking Skeleton** — The thinnest end-to-end slice that proves the full technology stack works under automated test.
