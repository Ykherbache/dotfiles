# Chapter 8: How Do I Add a Feature?

## Test-Driven Development (TDD)

The TDD cycle:
1. **Write a failing test case**
2. **Get it to compile** (stub methods returning defaults)
3. **Make it pass** (write minimal production code)
4. **Remove duplication** (refactor)
5. **Repeat**

### TDD Extended for Legacy Code
0. **Get the class you want to change under test** ← added step
1. Write a failing test case
2. Get it to compile
3. Make it pass — **try not to change existing code**
4. Remove duplication
5. Repeat

### Key TDD Principle
> We are either writing code or refactoring; we are never doing both at once.

## Programming by Difference

Use inheritance to add features without modifying a class directly:
1. Subclass the existing class
2. Override the relevant method in the subclass
3. Write tests for the new behavior
4. Later, refactor to fold the change into a better design (e.g., configuration flag, strategy pattern)

### Liskov Substitution Principle (LSP)
Objects of subclasses must be substitutable for objects of their superclasses. Rules of thumb:
1. **Avoid overriding concrete methods** whenever possible
2. If you must override, **call the overridden method** from the override

### Normalized Hierarchy
A hierarchy where no class has more than one implementation of a method — no concrete overrides. When you ask "How does this class do X?", the answer is always in one place.

## Rename Class
> Rename Class is the most powerful refactoring. It changes the way people see code and lets them notice possibilities they might not have considered before.
