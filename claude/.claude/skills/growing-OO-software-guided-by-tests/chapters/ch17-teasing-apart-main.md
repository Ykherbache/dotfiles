# Ch 17: Teasing Apart Main

## Problem: Main Is Growing

As features accumulate, the `Main` class becomes a tangle of object creation, wiring, and application logic. It knows too much about too many things.

## Refactoring Strategy: Extract Roles

Split `Main` into focused components by identifying distinct responsibilities:

### SniperLauncher
Creates and wires new `AuctionSniper` instances. Extracted from the portfolio-adding logic. Implements `UserRequestListener` so the UI can trigger new snipers without knowing the wiring details.

### XMPPAuctionHouse
Factory for `XMPPAuction` objects. Encapsulates XMPP connection management. The domain doesn't know XMPP exists — it uses the `AuctionHouse` interface.

### Separation of Concerns in Main
After refactoring, `Main` only:
1. Creates the XMPP connection
2. Creates the `AuctionHouse`
3. Creates the `SniperPortfolio` and wires it to the UI
4. Creates the `SniperLauncher` and connects it to user input

## Testing Impact

Each extracted component is independently testable:
- `SniperLauncher`: mock the `AuctionHouse` and `SniperPortfolio`
- `XMPPAuctionHouse`: integration test against real XMPP server
- `Main`: almost no logic left to test — it's pure wiring

## Lesson
The `Main` class (or composition root) should only wire objects together. When it accumulates logic, extract that logic into named objects with clear roles. The composition root is the one place that knows about all the concrete types — keep it thin.
