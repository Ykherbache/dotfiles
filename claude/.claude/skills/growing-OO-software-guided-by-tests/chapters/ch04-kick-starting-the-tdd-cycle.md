# Ch 4: Kick-Starting the Test-Driven Development Cycle

## The Walking Skeleton

The first thing to build is a **Walking Skeleton**: the thinnest possible slice of functionality that exercises the full technology stack end-to-end. It must:
- Build, deploy, and test automatically
- Touch every integration point (UI, middleware, database, external services)
- Be covered by at least one end-to-end acceptance test

The skeleton is intentionally trivial in functionality. Its purpose is to **flush out infrastructure and deployment risks early**, not to deliver user value.

## Why Start Here

- Deploying and testing is harder than writing code — do the hard thing first
- Early end-to-end feedback reveals architectural mismatches before they compound
- The build/deploy/test cycle is your most important feedback loop — get it working immediately
- Decisions made early are the hardest to change; test them soonest

## Practical Steps

1. Decide on the first meaningful feature (even if minimal)
2. Write one acceptance test that exercises it end-to-end
3. Build just enough code and infrastructure to make it pass
4. Automate the build-deploy-test cycle completely

## Key Insight

Teams that skip the skeleton and start with "interesting" features often discover, weeks in, that their components don't integrate. The skeleton forces integration from day one.

## Relationship to Incremental Development

After the skeleton walks, **grow it incrementally** — each feature adds flesh to the bones. The architecture evolves under the pressure of real, tested requirements rather than speculative design.
