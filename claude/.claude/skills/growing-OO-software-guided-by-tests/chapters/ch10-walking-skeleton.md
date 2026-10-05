# Ch 10: The Walking Skeleton

## Building the First End-to-End Test

The first acceptance test proves the thinnest slice works end-to-end:
1. Auction sends a "Close" event
2. Sniper shows status "Lost"

This requires building: XMPP connection, message parsing, Swing UI, and test infrastructure — all at once.

## End-to-End Test Infrastructure

### FakeAuctionServer
A test helper that acts as an auction house. It:
- Connects to a real XMPP server (OpenFire)
- Sends price events and close notifications
- Asserts that it received expected bids from the Sniper

### ApplicationRunner
Launches the real Sniper application in-process and asserts on its UI state using WindowLicker (Swing test framework). Checks labels and table cells for expected status text.

## Key Decisions

### Real Infrastructure in Acceptance Tests
The tests use a real XMPP server, not a fake one. This catches integration issues early. The test infrastructure wraps the XMPP complexity behind readable helper methods.

### Test Readability Over Mechanics
The acceptance test reads as a scenario:
```
auction.startSellingItem();
application.startBiddingIn(auction);
auction.hasReceivedJoinRequestFromSniper();
auction.announceClosed();
application.showsSniperHasLostAuction();
```

### Minimum Production Code
The skeleton's production code is deliberately ugly — hardcoded, minimal, just enough to pass. The goal is to prove the architecture works, not to write clean code yet. Clean design emerges in subsequent iterations.

## Lesson
Getting the walking skeleton to work is the hardest single step. It forces every technology choice to prove itself under test immediately.
