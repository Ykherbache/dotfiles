# Chapter 4: The Seam Model

## Core Definition

> **Seam**: A place where you can alter behavior in your program without editing in that place.

> **Enabling Point**: The place where you make the decision to use one behavior or another.

## Three Types of Seams

### 1. Preprocessing Seams (C/C++ only)
- Use `#define` macros to replace function calls
- Use `#include` to inject test definitions
- **Enabling point**: preprocessor defines (`#ifdef TESTING`)

### 2. Link Seams
- Replace production libraries/objects with test versions at link time
- Create stub libraries with empty or recording implementations
- **Enabling point**: build scripts, classpath, makefile
- Works in any compiled language

### 3. Object Seams (preferred)
- Use polymorphism: subclass and override methods
- Pass different objects to change behavior at a call site
- **Enabling point**: constructor arguments, method parameters, factory methods
- Only works when the object isn't created locally with a hard-coded type

## Guidelines

- **Object seams are the best choice** in OO languages — most explicit, easiest to maintain
- Reserve preprocessing and link seams for pervasive dependencies with no better alternative
- A call is NOT a seam if the object is created locally with `new ConcreteClass()` — there's no enabling point
- When you see code in terms of seams, testing becomes easier and new code naturally becomes more testable
