# Git Standards

Owner: branches, commit format, merge strategy, protected branches, what enters history.

## Default branch

New repo MUST use `main`. `master` is legacy only. MUST NOT create new `master`.

## Branches

One prefix per branch. Prefix maps to the commit type it produces:

| Prefix | Use | Commit type |
| --- | --- | --- |
| `feat/` | new capability | `feat` |
| `fix/` | bug fix | `fix` |
| `hotfix/` | urgent production fix | `fix` |
| `refactor/` | behavior-preserving restructure | `refactor` |
| `perf/` | performance work | `perf` |
| `docs/` | documentation only | `docs` |
| `test/` | tests only | `test` |
| `chore/` | maintenance | `chore` |
| `ci/` | pipeline config | `ci` |
| `build/` | build system, packaging, dependency bumps | `build` |

`hotfix/` is a branch prefix only. Conventional Commits has no `hotfix` type. Hotfix commits MUST use `fix`.

Names MUST be lowercase, hyphen-separated, short:

```text
feat/user-profile
fix/token-refresh
hotfix/payment-timeout
refactor/payment-service
```

## Commits

Commits MUST use Conventional Commits.

```text
<type>(<optional scope>): <subject>
```

Allowed types: `feat`, `fix`, `refactor`, `perf`, `docs`, `test`, `chore`, `ci`, `build`, `style`, `revert`.

```text
feat: add profile image upload
fix: prevent duplicate invoice creation
refactor: isolate payment validation
chore: update lint configuration
```

Breaking change MUST be declared, either `feat!:` or footer:

```text
BREAKING CHANGE: removes v1 auth endpoint
```

Rules:

- One commit, one logical intention. MUST.
- Commit SHOULD build on its own.
- MUST NOT mix formatting-only change with behavior change.
- Subject in imperative mood, no trailing period. SHOULD.

## Before push

Run checks required at push time. Names and commands: [CHECKS.md](CHECKS.md).

MUST NOT push with a failing required check.

## What MUST NOT enter history

- Secrets of any kind. Owner of the rule: [SECURITY.md](SECURITY.md).
- Editor state, local IDE config, OS junk files.
- Generated build artifacts, unless repo declares it needs them committed.

## What MUST enter history

- Lockfiles. See [DEPENDENCIES.md](DEPENDENCIES.md).
- `.env.example` with placeholder values only, never real values. See [SECURITY.md](SECURITY.md).
- Generated standards files written by the sync script. Declared exception to the build-artifact rule above. Each carries the `GENERATED FILE` header. See [../README.md](../README.md).

Secret leaked into history? Follow the incident steps in [SECURITY.md](SECURITY.md). Do not just delete the line.

## Rebase and merge

- Rebase local feature work when it improves history clarity. MAY.
- MUST NOT rewrite history of a shared or protected branch.
- MUST NOT force-push a branch someone else has pulled. Use `--force-with-lease` on your own branch only.
- Avoid merge commits inside a short-lived feature branch. SHOULD.
- Resolve conflicts deliberately. MUST NOT accept all incoming or all current blindly.

## Protected branches

Typically protected:

```text
main
production
release/*
```

Rules:

- Direct push to a protected branch MUST be disabled.
- Every change to a protected branch MUST arrive through a pull request. Approval count and review rules: [PR.md](PR.md).
- Break-glass direct push MAY be allowed for an active incident. It MUST be logged and followed by a retroactive PR.
