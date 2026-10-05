# Ch 15: Towards a Real User Interface

## Feature: Replace Label with Table

The single-label UI is replaced with a Swing `JTable` showing columns: item ID, last price, last bid, sniper state. This supports multiple items later.

## SnipersTableModel

A `TableModel` implementation that holds `SniperSnapshot` values. It:
- Implements `SniperListener` to receive state updates from the domain
- Translates snapshots into table cell values
- Fires table change events on the Swing EDT

## Testing Swing Components

### Unit Testing the TableModel
Test `SnipersTableModel` directly — call its `SniperListener` methods and assert on the `TableModel` data. No Swing threading needed because no real UI is involved.

### Acceptance Testing the UI
`ApplicationRunner` uses WindowLicker to find table cells by content. The acceptance test asserts visible table state without knowing the implementation.

## Defect-Driven Development

A threading bug was found: domain events arrived on XMPP threads but Swing requires EDT updates. The fix: ensure `SniperListener` callbacks are marshaled to the EDT. This was caught by the acceptance tests running against a real XMPP server.

**When you find a defect, write a failing test first, then fix it.** The test prevents regression and documents the threading contract.

## Column Enum Pattern

Table columns are defined as an enum with `at(index)` lookup, display name, and a method to extract the value from a `SniperSnapshot`. This keeps column logic cohesive and extensible.

## Lesson
UI components are testable when they implement domain interfaces. Separate the model (data + logic) from the view (rendering) and test the model directly.
