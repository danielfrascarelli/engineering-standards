# Engineering Standards

Central rules for every repository in this workspace.

One source of truth. No copy/paste drift. Every repo consumes same rules.

## Layout

```text
engineering-standards/
├── AGENTS.md                     # rules for AI agents and automated contributors
├── README.md                     # this file: model, precedence, consumption
├── standards/
│   ├── CHECKS.md                 # canonical validation check names
│   ├── CONTRIBUTING.md           # contributor workflow
│   ├── DELIVERY.md               # CI pipeline, containers, deploy safety
│   ├── DEPENDENCIES.md           # dependency intake, licenses, pinning, patching
│   ├── DOCUMENTATION.md          # documentation rules
│   ├── GIT.md                    # branches, commits, merge, protected branches
│   ├── PR.md                     # pull request rules
│   ├── RELEASES.md               # versioning, tags, release notes
│   ├── SECURITY.md               # mandatory security rules
│   └── TESTING.md                # test strategy
├── stacks/
│   ├── NESTJS.md
│   ├── NODE.md
│   ├── PYTHON.md
│   └── REACT.md
├── tooling/
│   └── PLUGINS.md                # approved tools and agent plugins
├── scripts/
│   ├── sync-standards.sh         # copy standards into consuming repo
│   ├── validate-standards.sh     # enforce this repo's own rules
│   └── hooks/                    # reference git hooks for consuming repos
│       ├── commit-msg            # rejects AI-agent trailers
│       ├── install.sh
│       └── pre-push              # rejects commits with the wrong author
└── .github/
    ├── CODEOWNERS
    ├── pull_request_template.md
    └── workflows/
        └── validate-standards.yml
```

`AGENTS.md` stays at root. Agent tooling looks for it there.

## Rule strength

Every rule carries one keyword. Keyword decides what happens when rule is inconvenient.

| Keyword | Meaning |
| --- | --- |
| MUST, MUST NOT | Mandatory. Violation blocks merge. Needs declared override to bypass. |
| SHOULD, SHOULD NOT | Default. Deviate only with reason written in PR description. |
| MAY | Allowed. No preference. |

MUST rules in [SECURITY.md](standards/SECURITY.md) are never overridable.

Never write a rule without a keyword. Keywordless prose is guidance, not standard.

## Ownership map

One topic, one owner file. Other files link. They MUST NOT restate.

| Topic | Owner |
| --- | --- |
| Check names, when checks run | [standards/CHECKS.md](standards/CHECKS.md) |
| CI pipeline shape, gate integrity, containers, deploy safety | [standards/DELIVERY.md](standards/DELIVERY.md) |
| Secrets, authorization, crypto, log redaction | [standards/SECURITY.md](standards/SECURITY.md) |
| Dependency intake, licenses, pinning, vulnerability patching | [standards/DEPENDENCIES.md](standards/DEPENDENCIES.md) |
| Branches, commit format, merge, protected branches | [standards/GIT.md](standards/GIT.md) |
| PR size, description fields, review, approvals | [standards/PR.md](standards/PR.md) |
| Test strategy, coverage stance | [standards/TESTING.md](standards/TESTING.md) |
| Human contributor workflow | [standards/CONTRIBUTING.md](standards/CONTRIBUTING.md) |
| Agent-only rules | [AGENTS.md](AGENTS.md) |
| Documentation expectations | [standards/DOCUMENTATION.md](standards/DOCUMENTATION.md) |
| Versioning, tags, release notes | [standards/RELEASES.md](standards/RELEASES.md) |
| Approved tools and plugins | [tooling/PLUGINS.md](tooling/PLUGINS.md) |
| Stack rules | [stacks/](stacks/) |

Found same rule in two files? That is a bug. Delete duplicate, keep link to owner.

## Precedence

Apply in this order. Lower number wins.

1. Security and legal MUST rules. Never overridable.
2. Repo-specific rule that **declares an explicit override**.
3. Stack standards, `stacks/`.
4. Global standards, `standards/` and `AGENTS.md`.
5. Tool defaults.

Explicit override means local `AGENTS.md` names central rule it replaces, plus reason:

```md
## Overrides

- Replaces standards/GIT.md "Rebase local feature work when it improves history clarity".
  This repo forbids rebase. Reason: feature branches are shared between three teams.
```

Repo rule that does not declare an override does not win. Undeclared conflict resolves to central rule.

Security MUST rules stay in force regardless of any declared override.

## Consuming repo

Keep only project-specific facts and declared overrides locally. Do not duplicate central rules.

Recommended local `AGENTS.md`:

```md
# Project Agent Rules

Central standards apply first. See .standards/README.md for precedence.

Project facts:
- Runtime: Node.js 22
- Package manager: pnpm
- Test runner: Vitest
- Deployment target: AWS Lambda
- Database: PostgreSQL

Git identity (see .standards/standards/GIT.md, "Authorship"):
- user.name:  danielfrascarelli
- user.email: dsanfra@gmail.com
- gh account: danielfrascarelli

Checks (see .standards/standards/CHECKS.md):
- format: pnpm format:check
- lint: pnpm lint
- typecheck: pnpm typecheck
- test: pnpm test
- build: pnpm build
- security: pnpm audit --audit-level=high

## Overrides
(none)
```

## Consumption strategies

### Option A, git submodule

Pin standards revision per repo:

```bash
git submodule add https://github.com/danielfrascarelli/engineering-standards.git .standards
```

Agents then read `.standards/AGENTS.md`, `.standards/standards/GIT.md`, `.standards/stacks/NODE.md`.

Use when you want explicit version pinning.

### Option B, sync script

Copy selected files into consuming repo:

```bash
./scripts/sync-standards.sh --target /path/to/my-app
```

Script writes generated copies under `.standards/` in target repo. Every generated file starts with:

```md
<!-- GENERATED FILE. DO NOT EDIT DIRECTLY. Source: engineering-standards@<rev> -->
```

Generated rule files ARE committed in consuming repo. This is the declared exception to the build-artifact rule in [standards/GIT.md](standards/GIT.md).

Use when agents need rules physically present.

### Option C, CI validation

[.github/workflows/validate-standards.yml](.github/workflows/validate-standards.yml) validates this repo. Consuming repos SHOULD run an equivalent job that fails when:

- required standards files are missing;
- generated rule files are stale against pinned revision;
- local rule overrides a central rule without an `## Overrides` entry;
- a security MUST rule was removed locally.

## Stack document template

Every file in `stacks/` MUST use this section order. Missing section means stack doc is incomplete.

```md
# <Stack> Standards
## Runtime and version
## Language and types
## Project structure
## Lint and format
## Errors
## Logging
## Security notes
## Testing
```

Extra sections MAY be added where they fit. The eight above MUST still appear, in this relative order.

Stack docs MUST NOT restate global rules. Link to owner instead.

`scripts/validate-standards.sh` enforces this.

## Updating standards

1. Change rule here.
2. Review like production code. See [standards/PR.md](standards/PR.md).
3. Merge.
4. Bump consuming repos: submodule pointer, or rerun sync script.
5. Never copy/paste by hand.

Rule change that tightens a MUST is a breaking change. See [standards/RELEASES.md](standards/RELEASES.md).

## Rule design principles

Good rule is:

- explicit;
- carries a strength keyword;
- testable when possible;
- short enough for human and agent;
- owned by exactly one file;
- opinionated where consistency matters.

Bad rule: "write clean code". No keyword, no owner, no test. Delete it.
