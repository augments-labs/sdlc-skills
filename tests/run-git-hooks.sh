#!/usr/bin/env bash
# Offline tests for the local git hook installer and its pre-commit hook.
#
# What this guards: a contributor who never runs the CI validators locally
# ships a change that breaks a skill, a manifest, or a chain budget, and finds
# out only when CI fails on the PR. install-git-hooks.sh plus
# scripts/git-hooks/pre-commit close that gap with no third-party tool. This
# test proves the hook actually runs the real validators against a real
# (fixture) copy of this tree — not a stub — that it stays out of paths that
# cannot affect them, and that it judges the staged INDEX rather than the
# working tree: a partial stage (some hunks staged, one more unstaged edit on
# top — the ordinary `git add -p` shape) must be judged as it will actually
# be committed, in both directions.
#
# Deterministic on purpose: file in, file out, exit code out. No model runs,
# no network, and the only git repositories touched are temporary ones this
# file creates under mktemp -d and destroys on exit. This checkout's own
# core.hooksPath is read for a before/after comparison, never written.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 2

case "${1-}" in
  -h|--help)
    cat <<'EOF'
tests/run-git-hooks.sh — offline checks for the local git hook installer.

Takes no arguments; builds temporary fixture git repositories under mktemp -d
(full copies of this working tree) and exercises
scripts/sh/install-git-hooks.sh and scripts/git-hooks/pre-commit against them,
including a plain clone, a linked worktree of one, and a partial stage in
both directions (defect staged/tree reverted, and the reverse). Never touches
this checkout's own git config.

  --help    this text

Exit codes: 0 every check passed · 1 at least one failed · 2 not run from the repo
EOF
    exit 0;;
esac

ROOT="$PWD"
INSTALLER="$ROOT/scripts/sh/install-git-hooks.sh"
HOOK="$ROOT/scripts/git-hooks/pre-commit"

fails=0
ok()  { echo "  ok    $1"; }
bad() { echo "  FAIL  $1"; fails=1; }
check(){ if [ "$2" = "$3" ]; then ok "$1"; else bad "$1 (expected '$3', got '$2')"; fi; }

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

before_hookspath="$(git config --get core.hooksPath 2>/dev/null || true)"

# A fixture repository is a full copy of this working tree (any uncommitted
# edit to the two new scripts included), so the real validators see real
# skill content and a real ~9s run, not a simulated one. In this worktree
# .git is a pointer FILE, not a directory — it is removed before `git init`
# runs, and no git command runs in the fixture before that removal, so the
# fixture never shares state with the real repository.
fixture() {  # <dest dir>
  local dest="$1"
  mkdir -p "$dest"
  cp -a "$ROOT/." "$dest/"
  rm -f "$dest/.git"
  git -C "$dest" init -q
  git -C "$dest" config user.email t@example.invalid
  git -C "$dest" config user.name tester
  git -C "$dest" add -A
  git -C "$dest" commit -qm base
}

# Appends a vendor model name to a skill body — the concrete defect
# validate-skills.sh's VENDORS check exists to catch (see AGENTS.md
# "Authoring rules" #2). Any governed skill file works; this one is small.
break_a_skill() {  # <fixture dir>
  printf '\nNote: never mention Claude or Sonnet by name in skill text.\n' \
    >> "$1/skills/common/yagni/SKILL.md"
}

# For the F-6 "index clean, working tree broken" direction: stages a clean
# edit (kept in sync with its plugins/ mirror in the INDEX, so no incidental
# mirror-drift failure) to a skill that is not a member of any chain in
# chains.toml (so a few extra words cannot trip a chain budget sitting at its
# limit — scripts/sh/data/chains.toml's [bug-fix] chain has zero slack at
# 5898/5898 words), then breaks only the unstaged working-tree copy on top,
# without re-staging.
stage_clean_then_break_tree() {  # <fixture dir>
  local dest="$1"
  printf '\nA harmless clean note.\n' >> "$dest/skills/common/handoff/SKILL.md"
  printf '\nA harmless clean note.\n' >> "$dest/plugins/sdlc-skills/skills/handoff/SKILL.md"
  git -C "$dest" add skills/common/handoff/SKILL.md plugins/sdlc-skills/skills/handoff/SKILL.md
  printf '\nNote: never mention Claude or Sonnet by name in skill text.\n' \
    >> "$dest/skills/common/handoff/SKILL.md"
}

