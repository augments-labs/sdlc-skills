#!/usr/bin/env bash
# Offline tests for scripts/sh/validate-skills.sh's "every assets/ template
# has the house shape" check.
#
# What this guards: template-format.md's Shape rules 1-5 (H1, a preamble
# line before the fence, exactly one outer fence with a markdown/text
# language, a {{slot}} inside it, no bare <angle> placeholder outside an
# inline code span) are enforced by one bash+awk block, not read on trust.
# Each rule is broken, one file at a time, on a disposable copy of the tree,
# and the gate must name the broken file; the real, unbroken tree must stay
# green. The fence rule's other branches — a 5-backtick opening fence, a
# disallowed fence language, no fenced block at all, an empty file, and two
# outer fence pairs — get their own fixtures alongside the five above.
#
# Deterministic on purpose: file in, file out, exit code out. No model runs,
# no network. Both copies of the tree live under a temporary directory and
# are removed on exit; the checkout itself is never mutated.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 2

case "${1-}" in
  -h|--help)
    cat <<'EOF'
tests/run-validate-skills.sh — offline check for the "every assets/ template
has the house shape" gate in scripts/sh/validate-skills.sh.

Takes no arguments; copies the repository tree into a temporary directory
twice (once to break one or more fixtures per Shape rule, once left
untouched), runs
scripts/sh/validate-skills.sh against each copy, and asserts the check names
the broken file and stays silent on the untouched tree. Never mutates the
checkout.

  --help    this text

Exit codes: 0 every check passed · 1 at least one failed · 2 not run from the repo
EOF
    exit 0;;
esac

[ -f scripts/sh/validate-skills.sh ] || { echo "not run from the repository root" >&2; exit 2; }

fails=0
ok()  { echo "  ok    $1"; }
bad() { echo "  FAIL  $1"; fails=1; }

tmp="$(mktemp -d)" || exit 2
trap 'rm -rf "$tmp"' EXIT

copy_tree() {  # <dest>
  mkdir -p "$1"
  cp -a . "$1"/
  rm -rf "$1/.git"
}

# ---------------------------------------------------------------------------
# Copy 1: one fixture broken per rule, all in the same tree so one gate run
# checks every rule.
# ---------------------------------------------------------------------------
broken="$tmp/broken"
copy_tree "$broken"

r1="$broken/skills/common/yagni/assets/challenge-report.md"
r2="$broken/skills/common/handoff/assets/handoff-template.md"
r3="$broken/skills/common/using-git-worktrees/assets/workspace-record.md"
r4="$broken/skills/deployment/release-readiness/assets/release-candidate.md"
r5="$broken/skills/design/architecture-decisions/assets/adr-template.md"
r6="$broken/skills/analysis/writing-specs/assets/spec-template.md"
r7="$broken/skills/design/coding-standards/assets/standards-template.md"
r8="$broken/skills/common/clarifying-intent/assets/brief-template.md"
r9="$broken/skills/design/data-model/assets/data-model-section.md"
r10="$broken/skills/planning/scoping/assets/scope-section.md"

# Rule 1: line 1 must be an H1.
cat > "$r1" <<'EOF'
Example template (not a heading)

This is the preamble sentence describing who fills this and when it happens.

```markdown
Body line with a slot: {{name}}.
```
EOF

# Rule 2: at least one non-empty, non-heading line must precede the fence.
cat > "$r2" <<'EOF'
# Example template


```markdown
Body line with a slot: {{name}}.
```
EOF

# Rule 3: exactly one outer fence pair — this one opens but never closes.
cat > "$r3" <<'EOF'
# Example template

This is the preamble sentence describing who fills this and when it happens.

