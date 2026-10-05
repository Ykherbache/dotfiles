# Chapter 7: It Takes Forever to Make a Change

## Two Causes of Slow Changes

### 1. Understanding
- In well-maintained systems: takes time to understand, but change is easy afterward
- In legacy systems: takes time to understand AND change is still hard
- Solution: Break into small, well-named, understandable pieces

### 2. Lag Time
Time between making a change and getting feedback. Long lag time → developers batch changes → more errors → slower feedback → vicious cycle.

**Target**: Compile and run tests for any class in **< 10 seconds**. With motivation, **< 5 seconds**.

## Breaking Build Dependencies

### The Dependency Inversion Principle
> Depend on interfaces or abstract classes, not concrete classes. Interfaces change far less often than implementations.

### Strategy: Extract Interfaces for Compilation Firewalls
1. Extract Interface or Extract Implementer on classes your target depends on
2. Your target now depends on the interface, not the implementation
3. Changes to implementations don't force recompilation of your target

### Package/Library Restructuring
- Move tested clusters into separate packages/libraries
- Overall rebuild time may increase slightly, but **average incremental build time drops dramatically**
- You only pay the setup cost once; you reap benefits forever

## Key Insight
Fast edit-compile-test cycles transform development from "waiting at a bus stop" into "driving" — concentration intensifies, mistakes are caught immediately, and the quality of mental work fundamentally changes.
