# Ch 13: The Sniper Makes a Bid

## Feature: Sniper Responds to Price with a Bid

The Sniper receives a price event and must decide whether to bid. This chapter extracts the core domain object: `AuctionSniper`.

## AuctionSniper: The Domain Object

`AuctionSniper` implements `AuctionEventListener` and contains the bidding logic:
- On `currentPrice()`: if not from us, bid higher (price + increment) via `Auction` interface
- On `auctionClosed()`: notify listener that we lost
- Reports state changes via `SniperListener`

## Interface Discovery Through Tests

Unit tests for `AuctionSniper` mock two collaborators:
- **`Auction`**: the outbound port — `bid(amount)` sends a bid
- **`SniperListener`**: the notification — `sniperBidding()`, `sniperLost()`

Both interfaces were discovered by asking: "what does the Sniper need to tell the outside world?" The test drove the interface design.

## The Auction Interface

`Auction` wraps the mechanics of sending a bid via XMPP. The Sniper doesn't know about XMPP — it just calls `auction.bid(price)`. The `XMPPAuction` adapter implements this by formatting and sending the appropriate XMPP message.

## Bidder Distinction: From Other vs. From Sniper

Price events include a `PriceSource` (FromSniper or FromOtherBidder). When the price is from us, we're winning — don't bid again. When from another bidder, bid higher. This distinction drives the state transitions.

## Refactoring the Main Class

`Main` now wires together: `XMPPAuction` → `AuctionSniper` → `SniperStateDisplayer` (UI). Each component has a single responsibility. The wiring happens in one place; the components are independently testable.

## Lesson
Each new behavior exposes the next interface to discover. Let the tests guide you — mock what you need, name the interface, implement it next.
