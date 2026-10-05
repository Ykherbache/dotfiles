# Chapter 19: My Project Is Not Object Oriented

## The Challenge
Procedural languages (C, COBOL, FORTRAN) have fewer seams than OO languages, making dependency breaking much harder.

## Primary Strategy
1. Find a **pinch point** (Ch. 12) to test a larger chunk at once
2. Use **link seams** — create fake libraries with stub functions
3. Use **preprocessing seams** (C/C++) — `#define` to replace function calls

## Procedural Dependency-Breaking Techniques

### Link Seam (Most Common)
Create a test library with empty/recording versions of problematic functions:
```c
void ksr_notify(int scan_code, struct rnode_packet *packet) {
    // empty — or record the call for sensing
}
```
Link against test library instead of production library.

### Function Pointers (C)
Replace direct function calls with calls through function pointers. In tests, set the pointer to a fake implementation.

### Macro Preprocessing (C/C++)
Use `#ifdef TESTING` to swap implementations at compile time.

## Migration Path to OO
If your language has an OO successor (C→C++, etc.):
- Wrap procedural code in thin classes
- Introduce interfaces gradually
- Use **Encapsulate Global References** to wrap global data in objects

## Key Insight
> Even in procedural code, you can write good, testable code by managing dependencies carefully. The techniques are fewer, but they work.
