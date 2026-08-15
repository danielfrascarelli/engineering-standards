# Testing Standards

## Goals

Tests should reduce regression risk and document expected behavior.

Prioritize tests around:

- business rules;
- important edge cases;
- authorization boundaries;
- data transformations;
- failure handling;
- previously reported bugs.

## Test pyramid

Prefer:

1. Fast unit tests for domain logic.
2. Integration tests for boundaries and infrastructure.
3. End-to-end tests for critical user flows.

Do not move everything into E2E tests.

## Rules

- Test behavior, not implementation details.
- Avoid brittle selectors and internal-state assertions.
- Tests must be deterministic.
- Tests must not depend on execution order.
- Avoid arbitrary sleeps.
- Mock external systems only where appropriate.
- Prefer realistic fixtures over huge anonymous fixture blobs.

## Bug fixes

When practical, add a regression test that fails before the fix and passes after it.

## Coverage

Coverage is a signal, not the goal.

Do not add low-value tests only to increase a percentage.
