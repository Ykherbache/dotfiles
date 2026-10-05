# Chapter 1: Changing Software

## Four Reasons to Change Software

1. **Adding a feature** — new behavior
2. **Fixing a bug** — correcting existing behavior
3. **Improving the design** — refactoring (structure changes, behavior preserved)
4. **Optimizing resource usage** — performance (resource changes, behavior preserved)

## Key Insight: Behavior Preservation

All four change types share a common challenge: **preserving existing behavior**. Even when adding features, the vast majority of existing behavior must remain unchanged.

## The Three Questions of Risky Change

1. What changes do we have to make?
2. How will we know that we've done them correctly?
3. How will we know that we haven't broken anything?

## Anti-Pattern: Avoiding Change

Teams that minimize changes to "stay safe" create a vicious cycle:
- Classes grow larger and harder to understand
- Developers get rusty at making changes
- Fear of change increases
- Code quality degrades further

**The alternative**: Build a safety net of tests so changes become routine, not terrifying.
