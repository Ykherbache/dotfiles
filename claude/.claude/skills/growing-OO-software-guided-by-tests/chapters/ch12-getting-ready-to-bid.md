# Ch 12: Getting Ready to Bid

## Next Feature: Bidding in Response to Price Events

New acceptance test: auction reports a price, Sniper bids higher, auction closes, Sniper shows "Lost" (outbid). This forces the emergence of real domain logic.

## Architectural Decomposition Begins

The monolithic `Main` class is refactored under test pressure into:

### AuctionMessageTranslator
Parses incoming XMPP messages into domain events. Translates protocol-level strings into typed method calls on an `AuctionEventListener` interface. This is the **adapter** between XMPP and the domain.

### AuctionEventListener Interface
Domain-level callback: `auctionClosed()`, `currentPrice(price, increment, bidder)`. Discovered through the mocking process — "what does the Sniper need to know?"

### Separation Emerges from Tests
The unit test for `AuctionMessageTranslator` mocks `AuctionEventListener`. This forces the interface to exist and defines exactly what events the translator must produce. The mock is the specification.

## Outside-In TDD in Action

1. **Acceptance test** defines the feature (bid on price, show bidding status)
2. **Unit test** for translator: given XMPP message, expect domain event on listener
3. **Unit test** for Sniper logic: given price event, send bid via Auction interface
4. Each layer's test mocks the layer below, discovering its interface

## Key Refactoring: Extract Interface

When a class does two things (parse messages AND decide what to do), extract an interface between them. The interface names the relationship — `AuctionEventListener` describes the role, not the implementation.

## Lesson
Features drive decomposition. Don't split classes speculatively — let the tests show you where the seams are by making the code hard to test when responsibilities are mixed.
