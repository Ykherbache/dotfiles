# Ch 14: The Sniper Wins an Auction

## Feature: Winning State

When the auction closes while the Sniper has the highest bid, it should report "Won" instead of "Lost."

## State Machine Emergence

The Sniper's behavior is now a state machine:
- **Joining** → received price from other → **Bidding**
- **Joining** → auction closed → **Lost**
- **Bidding** → received price from other → **Bidding** (bid again)
- **Bidding** → received price from sniper → **Winning**
- **Winning** → auction closed → **Won**
- **Winning** → received price from other → **Bidding** (outbid)

The state machine wasn't designed upfront — it **emerged** from the sequence of acceptance tests, each adding one transition.

## SniperState Enum

States are reified into a `SniperState` enum. Each state knows whether the auction is still open and what the final outcome is. The enum replaces scattered boolean flags.

## SniperSnapshot Value Object

Bundles the Sniper's current state: item ID, last price, last bid, sniper state. This value object flows from domain to UI, keeping the `AuctionSniper` decoupled from Swing.

## Test Pattern: Allow Queries, Expect Commands

- `allowing(auction).bid(...)` — stubs for queries about state
- `oneOf(listener).sniperWinning()` — expectations for state-change notifications
- This keeps tests focused on the behavior under test, not on incidental interactions

## Lesson
State machines emerge naturally from incremental TDD. Each test adds one transition. The explicit enum makes states visible and prevents impossible transitions.
