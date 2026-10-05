# Ch 16: Sniping for Multiple Items

## Feature: Track Multiple Auctions Simultaneously

The Sniper must manage several auctions at once, each with independent state. The table shows one row per item.

## SniperPortfolio: Managing a Collection

A new `SniperPortfolio` object manages the collection of active snipers. It:
- Creates a new `AuctionSniper` per item
- Notifies a `PortfolioListener` when snipers are added
- Wires each sniper to its own `Auction` and connects it to the table model

## Growing the Design

The table model now listens to the portfolio (for row additions) and to individual snipers (for row updates). This is the **Composite Simpler Than Sum of Parts** principle — the portfolio hides multi-sniper wiring complexity.

## Test Impact

### Acceptance Test
Multiple fake auctions run in parallel. The test asserts that each row shows the correct state for its item.

### Unit Tests
- `SniperPortfolio` tested with mock `PortfolioListener`
- `SnipersTableModel` tested for both adding rows and updating existing rows
- Each sniper still tested in isolation

## Wiring in Main

`Main` evolves to create the portfolio, pass it the table model as listener, and loop over item IDs to add snipers. The wiring code grows but remains in one place.

## Lesson
When you need a collection of domain objects, introduce a first-class collection object rather than exposing a raw list. The collection object owns the creation and lifecycle of its members, keeping the rest of the system simple.
