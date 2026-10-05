# Chapter 25: Dependency-Breaking Techniques

A catalog of 24 techniques for breaking dependencies to get legacy code under test. Each technique is a safe, mechanical transformation.

## Quick Reference

| Technique | When to Use | Language |
|-----------|------------|----------|
| **Adapt Parameter** | Can't create parameter object for testing | All OO |
| **Break Out Method Object** | Monster method with tangled dependencies | All OO |
| **Definition Completion** | Need alternate method bodies at link time | C/C++ |
| **Encapsulate Global References** | Globals used across multiple methods/classes | All OO |
| **Expose Static Method** | Method doesn't use instance data, class hard to instantiate | All OO |
| **Extract and Override Call** | Single problematic static/global call in a method | All OO |
| **Extract and Override Factory Method** | Object creation in constructor blocks testing | Java, C#, Ruby (not C++) |
| **Extract and Override Getter** | Multiple methods depend on same problematic object | All OO (esp. C++) |
| **Extract Implementer** | Want interface name = current class name | All OO |
| **Extract Interface** | Need to substitute fake for a dependency | All OO |
| **Introduce Instance Delegator** | Static methods cause "static cling" | All OO |
| **Introduce Static Setter** | Singleton or global blocks test setup | All OO |
| **Lean on the Compiler** | Need to find all references to something | Statically typed |
| **Link Substitution** | Replace function bodies at link time | C, C++, Java (classpath) |
| **Parameterize Constructor** | Constructor creates hard-to-test objects | All OO |
| **Parameterize Method** | Method creates hard-to-test objects internally | All OO |
| **Preserve Signatures** | Refactoring without tests, minimize transcription errors | All |
| **Primitivize Parameter** | Class impossible to instantiate, but logic works on primitives | All |
| **Pull Up Feature** | Methods to test are unrelated to bad dependencies | All OO |
| **Push Down Dependency** | Bad dependencies pervade class but isolatable | All OO |
| **Replace Function with Function Pointer** | Break dependency in procedural C code | C |
| **Replace Global Reference with Getter** | Class uses global/singleton directly | All OO |
| **Subclass and Override Method** | Core technique: nullify or replace any method behavior | All OO |
| **Supersede Instance Variable** | Constructor creates objects, can't use factory override (C++) | C++ primarily |
| **Template Redefinition** | Replace types via generics/templates | C++, generics languages |
| **Text Redefinition** | Redefine methods at runtime in interpreted languages | Ruby, Python, JS |

## Technique Details

### Adapt Parameter
Create a wrapper/adapter around a parameter type you can't instantiate in tests. Extract an interface for the wrapper so you can pass a fake.

### Break Out Method Object
Extract a monster method into its own class. The method becomes a `run()` or `draw()` on the new object. Constructor takes original class reference + method parameters. Then use **Extract Interface** on the original class to break the remaining dependency.

### Definition Completion (C/C++)
Provide alternate method definitions in test files. Include the header, provide stub bodies, link against test definitions instead of production. **Use sparingly** — creates duplicate definitions. Best as a temporary first step.

### Encapsulate Global References
Bundle related globals into a class. Replace bare global references with `instance.member` access. Then use **Parameterize Constructor** or **Introduce Static Setter** for test substitution. Start with data or small methods; move larger methods after tests exist.

### Expose Static Method
Make a method that doesn't use instance data `public static`. Now testable without instantiating the class. The static area is a "staging area" for methods that don't belong on the class yet.

### Extract and Override Call
Extract a single problematic call into its own method. Override in a testing subclass. **Most common technique** — ideal for breaking dependencies on global variables and static methods.

