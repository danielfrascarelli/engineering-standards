# Testing Standards

Owner: test strategy, test quality, regression policy, coverage stance.

Runner names and when tests run: [CHECKS.md](CHECKS.md).

## Purpose

Tests cut regression risk and document expected behavior. Nothing else.

Prioritize tests around:

- business rules;
- authorization boundaries;
- data transformations;
- failure handling;
- important edge cases;
- previously reported bugs.

## Shape

Prefer, in order:

1. Fast unit tests for domain logic.
2. Integration tests for boundaries and infrastructure.
3. End-to-end tests for critical user flows only.

MUST NOT push everything into end-to-end tests. They are slow and flaky at scale.

## Rules

- MUST test behavior, not implementation detail.
- MUST be deterministic. Flaky test is a broken test.
- MUST NOT depend on execution order or on another test's leftover state.
- MUST NOT use arbitrary sleeps. Wait on a condition instead.
- MUST NOT assert on private internal state.
- SHOULD avoid brittle selectors.
- SHOULD mock only at external system boundaries. Mocking your own domain hides bugs.
- SHOULD prefer small realistic fixtures over large opaque fixture blobs.

Test name SHOULD state the behavior, not the function name.

## Regressions

Bug fix MUST ship with a regression test that fails before the fix and passes after it.

Exception: reproduction is not feasible in an automated test. Then the PR description MUST say why. See [PR.md](PR.md).

## Flaky tests

- MUST NOT delete or skip a failing test to make the build green. See [CHECKS.md](CHECKS.md).
- Test quarantined as flaky MUST have a tracking issue and an owner.
- Quarantine is temporary. Untracked quarantine MUST NOT stay past one release. See [RELEASES.md](RELEASES.md).

## Coverage

Coverage is a signal, not a goal.

- MUST NOT add low-value tests only to move a percentage.
- Repo MAY set a coverage floor to stop erosion.
- Coverage floor MUST NOT be the only quality gate.
