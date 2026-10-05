# Chapter 11 — The Theory of Constraints

Use TOC to find where improvement will actually matter. In any system, one constraint limits throughput.

## The Laundry Example
Washer (45 min) → Dryer (90 min) → Folding (15 min). Bottleneck = dryer. Getting a second washer just creates piles of wet clothes. To improve throughput: (1) ensure dryer runs at full capacity, (2) increase dryer capacity or offload drying work.

## Finding the Constraint
Look for where work piles up. Piles of features waiting for integration? Integration is the constraint. One overwhelmed deployment person holding up twenty programmers? Shift people to deployment.

## Push vs Pull
- **Push** (anti-pattern): pile up requirements → pile up designs → pile up code → big bang integration
- **Pull** (XP): stories specified just before implementation → tests pulled from specs → code written to match tests → design refined to match code

## The Constraint Shift Problem
XP team improves dramatically → bottleneck shifts to marketing ("can't specify features fast enough") → the new constraint blames XP → team disbanded. **Prevention**: executive sponsorship, strong external relationships.

## Limitations of TOC
It's a model — a map, not the territory. People are not boxes. The closer an organization is to efficient but chaotic communication, the less accurately TOC maps. Still useful for awareness: draw your current process as linked activities and look for where work piles up.

## Key Insight
The reward system and culture must align with overall throughput, not individual productivity. "If everyone is trying to make sure his function is not seen as the constraint, no change will happen."