### Extract and Override Factory Method
Move object creation from constructor into a protected factory method. Override in testing subclass to return fakes. **Not available in C++** (virtual calls don't resolve to derived class in constructors).

### Extract and Override Getter
Introduce a lazy getter for a problematic instance variable. Replace all direct uses with getter calls. Override getter in testing subclass. Good when multiple methods depend on the same problematic object.

### Extract Implementer
When you want the current class name for the interface: push all concrete code down into a `ProductionXxx` subclass, turn the original class into a pure interface. More complex with inheritance hierarchies.

### Extract Interface
**Safest dependency-breaking technique.** Create an empty interface, have the class implement it, change references to use interface type, let compiler tell you which methods to add. You don't need to extract ALL public methods — only the ones used in the context you're testing.

### Introduce Instance Delegator
Add instance methods that delegate to static methods. Pass the object in so you can substitute via **Subclass and Override Method**. Over time, move static method bodies into instance methods.

### Introduce Static Setter
For singletons: add a static setter to replace the instance. Make constructor `protected` (not `private`) so you can subclass. In tests, set a fake via the setter. Use `tearDown` to restore state. **Goal**: eventually reduce global references until singleton becomes a normal class.

### Lean on the Compiler
Deliberately introduce a compile error (rename method, change type) to find all references. Fix them, then revert. Not a substitute for tests, but invaluable for dependency analysis.

### Link Substitution
Create a fake library with identical function signatures. Link tests against fakes instead of production code. Best for pure data-sink libraries (e.g., graphics). Also works in Java via classpath manipulation.

### Parameterize Constructor
Add a constructor parameter for an internally-created object. Keep the original constructor delegating to the new one with `new RealObject()`. Clients unchanged; tests pass fakes. **Very common, use frequently.**

### Parameterize Method
Same as Parameterize Constructor but for methods. Add a parameter for the internally-created object. Keep original method as a forwarding wrapper. Use when **Extract and Override Factory Method** feels too heavy.

### Preserve Signatures
**Copy/paste method signatures** instead of retyping. Minimizes transcription errors during manual refactoring without tests. Your primary safety mechanism when breaking dependencies without test coverage.

### Primitivize Parameter
Extract logic into a free function that operates on primitives. The class method delegates by converting its data to the primitive representation. **Last resort** — leaves code in poor state. Only use if you commit to proper testing later.

### Pull Up Feature
Move methods you want to test into an abstract superclass, leaving bad dependencies in the original class. Create a testing subclass of the abstract class. Not ideal design, but a safe first step when **Preserve Signatures** and **Lean on the Compiler** are used.

### Push Down Dependency
Make the current class abstract. Push bad dependencies down into a new production subclass. Create a testing subclass that nulls out the problematic behavior. Inverse of Pull Up Feature.

### Replace Function with Function Pointer (C)
Replace function declaration with a function pointer of the same name. Rename original function to `xxx_production`. Initialize pointer to production function at startup. Tests can reassign the pointer.

### Replace Global Reference with Getter
Write a protected getter that returns the global/singleton. Replace all direct global access with getter calls. Override getter in testing subclass to return a fake.

### Subclass and Override Method
**The core technique.** Make a method protected/virtual. Create a testing subclass that overrides it. In production, instantiate the real class; in tests, instantiate the testing subclass. Many other techniques are variations of this one.

### Supersede Instance Variable
Add a `supersedeXxx()` method that replaces an instance variable after construction. Use in C++ when **Extract and Override Factory Method** won't work (no virtual calls in constructors). Generally prefer other techniques when available.

### Template Redefinition (C++)
Convert class to a template parameterized on the type you want to replace. Use `typedef` to alias the template with production types under the original name. Tests instantiate with fake types. Useful when dependencies are already in template code.

### Text Redefinition (Ruby, Python, etc.)
Reopen a class in the test file and redefine specific methods. Only the redefined methods change — the rest of the class is untouched. Beware: redefinition persists for the process lifetime.

## Selection Guide

**Start here**: Subclass and Override Method, Extract Interface, Parameterize Constructor
**For static/global calls**: Extract and Override Call, Replace Global Reference with Getter
**For singletons**: Introduce Static Setter, Extract Interface
**For constructors**: Parameterize Constructor, Extract and Override Factory Method
**For monster methods**: Break Out Method Object, Expose Static Method
**For C/procedural code**: Link Substitution, Replace Function with Function Pointer, Definition Completion
**For interpreted languages**: Text Redefinition
