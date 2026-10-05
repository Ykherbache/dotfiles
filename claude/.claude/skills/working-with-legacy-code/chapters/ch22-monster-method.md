# Chapter 22: I Need to Change a Monster Method and I Can't Write Tests for It

## Varieties of Monsters

| Type | Shape | Description |
|------|-------|-------------|
| **Bulleted** | Flat, sequential | List of code chunks with little indentation. Easier to break apart. |
| **Snarled** | Deeply nested | Dominated by nested conditionals/loops. Vertigo-inducing indentation. |

Most real monsters are a mix of both.

## With Automated Refactoring Support

Use the tool exclusively — no manual edits mixed in:
1. Extract methods to **name high-level pieces** and **separate logic from dependencies**
2. Introduce seams via the extracted methods (Subclass and Override Method)
3. After extraction, write tests, then do manual refactoring

**Goals of extraction**:
- Separate logic from awkward dependencies
- Introduce seams for testing

## Without Automated Refactoring Support

### Introduce Sensing Variable
Add a temporary variable to observe what happens inside the monster. Use it to write tests. Remove it after refactoring is done.

### Extract What You Can
Common extraction errors:
1. Forgetting to pass a variable
2. Naming conflicts with base class methods
3. Wrong parameter/return types

### Preserve Signatures
**Copy/paste argument lists** rather than retyping — minimizes transcription errors. When breaking dependencies without tests, this is your primary safety mechanism.

### Coupling Count
Count the values flowing in and out of a potential extraction:
- Parameters in + return values out = coupling count
- **Lower is better** — prefer extractions with coupling count ≤ 3-4
- Higher coupling count = higher risk of error during manual extraction

## Key Practices
- **Hyperaware editing** — know exactly what each keystroke changes (behavior or structure)
- **Single-goal editing** — do one thing at a time; write down the others for later
- **Lean on the Compiler** — make intentional errors to find all affected call sites
