#!/usr/bin/env bash
#
# Validate this standards repository.
#
# Fails when:
#   1. a required standards file is missing;
#   2. a relative markdown link does not resolve;
#   3. a stack document is missing a mandated section, or has them out of order;
#   4. the sync script cannot run.
#
# Run locally before pushing. CI runs the same script.
#
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

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
  standards/DEPENDENCIES.md
  standards/DOCUMENTATION.md
  standards/GIT.md
  standards/PR.md
  standards/RELEASES.md
  standards/SECURITY.md
  standards/TESTING.md
  stacks/NODE.md
  stacks/PYTHON.md
  stacks/REACT.md
  tooling/PLUGINS.md
  scripts/sync-standards.sh
  .github/CODEOWNERS
  .github/pull_request_template.md
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

# ----------------------------------------------------------------

echo
if [[ "$FAILURES" -gt 0 ]]; then
  echo "$FAILURES failure(s)." >&2
  exit 1
fi
echo "All checks passed."
