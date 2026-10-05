# Chapter 13: I Need to Make a Change, but I Don't Know What Tests to Write

## Characterization Tests

Tests that document **actual current behavior**, not intended behavior.

### Algorithm
1. Use the code in a test harness
2. Write an assertion you **know will fail**
3. Let the failure tell you what the behavior actually is
4. Change the test to expect that actual behavior
5. Repeat

### Why This Works
- These tests have no "moral authority" — they document reality, not correctness
- They create a **change detection mechanism** for the future
- If you find a bug while characterizing, mark it as suspicious — don't silently fix it

## The Method Use Rule
> Before you use a method in a legacy system, check to see if there are tests for it. If there aren't, write them.

## Heuristics for Characterizing Classes
1. **Look for tangled logic** — use sensing variables to verify execution paths
2. **List what can go wrong** — formulate tests that trigger error conditions
3. **Think about extreme input values** — boundaries reveal bugs
4. **Look for invariants** — conditions that should always hold true

## Targeted Testing
After characterization, examine your planned changes and verify your tests cover them:
- Will these tests detect if my change breaks something?
- Are there code paths my change affects that aren't covered?
- If not covered, add more characterization tests before changing

## When You Find Bugs
- **Undeployed system**: Fix immediately
- **Deployed system**: Analyze whether someone depends on the buggy behavior before fixing
- Bias toward fixing, but escalate quickly to understand ripple effects
