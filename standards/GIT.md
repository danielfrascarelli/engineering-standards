# Git Standards

Owner: branches, commit format, merge strategy, protected branches, what enters history.

## Default branches

Every repo MUST have two long-lived branches:

| Branch | Holds | Protected |
| --- | --- | --- |
| `main` | production: what is deployed, or deployable, right now | yes |
| `develop` | development: finished work accumulating between releases | yes |

- Both MUST be protected. Direct push to either MUST be disabled.
- Every change to either MUST arrive through a pull request. MUST NOT commit directly to `main` or to `develop`.
- `master` is legacy only. MUST NOT create a new `master`.
- Feature work MUST branch off `develop` and merge back into `develop`.
- `develop` reaches `main` through a release pull request. See [RELEASES.md](RELEASES.md).
- `hotfix/` MUST branch off `main` and MUST merge into both `main` and `develop`. A hotfix landing only in `main` is reintroduced by the next release.
- Where another standard says "integration branch", it means `develop`.

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

Every prefix above branches off `develop`, except `hotfix/`, which branches off `main`.

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

- Commit messages MUST be written in English. Owner of the language rule for commits: this file. Documentation and prose: [DOCUMENTATION.md](DOCUMENTATION.md). Code comments and user-facing copy: the repo's own `AGENTS.md`.
- One commit, one logical intention. MUST.
- Commit SHOULD build on its own.
- MUST NOT mix formatting-only change with behavior change.
- Subject in imperative mood, no trailing period. SHOULD.

## Authorship

Every repo declares one git identity for its commits and pull requests. Identity is not always the same across repos, so it MUST be declared per repo, never assumed.

Three layers. Each has a distinct job. None is sufficient alone.

| Layer | Job | Where |
| --- | --- | --- |
| Declaration | states the identity, travels with the repo | repo `AGENTS.md`, project-facts block |
| Application | makes commits actually carry it | `git config` at repo level |
| Enforcement | stops a wrong commit | committed `.githooks/`, plus a CI check |

### Declaration

Repo `AGENTS.md` MUST carry a `Git identity` block. The values below are an example of the shape, not the identity every repo uses:

```md
Git identity:
- user.name:  danielfrascarelli
- user.email: dsanfra@gmail.com
- gh account: danielfrascarelli
```

Identity differs between repos. MUST NOT copy another repo's block forward. MUST read the block from the repo being worked on, and MUST verify the local `git config` against it before the first commit — see "Application" below. That verification is the point of the declaration; the values themselves are per repo.

MUST NOT invent a separate file for this. A fourth location nothing reads drifts.

### Application

- Identity MUST be set at repo level: `git config user.name` and `git config user.email`.
- A global git config MUST NOT be relied on. It is wrong the moment a second repo uses a different identity.
- Identity MUST be verified before the first commit in a new clone or worktree. `git worktree add` does not carry local config or untracked files.

### Enforcement

- Hooks MUST be committed under `.githooks/` and installed with `git config core.hooksPath .githooks`, exposed as a `hooks:install` script.
- `commit-msg` MUST reject AI-agent trailers. `pre-push` MUST reject a commit whose author is not the declared identity.
- `core.hooksPath` is per clone and opt-in, so CI MUST run the same two checks. A hook alone is not a gate.
- Reference implementations: [../scripts/hooks/](../scripts/hooks/).

### No agent traces

Commit messages and PR bodies MUST NOT contain:

- `Co-Authored-By:` naming an AI agent or assistant;
- an agent session link, including `claude.ai/code` URLs;
- a "Generated with ..." footer naming a tool.

Commits carry the declared human identity. Tooling used to produce a change is not authorship, and a trailer naming it makes history harder to read and to attribute.

This applies to agents. See [../AGENTS.md](../AGENTS.md).

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

Always protected:

```text
main
develop
release/*
```

Rules:

- Direct push to a protected branch MUST be disabled.
- Every change to a protected branch MUST arrive through a pull request. Approval count and review rules: [PR.md](PR.md).
- Break-glass direct push MAY be allowed for an active incident. It MUST be logged and followed by a retroactive PR.
