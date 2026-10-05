# Chapter 9: I Can't Get This Class into a Test Harness

## Four Common Problems

1. **Objects can't be created easily** — complex constructors
2. **Test harness won't build with the class** — compilation dependencies
3. **Constructor has bad side effects** — connects to DB, network, hardware
4. **Significant work happens in the constructor** — need to sense it

## Techniques by Problem

### The Irritating Parameter
A constructor parameter that's hard to create or has undesirable side effects.

**Solutions** (in order of preference):
- **Extract Interface** on the parameter class → create a fake implementing it
- **Pass Null** — if the parameter isn't used in the code path you're testing, just pass `null`. The runtime will throw if it's accessed, which tells you quickly.
- **Subclass and Override Method** — if the dependency is in a method called by the constructor

### The Hidden Dependency
Constructor internally creates objects with `new` that are hard to deal with.

**Solutions**:
- **Parameterize Constructor** — add a parameter for the dependency, keep original constructor as a convenience that calls the new one
- **Extract and Override Factory Method** — move the `new` call to a method you can override in a testing subclass

### The Construction Blob
Constructor creates many objects in a tangled way.

**Solutions**:
- **Supersede Instance Variable** — add a setter to replace the problematic object after construction
- **Extract and Override Factory Method**

### The Onion Parameter
Parameter needs another parameter, which needs another...

**Solution**: Use **Extract Interface** at the right level, or **Pass Null** for parameters you don't need.

## Key Tactic: Construction Tests
```java
public void testCreate() {
    // Just try to create the object — no assertions needed yet
    CreditValidator validator = new CreditValidator(null, null, "a");
}
```
Start with null parameters and fill them in as the compiler/runtime tells you what's needed.

## Null Object Pattern
Instead of returning null, return an object that does nothing. Shields clients from null checks, but be careful with counting/aggregation logic.
