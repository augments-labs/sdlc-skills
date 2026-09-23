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
printf '# Plan\n\n## Tasks\n\n- [ ] `T-1` — Task one · `01-task.md` · `todo`\n' > "$plan/00-index.md"
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
# The identity is the plan's version, computed the way plan-version.sh computes one.
want="$(bash "$D/plan-version.sh" "$plan")"
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
# Mirroring a task checkbox into the index is not an amendment: plan-version.sh
# normalizes every checkbox and state label, so the identity is unchanged.
printf '# Plan\n\n## Tasks\n\n- [x] `T-1` — Task one · `01-task.md` · `done`\n' > "$plan/00-index.md"
bash "$D/sdd-workspace.sh" --plan "$plan" --check >/dev/null 2>&1
rc=$?
check "--check still passes after the checkbox flip (identity unchanged)" "$rc" "0"
printf '\n- amended\n' >> "$plan/00-index.md"
bash "$D/sdd-workspace.sh" --plan "$plan" --check >/dev/null 2>&1
rc=$?
check "--check reports drift after the plan is amended" "$rc" "1"
bash "$D/sdd-workspace.sh" --plan "$tmp/nope" >/dev/null 2>&1
rc=$?
check "a missing plan index is a usage error" "$rc" "2"

echo "--- sdd-workspace.sh: a plan plan-version.sh rejects is reported, not silently accepted"
badplan="$tmp/badplan"
mkdir -p "$badplan"
printf '# Plan\n\nNo tasks section here.\n' > "$badplan/00-index.md"
bash "$D/sdd-workspace.sh" --plan "$badplan" >"$tmp/badplan.out" 2>"$tmp/badplan.err"
rc=$?
check "a plan-version.sh rejection is a usage error (exit 2)" "$rc" "2"
if grep -qF 'could not compute the identity of' "$tmp/badplan.err"; then
  ok "stderr names the identity failure"
else
  bad "stderr does not name the identity failure"
fi

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

echo "--- task-brief.sh: fills {{report-template}} last, from ROLE-report.md"
roles2="$tmp/roles2"
mkdir -p "$roles2"
cat > "$roles2/implementer.md" <<'TPL'
ROLE: implementer
TASK FILE: {{task-file}}
WORKSPACE: {{workspace}}
BASE: {{base}}
TIER: {{tier}}
REPORT: {{report}}

## Report template
{{report-template}}
TPL
# The fixture report holds the worker's own {{finding}} placeholder and a
# literal & — bash's patsub_replacement (on by default, bash 5.2+) expands an
# unquoted & in a substitution's replacement to the matched text, so a naive
# insertion would corrupt this line into the matched slot text instead.
cat > "$roles2/implementer-report.md" <<'TPL'
REPORT-BODY-START
Finding: {{finding}}
Formula: A & B
TPL
bash "$D/task-brief.sh" --task "$plan/01-task.md" --role implementer --roles "$roles2" \
  --workspace /w --base abc1234 --tier medium --report "$tmp/r.md" >"$tmp/slot-a.out" 2>"$tmp/slot-a.err"
rc=$?
check "(a) renders with the report inserted (exit 0)" "$rc" "0"
if grep -qF 'Finding: {{finding}}' "$tmp/slot-a.out"; then
  ok "(a) report text carries the worker's own {{finding}} verbatim"
else
  bad "(a) report text is missing {{finding}} verbatim"
fi
if grep -qF 'Formula: A & B' "$tmp/slot-a.out"; then
  ok "(a) report text carries & verbatim, not expanded to the matched text"
else
  bad "(a) & was expanded or dropped instead of inserted verbatim"
fi
out_a="$(cat "$tmp/slot-a.out")"
prefix_a="${out_a%%REPORT-BODY-START*}"
case "$prefix_a" in
  *'{{'*) bad "(a) text before the inserted report still holds a placeholder";;
  *)      ok "(a) nothing before the inserted report holds a placeholder";;
esac

echo "--- task-brief.sh: {{report-template}} with no report file is exit 2"
roles3="$tmp/roles3"
mkdir -p "$roles3"
cp "$roles2/implementer.md" "$roles3/implementer.md"
bash "$D/task-brief.sh" --task "$plan/01-task.md" --role implementer --roles "$roles3" \
  --workspace /w --base abc1234 --tier medium --report "$tmp/r.md" >"$tmp/slot-b.out" 2>"$tmp/slot-b.err"
