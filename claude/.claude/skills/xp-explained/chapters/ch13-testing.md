# Chapter 13 — Testing: Early, Often, and Automated

Defects destroy the trust required for effective software development. Testing is a technical activity that directly addresses this.

## Two Principles Applied

**Double-Checking** — State what a computation does in two ways (test and implementation). If they match, high confidence. Don't copy calculation results as expected values — calculate independently.

**Defect Cost Increase (DCI)** — Empirically verified: earlier detection = cheaper fix. XP uses DCI in reverse by testing in the inner loop of programming.

## Two Perspectives

| Test Type | Written By | Scope | Purpose |
|---|---|---|---|
| Programmer tests | Programmers | Component-level, exhaustive | Fast, thousands per build |
| Customer tests | Customers/testers | System-level, story-oriented | Weekly confidence |

They double-check each other. If programmer tests are perfect, customer tests won't catch anything.

## The Stress Cycle (anti-pattern)
Manual testing: stress → fewer tests → more defects → more stress. Automated testing reverses this: stress → run more tests → reduced defects → reduced stress.

## Key Positions

- Testing must be automated — no contest
- Programmers must write tests (the coordination cost of handing off to a separate tester at minute-scale intervals is prohibitive)
- Beta testing is a symptom of weak testing practices
- Static analysis and model checking are valid double-checking, but need to be faster
- Test first when possible — it separates interface from implementation, provides certainty, and measures progress
- "Keep only one broken test at a time"

## Actionable Takeaway
Invest in defect reduction as an investment in teamwork. Every mistake by one team member that affects another costs time, energy, and trust.
