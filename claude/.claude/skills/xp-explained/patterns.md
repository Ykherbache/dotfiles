# Patterns & Anti-Patterns — XP Explained

## Decision Frameworks

### When to Design Up Front vs Incrementally
- **Design up front** when instinctive design is sufficient (any solution works) or when experience adds little value over careful thought
- **Design incrementally** when no amount of pure thought without experience yields a good-enough design — which is most of the time in novel software
- **Heuristic**: use Once and Only Once (eliminate duplication) as your compass for where to invest in design next

### When to Adopt a Corollary Practice
A corollary practice is safe when its prerequisites are in place:
- Daily Deployment → needs near-zero defect rate, automated build, automated rollback, high trust
- Shared Code → needs collective responsibility culture, pair programming, CI
- Root-Cause Analysis → needs low enough defect rate that investing deeply per defect is proportional

### How to Choose What to Change First
1. Look at what you're doing and what you want to achieve
2. Pick the primary practice on that path
3. Move one step closer to the practice's endpoint
4. Evaluate whether it helped
5. Repeat or pick the next practice

## Recurring Patterns

### The Stress Cycle (anti-pattern)
Stress → less testing → more defects → more stress → less testing. **Break it** with automated tests: the more stressed you are, the more you run them.

### The Big Batch Anti-Pattern
Responding to integration pain by integrating less often → bigger batches → more pain → even less often. **Reverse it**: when flow breaks down, resolve the problems and return to frequent delivery.

### The Overcommitment Trap
Agreeing to "aggressive" (unrealistic) schedules → habitual underdelivery → waste from defect loads, low morale, antagonistic relationships. **Break it** with slack: commit to what you can actually do. A few met commitments rebuild trust faster than many broken ones.

### Taylorist Echoes (anti-pattern)
Separating planning from execution. Architecture groups prescribing work without sharing consequences. Separate QA departments sending the message that engineering isn't responsible for quality. **Replace with**: accepted responsibility, whole team, shared code.

### The Constraint Shift Problem
XP team improves dramatically → bottleneck shifts to marketing/management → new constraint blames XP → team disbanded. **Prevent with**: executive sponsorship, strong external relationships, transparent communication of how improved development shifts organizational constraints.

### Vulnerability is Safety (pattern)
Holding back 20% effort doesn't protect from failure — it just adds guilt. Going full out, accepting consequences, and communicating clearly is the safer path. Your self-worth should be based on effort, not outcomes you can't control.

### Conquer and Divide (pattern)
Don't divide a big problem among big teams up front. Start small, solve a small piece, find natural fracture lines, then split. Integration risk is managed by integrating frequently across teams.

## Planning Patterns

### Grocery Shopping Model
Stories = items, estimates = prices, time = budget. If the cart exceeds budget, put items back. Never change estimates or budget during negotiation — change scope.

### Yesterday's Weather
Plan this cycle for exactly what you accomplished last cycle. Simple, honest, self-correcting.

### Four-Step Planning (any timescale)
1. List items of work
2. Estimate them
3. Set the budget
4. Agree on work within budget (negotiate scope, not estimates)

## Testing Patterns

### Double-Checking
Write tests and code as two independent expressions of the same computation. If they agree, high confidence of correctness. Don't copy calculation results as expected values — calculate examples independently.

### Two Perspectives
Programmer tests: exhaustive, component-level, fast. Customer tests: system-level, story-oriented, weekly. They double-check each other.

### DCI in Reverse
Traditional: find defects late, fix expensively. XP: find defects in the inner loop of programming, fix cheaply. Bring load testing, stress testing, and static analysis into the daily cycle.

## Team Patterns

### Ideal Team Size Thresholds (Gladwell)
- **≤12**: comfortable daily interaction, high trust
- **≤150**: can recognize faces, maintain basic trust
- **Beyond 150**: fracture into team-of-teams; conquer-and-divide

### Hiring for XP
Given the choice between an extremely skilled loner and a competent-but-social programmer, XP teams consistently choose the social candidate. Best interview: have the candidate work with the team for a day, including pairing.

### Fractional People Anti-Pattern
Splitting people across teams (40%/60%) wastes time on task-switching. Group people into dedicated teams instead.
