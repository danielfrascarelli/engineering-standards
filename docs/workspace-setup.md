# Example workspace setup

Not required by consuming repositories. Nothing here is a standard, and no CI job checks it.

This records how one local workspace is configured, so a new machine can be brought to the same state quickly. The portable rules — which plugins are allowed, what review a plugin needs — live in [../tooling/PLUGINS.md](../tooling/PLUGINS.md).

## Agent plugins

Both plugins are on the allowlist in [../tooling/PLUGINS.md](../tooling/PLUGINS.md).

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

## Git hooks

Hooks are per clone and per worktree. A fresh clone has none until this runs:

```bash
./scripts/hooks/install.sh
```

In a consuming repo, run the copy under `.standards/`:

```bash
./.standards/scripts/hooks/install.sh
```

That is also why CI repeats the same checks. See [../standards/GIT.md](../standards/GIT.md), "Authorship".

## Secret scanner

The `security` check needs a scanner on PATH. See [../standards/CHECKS.md](../standards/CHECKS.md).

```bash
# Debian/Ubuntu
sudo apt-get install -y gitleaks

# macOS
brew install gitleaks
```
