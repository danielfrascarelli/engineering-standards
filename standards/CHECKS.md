# Validation Checks

Canonical check names. Every other standard references these names. Repos MUST NOT rename them.

Owner of this topic: this file. No other document defines its own check list.

## The six checks

| Check | What it does |
| --- | --- |
| `format` | Formatter in check mode. Fails on unformatted code. |
| `lint` | Linter. Fails on static rule violations. |
| `typecheck` | Type checker. Fails on type errors. |
| `test` | Test runner. Fails on regressions. |
| `build` | Build command. Fails when artifact does not compile or bundle. |
| `security` | Dependency audit plus secret scan. Fails on known critical vulnerability or leaked secret. Both operations MUST run. See ["The security check"](#the-security-check). |

## When each check runs

Which checks are required at each moment. The order they run in is owned by [DELIVERY.md](DELIVERY.md); the listing below is not one.

| Moment | Required |
| --- | --- |
| Before commit | `format`, `lint` |
| Before push | `format`, `lint`, `typecheck`, `test`, `build` |
| Before requesting review | all six |
| CI on pull request | all six |

## Per-stack commands

Repos MUST expose the six under stable script names. Reference implementations:

| Check | Node, React | Python |
| --- | --- | --- |
| `format` | `npm run format:check` | `ruff format --check .` |
| `lint` | `npm run lint` | `ruff check .` |
| `typecheck` | `npm run typecheck` | `mypy .` or `pyright` |
| `test` | `npm test` | `pytest` |
| `build` | `npm run build` | `python -m build` |
| `security` | `npm run security` | `make security` |

Note: `security` is one repository command on purpose. It wraps two operations, and a table cell holding only the dependency audit is how the secret scan went missing.

## The security check

`security` MUST:

1. run a dependency audit;
2. run a secret scanner over the repository;
3. exit non-zero when either operation fails.

A repo MUST declare what its `security` command wraps, in its local `AGENTS.md`:

```md
Checks:
- security: npm run security
  Runs: npm audit --audit-level=high && gitleaks detect --source . --redact
```

Scanner choice is the repo's. `gitleaks`, `trufflehog`, and a platform-provided scanner are all acceptable. MUST NOT count a platform scanner that only reports after merge: the check has to fail before the merge.

Secret-scanning rules and the incident procedure are owned by [SECURITY.md](SECURITY.md).

Reference wrappers:

```json
{ "scripts": { "security": "npm audit --audit-level=high && gitleaks detect --source . --redact" } }
```

```makefile
security:
	pip-audit
	gitleaks detect --source . --redact
```

## Rules

- Repo MUST expose all six, or declare in its local `AGENTS.md` which check does not apply and why.
- Check MUST NOT be marked passed unless it ran. See [AGENTS.md](../AGENTS.md).
- Could not run a check? MUST name the check and the reason. Silence is not allowed.
- Check fails? Fix cause. MUST NOT disable test, delete assertion, weaken lint rule, or add blanket ignore to force green.
- Narrow, commented suppression MAY be used when tool is wrong. Blanket file-level or repo-level suppression MUST NOT.
- `security` failure on a critical vulnerability blocks merge. See [SECURITY.md](SECURITY.md).

## Related

- [AGENTS.md](../AGENTS.md) — agent validation duties
- [GIT.md](GIT.md) — checks before push
- [PR.md](PR.md) — checks before review
- [CONTRIBUTING.md](CONTRIBUTING.md) — workflow position
