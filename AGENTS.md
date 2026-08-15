# Agent Rules

These rules apply to AI coding agents, autonomous tools, code-generation assistants, and automated contributors.

## Before changing code

- Read the repository `README.md`.
- Read local repository instructions.
- Read the applicable central standards.
- Inspect existing patterns before creating new abstractions.
- Identify the smallest change that satisfies the request.
- Do not assume undocumented architecture, APIs, dependencies, or infrastructure.

## Scope discipline

- Make focused changes.
- Do not perform unrelated refactors.
- Do not rename, move, or reformat unrelated files.
- Do not upgrade dependencies unless required by the task.
- Do not change public APIs without explicit need.
- Preserve backwards compatibility unless the task explicitly removes it.

## Implementation

- Reuse existing utilities and patterns before introducing new ones.
- Prefer simple code over clever code.
- Keep business logic separate from transport, UI, framework, and persistence layers.
- Avoid hidden side effects.
- Avoid unnecessary abstractions.
- Do not introduce speculative extensibility.
- Do not add dead code or commented-out code.

## Validation

Before finishing, run the relevant checks when available:

- tests;
- lint;
- formatting;
- type checking;
- build;
- security checks affected by the change.

If a check cannot be run, state that explicitly.

## Communication

At completion, report:

- what changed;
- important implementation decisions;
- tests/checks executed;
- anything not validated;
- follow-up risks or TODOs only when relevant.

## Forbidden behavior

- Never commit secrets.
- Never fabricate test results.
- Never claim a command succeeded without running it.
- Never disable tests to make a build pass.
- Never suppress errors without understanding them.
- Never weaken security controls for convenience.
