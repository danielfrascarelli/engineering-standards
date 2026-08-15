#!/usr/bin/env bash
#
# Copy the reference hooks into a repo's .githooks/ and point git at them.
#
# Run from the consuming repo, or pass --target.
#
# Rule: standards/GIT.md, "Authorship".
#
set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$(pwd)"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target) TARGET="${2:-}"; shift 2 ;;
    -h|--help)
      echo "Usage: install.sh [--target <repo-path>]"
      exit 0 ;;
    *) echo "install.sh: unknown argument: $1" >&2; exit 2 ;;
  esac
done

if [[ ! -d "$TARGET/.git" ]] && ! git -C "$TARGET" rev-parse --git-dir > /dev/null 2>&1; then
  echo "install.sh: not a git repository: $TARGET" >&2
  exit 1
fi

mkdir -p "$TARGET/.githooks/lib"

for hook in commit-msg pre-push; do
  cp "$SRC_DIR/$hook" "$TARGET/.githooks/$hook"
  chmod +x "$TARGET/.githooks/$hook"
  echo "installed: $TARGET/.githooks/$hook"
done

# Both hooks source the shared trailer pattern from here.
cp "$SRC_DIR/lib/agent-trailers.sh" "$TARGET/.githooks/lib/agent-trailers.sh"
echo "installed: $TARGET/.githooks/lib/agent-trailers.sh"

git -C "$TARGET" config core.hooksPath .githooks
echo "set: core.hooksPath = .githooks"

cat <<'EOF'

Hooks are per clone. Every new clone and every new worktree must run this again.
That is why CI must run the same checks. See standards/GIT.md, "Authorship".

Commit .githooks/ to the repo, lib/ included.
EOF
