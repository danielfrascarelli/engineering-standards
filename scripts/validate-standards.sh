#!/usr/bin/env bash
#
# Validate this standards repository.
#
# Fails when:
#   1. a required standards file is missing;
#   2. a relative markdown link does not resolve;
#   3. a stack document is missing a mandated section, or has them out of order;
#   4. the sync script cannot run;
#   5. a reference hook is not executable;
#   6. the installed .githooks/ copy has drifted from scripts/hooks/;
#   7. a commit carries the wrong identity or an agent trailer;
#   8. a trailer fixture no longer behaves as specified.
#
# Usage:
#   scripts/validate-standards.sh [--range <base>..<head>]
#
#   --range   Restrict the authorship checks to the commits introduced by this
#             push or pull request. Without it every commit is scanned, which
#             is right for this repo and wrong for a repo adopting the rule
#             after it already has history.
#
# Run locally before pushing. CI runs the same script.
#
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# shellcheck source=hooks/lib/agent-trailers.sh
source "$ROOT/scripts/hooks/lib/agent-trailers.sh"

RANGE=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --range) RANGE="${2:-}"; shift 2 ;;
    -h|--help)
      echo "Usage: validate-standards.sh [--range <base>..<head>]"
      exit 0 ;;
    *) echo "validate-standards: unknown argument: $1" >&2; exit 2 ;;
  esac
done

FAILURES=0

fail() {
  echo "FAIL: $*" >&2
  FAILURES=$((FAILURES + 1))
}

pass() {
  echo "ok: $*"
}

# ---------------------------------------------------------------- 1. required files

REQUIRED=(
  AGENTS.md
  README.md
  standards/CHECKS.md
  standards/CONTRIBUTING.md
  standards/DELIVERY.md
  standards/DEPENDENCIES.md
  standards/DOCUMENTATION.md
  standards/GIT.md
  standards/PR.md
  standards/RELEASES.md
  standards/SECURITY.md
  standards/TESTING.md
  stacks/NESTJS.md
  stacks/NODE.md
  stacks/PYTHON.md
  stacks/PYTHON_ML.md
  stacks/REACT.md
  tooling/PLUGINS.md
  docs/workspace-setup.md
  scripts/sync-standards.sh
  scripts/validate-consumer-standards.sh
  scripts/check-pr-body.sh
  scripts/test-agent-trailers.sh
  scripts/hooks/commit-msg
  scripts/hooks/pre-push
  scripts/hooks/install.sh
  scripts/hooks/lib/agent-trailers.sh
  .githooks/commit-msg
  .githooks/pre-push
  .githooks/lib/agent-trailers.sh
  .github/CODEOWNERS
  .github/pull_request_template.md
  .github/workflows/validate-standards.yml
  .github/workflows/validate-consumer-standards.example.yml
)

missing=0
for f in "${REQUIRED[@]}"; do
  [[ -e "$f" ]] || { fail "required file missing: $f"; missing=1; }
done
[[ "$missing" -eq 0 ]] && pass "all ${#REQUIRED[@]} required files present"

# ---------------------------------------------------------------- 2. relative links

link_failures=0
while IFS= read -r doc; do
  doc_dir="$(dirname "$doc")"
  while IFS= read -r target; do
    [[ -z "$target" ]] && continue
    case "$target" in
      http://*|https://*|mailto:*|'#'*) continue ;;
    esac
    target="${target%%#*}"
    [[ -z "$target" ]] && continue
    if [[ ! -e "$doc_dir/$target" ]]; then
      fail "broken link in $doc -> $target"
      link_failures=$((link_failures + 1))
    fi
  done < <(grep -oE '\]\([^)]+\)' "$doc" 2>/dev/null | sed -E 's/^\]\(//; s/\)$//' || true)
done < <(find . -name '*.md' -not -path './.git/*' | sort)

[[ "$link_failures" -eq 0 ]] && pass "all relative markdown links resolve"

# ---------------------------------------------------------------- 3. stack template

REQUIRED_SECTIONS=(
  "Runtime and version"
  "Language and types"
  "Project structure"
  "Lint and format"
  "Errors"
  "Logging"
  "Security notes"
  "Testing"
)

