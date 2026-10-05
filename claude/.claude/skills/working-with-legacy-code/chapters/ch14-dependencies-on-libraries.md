# Chapter 14: Dependencies on Libraries Are Killing Me

## Core Rule
> Avoid littering direct calls to library classes throughout your code. You might think you'll never change them, but that can become a self-fulfilling prophecy.

## Problems with Library Dependencies
- Libraries may use `sealed`/`final` classes — can't subclass for fakes
- Non-virtual methods — can't override for sensing/separation
- Vendor lock-in — when you can't separate, you can't switch

## Solutions
1. **Write thin wrappers** over library classes you depend on heavily
2. Use wrappers as seams for testing
3. Every hard-coded library call is a place where you *could have had* a seam

## The Once Dilemma
Libraries that assume a single instance (singletons) make faking difficult. Sometimes wrapping the singleton is the only option.

## The Restricted Override Dilemma
Some languages default to non-virtual methods. Using coding conventions ("treat this as non-virtual") is often as effective as language enforcement, while preserving testability.

## Key Advice
> Library designers who use language features to enforce design constraints often forget that good code runs in both production and test environments.
