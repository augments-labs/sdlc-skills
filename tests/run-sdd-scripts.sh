#!/usr/bin/env bash
# Offline tests for the subagent-driven-development scripts.
#
# What these guard: the three scripts exist because prose got the same three
# things wrong every time — a ledger that no longer binds to the plan it claims,
# a brief dispatched with a placeholder still in it, and a reviewer handed a
# description of a diff instead of the diff. Each check below is one of those
# failures, made to happen.
#
# Deterministic on purpose: file in, file out, exit code out. No model runs, no
# network, and the only git repository touched is one this file creates.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 2

case "${1-}" in
  -h|--help)
    cat <<'EOF'
tests/run-sdd-scripts.sh — offline unit checks for the SDD scripts.

Takes no arguments; exercises sdd-workspace.sh, task-brief.sh, and
review-package.sh against temporary fixtures it creates and removes.

  --help    this text

Exit codes: 0 every check passed · 1 at least one failed · 2 not run from the repo
EOF
    exit 0;;
esac

D=skills/implementation/subagent-driven-development/scripts
A=skills/implementation/subagent-driven-development/assets
fails=0
ok()  { echo "  ok    $1"; }
bad() { echo "  FAIL  $1"; fails=1; }
check(){ if [ "$2" = "$3" ]; then ok "$1"; else bad "$1 (expected '$3', got '$2')"; fi; }

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# A plan directory is the input all three scripts start from.
plan="$tmp/plan"
mkdir -p "$plan"
printf '# Plan\n\n- **Normative version:** r1\n' > "$plan/00-index.md"
printf '# Task 01\n\n**Task ID:** `T-1`\n**Files:** src/a.txt\n' > "$plan/01-task.md"

echo "--- every script answers --help and documents its exit codes"
for s in sdd-workspace task-brief review-package; do
  if [ ! -f "$D/$s.sh" ]; then
    bad "$s.sh: missing"
    continue
  fi
  [ -x "$D/$s.sh" ] && ok "$s.sh: executable" || bad "$s.sh: not executable"
  bash "$D/$s.sh" --help >"$tmp/help.out" 2>&1
  rc=$?
  if [ "$rc" -ne 0 ]; then
    bad "$s.sh: --help exited $rc"
  elif grep -qi 'exit code' "$tmp/help.out"; then
    ok "$s.sh: --help documents its exit codes"
  else
    bad "$s.sh: --help does not document its exit codes"
  fi
done

echo "--- sdd-workspace.sh: the ledger binds to the plan, and says so on line 1"
led="$plan/sdd-ledger.md"
bash "$D/sdd-workspace.sh" --plan "$plan" >"$tmp/ws.out" 2>&1
rc=$?
check "creates the ledger (exit 0)" "$rc" "0"
if [ -f "$led" ]; then
  ok "ledger written beside the plan"
else
  bad "no ledger at $led"
fi
# The identity is the plan index's, computed the way the library computes one.
want="$(git hash-object "$plan/00-index.md" | cut -c1-7)"
line1="$(head -1 "$led" 2>/dev/null)"
case "$line1" in
  *"$want"*) ok "line 1 carries the plan identity ($want)" ;;
  *)         bad "line 1 does not carry the plan identity $want (got: ${line1:-<empty>})" ;;
esac
# Resuming after a compaction re-runs this. It must not wipe what was recorded.
printf 'ruling: kept the existing migration path\n' >> "$led"
bash "$D/sdd-workspace.sh" --plan "$plan" >/dev/null 2>&1
rc=$?
check "second run is idempotent (exit 0)" "$rc" "0"
if grep -q 'kept the existing migration path' "$led"; then
  ok "a second run preserves recorded rows"
else
  bad "a second run truncated the ledger — the run's history is gone"
fi

echo "--- sdd-workspace.sh --check: a ledger bound to a superseded plan is drift"
bash "$D/sdd-workspace.sh" --plan "$plan" --check >/dev/null 2>&1
rc=$?
check "--check passes while the plan is unchanged" "$rc" "0"
printf '\n- amended\n' >> "$plan/00-index.md"
bash "$D/sdd-workspace.sh" --plan "$plan" --check >/dev/null 2>&1
rc=$?
check "--check reports drift after the plan is amended" "$rc" "1"
bash "$D/sdd-workspace.sh" --plan "$tmp/nope" >/dev/null 2>&1
rc=$?
check "a missing plan index is a usage error" "$rc" "2"

