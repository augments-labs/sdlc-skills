#!/usr/bin/env bash
# Offline test for check-skill.sh's reference-depth policy check.
#
# What this guards: a support file under references/ or assets/ that names a
# third file is exactly the chain (SKILL.md -> support file -> support file)
# check-skill.sh's reference-depth rule exists to catch, because the agent
# only sees the third file when SKILL.md names it too. The rule must keep
# firing when SKILL.md hides that third file, and go silent once SKILL.md
# names it. Both arms are run against the real script, on a fixture skill
# built only for this chain, not a scratch-and-delete run left out of the
# committed suite.
#
# Deterministic on purpose: file in, file out, exit code out. No model runs,
# no network. Fixtures live under a temporary directory removed on exit; the
# checkout itself is never mutated.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 2

case "${1-}" in
  -h|--help)
    cat <<'EOF'
tests/run-check-skill.sh — offline check for check-skill.sh's reference-depth
rule.

Takes no arguments; builds a minimal fixture skill under a temporary
directory in two variants (SKILL.md hides the third file / SKILL.md names it
too) and asserts
skills/common/writing-skills/scripts/check-skill.sh --strict warns in the
first and stays silent in the second. Never mutates the checkout.

  --help    this text

Exit codes: 0 every check passed · 1 at least one failed · 2 not run from the repo
EOF
    exit 0;;
esac

CHECK=skills/common/writing-skills/scripts/check-skill.sh
[ -f "$CHECK" ] || { echo "not run from the repository root" >&2; exit 2; }

fails=0
ok()  { echo "  ok    $1"; }
bad() { echo "  FAIL  $1"; fails=1; }

tmp="$(mktemp -d)" || exit 2
trap 'rm -rf "$tmp"' EXIT

# Every other check-skill.sh rule is built to pass on this fixture, so the
# assertions below can look for reference-depth alone without noise from an
# unrelated finding.
build_skill() {  # <dir> <also-name-b: 0|1>
  dir="$1"; also="$2"
  mkdir -p "$dir/references"
  {
    printf -- '---\n'
    printf 'name: depth-fixture\n'
    printf 'description: Use this when testing that check-skill.sh either warns on a hidden third-level reference chain or stays silent once SKILL.md names the third file too.\n'
    printf -- '---\n\n'
    printf '# Depth fixture\n\n'
    printf 'A minimal fixture skill that exists only to exercise the\n'
    printf 'reference-depth check. Read `references/a.md` before anything else,\n'
    printf 'when preparing a deeper reference chain.\n\n'
    if [ "$also" = 1 ]; then
      printf 'It also names `references/b.md` here, before that chain is exercised, so the chain is not hidden.\n\n'
    fi
    printf '## Gotchas\n\n'
    printf -- '- None; this is a fixture, not real guidance.\n'
  } > "$dir/SKILL.md"
  {
    printf '# A\n\n'
    printf 'This file exists only to name a deeper file, `references/b.md`, before\n'
    printf 'this chain is exercised.\n'
  } > "$dir/references/a.md"
  {
    printf '# B\n\n'
    printf 'Leaf file. Nothing here names anything deeper.\n'
  } > "$dir/references/b.md"
}

echo "--- check-skill.sh: reference-depth warns when SKILL.md hides the third file"
hidden="$tmp/hidden/depth-fixture"
build_skill "$hidden" 0
out_hidden="$tmp/hidden.out"
bash "$CHECK" --strict "$hidden" >"$out_hidden" 2>&1
if grep -q 'reference-depth' "$out_hidden"; then
  ok "reference-depth fires when SKILL.md does not name the hidden third file"
else
  bad "reference-depth did not fire on the hidden-third-file fixture"
fi

echo "--- check-skill.sh: reference-depth is silent once SKILL.md names the third file too"
named="$tmp/named/depth-fixture"
build_skill "$named" 1
out_named="$tmp/named.out"
bash "$CHECK" --strict "$named" >"$out_named" 2>&1
if grep -q 'reference-depth' "$out_named"; then
  bad "reference-depth still fired even though SKILL.md names the third file too"
else
  ok "reference-depth is suppressed once SKILL.md names the third file too"
fi

echo "---"
[ "$fails" -eq 0 ] && { echo "check-skill.sh tests: PASS"; exit 0; }
echo "check-skill.sh tests: FAIL"; exit 1
