# Chapter 12: I Need to Make Many Changes in One Area

## Interception Points

An **interception point** is a place where you can detect the effects of a particular change. Not all interception points are equal — find the ones that cover the most change with the least test-writing effort.

## Pinch Points

A **pinch point** is a narrowing in an effect sketch — a single method or class through which the effects of many changes must flow.

### Why Pinch Points Matter
- Write tests at a pinch point to cover **multiple changes** at once
- Provides "cover" for broader refactoring in the area
- Structure below the pinch point can change radically while tests hold

### Finding Pinch Points
1. Identify all your change points
2. Draw effect sketches for each
3. Look for common downstream points where effects converge
4. That convergence is your pinch point

## Higher-Level Tests as a First Step

- Pinch point tests are higher-level than unit tests
- They test a cluster of classes through one interface
- Use them as a **stepping stone** — not a substitute for unit tests
- Once you have pinch point coverage, write finer-grained unit tests underneath

## Caution
> Don't let pinch point tests grow into mini-integration tests. If the set of classes under a pinch point gets too large, look for narrower pinch points closer to your changes.
