# Working Effectively with Legacy Code

**Author**: Michael C. Feathers | **Source**: Robert C. Martin Series (2005)

Apply these frameworks when making changes to code without tests, breaking dependencies for testability, or deciding how to add features safely to legacy systems.

## Core Definition

> **Legacy code is code without tests.** It doesn't matter how old it is, how clean it is, or what language it's in. Without tests, every change is a gamble.

## The Legacy Code Change Algorithm

The master workflow for every change:

1. **Identify change points** — where must the code change?
2. **Find test points** — where can tests verify the change? (Use effect sketches and pinch points)
3. **Break dependencies** — what prevents testing? (Use Ch25 techniques)
4. **Write tests** — characterization tests for existing behavior, then tests for new behavior
5. **Make changes and refactor** — now safe under test coverage

## The Seam Model

A **seam** is a place where you can alter behavior without editing code at that point. Every seam has an **enabling point** — where you choose the alternative.

| Seam Type | Mechanism | Enabling Point | Languages |
|-----------|-----------|---------------|-----------|
| **Object** | Polymorphism | Object creation / injection | All OO |
| **Link** | Library substitution | Build config / classpath | C, C++, Java |
| **Preprocessing** | Macros | #define directives | C, C++ |

**Prefer object seams** — they're explicit, readable, and don't require build tricks.

## Two Reasons to Break Dependencies

- **Sensing** — can't observe what the code does (need to inspect side effects)
- **Separation** — can't run the code in isolation (need to decouple from collaborators)

## Adding Code Safely (Without Tests on Existing Code)

| Technique | When | How |
|-----------|------|-----|
| **Sprout Method** | New logic needed, existing method | Write new tested method, call from change point |
| **Sprout Class** | New logic, hard dependencies | New tested class, instantiate from change point |
| **Wrap Method** | Add before/after behavior | Rename original, new method calls both |
| **Wrap Class** | Add behavior, different responsibility | Decorator pattern around original |

## Characterization Tests

Tests that document **actual behavior**, not intended behavior:
1. Write a test you expect to fail
2. Run it — observe actual output
3. Assert what actually happened
4. The system's behavior *is* the specification

## Effect Analysis

- **Effect Sketch**: Diagram tracing change propagation (variable -> method -> variable). Arrows = "affects."
- **Pinch Point**: Where many effects converge through few methods. Best place to test — one test covers many upstream changes.
- **Method Use Rule**: Look at what a method returns and what it modifies. Follow the chain forward.

## Key Principles

| Principle | Application |
|-----------|------------|
| **Single Responsibility (SRP)** | One reason to change per class. Use feature sketches to find hidden responsibilities. |
| **Open/Closed (OCP)** | Add behavior via new classes/methods, not modifying existing. Sprout and Wrap embody this. |
| **Liskov Substitution (LSP)** | Subclasses must be substitutable. Watch when using Programming by Difference. |
| **Interface Segregation (ISP)** | Don't force clients to depend on unused methods. Different callers = different interfaces. |
| **Dependency Inversion (DIP)** | Depend on abstractions. Extract Interface is the primary mechanism. |

## Top Dependency-Breaking Techniques

From the [full catalog of 26 techniques](chapters/ch25-dependency-breaking-techniques.md):

| Technique | One-Line Summary |
|-----------|-----------------|
| **Parameterize Constructor** | Externalize object creation via constructor parameter |
| **Extract Interface** | Safest technique — compiler-guided interface extraction |
| **Subclass and Override Method** | The core technique — override any method in a testing subclass |
| **Extract and Override Call** | Isolate one problematic call into an overridable method |
| **Introduce Static Setter** | Tame singletons by adding a test-only setter |
| **Preserve Signatures** | Copy/paste signatures to avoid transcription errors |
| **Lean on the Compiler** | Introduce errors deliberately to find all references |
| **Break Out Method Object** | Extract monster method into its own testable class |

## Safety Practices (No Tests Required)

