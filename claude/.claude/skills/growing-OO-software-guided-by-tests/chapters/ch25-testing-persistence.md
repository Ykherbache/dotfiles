# Ch 25: Testing with Databases

## The Challenge

Database tests are slow, stateful, and fragile. But databases are critical infrastructure — they can't be ignored.

## Test Layers for Persistence

### Unit Tests: No Database
Domain objects and business logic are tested with mocks for the persistence layer. The domain depends on repository interfaces, not on JDBC or SQL.

### Integration Tests: Real Database
Repository implementations are tested against a real database (often in-memory or containerized). These tests verify:
- SQL queries return correct results
- Mappings between domain objects and tables are correct
- Transactions and constraints work as expected

### End-to-End Tests: Full Stack
Acceptance tests exercise the complete path including persistence. They use the real database but focus on behavior, not on data correctness.

## Practical Techniques

### Round-Trip Tests
Insert an object, read it back, compare. This verifies the mapping is lossless. Use builders to create complex domain objects for round-trip testing.

### Transaction Management
Each test runs in a transaction that's rolled back afterward. This isolates tests from each other without needing to clean up data.

### Schema Management
Tests need a known schema. Use migration tools (Flyway, Liquibase) to manage schema evolution. Tests should use the same migrations as production.

## Adapter Pattern for Persistence
The repository interface is part of the domain. The implementation (using JDBC, Hibernate, etc.) is an adapter. This keeps the domain testable without a database and allows swapping persistence technologies.

## Anti-pattern: Testing the ORM
Don't test that Hibernate or JPA work correctly — test that your mappings and queries produce the right results. Trust the framework; verify your usage of it.