rc=$?
check "(b) missing report template fails the render (exit 2)" "$rc" "2"
if grep -qF "no report template at $roles3/implementer-report.md" "$tmp/slot-b.err"; then
  ok "(b) error names the missing report template path"
else
  bad "(b) error does not name the missing report template path"
fi

echo "--- task-brief.sh: an unfilled ordinary placeholder still wins over the report slot"
bash "$D/task-brief.sh" --task "$plan/01-task.md" --role implementer --roles "$roles2" \
  --workspace /w --base abc1234 --report "$tmp/r.md" >"$tmp/slot-c.out" 2>"$tmp/slot-c.err"
rc=$?
check "(c) missing --tier fails the render (exit 1)" "$rc" "1"
if grep -qF 'unfilled placeholder: {{tier}}' "$tmp/slot-c.err"; then
  ok "(c) error names {{tier}}"
else
  bad "(c) error does not name {{tier}}"
fi
if grep -qF '{{report-template}}' "$tmp/slot-c.err"; then
  bad "(c) error wrongly names {{report-template}}"
else
  ok "(c) error does not name {{report-template}}"
fi

echo "--- task-brief.sh: an & in the task's own body survives literally"
roles4="$tmp/roles4"
mkdir -p "$roles4"
cat > "$roles4/implementer.md" <<'TPL'
ROLE: implementer
TASK FILE: {{task-file}}
BODY:
{{task-body}}
WORKSPACE: {{workspace}}
BASE: {{base}}
TIER: {{tier}}
REPORT: {{report}}
TPL
amp_task="$tmp/amp-task.md"
printf '# Task\n\nFormula: a & b\n' > "$amp_task"
bash "$D/task-brief.sh" --task "$amp_task" --role implementer --roles "$roles4" \
  --workspace /w --base abc1234 --tier medium --report "$tmp/r.md" >"$tmp/amp.out" 2>"$tmp/amp.err"
rc=$?
check "renders with the task body inserted (exit 0)" "$rc" "0"
if grep -qF 'Formula: a & b' "$tmp/amp.out"; then
  ok "& in the task body survives literally"
else
  bad "& in the task body was expanded (patsub_replacement) or dropped"
fi

echo "--- task-brief.sh: a literal {{...}} in the task's own content passes through"
lit_task="$tmp/lit-task.md"
printf '# Task\n\nExample placeholder: {{example}}\n' > "$lit_task"
bash "$D/task-brief.sh" --task "$lit_task" --role implementer --roles "$roles4" \
  --workspace /w --base abc1234 --tier medium --report "$tmp/r.md" >"$tmp/lit.out" 2>"$tmp/lit.err"
rc=$?
check "renders despite the task's own {{example}} (exit 0)" "$rc" "0"
if grep -qF '{{example}}' "$tmp/lit.out"; then
  ok "the task's own {{example}} passes through unfilled"
else
  bad "the task's own {{example}} was stripped or rejected"
fi
# A real, script-owned placeholder left unfilled must still fail — the fix for
# the task's own {{example}} must not widen into ignoring every {{...}}.
bash "$D/task-brief.sh" --task "$lit_task" --role implementer --roles "$roles4" \
  --workspace /w --base abc1234 --report "$tmp/r.md" >"$tmp/lit2.out" 2>"$tmp/lit2.err"
rc=$?
check "an unfilled script placeholder still fails (exit 1)" "$rc" "1"

echo "--- task-brief.sh: a role template's brief inside one fence renders the fenced body only"
roles5="$tmp/roles5"
mkdir -p "$roles5"
cat > "$roles5/implementer.md" <<'TPL'
# Preamble

Some text that must never appear in the rendered brief.

````markdown
BODY START
TASK FILE: {{task-file}}
WORKSPACE: {{workspace}}
BASE: {{base}}
TIER: {{tier}}
REPORT: {{report}}
BODY END
````

Trailing text that must also never appear.
TPL
bash "$D/task-brief.sh" --task "$plan/01-task.md" --role implementer --roles "$roles5" \
  --workspace /w --base abc1234 --tier medium --report "$tmp/r.md" >"$tmp/fence.out" 2>"$tmp/fence.err"
