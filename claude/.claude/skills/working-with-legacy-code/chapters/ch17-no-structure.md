# Chapter 17: My Application Has No Structure

## Why Structure Degrades
- System too complex for anyone to hold the big picture
- Reactive mode — emergency after emergency erodes awareness
- Architect disconnected from the codebase — paper architecture diverges from reality

## Key Principle
> Architecture is too important to be left exclusively to a few people. Every person touching the code should know the architecture.

## Technique: Telling the Story of the System

1. Two people sit together
2. One asks: "What is the architecture of the system?"
3. The other explains using **only 2-3 concepts** (pretend the listener knows nothing)
4. Then add the next most important thing, then the next
5. Continue until you've covered the core design

### The Power of Simplification
When you simplify, you'll feel like you're lying. That discomfort reveals:
- Where the system could be simpler
- What exists as pragmatic compromise vs. essential design
- Whether current changes align with the "simple story" or make it more of a lie

### As a Team Practice
- Tell the story often, in different ways
- Trade off which concepts matter more
- When choosing between two implementations, pick the one that makes the brief story feel less like a lie

## Other Techniques
- **Naked CRC** — use index cards for classes/responsibilities/collaborations to map architecture
- **Conversation Scrutiny** — listen for domain concepts in team conversations that don't have corresponding code abstractions
