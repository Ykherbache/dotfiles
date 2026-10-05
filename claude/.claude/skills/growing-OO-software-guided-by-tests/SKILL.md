# Growing Object-Oriented Software, Guided by Tests

**Freeman & Pryce (2010)** — The definitive guide to London School TDD: outside-in, mock-driven, design-focused test-driven development.

## When to Use This Skill

Apply when writing tests, designing object interfaces, structuring TDD workflows, reviewing test quality, or advising on OO design. The frameworks below are language-agnostic despite Java examples.

---

## Core Frameworks

### 1. The Two TDD Loops
- **Outer loop**: Write a failing acceptance test per feature. It stays red while you build.
- **Inner loop**: Red → Green → Refactor for each object. Repeat until the acceptance test passes.
- The outer loop ensures you build the right thing; the inner loop ensures you build it right.

### 2. Walking Skeleton
Build the thinnest end-to-end slice first. It must build, deploy, and test automatically. Proves the architecture works before features are added. Do the hard thing (integration) first.

### 3. Interface Discovery via Mocks
Mock a collaborator interface before it exists. The test defines what methods, parameters, and returns are needed. The mock IS the specification. Implement the interface next.

### 4. Five Rules of Thumb
1. **Never write functionality without a failing test** (Golden Rule)
2. **Only mock types you own** — write adapters for third-party code
3. **Allow queries, expect commands** — stub returns, verify side effects
4. **Listen to the tests** — hard test = bad design
5. **Tell, don't ask** — send commands, don't pull state

### 5. Object Peer Stereotypes
- **Dependencies**: services needed to work (constructor-injected)
- **Notifications**: objects informed of changes (fire-and-forget)
- **Adjustments**: peers that tune behavior (strategies, policies)

### 6. Ports and Adapters
Domain at the center, unaware of infrastructure. Ports = interfaces the domain defines. Adapters = implementations for specific technologies. Domain is testable without infrastructure.

### 7. Listen to the Tests
| Test Smell | Design Problem | Fix |
|---|---|---|
| Long constructor | Too many dependencies | Split object |
| Many expectations | Too many interactions | Extract coordinator |
| Hard to construct | Depends on concretions | Inject interfaces |
| Can't name test | Object does too much | Split responsibilities |

### 8. Value Type Discovery
- **Breaking out**: extract value from primitive
- **Budding off**: split growing object into value + behavior
- **Bundling up**: group related values into named concept

### 9. Composite Simpler Than Sum of Parts
A composed object's API must be simpler than its components' combined APIs. If composition adds complexity, the decomposition is wrong.

### 10. Context Independence
Objects have no built-in knowledge of their environment. Everything arrives via interface (constructor, method params). Makes objects reusable and testable.

---

## Test Quality Framework

### Readable Tests
- Name tests after behavior: `reportsSniperBiddingWhenPriceArrives()`
- Arrange-Act-Assert with clear separation
- Test Data Builders for complex objects (sensible defaults, override what matters)
- Custom Hamcrest matchers for domain assertions

### Diagnostic Quality
Every failing test must explain: what was expected, what was received, and enough context to diagnose without a debugger. Invest in `describeTo()` and `describeMismatch()`.

### Test Flexibility
- Specify exactly what matters, ignore the rest
- Allow queries (`allowing`), expect commands (`oneOf`)
- Don't mock values — use real instances
- One test per behavior, not per method

---

## Async Testing

### Sampling: Poller + Probe
Poll a condition until satisfied or timed out. Probe describes expectation and mismatch.

### Listening: NotificationTrace
Collect events, assert with blocking wait + matcher.

### Executor Pattern
Separate domain logic (synchronous) from concurrency policy (Executor). Use `DeterministicExecutor` in unit tests.

---

## Chapter Index

### Part I — Introduction
- [Ch 1: What Is the Point of TDD?](chapters/ch01-what-is-the-point-of-tdd.md) — Nested feedback loops, golden rule
- [Ch 2: TDD with Objects](chapters/ch02-tdd-with-objects.md) — Tell don't ask, peer stereotypes, mocks as design tool
- [Ch 3: Introduction to Tools](chapters/ch03-introduction-to-tools.md) — JUnit, Hamcrest, jMock2

### Part II — The Process of TDD
- [Ch 4: Kick-Starting the Cycle](chapters/ch04-kick-starting-the-tdd-cycle.md) — Walking skeleton
- [Ch 5: Maintaining the Cycle](chapters/ch05-maintaining-the-tdd-cycle.md) — Start simple, watch tests fail, refactor on green
- [Ch 6: OO Style](chapters/ch06-object-oriented-style.md) — Ports & adapters, value types, composite principle
- [Ch 7: Achieving OO Design](chapters/ch07-achieving-object-oriented-design.md) — Breaking out/budding off/bundling up
- [Ch 8: Third-Party Code](chapters/ch08-building-on-third-party-code.md) — Only mock types you own, adapter layer

### Part III — Worked Example (Auction Sniper)
- [Ch 9-11](chapters/ch09-auction-sniper-overview.md) — Walking skeleton end-to-end
- [Ch 12-13](chapters/ch12-getting-ready-to-bid.md) — Interface discovery, domain extraction
- [Ch 14](chapters/ch14-sniper-wins-auction.md) — State machine emergence
- [Ch 15-16](chapters/ch15-towards-real-ui.md) — UI testing, multiple items, portfolio
- [Ch 17](chapters/ch17-teasing-apart-main.md) — Extracting composition root
- [Ch 18-19](chapters/ch18-filling-in-details.md) — Stop price, error handling

### Part IV — Sustainable TDD
- [Ch 20](chapters/ch20-listening-to-the-tests.md) — Test smells → design fixes
- [Ch 21](chapters/ch21-test-readability.md) — Expressive names, builders, matchers
- [Ch 22](chapters/ch22-constructing-complex-test-data.md) — Test Data Builders
- [Ch 23](chapters/ch23-test-diagnostics.md) — Failure messages, self-describing values
- [Ch 24](chapters/ch24-test-flexibility.md) — Precision, allow/expect, don't mock values

### Part V — Advanced Topics
- [Ch 25](chapters/ch25-testing-persistence.md) — Database testing layers
- [Ch 26](chapters/ch26-testing-asynchronous-code.md) — Poller/Probe, NotificationTrace, Executor
- [Ch 27](chapters/ch27-testing-concurrency.md) — Stress tests, observable invariants

### Appendices
- [History of Mock Objects](chapters/app01-history-of-mock-objects.md)
- [jMock2 Cheat Sheet](chapters/app02-jmock2-cheat-sheet.md)
- [Writing Hamcrest Matchers](chapters/app03-writing-hamcrest-matchers.md)

---

## Supporting Files
- [Glossary](glossary.md) — Key terms with precise definitions
- [Patterns & Anti-Patterns](patterns.md) — When/do/why for each pattern
- [Cheatsheet](cheatsheet.md) — Quick reference card