rc=$?
check "renders the fenced body (exit 0)" "$rc" "0"
if grep -qF 'Preamble' "$tmp/fence.out" || grep -qF 'Trailing text' "$tmp/fence.out"; then
  bad "output still carries text from outside the fence"
else
  ok "no text from outside the fence survives"
fi
if grep -qxF '````markdown' "$tmp/fence.out" || grep -qxF '````' "$tmp/fence.out"; then
  bad "output still carries a fence marker line"
else
  ok "no fence marker line survives in the output"
fi
if grep -qF 'BODY START' "$tmp/fence.out" && grep -qF 'BODY END' "$tmp/fence.out"; then
  ok "the fenced body itself is present"
else
  bad "the fenced body content is missing"
fi

echo "--- task-brief.sh: a template with two fenced briefs is refused"
roles6="$tmp/roles6"
mkdir -p "$roles6"
cat > "$roles6/implementer.md" <<'TPL'
````markdown
First body: {{task-file}}
````

````markdown
Second body: {{workspace}}
````
TPL
bash "$D/task-brief.sh" --task "$plan/01-task.md" --role implementer --roles "$roles6" \
  --workspace /w --base abc1234 --tier medium --report "$tmp/r.md" >"$tmp/twofence.out" 2>"$tmp/twofence.err"
rc=$?
check "two fenced briefs is refused (exit 2)" "$rc" "2"
if grep -qF 'template carries more than one fenced brief' "$tmp/twofence.err"; then
  ok "error names the two-fence problem"
else
  bad "error does not name the two-fence problem"
fi

echo "--- task-brief.sh: a fence opened but never closed is refused"
roles7="$tmp/roles7"
mkdir -p "$roles7"
cat > "$roles7/implementer.md" <<'TPL'
````markdown
Unterminated body: {{task-file}}
TPL
bash "$D/task-brief.sh" --task "$plan/01-task.md" --role implementer --roles "$roles7" \
  --workspace /w --base abc1234 --tier medium --report "$tmp/r.md" >"$tmp/openfence.out" 2>"$tmp/openfence.err"
rc=$?
check "an unclosed fence is refused (exit 2)" "$rc" "2"
if grep -qF "template's fenced brief has no closing fence" "$tmp/openfence.err"; then
  ok "error names the unclosed-fence problem"
else
  bad "error does not name the unclosed-fence problem"
fi

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
# base is not an ancestor of head (divergent branches)
divergent_base="$(git -C "$repo" rev-parse HEAD)"
git -C "$repo" checkout -q --detach "$base"
printf 'divergent\n' > "$repo/c.txt"
git -C "$repo" add c.txt
git -C "$repo" commit -qm divergent
divergent_head="$(git -C "$repo" rev-parse HEAD)"
git -C "$repo" checkout -q -
bash "$D/review-package.sh" --repo "$repo" --base "$divergent_base" --head "$divergent_head" --out "$tmp/pkg4" >"$tmp/pkg4.out" 2>&1
rc=$?
check "base not an ancestor of head is a usage error (exit 3)" "$rc" "3"
if grep -q "$divergent_base is not an ancestor of $divergent_head" "$tmp/pkg4.out"; then
  ok "error message names the revisions"
else
  bad "error message missing or incorrect"
fi

echo "--- the shipped role templates render through the same path"
if [ -d "$A" ]; then
  for role in implementer task-reviewer re-reviewer; do
    bash "$D/task-brief.sh" --task "$plan/01-task.md" --role "$role" --roles "$A" \
      --workspace /w --base abc1234 --tier medium --report "$tmp/r.md" >"$tmp/$role.out" 2>&1
    rc=$?
    if [ "$rc" -ne 0 ]; then
      bad "shipped $role.md does not render (exit $rc)"
      continue
    fi
    # A brief's own report is inserted after the "## Report template" line, so
    # only the text up to that line is checked here; a brief without that line
    # (none ship one yet) is checked whole, as before.
    if grep -q '^## Report template$' "$tmp/$role.out"; then
      shipped_check="$(sed -n '1,/^## Report template$/p' "$tmp/$role.out")"
    else
      shipped_check="$(cat "$tmp/$role.out")"
    fi
    if printf '%s' "$shipped_check" | grep -q '{{'; then
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
