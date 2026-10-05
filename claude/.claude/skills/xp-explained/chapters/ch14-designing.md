# Chapter 14 — Designing: The Value of Time

The question is not whether to design, but when to design. XP's answer: design always, in the light of experience.

## The Dog House to Skyscraper Metaphor
In software, you can start with a dog house and gradually replace pieces until you have a skyscraper, continuously occupying the structure. Absurd in the physical world; sensible and low-risk in software.

## When to Design (Three Scenarios)
1. **Any design works** — instinct is sufficient, go ahead and design now
2. **Thought or experience needed** — careful thought yields good-enough answers, but experience yields better ones
3. **Experience is essential** — no amount of pure thought without experience will suffice; incremental design is inevitable

## "Design Always"
The alternative to BDUF isn't no design — it's designing after implementing, close to when the design is used. McConnell's "LDUF/ENUF" is a strawman; XP says design continuously.

## Once and Only Once
The most powerful design heuristic. Data, structure, or logic in only one place. One conceptual change = one code change. Spot duplication → work with design to unify.

## Four Criteria of Simple Design
1. **Appropriate for audience** — people who work with it understand it
2. **Communicative** — every needed idea is represented
3. **Factored** — no duplication
4. **Minimal** — fewest elements within the above constraints

## Incremental Database Design (Sadalage)
1. Start with empty database
2. Add tables/columns with numbered migration scripts that also migrate existing data
3. Deploy = roll out new code + run migration scripts

## Dealing with Legacy ("Big Ball of Mud")
"Brighten the corner where you are." As you modify code, clean up locally. Resist cleaning too far afield. Make a public list of bigger improvements. Soon the code you change frequently is well-designed.

## Long-Running Design Changes
Stage them. Concentrate leaked assumptions, reduce scope until the change fits in a week. Weekly delivery of functionality is the cornerstone of trust — the convenience of designers is lower priority.