echo "--- task-brief.sh: renders a role brief, and refuses an unfilled one"
roles="$tmp/roles"
mkdir -p "$roles"
cat > "$roles/implementer.md" <<'TPL'
ROLE: implementer
TASK FILE: {{task-file}}
WORKSPACE: {{workspace}}
BASE: {{base}}
TIER: {{tier}}
REPORT: {{report}}
TPL
cat > "$roles/task-reviewer.md" <<'TPL'
ROLE: task reviewer
TASK FILE: {{task-file}}
WORKSPACE: {{workspace}}
BASE: {{base}}
TIER: {{tier}}
REPORT: {{report}}
TPL
bash "$D/task-brief.sh" --task "$plan/01-task.md" --role implementer --roles "$roles" \
  --workspace /w --base abc1234 --tier medium --report "$tmp/r.md" >"$tmp/brief.out" 2>&1
rc=$?
check "renders a complete brief (exit 0)" "$rc" "0"
for probe in "$plan/01-task.md" "/w" "abc1234" "medium"; do
  if grep -qF -- "$probe" "$tmp/brief.out"; then
    ok "brief carries '$probe'"
  else
    bad "brief is missing '$probe'"
  fi
done
if grep -q '{{' "$tmp/brief.out"; then
  bad "brief still contains a placeholder"
else
  ok "no placeholder survives in the rendered brief"
fi
# The whole point: a half-filled brief must not reach a worker.
bash "$D/task-brief.sh" --task "$plan/01-task.md" --role implementer --roles "$roles" \
  --workspace /w --base abc1234 --report "$tmp/r.md" >"$tmp/partial.out" 2>&1
rc=$?
check "an unfilled placeholder fails the render (exit 1)" "$rc" "1"
bash "$D/task-brief.sh" --task "$plan/01-task.md" --role nonesuch --roles "$roles" \
  --workspace /w --base abc1234 --tier medium --report "$tmp/r.md" >/dev/null 2>&1
rc=$?
check "an unknown role is a usage error (exit 2)" "$rc" "2"

echo "--- review-package.sh: the reviewer gets the diff itself"
repo="$tmp/repo"
mkdir -p "$repo"
git -C "$repo" init -q
git -C "$repo" config user.email t@example.invalid
git -C "$repo" config user.name tester
printf 'one\n' > "$repo/a.txt"
git -C "$repo" add a.txt
git -C "$repo" commit -qm base
base="$(git -C "$repo" rev-parse HEAD)"
printf 'two\n' > "$repo/a.txt"
printf 'new\n' > "$repo/b.txt"
git -C "$repo" add -A
git -C "$repo" commit -qm work
head="$(git -C "$repo" rev-parse HEAD)"

out="$tmp/pkg"
bash "$D/review-package.sh" --repo "$repo" --base "$base" --head "$head" --out "$out" \
  --task "$plan/01-task.md" >"$tmp/pkg.out" 2>&1
rc=$?
check "assembles the package (exit 0)" "$rc" "0"
for f in diff.patch files.txt package.md; do
  [ -s "$out/$f" ] && ok "wrote $f" || bad "missing or empty $out/$f"
done
if grep -q '^+two$' "$out/diff.patch"; then
  ok "diff.patch holds the real hunk, not a summary of it"
else
  bad "diff.patch does not contain the changed line"
fi
if grep -qx 'b.txt' "$out/files.txt" && grep -qx 'a.txt' "$out/files.txt"; then
  ok "files.txt lists every changed path"
else
  bad "files.txt does not list both changed paths"
fi
for probe in diff.patch files.txt; do
  grep -qF "$probe" "$out/package.md" && ok "package.md names $probe" \
    || bad "package.md does not name $probe"
done
# Nothing to review is a result, not a package.
bash "$D/review-package.sh" --repo "$repo" --base "$head" --head "$head" --out "$tmp/pkg2" >/dev/null 2>&1
rc=$?
check "an empty range is reported, not packaged (exit 1)" "$rc" "1"
bash "$D/review-package.sh" --repo "$tmp" --base "$base" --head "$head" --out "$tmp/pkg3" >/dev/null 2>&1
rc=$?
check "outside a repository is a usage error (exit 2)" "$rc" "2"

echo "--- the shipped role templates render through the same path"
if [ -d "$A" ]; then
  for role in implementer task-reviewer re-reviewer; do
    bash "$D/task-brief.sh" --task "$plan/01-task.md" --role "$role" --roles "$A" \
      --workspace /w --base abc1234 --tier medium --report "$tmp/r.md" >"$tmp/$role.out" 2>&1
    rc=$?
    if [ "$rc" -ne 0 ]; then
      bad "shipped $role.md does not render (exit $rc)"
    elif grep -q '{{' "$tmp/$role.out"; then
      bad "shipped $role.md leaves a placeholder after rendering"
    else
      ok "shipped $role.md renders complete"
    fi
  done
else
  bad "no role templates at $A"
fi

echo "---"
[ "$fails" -eq 0 ] && { echo "SDD script tests: PASS"; exit 0; }
echo "SDD script tests: FAIL"; exit 1
