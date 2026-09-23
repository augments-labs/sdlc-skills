#!/usr/bin/env bash
# Offline tests for state-identity.sh, including its non-repository mode.
#
# What this guards: a deliverable with no git repository behind it at all —
# T-005's own motivating case — used to make state-identity.sh exit 2 before
# it produced anything, so no gate could bind evidence to it. This pins the
# existing in-repository behaviour (digest stability, drift, --committed) and
# proves the non-repository mode: a stable digest over the directory's files,
# drift when a file's content changes, .sdlc-skills/evidence/ left out, and
# --committed refusing to claim a commit can hold a state with no repository
# behind it.
#
# Deterministic on purpose: file in, file out, exit code out. No model runs,
# no network, and the only git repositories touched are ones this file
# creates under a temporary directory removed on exit.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 2
ROOT="$PWD"

case "${1-}" in
  -h|--help)
    cat <<'EOF'
tests/run-state-identity.sh — offline unit checks for state-identity.sh.

Takes no arguments; exercises the script inside a temporary git repository
(pinning its existing behaviour) and against a temporary plain directory
outside any repository (its non-repository mode). Never mutates the checkout.

  --help    this text

Exit codes: 0 every check passed · 1 at least one failed · 2 not run from the repo
EOF
    exit 0;;
esac

S=skills/testing/verification-before-completion/scripts/state-identity.sh
[ -f "$S" ] || { echo "not run from the repository root" >&2; exit 2; }
S_ABS="$ROOT/$S"

fails=0
ok()  { echo "  ok    $1"; }
bad() { echo "  FAIL  $1"; fails=1; }
check(){ if [ "$2" = "$3" ]; then ok "$1"; else bad "$1 (expected '$3', got '$2')"; fi; }

tmp="$(mktemp -d)" || exit 2
trap 'rm -rf "$tmp"' EXIT

echo "--- inside a git repository: existing behaviour is pinned"
repo="$tmp/repo"
mkdir -p "$repo"
git -C "$repo" init -q
git -C "$repo" config user.email t@example.invalid
git -C "$repo" config user.name tester
printf 'one\n' > "$repo/a.txt"
git -C "$repo" add a.txt
git -C "$repo" commit -qm base

rd1="$(cd "$repo" && bash "$S_ABS" --quiet)"
rd2="$(cd "$repo" && bash "$S_ABS" --quiet)"
check "in-repo digest is stable across two runs" "$rd1" "$rd2"

printf 'two\n' > "$repo/a.txt"
rd3="$(cd "$repo" && bash "$S_ABS" --quiet)"
[ "$rd3" != "$rd1" ] && ok "in-repo digest drifts on an edit" || bad "in-repo digest did not drift on an edit"

(cd "$repo" && bash "$S_ABS" --compare "$rd1" >/dev/null 2>"$tmp/repo-drift.err")
rc=$?
check "in-repo --compare detects drift (exit 1)" "$rc" "1"

git -C "$repo" add -A
git -C "$repo" commit -qm work
committed_out="$(cd "$repo" && bash "$S_ABS" --committed --quiet)"
rc=$?
check "in-repo --committed on a clean commit exits 0" "$rc" "0"
want_head="$(git -C "$repo" rev-parse HEAD)"
check "in-repo --committed prints the revision" "$committed_out" "$want_head"

json1="$(cd "$repo" && bash "$S_ABS")"
keys="$(printf '%s\n' "$json1" | grep -oE '"[a-zA-Z_]+":' | tr -d '":' | LC_ALL=C sort -u)"
want_keys="$(printf '%s\n' branch captured_at clean cwd digest environment head platform schema source staged_count unstaged_count untracked_count workspace | LC_ALL=C sort -u)"
check "in-repo JSON field shape is unchanged by the non-repository-mode addition" "$keys" "$want_keys"

echo "--- outside any repository: non-repository mode"
plain="$tmp/plain"
mkdir -p "$plain"
printf 'hello\n' > "$plain/a.txt"
printf 'world\n' > "$plain/b.txt"

nd0a="$(bash "$S_ABS" --path "$plain" --quiet)"
rc=$?
check "non-repo --quiet exits 0" "$rc" "0"
nd0b="$(bash "$S_ABS" --path "$plain" --quiet)"
check "non-repo digest is stable across two runs" "$nd0a" "$nd0b"

printf 'world-changed\n' > "$plain/b.txt"
nd_changed="$(bash "$S_ABS" --path "$plain" --quiet)"
[ "$nd_changed" != "$nd0a" ] && ok "non-repo digest changes when a file's content changes" \
  || bad "non-repo digest did not change when a file's content changed"

printf 'world\n' > "$plain/b.txt"
nd_restored="$(bash "$S_ABS" --path "$plain" --quiet)"
check "non-repo digest returns once the file is restored" "$nd_restored" "$nd0a"

mkdir -p "$plain/.sdlc-skills/evidence"
printf 'note\n' > "$plain/.sdlc-skills/evidence/note.md"
nd_evidence1="$(bash "$S_ABS" --path "$plain" --quiet)"
check "non-repo digest ignores a new file under .sdlc-skills/evidence/" "$nd_evidence1" "$nd0a"
printf 'note-changed\n' > "$plain/.sdlc-skills/evidence/note.md"
nd_evidence2="$(bash "$S_ABS" --path "$plain" --quiet)"
check "non-repo digest ignores an edit under .sdlc-skills/evidence/" "$nd_evidence2" "$nd0a"

