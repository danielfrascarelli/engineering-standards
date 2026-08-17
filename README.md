# Engineering Standards

Central rules for every repository in this workspace.

One source of truth. No copy/paste drift. Every repo consumes same rules.

This repository is versioned, and it is pre-1.0: a MINOR release MAY break a consuming repo. Tags,
release flow, and what counts as MAJOR here: [standards/RELEASES.md](standards/RELEASES.md). Released
versions: [CHANGELOG.md](CHANGELOG.md).

## Layout

```text
engineering-standards/
├── AGENTS.md                     # rules for AI agents and automated contributors
├── CHANGELOG.md                  # released versions, updated in the release PR
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
│   ├── PYTHON_ML.md              # extends PYTHON.md, for services that ship a model
│   └── REACT.md
├── tooling/
│   └── PLUGINS.md                # approved tools and agent plugins
├── docs/
│   ├── workspace-setup.md        # example local setup, not a requirement
│   └── examples/
│       └── validate-consumer-standards.yml   # copy into a consuming repo; not run here
├── scripts/
│   ├── sync-standards.sh              # copy standards into consuming repo
│   ├── validate-standards.sh          # enforce this repo's own rules
│   ├── validate-consumer-standards.sh # enforce them in a consuming repo
│   ├── check-pr-body.sh               # rejects agent traces in a PR body
│   ├── test-agent-trailers.sh         # fixtures for the trailer pattern
│   └── hooks/                         # reference git hooks for consuming repos
│       ├── commit-msg                 # rejects AI-agent trailers
│       ├── install.sh
│       ├── pre-push                   # rejects commits with the wrong author
│       └── lib/
│           └── agent-trailers.sh      # the one definition of the pattern
├── .githooks/                    # this repo's installed copy of scripts/hooks/
└── .github/
    ├── CODEOWNERS
    ├── pull_request_template.md
    └── workflows/
        └── validate-standards.yml
```

`AGENTS.md` MUST stay at the repository root. Agent tooling looks for it there.

Note: `.githooks/` is a copy of `scripts/hooks/`, written by `scripts/hooks/install.sh`. `scripts/validate-standards.sh` fails when the two diverge, so the copy cannot rot.

## Rule strength

Every rule carries one keyword. Keyword decides what happens when rule is inconvenient.

| Keyword | Meaning |
| --- | --- |
| MUST, MUST NOT | Mandatory. Violation blocks merge. Needs declared override to bypass. |
| SHOULD, SHOULD NOT | Default. Deviate only with reason written in PR description. |
| MAY | Allowed. No preference. |

MUST rules in [SECURITY.md](standards/SECURITY.md) are never overridable.

Every normative rule MUST contain MUST, MUST NOT, SHOULD, SHOULD NOT, or MAY.

