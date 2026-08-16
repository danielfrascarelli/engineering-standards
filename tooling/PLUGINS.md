# Plugins and Tooling Standards

Owner: approved agent plugins, AI tool policy, tool intake.

Stack toolchains are not here. They live with each stack: [../stacks/](../stacks/).
Library and package rules are not here. They live in [../standards/DEPENDENCIES.md](../standards/DEPENDENCIES.md).

## Tool intake

- SHOULD prefer existing repo tooling over introducing an alternative.
- MUST NOT install a tool that duplicates an existing capability without a stated reason.
- MUST review permissions before enabling a plugin with repository, shell, cloud, or secret access.
- MUST treat an agent plugin as executable tooling, not passive documentation.
- Plugin version pinning follows [../standards/DEPENDENCIES.md](../standards/DEPENDENCIES.md).

## Approved agent plugins

These are installed in every workspace. Not examples — the actual set.

| Plugin | Marketplace | Purpose |
| --- | --- | --- |
| `caveman` | `JuliusBrussee/caveman` | terse agent output, less conversational noise |
| `frontend-design` | `claude-plugins-official` | visual design guidance for UI work |

Install:

```bash
claude plugin marketplace add JuliusBrussee/caveman
claude plugin install caveman@caveman

claude plugin install frontend-design@claude-plugins-official
```

Resulting `~/.claude/settings.json` fragment:

```json
{
  "enabledPlugins": {
    "caveman@caveman": true,
    "frontend-design@claude-plugins-official": true
  },
  "extraKnownMarketplaces": {
    "caveman": {
      "source": { "source": "github", "repo": "JuliusBrussee/caveman" }
    }
  }
}
```

Rules:

- Plugin output style MUST NOT override a security, legal, or repo-specific constraint.
- Plugin behavior MUST NOT change what gets committed, only how the agent speaks.
- Adding a plugin to this table needs a PR. See [../standards/PR.md](../standards/PR.md).

## Approved AI coding tools

```text
Claude Code
```

Other tools MAY be used for exploration. Committing their output makes them subject to every rule here.

Rules:

- Generated code MUST pass the same review, checks, and tests as hand-written code. See [../standards/CHECKS.md](../standards/CHECKS.md).
- Generated code is never exempt from review. MUST.
- MUST NOT give a tool a secret unless it is approved and required. See [../standards/SECURITY.md](../standards/SECURITY.md).
- Repository write permission for a tool MUST follow least privilege. No token with protected-branch write.
- Agent duties: [../AGENTS.md](../AGENTS.md).