echo "--- both scripts exist, are executable, and answer --help with documented exit codes"
for s in "$INSTALLER" "$HOOK"; do
  if [ ! -f "$s" ]; then
    bad "$s: missing"
    continue
  fi
  [ -x "$s" ] && ok "$(basename "$s"): executable" || bad "$(basename "$s"): not executable"
  bash "$s" --help >"$tmp/help.out" 2>&1
  rc=$?
  if [ "$rc" -ne 0 ]; then
    bad "$(basename "$s"): --help exited $rc"
  elif grep -qi 'exit code' "$tmp/help.out"; then
    ok "$(basename "$s"): --help documents its exit codes"
  else
    bad "$(basename "$s"): --help does not document its exit codes"
  fi
done

echo "--- install-git-hooks.sh: refuses outside this repository's root"
notrepo="$tmp/not-a-repo"
mkdir -p "$notrepo"
( cd "$notrepo" && bash "$INSTALLER" >"$tmp/notrepo.out" 2>&1 )
rc=$?
check "not inside a git repository is refused (exit 2)" "$rc" "2"

fx1="$tmp/fx1"
fixture "$fx1"
( cd "$fx1/skills" && bash "$INSTALLER" >"$tmp/subdir.out" 2>&1 )
rc=$?
check "run from a subdirectory is refused (exit 2)" "$rc" "2"
current="$(git -C "$fx1" config --get core.hooksPath 2>/dev/null || true)"
[ -z "$current" ] && ok "a refused run leaves core.hooksPath unset" || bad "a refused run set core.hooksPath ($current)"

