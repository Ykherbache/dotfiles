# Chapter 20: This Class Is Too Big and I Don't Want It to Get Any Bigger

## Single-Responsibility Principle (SRP)
> Every class should have a single purpose in the system, and there should be only one reason to change it.

## Problems with Big Classes
1. **Confusion** — 50+ methods, hard to know what to change
2. **Scheduling conflicts** — many reasons to change = many developers colliding
3. **Testing difficulty** — too much encapsulation hides effects; people fall back to Edit and Pray

## Immediate Tactic
Use **Sprout Class** and **Sprout Method** to stop making things worse. Add new code in new places.

## Seeing Responsibilities — 7 Heuristics

### 1. Group Methods
List all methods. Find clusters with similar names/purposes. Each cluster hints at a separate responsibility.

### 2. Look at Hidden Methods
Many private/protected methods = another class dying to get out. If you want to test a private method, it belongs on another class.

### 3. Look for Decisions That Can Change
If a policy or algorithm could change independently, it's a separate responsibility.

### 4. Look for Internal Relationships
Sketch which methods use which instance variables. Groups of methods using the same variables form natural clusters.

### 5. Look for the Primary Responsibility
Try describing the class in one sentence. Everything not in that sentence is a candidate for extraction.

### 6. When All Else Fails, Do Some Scratch Refactoring
Try breaking the class apart on a throwaway branch to see what feels right.

### 7. Focus on the Current Work
You don't have to fix the whole class. Extract just enough to make your current change clean and tested.

## Feature Sketches
Draw which methods use which instance variables. Clusters of methods + variables that form independent groups are natural extraction targets.

## Interface Segregation Principle (ISP)
> Clients should not be forced to depend on methods they don't use.

If different callers use different subsets of a class's methods, those subsets represent different interfaces (and possibly different classes).
