# Ch 18: Filling In the Details

## Feature: Adding Items Through the UI

Users type an item ID and stop price into a text field and click "Join Auction." This triggers the Sniper to start bidding on that item.

## UserRequestListener Interface

The UI fires `joinAuction(itemId)` on a `UserRequestListener` when the user clicks the button. The `SniperLauncher` implements this interface. The UI has no knowledge of auctions, XMPP, or snipers — it just translates clicks into domain requests.

## Stop Price

Each sniper now has a maximum price. When the auction price exceeds the stop price, the sniper transitions to **Losing** (and then **Lost** on close) rather than continuing to bid. This adds new states to the state machine:
- **Bidding** → price exceeds stop price → **Losing**
- **Losing** → auction closed → **Lost**
- **Winning** → price exceeds stop price → **Losing** (outbid beyond limit)

## Test Data Builder Pattern

As test setup becomes complex (creating snipers with item IDs, stop prices, initial states), **Test Data Builders** emerge:
- Builder creates valid objects with sensible defaults
- Tests override only what matters for this scenario
- Reads like a specification: `aSniper().withItem("item-123").withStopPrice(1500).build()`

## Acceptance Test Evolution

Tests now interact with the real Swing UI — typing into text fields, clicking buttons. The `ApplicationRunner` helper encapsulates WindowLicker interactions behind intent-revealing methods.

## Lesson
Each new user-facing feature follows the same rhythm: write acceptance test, discover new interfaces via mocks, implement, refactor. The process is predictable and sustainable.
