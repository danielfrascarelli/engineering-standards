# Documentation Standards

Owner: what to document, README shape, comment rules, decision records.

## Principle

Docs carry what code cannot carry efficiently. Intent, constraints, operations.

MUST document:

- setup requirements;
- public APIs;
- environment variables, including which are secrets;
- operational procedures and runbooks;
- migrations;
- architecture decisions;
- non-obvious constraints and their reason.

MUST NOT document what the code already states plainly. That doc rots first.

## README

Repo `README.md` MUST contain:

- project purpose, one paragraph;
- prerequisites and runtime version;
- installation;
- local development;
- the six check commands. See [CHECKS.md](CHECKS.md);
- build;
- required environment variables;
- deployment entry point or link;
- links to deeper documentation.

Repo `AGENTS.md` MUST contain project facts and declared overrides. Shape: [../README.md](../README.md).

## Keeping docs true

- Behavior change MUST update affected docs in the same PR. See [PR.md](PR.md).
- A doc contradicting the code is a defect. It MUST be fixed or deleted, not left standing.
- MUST NOT leave a doc describing a removed feature.

## Comments

- Comment explains why, not what. SHOULD.
- MUST NOT leave commented-out code. Git has history. See [GIT.md](GIT.md).
- Stale comment MUST be updated or deleted with the code it describes.
- Non-obvious workaround MUST carry a comment naming the cause, and a link to the issue when one exists.

## Decision records

Architecture decision with lasting effect SHOULD get a short record under `docs/decisions/`.

One record holds: context, decision, alternatives rejected, consequences. Keep it under one page.

Superseded record MUST NOT be edited into a lie. Mark it superseded and link the replacement.