echo "--- install-git-hooks.sh: installs from the repository root when nothing was set before"
( cd "$fx1" && bash "$INSTALLER" >"$tmp/install1.out" 2>&1 )
rc=$?
check "install exits 0" "$rc" "0"
hp="$(git -C "$fx1" config --get core.hooksPath 2>/dev/null || true)"
check "core.hooksPath points at scripts/git-hooks" "$hp" "scripts/git-hooks"
common1="$(git -C "$fx1" rev-parse --git-common-dir)"
case "$common1" in /*) ;; *) common1="$fx1/$common1";; esac
if [ -f "$common1/sdlc-skills-hooks.previous" ]; then
  ok "previous-value file written beside the real git dir"
else
  bad "no previous-value file at $common1/sdlc-skills-hooks.previous"
fi

echo "--- install-git-hooks.sh --remove: restores unset when nothing was set before"
( cd "$fx1" && bash "$INSTALLER" --remove >"$tmp/remove1.out" 2>&1 )
rc=$?
check "--remove exits 0" "$rc" "0"
after="$(git -C "$fx1" config --get core.hooksPath 2>/dev/null || true)"
[ -z "$after" ] && ok "core.hooksPath is unset again" || bad "core.hooksPath still set to '$after'"

echo "--- install-git-hooks.sh: saves a prior custom value and --remove restores it"
fx2="$tmp/fx2"
fixture "$fx2"
git -C "$fx2" config core.hooksPath .githooks-custom
( cd "$fx2" && bash "$INSTALLER" >"$tmp/install2.out" 2>&1 )
rc=$?
check "install over an existing hooksPath exits 0" "$rc" "0"
hp2="$(git -C "$fx2" config --get core.hooksPath 2>/dev/null || true)"
check "core.hooksPath now points at scripts/git-hooks" "$hp2" "scripts/git-hooks"
( cd "$fx2" && bash "$INSTALLER" --remove >"$tmp/remove2.out" 2>&1 )
rc=$?
check "--remove exits 0" "$rc" "0"
restored="$(git -C "$fx2" config --get core.hooksPath 2>/dev/null || true)"
check "core.hooksPath is restored to the prior custom value" "$restored" ".githooks-custom"

echo "--- install-git-hooks.sh: saves a prior ABSOLUTE value and --remove restores it"
fx7="$tmp/fx7"
fixture "$fx7"
git -C "$fx7" config core.hooksPath /abs/path/to/hooks
( cd "$fx7" && bash "$INSTALLER" >"$tmp/install7.out" 2>&1 )
rc=$?
check "install over an existing absolute hooksPath exits 0" "$rc" "0"
hp7="$(git -C "$fx7" config --get core.hooksPath 2>/dev/null || true)"
check "core.hooksPath now points at scripts/git-hooks" "$hp7" "scripts/git-hooks"
( cd "$fx7" && bash "$INSTALLER" --remove >"$tmp/remove7.out" 2>&1 )
rc=$?
check "--remove exits 0" "$rc" "0"
restored7="$(git -C "$fx7" config --get core.hooksPath 2>/dev/null || true)"
check "core.hooksPath is restored to the prior absolute value" "$restored7" "/abs/path/to/hooks"

echo "--- install-git-hooks.sh --remove: a foreign core.hooksPath with no prior install is left untouched"
fx6="$tmp/fx6"
fixture "$fx6"
git -C "$fx6" config core.hooksPath some/other/hooks
( cd "$fx6" && bash "$INSTALLER" --remove >"$tmp/remove6.out" 2>&1 )
rc=$?
check "--remove exits 0 even though sdlc-skills was never installed here" "$rc" "0"
foreign="$(git -C "$fx6" config --get core.hooksPath 2>/dev/null || true)"
check "the pre-existing foreign core.hooksPath is untouched" "$foreign" "some/other/hooks"

echo "--- pre-commit: a staged edit to CHANGELOG.md alone commits fast, without the validators"
fx3="$tmp/fx3"
fixture "$fx3"
( cd "$fx3" && bash "$INSTALLER" >"$tmp/install3.out" 2>&1 )
rc=$?
check "install in the base clone exits 0" "$rc" "0"
printf '\nirrelevant test note\n' >> "$fx3/CHANGELOG.md"
git -C "$fx3" add CHANGELOG.md
start=$(date +%s)
git -C "$fx3" commit -qm "docs: note" >"$tmp/skip.out" 2>&1
rc=$?
end=$(date +%s)
elapsed=$((end - start))
check "the commit succeeds (exit 0)" "$rc" "0"
if grep -qi 'skip' "$tmp/skip.out"; then
  ok "the hook prints a skip marker"
else
  bad "the hook printed no skip marker: $(cat "$tmp/skip.out")"
fi
if [ "$elapsed" -le 3 ]; then
  ok "the commit returned in ${elapsed}s (validators were not run; a full run takes ~9s)"
else
  bad "the commit took ${elapsed}s — looks like the validators ran despite the CHANGELOG.md-only change"
fi

echo "--- pre-commit: same relative core.hooksPath resolves in a linked worktree, and a staged skill defect fails the commit there"
wt="$tmp/fx3-wt"
git -C "$fx3" worktree add -q "$wt" -b wt-branch >"$tmp/wtadd.out" 2>&1
rc=$?
check "adding a linked worktree succeeds" "$rc" "0"
hpwt="$(git -C "$wt" config --get core.hooksPath 2>/dev/null || true)"
check "the linked worktree sees the same core.hooksPath" "$hpwt" "scripts/git-hooks"
if [ -x "$wt/scripts/git-hooks/pre-commit" ]; then
  ok "the linked worktree has its own executable copy of the hook"
else
  bad "no executable pre-commit at $wt/scripts/git-hooks/pre-commit"
fi
break_a_skill "$wt"
git -C "$wt" add skills/common/yagni/SKILL.md
git -C "$wt" commit -qm "break a skill" >"$tmp/wtdefect.out" 2>&1
rc=$?
if [ "$rc" -ne 0 ]; then
  ok "the commit is refused in the linked worktree (exit $rc)"
else
  bad "the commit succeeded in the linked worktree despite the vendor-name defect"
fi
if grep -q 'validate-skills.sh' "$tmp/wtdefect.out"; then
  ok "the hook's output names the failing validator (validate-skills.sh)"
else
  bad "the hook's output does not name the failing validator: $(tail -5 "$tmp/wtdefect.out")"
fi

echo "--- install-git-hooks.sh --remove: run from inside the linked worktree restores core.hooksPath"
( cd "$wt" && bash "$INSTALLER" --remove >"$tmp/wtremove.out" 2>&1 )
rc=$?
check "--remove from the worktree exits 0" "$rc" "0"
after_wt_parent="$(git -C "$fx3" config --get core.hooksPath 2>/dev/null || true)"
[ -z "$after_wt_parent" ] && ok "core.hooksPath is unset again, read from the parent clone" \
  || bad "core.hooksPath still set to '$after_wt_parent', read from the parent clone"
after_wt_self="$(git -C "$wt" config --get core.hooksPath 2>/dev/null || true)"
[ -z "$after_wt_self" ] && ok "core.hooksPath is unset again, read from the worktree itself" \
  || bad "core.hooksPath still set to '$after_wt_self', read from the worktree itself"

echo "--- pre-commit: a staged skill defect in a plain clone fails the commit and names the validator"
fx4="$tmp/fx4"
fixture "$fx4"
( cd "$fx4" && bash "$INSTALLER" >"$tmp/install4.out" 2>&1 )
break_a_skill "$fx4"
git -C "$fx4" add skills/common/yagni/SKILL.md
git -C "$fx4" commit -qm "break a skill" >"$tmp/defect4.out" 2>&1
rc=$?
if [ "$rc" -ne 0 ]; then
  ok "the commit is refused (exit $rc)"
else
  bad "the commit succeeded despite the vendor-name defect"
fi
if grep -q 'validate-skills.sh' "$tmp/defect4.out"; then
  ok "the hook's output names the failing validator (validate-skills.sh)"
else
  bad "the hook's output does not name the failing validator: $(tail -5 "$tmp/defect4.out")"
fi
if grep -qi 'vendor model name' "$tmp/defect4.out"; then
  ok "the real validator's own diagnostic reaches the commit output"
else
  bad "no validator diagnostic in the commit output — looks like a stub, not the real check"
fi

echo "--- pre-commit: a staged edit under plugins/sdlc-skills/ alone still runs validate-skills.sh (mirror drift)"
fx5="$tmp/fx5"
fixture "$fx5"
( cd "$fx5" && bash "$INSTALLER" >"$tmp/install5.out" 2>&1 )
# Desync only the mirror: validate-codex-plugin.sh (run by validate-skills.sh)
# diffs skills/<name> against plugins/sdlc-skills/skills/<name> and fails when
# they differ — this is where mirror drift is caught.
printf '\nmirror-only edit\n' >> "$fx5/plugins/sdlc-skills/skills/yagni/SKILL.md"
git -C "$fx5" add plugins/sdlc-skills/skills/yagni/SKILL.md
start=$(date +%s)
git -C "$fx5" commit -qm "mirror only" >"$tmp/mirror.out" 2>&1
rc=$?
end=$(date +%s)
elapsed=$((end - start))
if [ "$rc" -ne 0 ]; then
  ok "the commit is refused for a plugins/-only mirror edit (exit $rc)"
else
  bad "the commit succeeded despite desyncing the mirror"
fi
if grep -qi 'mirror' "$tmp/mirror.out" || grep -q 'validate-skills.sh' "$tmp/mirror.out"; then
  ok "the hook's output names the failing validator for the plugins/-only change"
else
  bad "the hook's output does not name the failing validator: $(tail -5 "$tmp/mirror.out")"
fi
if [ "$elapsed" -ge 2 ]; then
  ok "the validators actually ran for a plugins/-only change (${elapsed}s, not an instant skip)"
else
  bad "a plugins/-only change looked skipped (${elapsed}s) — plugins/ must still trigger the gate"
fi

echo "--- pre-commit: a partial stage (defect staged, working-tree copy reverted) still fails the commit"
# The ordinary `git add -p` shape: stage a defect, then revert only the
# working-tree file without re-staging (MM status — the index still carries
# the defect, the tree does not). The hook must judge the index it exported,
# not the tree, so the commit is still refused.
fx8="$tmp/fx8"
fixture "$fx8"
( cd "$fx8" && bash "$INSTALLER" >"$tmp/install8.out" 2>&1 )
break_a_skill "$fx8"
git -C "$fx8" add skills/common/yagni/SKILL.md
git -C "$fx8" show HEAD:skills/common/yagni/SKILL.md > "$fx8/skills/common/yagni/SKILL.md"
git -C "$fx8" status --porcelain skills/common/yagni/SKILL.md | grep -q '^MM' \
  && ok "fixture is a genuine partial stage (MM: index defective, tree clean)" \
  || bad "fixture setup did not produce MM status: $(git -C "$fx8" status --porcelain skills/common/yagni/SKILL.md)"
git -C "$fx8" commit -qm "partial stage" >"$tmp/partial-defect.out" 2>&1
rc=$?
if [ "$rc" -ne 0 ]; then
  ok "the commit is refused even though the working tree looks clean (exit $rc)"
else
  bad "the commit succeeded — the hook validated the reverted working tree, not the staged defect"
fi
if grep -q 'validate-skills.sh' "$tmp/partial-defect.out"; then
  ok "the hook's output names the failing validator (validate-skills.sh)"
else
  bad "the hook's output does not name the failing validator: $(tail -5 "$tmp/partial-defect.out")"
fi

echo "--- pre-commit: a clean stage with only the unstaged working-tree copy broken still commits"
# The inverse partial stage: the index is clean (and mirror-synced), only an
# unstaged edit on top of the working-tree file is broken. The hook must
# still judge the index, so the commit succeeds and carries the clean text.
fx9="$tmp/fx9"
fixture "$fx9"
( cd "$fx9" && bash "$INSTALLER" >"$tmp/install9.out" 2>&1 )
stage_clean_then_break_tree "$fx9"
git -C "$fx9" status --porcelain skills/common/handoff/SKILL.md | grep -q '^MM' \
  && ok "fixture is a genuine partial stage (MM: index clean, tree defective)" \
  || bad "fixture setup did not produce MM status: $(git -C "$fx9" status --porcelain skills/common/handoff/SKILL.md)"
git -C "$fx9" commit -qm "clean index, broken tree" >"$tmp/partial-clean.out" 2>&1
rc=$?
check "the commit succeeds — only the index is judged (exit 0)" "$rc" "0"
committed="$(git -C "$fx9" show HEAD:skills/common/handoff/SKILL.md)"
case "$committed" in
  *Claude*|*Sonnet*) bad "the committed content carries the unstaged defect — the hook validated the working tree" ;;
  *)                 ok "the committed content is exactly the clean staged version, not the broken working tree" ;;
esac

echo "--- this checkout's own git config is untouched"
after_hookspath="$(git config --get core.hooksPath 2>/dev/null || true)"
check "core.hooksPath in the real checkout is unchanged by the test" "$after_hookspath" "$before_hookspath"

echo "---"
[ "$fails" -eq 0 ] && { echo "git hook tests: PASS"; exit 0; }
echo "git hook tests: FAIL"; exit 1
