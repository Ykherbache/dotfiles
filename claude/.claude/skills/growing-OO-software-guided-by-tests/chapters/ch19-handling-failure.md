# Ch 19: Handling Failure

## Feature: Graceful Error Handling

When the Sniper encounters an unexpected message or a translation error, it should report "Failed" rather than crash silently or corrupt its state.

## New State: Failed

Added to the state machine: any state can transition to **Failed** on an error. The `AuctionSniper` catches translation exceptions and transitions to Failed, notifying the listener.

## AuctionMessageTranslator Error Handling

The translator is wrapped to catch parse exceptions. On failure, it:
1. Logs the raw message for debugging
2. Notifies the `AuctionEventListener` of failure
3. Stops processing further messages for this auction

## Defect-Driven Testing

The error handling feature was driven by observing real failures:
- Malformed XMPP messages from the auction server
- Unexpected message types
- Missing required fields

Each observed failure mode becomes a test case: given this broken input, expect the Failed state.

## Logging as a Feature

Logging isn't just debugging output — it's a **feature** that supports operations. The test verifies that error details are logged with enough information to diagnose the problem. The logger is injected as a dependency and mocked in tests.

## UI Shows Failure

The table row turns to "Failed" status. The acceptance test verifies this end-to-end: send a malformed auction message, assert the UI shows failure.

## Lesson
Error handling is a feature, not an afterthought. Test it explicitly. Inject loggers as dependencies so you can verify diagnostic output. Design error paths as carefully as success paths.