printf 'drift\n' > "$plain/a.txt"
bash "$S_ABS" --path "$plain" --compare "$nd0a" >/dev/null 2>"$tmp/plain-drift.err"
rc=$?
check "non-repo --compare detects drift (exit 1)" "$rc" "1"
printf 'hello\n' > "$plain/a.txt"
bash "$S_ABS" --path "$plain" --compare "$nd0a" >/dev/null 2>"$tmp/plain-match.err"
rc=$?
check "non-repo --compare matches once restored (exit 0)" "$rc" "0"

bash "$S_ABS" --path "$plain" --committed >"$tmp/plain-committed.out" 2>"$tmp/plain-committed.err"
rc=$?
check "non-repo --committed exits 5" "$rc" "5"
if grep -qi 'commit' "$tmp/plain-committed.err" && grep -qi 'no repository\|no commit' "$tmp/plain-committed.err"; then
  ok "non-repo --committed names why no commit can hold the state"
else
  bad "non-repo --committed error does not explain that no commit can hold the state"
fi

json2="$(bash "$S_ABS" --path "$plain")"
rc=$?
check "non-repo default JSON call exits 0" "$rc" "0"
if printf '%s\n' "$json2" | grep -qF '"repository": "none"'; then
  ok "non-repo JSON carries \"repository\": \"none\""
else
  bad "non-repo JSON is missing \"repository\": \"none\""
fi
if printf '%s\n' "$json2" | grep -q '"head"'; then
  bad "non-repo JSON still carries a HEAD field"
else
  ok "non-repo JSON carries no HEAD field"
fi
if printf '%s\n' "$json2" | grep -qF '"digest"'; then
  ok "non-repo JSON carries a digest field"
else
  bad "non-repo JSON is missing a digest field"
fi

echo "--- outside any repository: entering it via cwd works the same as --path"
cwd_out="$(cd "$plain" && bash "$S_ABS")"
rc=$?
check "cwd-only invocation (no --path) exits 0 outside a repository" "$rc" "0"
if printf '%s\n' "$cwd_out" | grep -qF '"repository": "none"'; then
  ok "cwd-only invocation also reports \"repository\": \"none\""
else
  bad "cwd-only invocation does not report \"repository\": \"none\""
fi

bash "$S_ABS" --path "$tmp/does-not-exist" >/dev/null 2>"$tmp/badpath.err"
rc=$?
check "--path naming a missing directory is a usage error (exit 2)" "$rc" "2"

echo "--- --help documents the non-repository mode"
help_out="$(bash "$S_ABS" --help)"
if printf '%s\n' "$help_out" | grep -qF -- '--path'; then
  ok "--help documents --path"
else
  bad "--help does not document --path"
fi
if printf '%s\n' "$help_out" | grep -qF '"repository": "none"'; then
  ok "--help documents the repository: none output"
else
  bad "--help does not document the repository: none output"
fi
if printf '%s\n' "$help_out" | grep -qi 'embedded git repository below'; then
  ok "--help documents the non-repo embedded-repository rule"
else
  bad "--help does not document the non-repo embedded-repository rule"
fi

echo "--- non-repo digest resists path-based delimiter injection (F-1)"
# The reviewer's collision: a manifest that joins hash<TAB>path<NEWLINE> records
# lets a single crafted filename (embedding a real record's hash and a tab)
# reproduce the exact byte string two ordinary files would produce. b.txt="Y\n"
# and z.txt="X\n" hash to Hb/Hz; a lone file named "b.txt<NEWLINE>Hz<TAB>z.txt"
# with body "Y\n" must no longer collide with the two-file directory.
collideA="$tmp/collideA"
collideB="$tmp/collideB"
mkdir -p "$collideA" "$collideB"
printf 'Y\n' > "$collideA/b.txt"
printf 'X\n' > "$collideA/z.txt"
Hz="$(printf 'X\n' | git hash-object --stdin)"
collide_name="b.txt"$'\n'"$Hz"$'\t'"z.txt"
printf 'Y\n' > "$collideB/$collide_name"

digA="$(bash "$S_ABS" --path "$collideA" --quiet)"
digB="$(bash "$S_ABS" --path "$collideB" --quiet)"
if [ "$digA" != "$digB" ]; then
  ok "non-repo digest does not collide across a newline/tab-crafted filename"
else
  bad "non-repo digest collides: a crafted filename (embedding a newline and a tab) reproduces another directory's digest ($digA)"
fi

echo "--- non-repo mode refuses an embedded git repository (F-2)"
embedded_parent="$tmp/embedded"
embedded_sub="$embedded_parent/sub"
mkdir -p "$embedded_sub"
git -C "$embedded_sub" init -q
git -C "$embedded_sub" config user.email t@example.invalid
git -C "$embedded_sub" config user.name tester
printf 'inner\n' > "$embedded_sub/inner.txt"
git -C "$embedded_sub" add inner.txt
git -C "$embedded_sub" commit -qm inner
printf 'outer\n' > "$embedded_parent/outer.txt"

bash "$S_ABS" --path "$embedded_parent" >"$tmp/embedded.out" 2>"$tmp/embedded.err"
rc=$?
check "non-repo mode exits 4 on an embedded git repository" "$rc" "4"
if grep -qi 'embedded' "$tmp/embedded.err" && grep -qF 'sub' "$tmp/embedded.err"; then
  ok "non-repo embedded-repository error names the path"
else
  bad "non-repo embedded-repository error does not name the path"
fi
# A plain directory with no embedded repository is unaffected.
check "non-repo mode without an embedded repository still exits 0" "$(bash "$S_ABS" --path "$plain" >/dev/null 2>&1; echo $?)" "0"

echo "---"
[ "$fails" -eq 0 ] && { echo "state-identity.sh tests: PASS"; exit 0; }
echo "state-identity.sh tests: FAIL"; exit 1
