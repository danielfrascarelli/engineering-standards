# Agent Rules

Applies to AI coding agents, autonomous tools, code-generation assistants, automated contributors.

Agents follow the same standards as human contributors. This file adds agent-specific duties. It does not replace them.

Baseline workflow: [standards/CONTRIBUTING.md](standards/CONTRIBUTING.md). Rules below are additions only.

Read order is owned by [README.md](README.md), ["Read order"](README.md#read-order). MUST follow it. This file states no order of its own.

## This repository

Git identity (see [standards/GIT.md](standards/GIT.md), "Authorship"):

- user.name:  danielfrascarelli
- user.email: dsanfra@gmail.com
- gh account: danielfrascarelli   # pull request author, not checked by git hooks

Every consuming repo carries its own block. Identity differs between repos. MUST NOT copy this one forward without checking. The sync script strips this section from the generated copy for that reason.

## Where standards live

In a consuming repo, central standards sit at `.standards/`, added by submodule or sync script. See [README.md](README.md).

Which documents to load, and in what order: [README.md](README.md), ["Read order"](README.md#read-order). MUST NOT load a stack document that no changed path maps to.

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

MUST run the six checks in [standards/CHECKS.md](standards/CHECKS.md) before reporting done.

- MUST NOT report a check as passed unless it ran.
- Check could not run? MUST name it and state why.
- MUST NOT disable test, delete assertion, or weaken lint rule to force green.

## Reporting

Agent report MUST contain every field of the PR description in [standards/PR.md](standards/PR.md), plus these agent-only fields:

- checks executed, with result;
- anything not validated, and why;
- assumptions made where request was ambiguous.

Agent opening a PR: PR description is the report. Do not write two different summaries.

## Committing

- MUST verify `git config user.name` and `git config user.email` at repo level match the identity declared in the repo's `AGENTS.md`, before the first commit in a clone or worktree.
- MUST NOT add a `Co-Authored-By:` trailer naming yourself or any AI tool.
- MUST NOT add a session link or a "Generated with ..." footer.
- The same three rules apply to the pull request title and body, not only to the commit message. MUST.
- Full rule: [standards/GIT.md](standards/GIT.md), "Authorship".

Note: the tool that produced a change is not its author. A commit is written as the declared human identity and describes the change, not the process.

## Forbidden

- MUST NOT commit secrets. See [standards/SECURITY.md](standards/SECURITY.md).
- MUST NOT fabricate test results.
- MUST NOT claim a command succeeded without running it.
- MUST NOT disable tests to make build pass.
- MUST NOT suppress errors without understanding them.
- MUST NOT weaken security control for convenience.
- MUST NOT push to protected branch. See [standards/GIT.md](standards/GIT.md).
- MUST NOT force-push shared branch.

## Overrides

(none)
