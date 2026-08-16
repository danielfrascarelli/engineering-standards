#!/usr/bin/env bash
#
# Fixtures for the shared agent-trailer pattern and the commit-msg hook.
#
# The pattern gates commit messages and pull request bodies. It has to reject
# the exact footers these tools emit and it has to leave a human co-author
# alone, so both directions are asserted here.
#
# Run directly, or through scripts/validate-standards.sh.
#
# Rule: standards/GIT.md, "No agent traces".
#
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOK="$ROOT/scripts/hooks/commit-msg"

FAILURES=0
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# expect_reject <name> <message>
expect_reject() {
  local name="$1" msg="$2" file="$tmp/msg"
  printf '%s\n' "$msg" > "$file"
  if "$HOOK" "$file" > /dev/null 2>&1; then
    echo "FAIL: fixture '$name' was accepted, expected rejection" >&2
    FAILURES=$((FAILURES + 1))
  else
    echo "ok: rejected $name"
  fi
}

# expect_accept <name> <message>
expect_accept() {
  local name="$1" msg="$2" file="$tmp/msg"
  printf '%s\n' "$msg" > "$file"
  if "$HOOK" "$file" > /dev/null 2>&1; then
    echo "ok: accepted $name"
  else
    echo "FAIL: fixture '$name' was rejected, expected acceptance" >&2
    FAILURES=$((FAILURES + 1))
  fi
}

expect_accept "plain commit" \
'feat: add profile image upload'

expect_accept "human co-author" \
'fix: correct invoice rounding

Co-Authored-By: Ana Ruiz <ana.ruiz@example.com>'

expect_accept "rule described in prose" \
'docs: explain the authorship rule

A commit MUST NOT carry a Co-Authored-By: trailer naming Claude, and MUST NOT
link to https://claude.ai/code. This commit only documents that.'

expect_accept "git comment lines are stripped" \
'chore: update lint configuration

# Co-Authored-By: Claude <noreply@anthropic.com>'

expect_reject "AI co-author" \
'feat: add caching layer

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>'

expect_reject "assistant co-author" \
'feat: add caching layer

Co-Authored-By: AI Assistant <bot@example.com>'

expect_reject "session trailer" \
'feat: add caching layer

Claude-Session: https://claude.ai/code/session_01DQXvjW6drxZ5BhQ3SiNZ9A'

expect_reject "bare session link" \
'feat: add caching layer

https://claude.ai/code/session_01DQXvjW6drxZ5BhQ3SiNZ9A'

expect_reject "generated footer with emoji" \
'feat: add caching layer

🤖 Generated with [Claude Code](https://claude.com/claude-code)'

expect_reject "generated footer plain" \
'feat: add caching layer

Generated with Copilot'

echo
if [[ "$FAILURES" -gt 0 ]]; then
  echo "$FAILURES trailer fixture failure(s)." >&2
  exit 1
fi
echo "All trailer fixtures passed."
