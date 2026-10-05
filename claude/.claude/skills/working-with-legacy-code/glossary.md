# Glossary

**Characterization Test** — A test that documents actual behavior of existing code, not intended behavior. Written by running code, observing output, and asserting what happened. The system's current behavior *is* the specification.

**Coupling Count** — The number of values flowing in and out of a potential method extraction (parameters in + return values out). Lower is safer for manual extraction without tests. Aim for 3-4 or less.

**Edit and Pray** — The industry-standard approach: plan carefully, make changes, poke around hoping nothing broke. Contrasted with Cover and Modify.

**Cover and Modify** — The test-first approach: get a safety net of tests in place, then make changes with confidence. The Software Vise.

**Effect Sketch** — A diagram tracing how a change propagates through variables, methods, and objects. Bubbles = variables/return values. Arrows = "affects." Used to find interception points for testing.

**Enabling Point** — The place where you decide which alternative to use at a seam. Every seam has one. For object seams, it's typically the constructor or setter where you choose which object to pass.

**Fake Object** — A test double that impersonates a collaborator. Contains simplified logic sufficient for testing. Distinct from mock objects which verify call sequences.

**Feature Sketch** — A diagram showing which methods use which instance variables in a class. Clusters of methods + variables that form independent groups suggest extraction targets for SRP.

**Interception Point** — A place where you can detect effects of a change via tests. Good ones are close to change points. Best ones are *pinch points*.

**Legacy Code** — Code without tests. Not necessarily old, not necessarily bad — just code where changes can't be verified automatically.

**Legacy Code Change Algorithm** — The master workflow: (1) Identify change points, (2) Find test points, (3) Break dependencies, (4) Write tests, (5) Make changes and refactor.

**Mock Object** — A fake that verifies expectations about how it was called (method names, argument values, call counts). Used for sensing: "was this method called with these arguments?"

**Normalized Hierarchy** — An inheritance hierarchy where no class has more than one implementation of a method (i.e., overrides exist only at one level). Simplifies understanding and modification.

**Null Object Pattern** — An object that conforms to an interface but does nothing. Useful for testing when you need to satisfy a dependency without caring about its behavior.

**Pinch Point** — A narrowing in an effect sketch where many effects converge through a small number of methods. Ideal test point: one test here covers many upstream changes.

**Programming by Difference** — Using inheritance to add variant behavior without modifying existing classes. Create subclass, override what differs. Useful as a temporary step; refactor toward composition later.

**Scratch Refactoring** — Refactoring on a throwaway branch purely for understanding. No commitment to keep the code. Delete the branch when done. Helps reveal structure in unfamiliar code.

**Seam** — A place where you can alter behavior without editing the code at that point. Three types: preprocessing seams (macros), link seams (library substitution), object seams (polymorphism).

**Sensing** — Breaking a dependency to *observe* what code does (inspect side effects, return values). One of two reasons to break dependencies (the other is Separation).

**Separation** — Breaking a dependency to *run code in isolation* from problematic collaborators. One of two reasons to break dependencies (the other is Sensing).

**Software Vise** — Tests that detect change. When you have code in a vise, behavior-altering mistakes are caught immediately. The goal of Cover and Modify.

**Sprout Method/Class** — Adding new functionality as a new method or class rather than modifying existing code. Call the new code from the old code. Keeps new code tested while leaving legacy code untouched.

**Wrap Method/Class** — Wrapping existing behavior with new behavior (before/after). Wrap Method renames the original and creates a new method with the old name. Wrap Class uses the Decorator pattern.
