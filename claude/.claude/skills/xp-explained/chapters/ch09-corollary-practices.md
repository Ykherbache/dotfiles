# Chapter 9 — Corollary Practices

Difficult or dangerous without primary practices in place. Trust your nose about what to try next.

## Real Customer Involvement
People whose lives are affected by the system join the team. Visionary customers participate in planning, may have a budget of development capacity. "It's easier to generalize a successful system than to specialize one that doesn't solve anyone's problem."

## Negotiated Scope Contract
Fix time, cost, quality — negotiate scope. Split big contracts into shorter ones with optional extensions. Aligns supplier and customer interests.

## Pay-Per-Use
Money is the ultimate feedback. Connects revenue flow directly to development decisions. Even subscription models give retention rates as feedback.

## Incremental Deployment
Gradually take over a legacy system's workload. Big-bang cutover: "that trick never works." Find a small piece, deploy it, run both systems in parallel. "End-to-end is further than you think."

## Team Continuity
Keep effective teams together. Large orgs treat programmers as "plug-compatible units" — this destroys trust and relationships. New members on established XP teams contribute independently within a month.

## Shrinking Teams
As capability grows, keep workload constant, reduce size. Freed people form new teams. Toyota practice — make excess capacity visible, then eliminate the waste that created it.

## Root-Cause Analysis (Five Whys)
1. Write system-level test demonstrating the defect
2. Write smallest unit test reproducing it
3. Fix it
4. Ask why five times — find the people problem at the root
5. Initiate process change

"After Five Whys, you find the people problem lying at the heart of the defect."

## Shared Code
Anyone can improve any part of the system at any time. Requires collective responsibility culture. Without it, "no one is responsible and quality will deteriorate."

## Code and Tests
Only permanent artifacts. Generate other documents from code and tests. "Ceremony interferes with the flow of value."

## Single Code Base
One code stream. Temporary branches live hours, not days. Multiple code bases are "an enormous source of waste." Fix the underlying design problem instead of adding more versions.

## Daily Deployment
Put new software into production every night. Prerequisites: near-zero defects, automated build, automated deployment with rollback, high trust. Use the "keystone" pattern for big features: deploy all non-visible changes incrementally, add the UI change last.
