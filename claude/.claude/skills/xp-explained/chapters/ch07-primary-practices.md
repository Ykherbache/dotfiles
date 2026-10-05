# Chapters 6-7 — Practices & Primary Practices

Practices are stated as absolutes to give clear goals and a vector from where you are to where you can be. They compound — interactions between practices amplify their effect.

## Sit Together
Open space for whole team. Privacy via small private spaces or limited hours. "No matter what the client says the problem is, it is always a people problem." Multisite teams can still do XP but should increase face time when problems arise.

## Whole Team
All skills and perspectives needed. Cross-functional. People identified with the team, not their function. Size thresholds: ≤12 for daily interaction, ≤150 for face recognition. Fractional allocation (40%/60%) destroys team sense — group into dedicated teams.

## Informative Workspace
15-second status for an observer. Story cards on a wall, sorted spatially. Big visible charts for active issues — take them down when resolved. Water, snacks, cleanliness for human needs.

## Energized Work
Sustainable hours only. "Where is the scientific evidence that 80-hour weeks produce more value than 40?" Long hours are a control illusion. When sick, stay home — it shows respect, not weakness. Start with declaring 2-hour "Code Time" blocks.

## Pair Programming
Two people, one machine, programming as dialogue. Benefits: stay on task, brainstorm, clarify ideas, lower frustration, hold each other accountable. Rotate frequently. Respect personal space and cultural differences. Tiring — 5-6 hours/day max. Solo exploration is fine, but bring back the idea, not the code.

## Stories
Units of customer-visible functionality, not "requirements" (which implies absolutism). Estimated early — estimation forces business/technical interaction. Index cards on a wall. Short names + short descriptions. "Do you want the Ferrari for $150K or the minivan for $25K?"

## Weekly Cycle
Monday: review progress, pick stories, break into tasks, sign up, estimate. Write tests first, implement, deploy Friday. Planning is necessary waste — reduce the percentage over time. "Monday's are unpleasant and planning is unpleasant, so why put them together?" — some teams start mid-week.

## Quarterly Cycle
Identify bottlenecks (especially external), plan themes, pick a quarter's worth of stories, focus on big picture. Synchronizes with other business activities. Good interval for team reflection and long-running experiments.

## Slack
Include droppable minor tasks. Iceland truck metaphor: drive in 2WD, save 4WD for when stuck. Structures: one week in eight as "Geek Week", 20% budget for programmer-chosen tasks, or just honest personal estimates.

## Ten-Minute Build
Automated, full system, all tests, ≤10 minutes. Longer → used less often → lost feedback. Path: first automate, then partial builds, then partial test suites. Automated builds become stress relievers at crunch time.

## Continuous Integration
Integrate after ≤ couple of hours. Prefer synchronous (wait for build, reflect on what you did) over async (email notification 30 min later). Build the complete product — if goal is CD, burn the CD. First deployment should be no big deal.

## Test-First Programming
Write failing test → make it pass. Controls scope creep, signals design problems (hard to test = design smell), builds trust, creates natural rhythm (test-code-refactor). Two sets: programmer tests (component, exhaustive) and customer tests (system, story-level).

## Incremental Design
Design every day in light of experience. "Design always" — not BDUF, not no design. Eliminate duplication (Once and Only Once) as primary heuristic. Cost of changes stays low with automated tests, continual improvement, and explicit social process. The question is not whether to design, but when.