- **Preserve Signatures** — copy/paste argument lists, never retype
- **Lean on the Compiler** — break something intentionally to find all call sites
- **Single-Goal Editing** — one change at a time; write down others for later
- **Hyperaware Editing** — every keystroke is either behavior-changing or structural; know which

## The Island Metaphor

Tested code = islands in an ocean. Every change grows them. Islands become landmasses, then continents. Work in tested areas becomes dramatically easier. **Keep growing the islands.**

> The attitude we bring to the work is important. Teams with millions of lines of legacy code can look at each day as a challenge and a chance to make things better.

## Chapter Index

| Ch | Topic | File |
|----|-------|------|
| 1 | Four reasons to change software | [ch01](chapters/ch01-changing-software.md) |
| 2 | Edit and Pray vs Cover and Modify, the master algorithm | [ch02](chapters/ch02-working-with-feedback.md) |
| 3 | Sensing vs Separation, fake/mock objects | [ch03](chapters/ch03-sensing-and-separation.md) |
| 4 | Seam types and enabling points | [ch04](chapters/ch04-the-seam-model.md) |
| 5 | Refactoring tools, mock frameworks, xUnit | [ch05](chapters/ch05-tools.md) |
| 6 | Sprout Method/Class, Wrap Method/Class | [ch06](chapters/ch06-i-dont-have-much-time.md) |
| 7 | Build dependencies and lag time | [ch07](chapters/ch07-it-takes-forever-to-make-a-change.md) |
| 8 | TDD, Programming by Difference | [ch08](chapters/ch08-how-do-i-add-a-feature.md) |
| 9 | Getting classes into test harnesses | [ch09](chapters/ch09-cant-get-class-into-test-harness.md) |
| 10 | Getting methods into test harnesses | [ch10](chapters/ch10-cant-run-method-in-test-harness.md) |
| 11 | Effect sketches and reasoning about effects | [ch11](chapters/ch11-what-methods-should-i-test.md) |
| 12 | Interception points and pinch points | [ch12](chapters/ch12-many-changes-in-one-area.md) |
| 13 | Characterization tests | [ch13](chapters/ch13-what-tests-to-write.md) |
| 14 | Dependencies on libraries | [ch14](chapters/ch14-dependencies-on-libraries.md) |
| 15 | Skin and Wrap the API | [ch15](chapters/ch15-all-api-calls.md) |
| 16 | Understanding unfamiliar code | [ch16](chapters/ch16-dont-understand-code.md) |
| 17 | Telling the Story of the System | [ch17](chapters/ch17-no-structure.md) |
| 18 | Test code organization | [ch18](chapters/ch18-test-code-in-the-way.md) |
| 19 | Non-OO and procedural challenges | [ch19](chapters/ch19-not-object-oriented.md) |
| 20 | SRP, ISP, and big classes | [ch20](chapters/ch20-class-too-big.md) |
| 21 | Removing duplication | [ch21](chapters/ch21-changing-same-code-everywhere.md) |
| 22 | Monster methods | [ch22](chapters/ch22-monster-method.md) |
| 23 | Safe editing practices | [ch23](chapters/ch23-not-breaking-anything.md) |
| 24 | Morale and the island metaphor | [ch24](chapters/ch24-we-feel-overwhelmed.md) |
| 25 | Dependency-breaking techniques catalog | [ch25](chapters/ch25-dependency-breaking-techniques.md) |

## Topic Index

| Topic | Chapters |
|-------|----------|
| Breaking dependencies | 3, 4, 9, 10, 25 |
| Adding features safely | 6, 8, 21 |
| Testing strategies | 2, 11, 12, 13 |
| Understanding code | 16, 17 |
| Large-scale concerns | 7, 14, 15, 20, 22 |
| Mindset and practices | 1, 23, 24 |
| Tools and setup | 5, 18, 19 |

## Supporting Files

- [glossary.md](glossary.md) — Key terms and definitions
- [patterns.md](patterns.md) — Patterns, anti-patterns, and decision matrix
- [cheatsheet.md](cheatsheet.md) — Quick-reference card
