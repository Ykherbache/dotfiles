# Ch 8: Building on Third-Party Code

## Only Mock Types You Own

Never mock third-party APIs directly. Instead, write a thin adapter (wrapper) that translates between your domain language and the external API. Mock the adapter interface in your tests.

### Why
- Third-party APIs can change without notice — mocking them couples tests to unstable contracts
- Third-party APIs are designed for generality, not your domain — tests become hard to read
- Adapter interfaces express what your code *needs*, not what the library *offers*
- Integration with the real third-party code is tested separately in integration tests

## Adapter Layer Pattern

1. Define an interface in your domain's terms (e.g., `AuctionEventListener` not `XMPPMessageListener`)
2. Implement a thin adapter that delegates to the third-party library
3. Write integration tests for the adapter against the real library
4. Mock the domain interface in all unit tests

## Integration Testing Third-Party Code

Write focused integration tests that verify your adapter works correctly with the real library. These tests:
- Run against a real instance (server, database, file system)
- Cover the specific behaviors you depend on
- Act as a **tripwire** — they break when the library changes in ways that affect you
- Are separate from your fast unit test suite

## Notifications vs. Dependencies

When integrating with external systems, distinguish:
- **Dependencies** you need to call (wrap with an adapter)
- **Notifications** you receive (translate incoming events through a listener adapter)

Both sides get their own adapter interfaces, keeping the domain model free of external types.

## Practical Heuristic

If you see an import from a third-party library in a domain class, consider whether an adapter is missing. Domain objects should only depend on domain types and adapter interfaces.
