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

## Authorship

Every repo declares one git identity for its commits and pull requests. Identity is not always the same across repos, so it MUST be declared per repo, never assumed.

Three layers. Each has a distinct job. None is sufficient alone.

| Layer | Job | Where |
| --- | --- | --- |
| Declaration | states the identity, travels with the repo | repo `AGENTS.md`, project-facts block |
| Application | makes commits actually carry it | `git config` at repo level |
| Enforcement | stops a wrong commit | committed `.githooks/`, plus a CI check |

### Declaration

Repo `AGENTS.md` MUST carry a `Git identity` block:

```md
Git identity:
- user.name:  danielfrascarelli
- user.email: dsanfra@gmail.com
- gh account: danielfrascarelli   # pull request author, not checked by git hooks
```

`user.name` and `user.email` are the enforced pair. `gh account` records who opens pull requests and pushes; git carries no such field, so no hook can check it. A rule that claims otherwise is a rule nothing enforces. Enforce it, when a repo needs it, with a CI step reading `github.event.pull_request.user.login` against a separately declared list of allowed pull request authors. MUST NOT state or imply that a git hook validates it.

MUST NOT invent a separate file for this. A fourth location nothing reads drifts.

### Application

- Identity MUST be set at repo level: `git config user.name` and `git config user.email`.
- A global git config MUST NOT be relied on. It is wrong the moment a second repo uses a different identity.
- Identity MUST be verified before the first commit in a new clone or worktree. `git worktree add` does not carry local config or untracked files.

### Enforcement

- Hooks MUST be committed under `.githooks/` and installed with `git config core.hooksPath .githooks`.
- Installation MUST be one documented command. A repo whose stack has a script runner SHOULD expose it as `hooks:install`; one whose stack has none MUST document the script path instead. Installing hooks MUST NOT require a package manager the repo does not otherwise use.
- `commit-msg` MUST reject AI-agent trailers. `pre-push` MUST reject a commit whose author name or author email is not the declared identity.
- Committer MAY differ from author when the hosting platform performed the merge. A platform merge rewrites the committer, never the author, so the author check is the one that carries the rule.
- Identity checks MUST apply to the commits a push or pull request introduces, not to the whole history. A repo adopting this rule keeps its existing history; rewriting history to satisfy a new rule breaks every clone and every open branch.
- `core.hooksPath` is per clone and opt-in, so CI MUST run the same checks. A hook alone is not a gate.
- The pattern of forbidden trailers MUST have one definition shared by hook and CI. Two copies drift, and the drift always favours the trailer.
- Reference implementations: [../scripts/hooks/](../scripts/hooks/). Fixtures: [../scripts/test-agent-trailers.sh](../scripts/test-agent-trailers.sh).

### No agent traces

Commit messages and PR bodies MUST NOT contain:

- `Co-Authored-By:` naming an AI agent or assistant;
- an agent session link, including `claude.ai/code` URLs;
- a "Generated with ..." footer naming a tool.

Note: commits carry the declared human identity. Tooling used to produce a change is not authorship, and a trailer naming it makes history harder to read and to attribute.

Enforcement is split, because the two halves are visible to different things:

| Surface | Gate |
| --- | --- |
| Commit message | `commit-msg` hook, plus the same check in CI |
| Pull request title and body | CI step reading the pull request event payload |

A git hook cannot see a pull request body. CI MUST check it, or the rule is mandatory on paper for half its surface. Reference: [../scripts/check-pr-body.sh](../scripts/check-pr-body.sh).

A `Co-Authored-By:` trailer naming a human co-author stays allowed. Only the patterns listed above are rejected.

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
- The environment template, when the repo reads environment variables. Rule owner: [SECURITY.md](SECURITY.md).
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
