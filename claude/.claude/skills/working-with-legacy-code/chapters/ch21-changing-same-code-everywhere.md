# Chapter 21: I'm Changing the Same Code All Over the Place

## The Problem
Duplication — making the same change in a dozen similar places. Feels like the system needs reengineering, but who has time?

## Strategy: Remove Duplication Incrementally

### Step 1: Identify the Duplication
Look at the similar classes side by side. What's identical? What varies?

### Step 2: Extract a Common Superclass or Interface
- Move shared code (fields, methods, structure) up to a parent class
- Keep varying parts in the subclasses
- Each subclass overrides only what differs

### Step 3: Use Template Method Pattern
When the overall algorithm is the same but specific steps differ:
1. Extract the algorithm skeleton into a base class method
2. Make the varying steps into abstract/virtual methods
3. Each subclass implements only its unique steps

## Open/Closed Principle
> Code should be open for extension but closed for modification.

When you remove duplication by creating abstractions, adding new variants requires only adding a new subclass — no modification of existing code.

## Key Insight
> Removing duplication doesn't have to be a grand effort. Do it in small chunks as you make your changes. Over time, the system improves dramatically. The results are surprising.

## Abbreviation Technique
When two methods are very similar but not identical:
1. Make them **exactly identical** by parameterizing or adjusting
2. Then extract the shared code
3. One method remains — DRY achieved