section_failures=0
for doc in stacks/*.md; do
  [[ -e "$doc" ]] || continue
  mapfile -t found < <(grep -E '^## ' "$doc" | sed -E 's/^## //' || true)
  idx=0
  for want in "${REQUIRED_SECTIONS[@]}"; do
    matched=0
    while [[ "$idx" -lt "${#found[@]}" ]]; do
      if [[ "${found[$idx]}" == "$want" ]]; then
        matched=1
        idx=$((idx + 1))
        break
      fi
      idx=$((idx + 1))
    done
    if [[ "$matched" -eq 0 ]]; then
      fail "$doc: missing section '## $want', or it appears out of order"
      section_failures=$((section_failures + 1))
    fi
  done
done
[[ "$section_failures" -eq 0 ]] && pass "stack documents follow the mandated section order"

# ---------------------------------------------------------------- 4. sync script

if [[ ! -x scripts/sync-standards.sh ]]; then
  fail "scripts/sync-standards.sh is not executable"
else
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT
  if scripts/sync-standards.sh --target "$tmp" --dry-run > /dev/null 2>&1; then
    pass "sync script runs"
  else
    fail "sync script failed on a dry run"
  fi
fi

# ---------------------------------------------------------------- 5. scripts executable

exec_failures=0
for script in \
  scripts/hooks/commit-msg \
  scripts/hooks/pre-push \
  scripts/hooks/install.sh \
  scripts/check-pr-body.sh \
  scripts/test-agent-trailers.sh \
  scripts/validate-consumer-standards.sh
do
  [[ -x "$script" ]] || { fail "$script is not executable"; exec_failures=$((exec_failures + 1)); }
done
[[ "$exec_failures" -eq 0 ]] && pass "reference hooks and scripts are executable"

# ---------------------------------------------------------------- 6. hook copies match
#
# scripts/hooks/ is the reference implementation. .githooks/ is this repo's
# installed copy. Two copies that nothing compares drift silently.

mirror_failures=0
for rel in commit-msg pre-push lib/agent-trailers.sh; do
  if [[ ! -e ".githooks/$rel" ]]; then
    fail ".githooks/$rel is missing. Run scripts/hooks/install.sh."
    mirror_failures=$((mirror_failures + 1))
  elif ! cmp -s "scripts/hooks/$rel" ".githooks/$rel"; then
    fail ".githooks/$rel differs from scripts/hooks/$rel. Run scripts/hooks/install.sh."
    mirror_failures=$((mirror_failures + 1))
  fi
done
[[ "$mirror_failures" -eq 0 ]] && pass "installed .githooks/ matches the reference hooks"

# ---------------------------------------------------------------- 7. authorship
#
# Hooks are per clone and opt-in, so the same checks run here. See
# standards/GIT.md, "Authorship".

read_declared() {
  sed -nE "s/^[[:space:]]*-?[[:space:]]*$1:[[:space:]]*(.+)[[:space:]]*$/\1/p" AGENTS.md | head -1
}

DECLARED_EMAIL="$(read_declared 'user\.email')"
DECLARED_NAME="$(read_declared 'user\.name')"

# A merge performed by the hosting platform rewrites the committer, never the
# author. Allow those committers; the author check still applies.
committer_allowed() {
  case "$1" in
    "$DECLARED_EMAIL") return 0 ;;
    noreply@github.com|*@users.noreply.github.com) return 0 ;;
    *) return 1 ;;
  esac
}

if [[ -z "$DECLARED_EMAIL" || -z "$DECLARED_NAME" ]]; then
  fail "AGENTS.md must declare both 'user.name:' and 'user.email:'. Add a Git identity block."
elif ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo "skip: not a git repository, authorship checks not run"
else
  if [[ -n "$RANGE" ]]; then
    log_args=("$RANGE")
    scope="commits in $RANGE"
  else
    log_args=(HEAD)
    scope="every commit"
  fi

  if ! commits="$(git log --format='%H%x09%an%x09%ae%x09%ce' "${log_args[@]}" 2>/dev/null)"; then
    fail "cannot resolve commit range: ${log_args[*]}"
  else
    identity_failures=0
    while IFS=$'\t' read -r sha author_name author_email committer_email; do
      [[ -z "$sha" ]] && continue
      if [[ "$author_email" != "$DECLARED_EMAIL" ]]; then
        fail "${sha:0:8} authored by <$author_email>, expected <$DECLARED_EMAIL>"
        identity_failures=$((identity_failures + 1))
      fi
      if [[ "$author_name" != "$DECLARED_NAME" ]]; then
        fail "${sha:0:8} author name '$author_name', expected '$DECLARED_NAME'"
        identity_failures=$((identity_failures + 1))
      fi
      if ! committer_allowed "$committer_email"; then
        fail "${sha:0:8} committed by <$committer_email>, expected <$DECLARED_EMAIL>"
        identity_failures=$((identity_failures + 1))
      fi
    done <<< "$commits"

    [[ "$identity_failures" -eq 0 ]] && \
      pass "$scope: declared identity $DECLARED_NAME <$DECLARED_EMAIL>"

    if git log --format='%B' "${log_args[@]}" | agent_trailers_present; then
      fail "$scope: an AI-agent trailer or session link is present. See standards/GIT.md 'Authorship'."
      git log --format='%B' "${log_args[@]}" | agent_trailers_show >&2 || true
    else
      pass "$scope: no agent trailers"
    fi
  fi
fi

# ---------------------------------------------------------------- 8. trailer fixtures

if ./scripts/test-agent-trailers.sh > /dev/null 2>&1; then
  pass "agent-trailer fixtures behave as specified"
else
  fail "scripts/test-agent-trailers.sh failed. Run it directly for the detail."
fi

# ----------------------------------------------------------------

echo
if [[ "$FAILURES" -gt 0 ]]; then
  echo "$FAILURES failure(s)." >&2
  exit 1
fi
echo "All checks passed."
