#!/usr/bin/env bash
#
# Copy the central standards into a consuming repository.
#
# Every generated file gets a header marking it read-only and recording the
# source revision, so drift is detectable. See README.md, "Option B, sync script".
#
set -euo pipefail

SRC_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST_NAME=".standards"
TARGET=""
DRY_RUN=0

usage() {
  cat <<'USAGE'
Usage: sync-standards.sh --target <repo-path> [--dest <dir>] [--dry-run]

  --target   Path to the consuming repository. Required.
  --dest     Directory inside the target to write into. Default: .standards
  --dry-run  Print what would be written, write nothing.

Example:
  ./scripts/sync-standards.sh --target ../my-app
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)  TARGET="${2:-}"; shift 2 ;;
    --dest)    DEST_NAME="${2:-}"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "sync-standards: unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

if [[ -z "$TARGET" ]]; then
  echo "sync-standards: --target is required" >&2
  exit 2
fi

if [[ ! -d "$TARGET" ]]; then
  echo "sync-standards: target is not a directory: $TARGET" >&2
  exit 1
fi

cd "$SRC_ROOT"

REV="$(git rev-parse --short HEAD 2>/dev/null || echo unknown)"
if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
  REV="${REV}-dirty"
  echo "sync-standards: warning: source tree is dirty, stamping ${REV}" >&2
fi

FILES=(
  AGENTS.md
  README.md
)
# docs/ is copied so the links out of tooling/ and README.md still resolve in the
# consuming repo. Nothing in docs/ is normative; it says so in its own first line.
while IFS= read -r f; do FILES+=("$f"); done < <(
  find standards stacks tooling docs -name '*.md' -type f | sort
)

DEST_ROOT="$TARGET/$DEST_NAME"

# The central AGENTS.md carries a "This repository" block declaring THIS repo's
# git identity. Copying it forward gives the consumer two identity blocks and a
# stale one wins as often as not. The block is replaced with a pointer to the
# consumer's own root AGENTS.md, which is the only authoritative declaration.
# See standards/GIT.md, "Authorship".
emit_body() {
  local rel="$1"
  if [[ "$rel" != "AGENTS.md" ]]; then
    cat "$rel"
    return
  fi
  awk '
    /^##[[:space:]]+This repository[[:space:]]*$/ {
      print "## This repository"
      print ""
      print "The git identity for commits lives in the consuming repository’s own root"
      print "`AGENTS.md`, never in this generated copy. See [standards/GIT.md](standards/GIT.md),"
      print "\"Authorship\"."
      skipping = 1
      next
    }
    /^##[[:space:]]/ { skipping = 0 }
    !skipping { print }
  ' "$rel"
}

for rel in "${FILES[@]}"; do
  out="$DEST_ROOT/$rel"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "would write: $out"
    continue
  fi
  mkdir -p "$(dirname "$out")"
  {
    echo "<!-- GENERATED FILE. DO NOT EDIT DIRECTLY. Source: engineering-standards@${REV} -->"
    echo
    emit_body "$rel"
  } > "$out"
  echo "wrote: $out"
done

if [[ "$DRY_RUN" -eq 0 ]]; then
  printf '%s\n' "$REV" > "$DEST_ROOT/SOURCE_REV"
  echo "wrote: $DEST_ROOT/SOURCE_REV"
  cat <<EOF

Done. ${#FILES[@]} files at $DEST_ROOT (revision $REV).

Next:
  1. Commit the generated files. They belong in history. See standards/GIT.md.
  2. Keep repo-specific rules and declared overrides in the target's own AGENTS.md.
  3. Re-run this script when the standards revision changes.
EOF
fi
