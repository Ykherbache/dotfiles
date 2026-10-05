# Chapter 16: I Don't Understand the Code Well Enough to Change It

## Techniques for Building Understanding

### Notes/Sketching
- Draw pictures as you read — names, relationships, arrows
- Doesn't need to be UML — blobs and lines work fine
- Informal and infectious — do it while pairing and others will join
- Write down the last important thing you saw, then the next, then connect them

### Listing Markup
Print the code and annotate it physically:
- **Separating responsibilities**: Use colored markers to group related code
- **Understanding method structure**: Line up opening/closing braces (inside-out)
- **Extract method candidates**: Circle code blocks, annotate with coupling count
- **Understanding effects of changes**: Mark changed lines → mark affected variables → mark affected methods → repeat

### Scratch Refactoring
1. Check out the code from version control
2. Refactor freely — extract methods, move things around, rename
3. **Don't check it in** — throw it away
4. You now understand the code much better

**Risks**: May develop a false model; may get too attached to the scratch structure.

### Delete Unused Code
If code isn't used, delete it. Version control preserves history. Unused code is noise that hinders understanding.

## Key Insight
> Spending time trying to understand something looks and feels suspiciously like not working. But understanding is the prerequisite for safe change.
