# Ch 9: Commissioning an Auction Sniper (Overview)

## The Worked Example

Part III builds an **Auction Sniper** — a Java Swing application that automatically bids in online auctions over XMPP. The example demonstrates the full TDD cycle from walking skeleton to production-ready features.

## System Architecture

- **XMPP server** (OpenFire): hosts auction chat rooms
- **Auction Sniper**: Swing GUI client that joins auctions, bids, and reports status
- **Auction house**: sends price events, accepts bids via XMPP messages

## Initial Feature List
1. Single item: join auction, lose immediately
2. Single item: join auction, bid, lose
3. Single item: join auction, bid, win
4. Multiple items with status tracking
5. User adds items through UI
6. Stop bidding at a maximum price

## Walking Skeleton Scope

The first end-to-end test: Sniper joins an auction, auction closes immediately, Sniper shows "Lost." This exercises:
- XMPP connection and message parsing
- Event translation from protocol to domain
- Swing UI update
- End-to-end acceptance test infrastructure (fake auction server)

## Key Design Decision: Ports and Adapters

From the start, the architecture separates:
- **XMPP adapter layer**: translates XMPP messages to/from domain events
- **Domain model**: `AuctionSniper`, `SniperState`, bidding logic
- **UI layer**: Swing table model displaying sniper status

This separation emerges from the tests, not from upfront architecture.
