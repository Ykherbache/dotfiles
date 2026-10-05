# Patterns & Anti-Patterns

## Core Patterns

### The Legacy Code Change Algorithm
**The** master pattern. Use for every change:
1. **Identify change points** — where in the code must I make changes?
2. **Find test points** — where can I write tests to cover those changes?
3. **Break dependencies** — what's preventing me from testing?
4. **Write tests** — characterization tests first, then tests for new behavior
5. **Make changes and refactor** — change under test coverage

### Sprout Method
**When**: Adding new functionality to existing code.
**How**: Write the new logic as a fresh, tested method. Call it from the change point.
**Why**: Keeps new code clean and tested. Old code untouched except for one call.

### Sprout Class
**When**: New functionality requires dependencies you can't easily get into a test harness.
**How**: Create a new class for the feature. Instantiate and use it from the change point.
**Why**: New class is born with tests. Avoids wrestling with existing dependency tangles.

### Wrap Method
**When**: You need to add behavior before/after an existing method.
**How**: Rename existing method. Create new method with old name that calls both.
**Why**: Preserves original behavior, adds new behavior, both testable.

### Wrap Class (Decorator)
**When**: Adding behavior that doesn't belong on the existing class.
**How**: Create a wrapper class with the same interface. Delegate to the original, add new behavior.
**Why**: Open/Closed Principle — extend without modifying.

### Characterization Testing
**When**: You need tests for existing code whose intended behavior is unclear.
**How**: (1) Write a test you expect to fail, (2) Run it, (3) Assert what actually happened.
**Why**: Documents real behavior. The system is the specification.

### Subclass and Override Method
**When**: Need to neutralize or replace behavior for testing.
**How**: Make method protected/virtual. Create testing subclass. Override the method.
**Why**: Minimal production code change (just access modifier). Maximum flexibility.

### Extract Interface
**When**: Need to substitute a fake for a collaborator.
**How**: Create interface with needed methods. Have class implement it. Code to interface.
**Why**: Safest technique — compiler catches every error. Incremental (add methods as needed).

## Strategic Patterns

### The Island Metaphor
Tested code areas are islands. Every change grows them. Islands become landmasses, then continents. Work in tested areas becomes dramatically easier. **Keep growing islands with every change.**

### Strangler Fig (Implicit)
Don't rewrite from scratch. Add tested code alongside legacy code. Over time, the tested code grows to surround and replace the legacy code. The green-field myth is a trap.

### Pinch Point Testing
When you need to test a cluster of classes, find the pinch point — where effects converge — and test there. One well-placed test covers many classes.

### Programming by Difference
Use inheritance to add features without modifying existing classes. Override what differs. Temporary technique — refactor toward composition once tests exist.

## Anti-Patterns

### Edit and Pray
Making changes without tests, hoping nothing breaks. Industry standard. Feels careful. Isn't.

### The Green-Field Myth
"Let's rewrite from scratch." The rewrite team must replicate a moving target while maintaining the old system. Usually fails. The legacy system becomes the future.

### Over-Mocking
Mocking everything creates brittle tests coupled to implementation. Prefer testing through pinch points. Mock at boundaries, not everywhere.

### Overly Ambitious Refactoring
Attempting large-scale restructuring without tests. Instead: break dependencies minimally, get tests in place, *then* refactor safely.

### Gold Plating Test Infrastructure
Building elaborate test frameworks before writing tests. Start simple. Use the testing framework. Add infrastructure only when pain demands it.

### Shotgun Testing
Writing tests randomly. Instead: use effect sketches to find interception points. Test at pinch points for maximum coverage with minimum tests.

## Decision Matrix: Which Technique When?

| Situation | First Choice | Alternative |
|-----------|-------------|-------------|
| Adding new feature | Sprout Method/Class | TDD + Programming by Difference |
| Can't instantiate class | Parameterize Constructor | Extract Interface + fake |
| Monster method | Extract Method (with tool) | Sensing Variable + manual extract |
| Global/singleton dependency | Extract and Override Call | Introduce Static Setter |
| Can't run method | Expose Static Method | Break Out Method Object |
| Don't understand code | Scratch Refactoring | Listing Markup + Notes |
| Class too big | Feature Sketch + Extract | Sprout Class for new work |
| Duplication everywhere | Template Method Pattern | Abbreviation Technique |
| Need to test cluster | Find Pinch Point | Higher-level characterization test |