Explanatory prose is allowed and useful, but it MUST be marked `Note:` so a reader never has to guess whether a sentence binds them. Headings, tables, code blocks, and examples are not rules and need no keyword.

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
| Read order, which documents apply to a change | this file, ["Read order"](#read-order) |
| Local workspace setup, plugin install commands | [docs/workspace-setup.md](docs/workspace-setup.md) |
| Agent-only rules | [AGENTS.md](AGENTS.md) |
| Documentation expectations, prose language | [standards/DOCUMENTATION.md](standards/DOCUMENTATION.md) |
| Versioning, tags, release notes | [standards/RELEASES.md](standards/RELEASES.md) |
| Approved tools and plugins | [tooling/PLUGINS.md](tooling/PLUGINS.md) |
| Stack rules | [stacks/](stacks/) |

Found the same rule in two files? That is a bug. The duplicate MUST be deleted and replaced by a link to the owner.

## Read order

Owner of this topic: this file. [AGENTS.md](AGENTS.md) and [standards/CONTRIBUTING.md](standards/CONTRIBUTING.md) link here. They MUST NOT state an order of their own.

Note: three documents used to open with three different "read this first" instructions. One order, in one place, is the fix. A separate entry-point file would be a fourth location, which is the failure mode this repo already forbids for git identity.

Read in this order:

1. Repository-root `AGENTS.md` — project facts, git identity, declared overrides, and the `Applicable standards` map. MUST.
2. `.standards/README.md`, this file — precedence and rule strength only. MUST.
3. `.standards/standards/CONTRIBUTING.md` — workflow from task to merged change. MUST.
4. The documents the `Applicable standards` map selects for the paths this change touches. MUST.

### Selecting documents

Reading every standard for every change is how agents burn context and cite irrelevant rules. Selection is driven by changed paths, declared in the consuming repo.

- For each changed file, load the documents its path maps to. MUST.
- MUST NOT load a stack document that no changed path maps to. A change under `services/ml/` does not load `REACT.md`.
- A path mapped to REACT MUST also load NODE. React runs on the Node toolchain; the reverse does not hold.
- A change touching authentication, secrets, external input, or cryptography MUST also load [SECURITY.md](standards/SECURITY.md), whatever its path.
- Map missing, or a changed path matches no entry? Say so and ask. MUST NOT guess which stack applies.

Standards not present at `.standards/`? Say so. MUST NOT invent rules to fill the gap.

## Precedence

Apply in this order. Lower number wins.

1. Security and legal MUST rules. Never overridable.
2. Repo-specific rule that **declares an explicit override**.
3. Stack standards, `stacks/`.
4. Global standards, `standards/` and `AGENTS.md`.
5. Tool defaults.

Within level 3, the more specific stack document wins. A document declaring "Extends X" narrows X; where the two disagree, the extending document is the rule. `REACT.md` allowing only Vitest beats `NODE.md` allowing Vitest or Jest, for a React repo. The extending document MUST NOT loosen a MUST it inherits — only narrow it.

Explicit override means the local `AGENTS.md` names the central rule it replaces, plus a reason. The shape is fixed so CI can check it: `Replaces <file> "<rule>"`, and a `Reason:`.

```md
## Overrides

- Replaces standards/GIT.md "Rebase local feature work when it improves history clarity".
  This repo forbids rebase. Reason: feature branches are shared between three teams.
```

An override MUST name the file, quote the rule it replaces, and give a `Reason:`. `scripts/validate-consumer-standards.sh` fails the build otherwise.

A repo with no overrides MUST still carry the section, reading `(none)`. An absent section and a forgotten one look identical.

Repo rule that does not declare an override does not win. Undeclared conflict resolves to central rule.

Security MUST rules stay in force regardless of any declared override.

## Consuming repo

Keep only project-specific facts and declared overrides locally. Do not duplicate central rules.

Required local `AGENTS.md`:

```md
# Project Agent Rules

Central standards apply first. See .standards/README.md for read order and precedence.

Project facts:
- Runtime: Node.js 22
- Package manager: pnpm
- Test runner: Vitest
- Deployment target: AWS Lambda
- Database: PostgreSQL

Git identity (see .standards/standards/GIT.md, "Authorship"):
- user.name:  danielfrascarelli
- user.email: dsanfra@gmail.com
- gh account: danielfrascarelli   # pull request author, not checked by git hooks

## Applicable standards

- `services/api/**`: NODE
- `apps/web/**`: NODE, REACT
- `services/ml/**`: PYTHON, PYTHON_ML
- Root dependency and lock files: DEPENDENCIES
- CI and workflow files: CHECKS, GIT, DELIVERY
- Auth, secrets, external input, crypto, wherever they live: SECURITY

Checks (see .standards/standards/CHECKS.md):
- format: pnpm format:check
- lint: pnpm lint
- typecheck: pnpm typecheck
- test: pnpm test
- build: pnpm build
- security: pnpm security
  Runs: pnpm audit --audit-level=high && gitleaks detect --source . --redact

## Overrides
(none)
```

Every consuming repo MUST carry the `Applicable standards` map. Without it, "the standards relevant to this change" is not a decidable statement and an agent picks by guess. Selection rules: ["Read order"](#read-order).

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

[.github/workflows/validate-standards.yml](.github/workflows/validate-standards.yml) validates this repo.

Consuming repos SHOULD run [scripts/validate-consumer-standards.sh](scripts/validate-consumer-standards.sh). It fails when:

- the standards directory or a required document is missing;
- `SOURCE_REV` is missing, empty, or records a dirty source tree;
- a generated document lost its `GENERATED FILE` header, which is what a hand edit looks like;
- `SOURCE_REV` is stale against the central standards;
- a security MUST rule was removed from the local copy;
- an `## Overrides` entry does not name the rule it replaces and give a `Reason:`.

```bash
./scripts/validate-consumer-standards.sh \
  --target "$GITHUB_WORKSPACE" \
  --dest .standards \
  --source "$GITHUB_WORKSPACE/.engineering-standards"
```

Copy-ready workflow: [docs/examples/validate-consumer-standards.yml](docs/examples/validate-consumer-standards.yml). It lives under `docs/` on purpose. GitHub runs every `.yml` under `.github/workflows/`, whatever the filename says, so an example kept there is not an example — it is a job this repo runs against a `.standards/` directory it does not have.

Note: the script detects which consumption option is in use. Submodule consumers have no `SOURCE_REV` and no generated headers, so those checks are skipped rather than failed, and the pinned commit is compared instead. Without `--source`, staleness and rule removal are reported as skipped, never as passed.

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

1. Change the rule here. MUST NOT change it first in a consuming repo.
2. Review like production code. See [standards/PR.md](standards/PR.md).
3. Merge.
4. Bump consuming repos: submodule pointer, or rerun the sync script.
5. MUST NOT copy/paste by hand.

Rule change that tightens a MUST is a breaking change. See [standards/RELEASES.md](standards/RELEASES.md).

## Rule design principles

Good rule is:

- explicit;
- carries a strength keyword;
- testable when possible;
- short enough for human and agent;
- owned by exactly one file;
- opinionated where consistency matters.

Note: a bad rule looks like "write clean code" — no keyword, no owner, no test. A rule like that MUST be deleted or rewritten.
