# Engineering Standards

Centralized engineering rules for all repositories in an organization or personal workspace.

The goal is simple: keep shared rules in one place, avoid copy/paste drift, and make every repository consume the same source of truth.

## What this repository contains

- `AGENTS.md` — universal rules for AI coding agents and automated contributors.
- `GIT.md` — branch, commit, rebase, merge, and repository hygiene rules.
- `SECURITY.md` — non-negotiable security rules.
- `TESTING.md` — testing philosophy and minimum expectations.
- `PR.md` — pull request creation and review rules.
- `PLUGINS.md` — approved tools, plugins, and agent integrations, including `juliusbrussee/caveman`.
- `CONTRIBUTING.md` — contributor workflow and repository expectations.
- `DEPENDENCIES.md` — dependency management rules.
- `DOCUMENTATION.md` — documentation standards.
- `RELEASES.md` — versioning and release conventions.
- `stacks/REACT.md` — React-specific standards.
- `stacks/NODE.md` — Node.js-specific standards.
- `stacks/PYTHON.md` — Python-specific standards.

## Source of truth model

Keep global rules here. Keep only project-specific exceptions inside each application repository.

Example application repository:

```text
my-app/
├── AGENTS.md
├── README.md
├── package.json
└── src/
```

Recommended local `AGENTS.md`:

```md
# Project Agent Rules

Apply the central engineering standards first.

Project-specific rules:
- Runtime: Node.js 22
- Package manager: pnpm
- Test runner: Vitest
- Deployment target: AWS Lambda
- Database: PostgreSQL

Local rules override central rules only when explicitly stated.
```

## Recommended consumption strategies

### Option A — Git submodule

Add this repository under a predictable path:

```bash
git submodule add <engineering-standards-repo-url> .standards
```

Then tools and agents can read:

```text
.standards/AGENTS.md
.standards/GIT.md
.standards/stacks/REACT.md
```

Use this when you want explicit version pinning per repository.

### Option B — Sync script

Maintain a small script that pulls selected files from this repository and generates local copies.

Generated files should begin with:

```md
<!-- GENERATED FILE. DO NOT EDIT DIRECTLY. -->
```

Use this when agents require rules to exist physically inside each repository.

### Option C — CI validation

Add CI that verifies repositories are using the expected standards revision.

The CI job should fail when:
- required standards are missing;
- generated rule files are stale;
- a local rule silently overrides a central mandatory rule;
- security requirements are removed.

## Precedence

Use this order:

1. Security and legal requirements.
2. Explicit repository-specific rules.
3. Stack-specific standards.
4. Global engineering standards.
5. Tool defaults.

Project-specific rules should be minimal. Do not duplicate central rules locally.

## Updating standards

1. Change the rule here.
2. Review the change like production code.
3. Merge it.
4. Update consuming repositories automatically or intentionally.
5. Avoid manual copy/paste.

## Rule design principles

Good rules are:
- explicit;
- testable when possible;
- short enough to be read by humans and agents;
- technology-aware;
- free of duplicated guidance;
- opinionated where consistency matters.

Avoid vague rules such as "write clean code". Prefer rules that can guide a concrete decision.