```markdown
Body line with a slot: {{name}}.
EOF

# Rule 4: at least one {{slot}} must sit inside the fence.
cat > "$r4" <<'EOF'
# Example template

This is the preamble sentence describing who fills this and when it happens.

```markdown
Body line with no placeholder at all.
```
EOF

# Rule 5: no bare <angle> placeholder outside an inline code span. The
# preamble's `<phase>`/`<name>` sit inside a code span and must NOT be
# flagged; the table cell's bare <name> must be.
cat > "$r5" <<'EOF'
# Example template

This is the preamble sentence describing who fills this and when it happens.
See `path/<phase>/<name>` for details, which must not be flagged.

```markdown
| Field | Value |
| --- | --- |
| Name | {{name}} |
| Owner | <name> |
```
EOF

# Rule 3 variant: the opening fence has 5 backticks, not 3 or 4.
cat > "$r6" <<'EOF'
# Example template

This is the preamble sentence describing who fills this and when it happens.

`````markdown
Body line with a slot: {{name}}.
`````
EOF

# Rule 3 variant: the opening fence's language is bash, not markdown or text.
cat > "$r7" <<'EOF'
# Example template

This is the preamble sentence describing who fills this and when it happens.

```bash
echo "Body line with a slot: {{name}}."
```
EOF

# Rule 3 variant: no fenced block at all.
cat > "$r8" <<'EOF'
# Example template

This is the preamble sentence describing who fills this and when it happens,
even though nothing here is ever fenced.
EOF

# Empty file.
: > "$r9"

# Rule 3 variant: two outer fence pairs (opens=2).
cat > "$r10" <<'EOF'
# Example template

This is the preamble sentence describing who fills this and when it happens.

```markdown
Body line with a slot: {{name}}.
```

```markdown
Second body block, also with a slot: {{other}}.
```
EOF

echo "--- validate-skills.sh: the house-shape check names each broken fixture"
out="$tmp/broken.out"
( cd "$broken" && bash scripts/sh/validate-skills.sh ) >"$out" 2>&1
rc=$?
[ "$rc" -ne 0 ] && ok "exit code is non-zero ($rc) with fixtures broken" \
  || bad "exit code is 0 even though ten fixtures are broken"

check_violation() {  # <label> <path (relative to repo root)> <expected substring>
  if grep -F "FAIL: $2:" "$out" | grep -qF "$3"; then
    ok "$1"
  else
    bad "$1 (expected a 'FAIL: $2:' line containing '$3')"
  fi
}
check_violation "rule 1 (H1) names the broken file" \
  "skills/common/yagni/assets/challenge-report.md" \
  "line 1 is not an H1"
check_violation "rule 2 (preamble) names the broken file" \
  "skills/common/handoff/assets/handoff-template.md" \
  "no non-empty, non-heading line before the first fence"
check_violation "rule 3 (one fence pair) names the broken file" \
  "skills/common/using-git-worktrees/assets/workspace-record.md" \
  "not exactly one outer fence pair (opens=1, closes=0)"
check_violation "rule 4 ({{slot}}) names the broken file" \
  "skills/deployment/release-readiness/assets/release-candidate.md" \
  "no {{slot}} found inside the fence"
check_violation "rule 5 (bare <angle>) names the broken file" \
  "skills/design/architecture-decisions/assets/adr-template.md" \
  "bare <angle> placeholder outside a code span: <name>"
check_violation "rule 3 (5-backtick fence) names the broken file" \
  "skills/analysis/writing-specs/assets/spec-template.md" \
  "opening fence is not 3 or 4 backticks"
check_violation "rule 3 (bash fence language) names the broken file" \
  "skills/design/coding-standards/assets/standards-template.md" \
  "opening fence language is not markdown or text"
check_violation "rule 3 (no fence) names the broken file" \
  "skills/common/clarifying-intent/assets/brief-template.md" \
  "no fenced block found"
check_violation "empty file names the broken file" \
  "skills/design/data-model/assets/data-model-section.md" \
  "empty file"
check_violation "rule 3 (two fence pairs) names the broken file" \
  "skills/planning/scoping/assets/scope-section.md" \
  "not exactly one outer fence pair (opens=2"

# The code-span reading of rule 5 must not fire: `path/<phase>/<name>` is
# backtick-wrapped prose, not a bare placeholder.
if grep -F "skills/design/architecture-decisions/assets/adr-template.md" "$out" | grep -qF '<phase>'; then
  bad "rule 5 wrongly flagged an <angle> token inside an inline code span"
else
  ok "rule 5 does not flag an <angle> token inside an inline code span"
fi

# ---------------------------------------------------------------------------
# Copy 2: untouched. The check must pass on the real, shipped templates —
# including the known case (skill-template.md's `skills/<phase>/<name>/
# SKILL.md` inline code span) that motivated the rule 5 reading above.
# ---------------------------------------------------------------------------
clean="$tmp/clean"
copy_tree "$clean"

echo "--- validate-skills.sh: the house-shape check passes on the untouched tree"
clean_out="$tmp/clean.out"
( cd "$clean" && bash scripts/sh/validate-skills.sh --strict ) >"$clean_out" 2>&1
rc=$?
[ "$rc" -eq 0 ] && ok "exit code is 0 on the untouched tree" \
  || bad "exit code is $rc on the untouched tree (expected 0)"

if grep -A1 'house shape' "$clean_out" | grep -q 'FAIL'; then
  bad "a FAIL line appears under 'house shape' on the untouched tree"
else
  ok "no FAIL line under 'house shape' on the untouched tree"
fi

if grep -qF "skill-template.md" "$clean_out"; then
  bad "skill-template.md's known code-span case (skills/<phase>/<name>/SKILL.md) was flagged"
else
  ok "skill-template.md's known code-span case is not flagged"
fi

echo "---"
[ "$fails" -eq 0 ] && { echo "validate-skills.sh tests: PASS"; exit 0; }
echo "validate-skills.sh tests: FAIL"; exit 1
