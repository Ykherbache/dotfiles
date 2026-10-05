# GOOS Cheatsheet

## The TDD Rhythm
1. Write a failing **acceptance test** (outer loop)
2. Write a failing **unit test** (inner loop)
3. Make it pass with the simplest code
4. **Refactor** on green
5. Repeat inner loop until acceptance test passes

## 5 Rules of Thumb
1. **Never write functionality without a failing test**
2. **Only mock types you own** — adapter layer for third-party code
3. **Allow queries, expect commands** — stub returns, verify side effects
4. **Listen to the tests** — hard tests = bad design
5. **Tell, don't ask** — send commands, don't pull state

## Starting a Project
- Build a **Walking Skeleton** first (thinnest end-to-end slice)
- Automate build → deploy → test from day one
- Acceptance test infrastructure pays for itself in every subsequent test

## Object Design Checklist
- [ ] Single, nameable responsibility?
- [ ] Context-independent (no built-in environment knowledge)?
- [ ] Composite simpler than sum of parts?
- [ ] Peers classified as Dependencies / Notifications / Adjustments?
- [ ] Value types extracted (Breaking out, Budding off, Bundling up)?

## Test Quality Checklist
- [ ] Test named after behavior, not method?
- [ ] Only specifies what matters (not over-constrained)?
- [ ] Failure message explains the problem without debugging?
- [ ] Uses builders for complex data?
- [ ] Arrange-Act-Assert clearly separated?

## When Tests Hurt → Design Fix
| Test Smell | Design Problem | Fix |
|---|---|---|
| Long constructor | Too many dependencies | Split object |
| Many expectations | Too many interactions | Extract coordinator |
| Hard to construct | Depends on concretions | Inject interfaces |
| Can't name the test | Object does too much | Split by responsibility |
| Mocking values | Wrong mock target | Use real values |

## Async Testing
- **State changes** → Poller + Probe (sampling)
- **Events** → NotificationTrace (listening)
- **Never** Thread.sleep() — use timeouts with diagnostics
- **Separate** domain logic from concurrency (Executor pattern)
