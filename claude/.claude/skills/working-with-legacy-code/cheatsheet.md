# Cheatsheet

## The Algorithm (memorize this)
1. Identify change points
2. Find test points
3. Break dependencies
4. Write characterization tests
5. Make changes and refactor

## Characterization Test Recipe
```
1. Call the code you want to characterize
2. Write an assertion you KNOW will fail
3. Run the test — let the failure tell you actual behavior
4. Change assertion to match actual behavior
5. Repeat until you've captured the behavior you care about
```

## Adding Code Safely

| Technique | Use When |
|-----------|----------|
| **Sprout Method** | New logic, existing method, easy dependencies |
| **Sprout Class** | New logic, hard dependencies |
| **Wrap Method** | Add before/after behavior to existing method |
| **Wrap Class** | Add behavior, different responsibility |

## Breaking Dependencies (Top 8)

1. **Parameterize Constructor** — externalize object creation
2. **Extract Interface** — safest, compiler-guided
3. **Subclass and Override Method** — the core technique
4. **Extract and Override Call** — isolate one bad call
5. **Introduce Static Setter** — tame singletons
6. **Replace Global Reference with Getter** — getter + override
7. **Break Out Method Object** — escape monster methods
8. **Expose Static Method** — test without instantiating

## Effect Analysis
- **Effect Sketch**: trace variable -> method -> variable chains
- **Pinch Point**: narrowing where effects converge = best test point
- **Rule**: test at pinch points for max coverage, min tests

## Safety Moves (No Tests Required)
- **Preserve Signatures** — copy/paste, don't retype
- **Lean on the Compiler** — break it to find all references
- **Single-Goal Editing** — one change at a time, write others down
- **Hyperaware Editing** — every keystroke: behavior change or structural?

## Key Principles
- **Legacy code = code without tests**
- **Behavior is the most important thing about software**
- **The seam is where you alter behavior without editing at that point**
- **Every seam has an enabling point**
- **Programming is the art of doing one thing at a time**
- **Don't rewrite from scratch — grow islands of tested code**
