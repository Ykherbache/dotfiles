# Ch 11: Passing the First Test

## Making the Walking Skeleton Pass

The chapter shows the messy reality of getting a first end-to-end test green. The production code is deliberately crude — one big `Main` class that connects to XMPP, joins an auction chat room, and updates a Swing label.

## Key Implementation Steps

1. **Connect to XMPP**: Use Smack library to log into OpenFire server
2. **Join auction chat**: Each auction is an XMPP chat room named by item ID
3. **Listen for messages**: Register a message listener on the chat
4. **Update UI on close**: When "close" message arrives, change Swing label to "Lost"

## Threading Concern (First Encounter)

XMPP messages arrive on a background thread but Swing requires UI updates on the Event Dispatch Thread (EDT). Solution: `SwingUtilities.invokeLater()` to marshal updates. This foreshadows the concurrency patterns explored in later chapters.

## Deliberate Shortcuts

- All logic in one class (no separation of concerns yet)
- Hardcoded message parsing (string comparison)
- Single label UI (no table, no multiple items)

These shortcuts are acceptable because the walking skeleton's purpose is to prove integration, not design. The tests will drive clean design in subsequent iterations.

## Test Infrastructure Payoff

The `FakeAuctionServer` and `ApplicationRunner` built in Ch 10 now pay off: each new acceptance test is just a few lines of readable scenario code. The infrastructure investment is amortized over every future test.

## Lesson
Ship something ugly that works end-to-end, then improve it under test pressure. Premature design without integration proof is speculation.
