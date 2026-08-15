# Plugins and Tooling Standards

This file defines approved or recommended engineering tools and agent plugins.

## General rules

- Prefer existing repository tooling over introducing alternatives.
- Do not install a new tool that duplicates an existing capability without a clear reason.
- Pin versions when reproducibility matters.
- Review permissions before enabling plugins with repository, shell, cloud, or secret access.
- Treat agent plugins as executable tooling, not passive documentation.

## Caveman

Plugin:

```text
juliusbrussee/caveman
```

Purpose:

- concise agent behavior;
- direct execution-oriented responses;
- reduced conversational noise;
- practical engineering workflow assistance.

Recommended usage:

- use for focused coding and repository tasks;
- combine with repository-specific `AGENTS.md` rules;
- never allow plugin behavior to override security, legal, or repository-specific constraints.

## JavaScript / TypeScript

Recommended baseline:

```text
TypeScript
ESLint
Prettier
Vitest or Jest
```

Choose one formatter and one primary lint strategy per repository.

## Python

Recommended baseline:

```text
Ruff
Pytest
mypy or pyright when static typing is enforced
```

## AI coding tools

Examples:

```text
OpenAI Codex
Claude Code
GitHub Copilot
```

Rules:

- agents must follow the same code review and testing standards as human contributors;
- generated code is not exempt from review;
- never provide secrets to a tool unless explicitly approved and required;
- repository write permissions should follow least privilege.
