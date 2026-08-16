#!/usr/bin/env bash
#
# Validate a consuming repository against the central standards.
#
# README.md, "Option C, CI validation", promises this gate. This is it.
#
# Two consumption modes exist and they fail differently, so the mode is
# detected rather than assumed:
#
#   Option A, submodule  .standards is a git submodule. No generated headers,
#                        no SOURCE_REV. The pinned commit is the revision.
#   Option B, sync       .standards holds generated copies written by
#                        scripts/sync-standards.sh. Headers and SOURCE_REV
#                        are mandatory, and staleness is detectable.
#
# Fails when:
#   1. the standards directory is missing, or a required document is missing;
#   2. Option B and SOURCE_REV is missing, or records a dirty source tree;
#   3. Option B and a generated document lacks the GENERATED FILE header;
#   4. Option B, --source given, and SOURCE_REV is stale against it;
#   5. --source given and a security MUST rule was dropped from the local copy;
#   6. the local AGENTS.md declares an override without naming the rule it
#      replaces and a reason.
#
# Usage:
#   scripts/validate-consumer-standards.sh [--target <repo>] [--dest <dir>] [--source <checkout>]
#
#   --target   Consuming repository root. Default: current directory.
#   --dest     Standards directory inside the target. Default: .standards
#   --source   Checkout of engineering-standards to compare against. Optional.
#              Without it, staleness and rule-removal cannot be checked and
#              both are reported as skipped, never as passed.
#
set -uo pipefail

TARGET="$(pwd)"
DEST_NAME=".standards"
SOURCE=""

usage() {
  cat <<'USAGE'
Usage: validate-consumer-standards.sh [--target <repo>] [--dest <dir>] [--source <checkout>]

  --target   Consuming repository root. Default: current directory.
  --dest     Standards directory inside the target. Default: .standards
  --source   Checkout of engineering-standards to compare against. Optional.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target) TARGET="${2:-}"; shift 2 ;;
    --dest)   DEST_NAME="${2:-}"; shift 2 ;;
    --source) SOURCE="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "validate-consumer-standards: unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

FAILURES=0
fail() { echo "FAIL: $*" >&2; FAILURES=$((FAILURES + 1)); }
pass() { echo "ok: $*"; }
skip() { echo "skip: $*"; }

if [[ ! -d "$TARGET" ]]; then
  echo "validate-consumer-standards: target is not a directory: $TARGET" >&2
  exit 2
fi

DEST="$TARGET/$DEST_NAME"

# ---------------------------------------------------------------- 0. mode

if [[ ! -d "$DEST" ]]; then
  fail "$DEST_NAME/ not found in $TARGET. Add the standards by submodule or sync script."
  echo
  echo "$FAILURES failure(s)." >&2
  exit 1
fi

MODE="sync"
if [[ -f "$TARGET/.gitmodules" ]] && grep -qE "path[[:space:]]*=[[:space:]]*$DEST_NAME/?$" "$TARGET/.gitmodules"; then
  MODE="submodule"
fi
pass "consumption mode: $MODE"

# ---------------------------------------------------------------- 1. required documents

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
  tooling/PLUGINS.md
)

missing=0
for rel in "${REQUIRED[@]}"; do
  [[ -f "$DEST/$rel" ]] || { fail "required standards document missing: $DEST_NAME/$rel"; missing=1; }
done
[[ "$missing" -eq 0 ]] && pass "all ${#REQUIRED[@]} required standards documents present"

if [[ ! -f "$TARGET/AGENTS.md" ]]; then
  fail "$TARGET/AGENTS.md is missing. It carries project facts, git identity, and declared overrides."
else
  pass "repository AGENTS.md present"
fi

# ---------------------------------------------------------------- 2. SOURCE_REV

REV=""
if [[ "$MODE" == "submodule" ]]; then
  skip "SOURCE_REV not used in submodule mode; the pinned commit is the revision"
  REV="$(git -C "$TARGET" submodule status "$DEST_NAME" 2>/dev/null | awk '{gsub(/^[-+U]/,"",$1); print $1}')"
  if [[ -z "$REV" ]]; then
    fail "cannot read the pinned submodule revision for $DEST_NAME"
  else
    pass "submodule pinned at ${REV:0:12}"
  fi
elif [[ ! -f "$DEST/SOURCE_REV" ]]; then
  fail "$DEST_NAME/SOURCE_REV is missing. Re-run scripts/sync-standards.sh."
else
  REV="$(tr -d '[:space:]' < "$DEST/SOURCE_REV")"
  if [[ -z "$REV" ]]; then
    fail "$DEST_NAME/SOURCE_REV is empty"
  elif [[ "$REV" == *-dirty ]]; then
    fail "$DEST_NAME/SOURCE_REV records '$REV'. Standards were synced from an uncommitted source tree; that revision is not reproducible."
  elif [[ "$REV" == unknown ]]; then
    fail "$DEST_NAME/SOURCE_REV records 'unknown'. Sync from a git checkout of the standards."
  else
    pass "SOURCE_REV records $REV"
  fi
fi

# ---------------------------------------------------------------- 3. generated headers

if [[ "$MODE" == "submodule" ]]; then
  skip "generated headers not used in submodule mode"
else
  header_failures=0
  checked=0
  while IFS= read -r doc; do
    checked=$((checked + 1))
    if ! head -1 "$doc" | grep -q 'GENERATED FILE. DO NOT EDIT DIRECTLY.'; then
      fail "${doc#"$TARGET/"} lacks the GENERATED FILE header. It was hand-edited or written by something other than the sync script."
      header_failures=$((header_failures + 1))
    fi
  done < <(find "$DEST" -name '*.md' -type f | sort)
  [[ "$header_failures" -eq 0 ]] && pass "all $checked generated documents carry the GENERATED FILE header"
