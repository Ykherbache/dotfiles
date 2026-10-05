# Chapter 10: I Can't Run This Method in a Test Harness

## Common Problems

1. **Method isn't accessible** — private/protected
2. **Hard to construct parameters** for the method call
3. **Method has bad side effects** — DB writes, launches missiles
4. **Need to sense through another object** the method uses

## Techniques

### The Hidden Method (private method you need to test)
**First**: Can you test through a public method? If yes, do that — it tests usage in context.

**If not**:
- Make it **public** — if that bothers you, the class has too many responsibilities
- Make it **protected** + create a **testing subclass** that exposes it
- Move the method to a **new class** where it can be public

> Good design is testable, and design that isn't testable is bad.

### The "Helpful" Language Feature (sealed/final classes)
When library classes are `sealed`/`final` and can't be subclassed or faked:
- **Adapt Parameter** — wrap the library type behind your own interface
- **Skin and Wrap the API** — create thin wrappers over library classes

### The Undetectable Side Effect
Method does something you can't observe through its return value:
- **Extract and Override Call** — move the side-effecting call to its own method, override it in a testing subclass
- **Expose Static Method** — if the method doesn't use instance data, make it static so it's callable without instantiating the class
- **Break Out Method Object** — move the long method to its own class where it's easier to test

### Subverting Access Protection
Reflection can access private members, but avoid keeping such tests long-term. The pain of inaccessible code should motivate better design.
