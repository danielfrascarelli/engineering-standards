#!/usr/bin/env bash
#
# Reject agent trailers and session links in a pull request title or body.
#
# A git hook cannot see a PR body, so the rule in standards/GIT.md
# "No agent traces" needs this half to be a gate at all.
#
# Reads the text from a file argument, or from stdin when the argument is "-".
#
# In CI, pass the body through an environment variable and pipe it in. Never
# interpolate it into the shell command: a PR body is untrusted input.
#
#   printf '%s\n' "$PR_TITLE" "$PR_BODY" | scripts/check-pr-body.sh -
#
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=hooks/lib/agent-trailers.sh
source "$ROOT/scripts/hooks/lib/agent-trailers.sh"

src="${1:--}"

if [[ "$src" == "-" ]]; then
  text="$(cat)"
elif [[ -f "$src" ]]; then
  text="$(cat "$src")"
else
  echo "check-pr-body: not a file: $src" >&2
  exit 2
fi

if printf '%s\n' "$text" | agent_trailers_present; then
  echo "check-pr-body: the pull request title or body contains an agent trailer or session link." >&2
  printf '%s\n' "$text" | agent_trailers_show >&2 || true
  echo "               See standards/GIT.md 'No agent traces'." >&2
  exit 1
fi

echo "ok: pull request title and body carry no agent traces"