fi

# ---------------------------------------------------------------- 4. staleness

if [[ -z "$SOURCE" ]]; then
  skip "no --source given; staleness against the central standards not checked"
elif [[ ! -d "$SOURCE" ]]; then
  fail "--source is not a directory: $SOURCE"
elif ! SOURCE_REV_NOW="$(git -C "$SOURCE" rev-parse HEAD 2>/dev/null)"; then
  fail "--source is not a git checkout: $SOURCE"
elif [[ -z "$REV" ]]; then
  skip "no local revision to compare against"
else
  short_now="${SOURCE_REV_NOW:0:${#REV}}"
  if [[ "$MODE" == "submodule" ]]; then
    if [[ "$REV" != "$SOURCE_REV_NOW" ]]; then
      fail "submodule pinned at ${REV:0:12}, central standards are at ${SOURCE_REV_NOW:0:12}. Bump the submodule."
    else
      pass "submodule matches the central standards revision"
    fi
  elif [[ "$REV" != "$short_now" ]]; then
    fail "$DEST_NAME/SOURCE_REV is $REV, central standards are at ${SOURCE_REV_NOW:0:${#REV}}. Re-run scripts/sync-standards.sh."
  else
    pass "generated standards match revision $REV"
  fi
fi

# ---------------------------------------------------------------- 5. security MUST rules
#
# A local copy that quietly drops a security MUST is the failure this catches.
# Security MUST rules are never overridable. See standards/SECURITY.md.

if [[ -z "$SOURCE" ]]; then
  skip "no --source given; removal of security MUST rules not checked"
elif [[ ! -f "$SOURCE/standards/SECURITY.md" ]]; then
  fail "--source has no standards/SECURITY.md: $SOURCE"
elif [[ ! -f "$DEST/standards/SECURITY.md" ]]; then
  skip "local standards/SECURITY.md missing; already reported above"
else
  dropped=0
  total=0
  while IFS= read -r rule; do
    [[ -z "$rule" ]] && continue
    total=$((total + 1))
    # -- because a rule line starts with "- " and would otherwise parse as options.
    if ! grep -qxF -- "$rule" "$DEST/standards/SECURITY.md"; then
      fail "security MUST rule missing from the local copy: ${rule:0:80}"
      dropped=$((dropped + 1))
    fi
  done < <(grep -E -- 'MUST' "$SOURCE/standards/SECURITY.md" || true)
  [[ "$dropped" -eq 0 ]] && pass "all $total security MUST lines present in the local copy"
fi

# ---------------------------------------------------------------- 6. declared overrides
#
# An override that does not name the rule it replaces is not an override, it is
# a local rule that silently loses to the central one. See README.md,
# "Precedence".

if [[ ! -f "$TARGET/AGENTS.md" ]]; then
  skip "no repository AGENTS.md; already reported above"
else
  overrides_block="$(awk '
    /^##[[:space:]]+Overrides[[:space:]]*$/ { inblock = 1; next }
    /^##[[:space:]]/ { inblock = 0 }
    inblock { print }
  ' "$TARGET/AGENTS.md")"

  if [[ -z "$(printf '%s' "$overrides_block" | tr -d '[:space:]')" ]]; then
    pass "no '## Overrides' section, or it is empty"
  else
    # Split into entries. An entry starts at a "- " bullet and runs to the next one.
    entries="$(printf '%s\n' "$overrides_block" | awk '
      /^[[:space:]]*-[[:space:]]/ { if (entry != "") print entry; entry = $0; next }
      /^[[:space:]]*$/ { next }
      { entry = entry " " $0 }
      END { if (entry != "") print entry }
    ')"

    override_failures=0
    entry_count=0
    while IFS= read -r entry; do
      [[ -z "$entry" ]] && continue
      # "(none)" is the declared way to say there are no overrides.
      if printf '%s' "$entry" | grep -qiE '^[[:space:]]*-?[[:space:]]*\(?none\)?[[:space:]]*$'; then
        continue
      fi
      entry_count=$((entry_count + 1))
      if ! printf '%s' "$entry" | grep -qE 'Replaces[[:space:]]+[A-Za-z0-9_./-]+\.md[[:space:]]+"[^"]+"'; then
        override_failures=$((override_failures + 1))
        fail "override does not name the rule it replaces as: Replaces <file> \"<rule>\" -- ${entry:0:70}"
      fi
      if ! printf '%s' "$entry" | grep -qE 'Reason:[[:space:]]*[^[:space:]]'; then
        override_failures=$((override_failures + 1))
        fail "override carries no 'Reason:' -- ${entry:0:70}"
      fi
    done <<< "$entries"

    if [[ "$override_failures" -eq 0 ]]; then
      pass "$entry_count declared override(s) name a rule and a reason"
    fi
  fi
fi

# Also catch the "(none)" line living outside a bullet.
if [[ -f "$TARGET/AGENTS.md" ]] && ! grep -qE '^##[[:space:]]+Overrides[[:space:]]*$' "$TARGET/AGENTS.md"; then
  echo "note: AGENTS.md has no '## Overrides' section. Add one reading '(none)' to make the absence explicit."
fi

# ----------------------------------------------------------------

echo
if [[ "$FAILURES" -gt 0 ]]; then
  echo "$FAILURES failure(s)." >&2
  exit 1
fi
echo "Consumer standards validated."
