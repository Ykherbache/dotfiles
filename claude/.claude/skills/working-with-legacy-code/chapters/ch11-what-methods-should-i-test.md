# Chapter 11: I Need to Make a Change. What Methods Should I Test?

## Effect Sketches

A hand-drawn diagram showing how changes propagate through code:
- **Bubble** for each variable/method that can be affected
- **Arrow** from cause to effect
- Trace forward from your change point to find all affected values

## Reasoning About Effects

For every functional change, there's a chain of effects. Ask:
- What variables change?
- What methods return different values?
- What objects receive different state?

Trace these forward to find all observable consequences.

## Reasoning Forward (for characterization tests)

Invert the process: look at objects and figure out what changes downstream if they break.
1. Start at your change points
2. Trace effects outward — what methods use the changed variable? What uses those methods?
3. Each place you can observe an effect is a potential **test point**

## Effect Sketch Tips

- Simpler effect structures = better design
- If your effect sketch is complex, it reveals a design problem
- Making the sketch simpler through refactoring makes code more maintainable
- You don't need formal notation — blobs and arrows suffice

## Practical Rule

> If your code is well structured, most methods have simple effect structures. Complex external effects should be the sum of much simpler internal effects.
