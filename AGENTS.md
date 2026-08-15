# Agent Rules

Applies to AI coding agents, autonomous tools, code-generation assistants, automated contributors.

Agents follow the same standards as human contributors. This file adds agent-specific duties. It does not replace them.

Baseline workflow: [standards/CONTRIBUTING.md](standards/CONTRIBUTING.md). Read it first. Rules below are additions only.

## Where standards live

In a consuming repo, central standards sit at `.standards/`, added by submodule or sync script. See [README.md](README.md).

Read order:

1. `.standards/README.md` — precedence and rule strength.
2. Repo `README.md`.
3. Repo `AGENTS.md` — project facts and declared overrides.
4. `.standards/standards/` and `.standards/stacks/` files relevant to the change.

Standards not present at `.standards/`? Say so. MUST NOT invent rules to fill gap.

## Before changing code

- MUST inspect existing patterns before creating new abstraction.
- MUST identify smallest change satisfying request.
- MUST NOT assume undocumented architecture, API, dependency, or infrastructure.
- Uncertain about intent? Ask. MUST NOT guess and build.

## Scope discipline

- MUST keep change focused on request.
- MUST NOT do unrelated refactor.
- MUST NOT rename, move, or reformat unrelated file.
- MUST NOT upgrade dependency unless task requires it. Dependency rules: [standards/DEPENDENCIES.md](standards/DEPENDENCIES.md).
- MUST NOT change public API without explicit need.
- MUST preserve backwards compatibility unless task explicitly removes it.
- Dependency became unused because of your change? Remove it. Dependency already unused before your change? Leave it, report it. See [standards/DEPENDENCIES.md](standards/DEPENDENCIES.md).

## Implementation

- MUST reuse existing utility and pattern before introducing new one.
- SHOULD prefer simple code over clever code.
- SHOULD keep business logic separate from transport, UI, framework, persistence.
- MUST NOT add hidden side effects.
- MUST NOT add speculative extensibility.
- MUST NOT leave dead code or commented-out code.

## Tests and docs

Same duty as human contributor. No exemption.

- MUST add or update tests for behavior you change. Strategy: [standards/TESTING.md](standards/TESTING.md).
- MUST update documentation when behavior changes. Rules: [standards/DOCUMENTATION.md](standards/DOCUMENTATION.md).
- Fixing a bug? Regression test policy is in [standards/TESTING.md](standards/TESTING.md). It applies to you unchanged.

## Validation

Run the six checks in [standards/CHECKS.md](standards/CHECKS.md) before reporting done.

- MUST NOT report a check as passed unless it ran.
- Check could not run? MUST name it and state why.
- MUST NOT disable test, delete assertion, or weaken lint rule to force green.

## Reporting

Agent report MUST contain every field of the PR description in [standards/PR.md](standards/PR.md), plus these agent-only fields:

- checks executed, with result;
- anything not validated, and why;
- assumptions made where request was ambiguous.

Agent opening a PR: PR description is the report. Do not write two different summaries.

## Forbidden

- MUST NOT commit secrets. See [standards/SECURITY.md](standards/SECURITY.md).
- MUST NOT fabricate test results.
- MUST NOT claim a command succeeded without running it.
- MUST NOT disable tests to make build pass.
- MUST NOT suppress errors without understanding them.
- MUST NOT weaken security control for convenience.
- MUST NOT push to protected branch. See [standards/GIT.md](standards/GIT.md).
- MUST NOT force-push shared branch.
