# Chapter 15: My Application Is All API Calls

## The Problem
Systems built primarily by calling library/framework APIs are hard to test and hard to see design in. The API calls obscure any hint of architecture.

## Strategy: Skin and Wrap the API

### Approach 1: Responsibility-Based Extraction
1. Identify **what your code does** (not the API calls, the *purpose*)
2. Create classes that represent those responsibilities
3. Move API call sequences into methods on those classes
4. Test the logic through the new class interfaces

### Approach 2: Separate Logic from API
1. Extract code that makes decisions into pure methods (no API calls)
2. Keep API interaction in thin orchestration layers
3. Test the decision logic directly

## Key Insight
> It is almost always a bad idea to have no separation between higher-level logic and lower-level API calls. Even the simplest systems benefit from having their logic separated from external interfaces.

## When to Apply
- Before adding new features to API-heavy code
- When you need to understand what the code actually does
- When multiple changes are needed in the same area
- When you want to swap out a library/framework
