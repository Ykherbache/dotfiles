# Chapter 23: How Do I Know That I'm Not Breaking Anything?

## Hyperaware Editing
Every keystroke either **changes behavior** or **doesn't**. Know which one you're doing at all times.

- TDD provides instant feedback (< 1 second test runs)
- Pair programming keeps you honest
- Both foster a **flow state** of editing with full awareness

## Single-Goal Editing
> Programming is the art of doing one thing at a time.

When tempted to fix something else mid-edit:
1. Write it down on a notepad
2. Finish your current change
3. Run tests
4. Then tackle the next thing

## Preserve Signatures
When refactoring without tests, **copy/paste method signatures** instead of retyping:
1. Copy entire argument list to buffer
2. Type new method declaration
3. Paste arguments into declaration
4. Type call to new method
5. Paste arguments into call
6. Delete types from the call, leaving only variable names

This mechanical process has minimal error opportunity.

## Lean on the Compiler
Deliberately introduce a compile error to find all places that reference something:
- Change a method name or type temporarily
- The compiler shows every call site
- Fix them all, then revert the name

Not a substitute for tests, but very useful for dependency analysis.

## Pair Programming
The greatest benefit: **keeping each other focused on one thing at a time** and maintaining awareness of what's changing.

## Key Mindset
> Code never breaks by itself. The only way it gets a fault is for someone to edit it. Every keystroke matters.
