# Contributing Standards

Owner: contributor workflow, from task to merged change.

Applies to humans and agents. Agents follow this file, then add the duties in [../AGENTS.md](../AGENTS.md).

## Before starting

1. Read the documents in the order owned by [../README.md](../README.md), ["Read order"](../README.md#read-order). MUST. This file states no order of its own.
2. Confirm task scope. Ambiguous? Ask before building. MUST.

## Workflow

1. Branch off `main` with the right prefix. See [GIT.md](GIT.md).
2. Make smallest coherent change.
3. Add or update tests. See [TESTING.md](TESTING.md).
4. Update docs when behavior changes. See [DOCUMENTATION.md](DOCUMENTATION.md).
5. Run required checks. See [CHECKS.md](CHECKS.md).
6. Open a focused pull request. See [PR.md](PR.md).

Steps 3, 4, 5 are MUST. Skipping one needs a stated reason in the PR description.

## Code quality

Contribution MUST:

- follow existing architecture;
- keep public interfaces intentional;
- use clear names;
- preserve compatibility unless the task explicitly changes it.

Contribution MUST NOT:

- duplicate existing logic;
- add abstraction with a single caller and no planned second;
- leave dead code or commented-out code.

## Review

- MUST address a review comment by changing the code, or by stating the technical reason for keeping it.
- MUST NOT resolve a review thread without addressing its substance.
- Disagreement that survives one round goes to the code owner. See [PR.md](PR.md).
