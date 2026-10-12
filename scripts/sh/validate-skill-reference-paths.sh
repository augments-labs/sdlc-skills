#!/usr/bin/env bash
# Resolve navigation paths exactly as they appear in one installable skill tree.
# Flags and exit codes: --help.

set -uo pipefail
cd "$(dirname "$0")/../.." || exit 2

usage() {
  cat <<'EOF'
scripts/sh/validate-skill-reference-paths.sh — do a tree's own links resolve?

  TREE      a directory holding installable skills   (required, positional)
  --help    this text

Run it once per installable layout: the canonical nested tree resolves paths
differently from a flattened plugin mirror, so a link can be valid in one and
dangling in the other.

Exit codes: 0 every reference resolves · 1 at least one is dangling
            2 missing or unreadable tree

Examples:
  bash scripts/sh/validate-skill-reference-paths.sh skills
  bash scripts/sh/validate-skill-reference-paths.sh plugins/sdlc-skills/skills
EOF
}

case "${1-}" in -h|--help) usage; exit 0;; esac

tree="${1:-}"
[ -n "$tree" ] && [ -d "$tree" ] || { usage >&2; exit 2; }

fail=0
err() { printf '  FAIL: %s\n' "$1"; fail=1; }

check_ref() {
  local src="$1" line="$2" ref="$3" target
  ref="${ref%%#*}"
  case "$ref" in
    ""|\#*|/*|*://*|mailto:*|.sdlc-skills/*|*\{\{*) return ;;
  esac
  target="$(dirname "$src")/$ref"
  [ -e "$target" ] ||
    err "$src:$line: reference '$ref' does not resolve in install tree '$tree'"
}

while IFS=: read -r src line ref; do
  check_ref "$src" "$line" "$ref"
done < <(
  {
    find "$tree" -name '*.md' -exec grep -HnoE '\]\([^)]*\)' {} + |
      sed -E 's#:\]\(([^)]*)\)$#:\1#'
    find "$tree" -name SKILL.md -exec \
      grep -HnoE '(\.\./)*([A-Za-z0-9._-]+/)*(references|assets)/[A-Za-z0-9._/-]+\.md' {} +
    find "$tree" \( -path '*/references/*.md' -o -path '*/assets/*.md' \) -exec \
      grep -HnoE '`(\.\./SKILL\.md|SKILL\.md|[A-Za-z0-9._-]+\.md)`' {} + |
      sed -E 's/:`([^`]*)`$/:\1/'
  } | sort -u
)

# Install adapters are allowed to package only a skill directory/tree. A
# shipped skill cannot depend on the repository documentation under docs/.
while IFS=: read -r src line _; do
  err "$src:$line: repository-only docs/ path is not install-portable"
done < <(grep -rnE 'docs/[A-Za-z0-9._/-]+\.md' "$tree" || true)

exit "$fail"
