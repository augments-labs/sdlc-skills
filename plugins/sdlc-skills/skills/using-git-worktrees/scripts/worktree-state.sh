#!/usr/bin/env bash
# Report checkout isolation, submodule status, dirty state, base resolution,
# branch collisions, and .worktrees/ ignore status as JSON on stdout.
#
# Read-only for repository files, refs, and the index.

set -uo pipefail

usage() {
  cat <<'EOF'
Usage: bash scripts/worktree-state.sh [OPTIONS]

Report checkout isolation, submodule status, dirty state, base resolution,
branch collisions, and .worktrees/ ignore status as JSON on stdout.
Read-only for repository files, refs, and the index.

Options:
  --dir DIR            Inspect repository at DIR (default: current directory).
  --base REF           Resolve REF and origin/REF commits in the base object.
  --check-branch NAME  Validate branch ref format and check local/remote collisions.
  --help               Show this help message.

Exit codes:
  0  state reported (and --check-branch, if given, is valid and unused)
  1  --check-branch failed (invalid ref format or local/remote branch exists)
  2  usage error or not inside a git repository
  3  git is not on PATH
EOF
}

dir="."
base_ref=""
check_branch=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dir)
      dir="${2:-}"
      [ -n "$dir" ] || { echo "Error: --dir requires a path." >&2; exit 2; }
      shift 2
      ;;
    --base)
      base_ref="${2:-}"
      [ -n "$base_ref" ] || { echo "Error: --base requires a ref." >&2; exit 2; }
      shift 2
      ;;
    --check-branch)
      check_branch="${2:-}"
      [ -n "$check_branch" ] || { echo "Error: --check-branch requires a branch name." >&2; exit 2; }
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Error: unknown argument \"$1\". Run with --help for usage." >&2
      exit 2
      ;;
  esac
done

command -v git >/dev/null 2>&1 || { echo "Error: git is not on PATH." >&2; exit 3; }

cd "$dir" 2>/dev/null || { echo "Error: cannot access directory \"$dir\"." >&2; exit 2; }
git rev-parse --git-dir >/dev/null 2>&1 || { echo "Error: not inside a git repository." >&2; exit 2; }

jstr() {
  local s="${1-}"
  s="${s//\\/\\\\}"; s="${s//\"/\\\"}"
  s="${s//	/\\t}"
  s="${s//$'\r'/\\r}"; s="${s//$'\n'/\\n}"
  printf '"%s"' "$s"
}
jbool() { case "${1:-}" in 1) printf 'true';; *) printf 'false';; esac; }
jnull() { [ -n "${1-}" ] && jstr "$1" || printf 'null'; }
jarray() {
  local first=1 line
  printf '['
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    [ "$first" = 1 ] || printf ', '
    first=0
    jstr "$line"
  done
  printf ']'
}

toplevel="$(git rev-parse --show-toplevel 2>/dev/null)" || toplevel=""
superproject="$(git rev-parse --show-superproject-working-tree 2>/dev/null)" || superproject=""
git_dir="$(cd "$(git rev-parse --git-dir 2>/dev/null)" 2>/dev/null && pwd -P)" || git_dir=""
common_dir="$(cd "$(git rev-parse --git-common-dir 2>/dev/null)" 2>/dev/null && pwd -P)" || common_dir=""

linked=0
if [ -z "$superproject" ] && [ -n "$git_dir" ] && [ -n "$common_dir" ] && [ "$git_dir" != "$common_dir" ]; then
  linked=1
fi

bare=0
[ "$(git rev-parse --is-bare-repository 2>/dev/null)" = "true" ] && bare=1

branch="$(git symbolic-ref --quiet --short HEAD 2>/dev/null)" || branch=""
detached=0
[ -n "$branch" ] || detached=1

main_root=""
candidate_root="${common_dir%/.git}"
if [ -n "$common_dir" ] && [ "$candidate_root" != "$common_dir" ] && git -C "$candidate_root" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  main_root="$candidate_root"
fi

worktrees_ignored=0
if [ -n "$main_root" ] && git -C "$main_root" check-ignore -q ".worktrees/" 2>/dev/null; then
  worktrees_ignored=1
fi

dirty_lines="$(git --no-optional-locks status --short 2>/dev/null)" || dirty_lines=""
dirty_count="$(printf '%s\n' "$dirty_lines" | grep -c . 2>/dev/null || true)"
wt_lines="$(git --no-optional-locks worktree list 2>/dev/null)" || wt_lines=""

base_json="null"
if [ -n "$base_ref" ]; then
  local_sha="$(git rev-parse --verify "${base_ref}^{commit}" 2>/dev/null)" || local_sha=""
  remote_sha="$(git rev-parse --verify "origin/${base_ref}^{commit}" 2>/dev/null)" || remote_sha=""
  base_json="$(printf '{ "ref": %s, "local_sha": %s, "remote_sha": %s }' \
    "$(jstr "$base_ref")" "$(jnull "$local_sha")" "$(jnull "$remote_sha")")"
fi

branch_json="null"
rc=0
if [ -n "$check_branch" ]; then
  valid_fmt=0
  git check-ref-format --branch "$check_branch" >/dev/null 2>&1 && valid_fmt=1
  local_ex=0
  git show-ref --verify --quiet "refs/heads/$check_branch" 2>/dev/null && local_ex=1
  remote_ex=0
  git show-ref --verify --quiet "refs/remotes/origin/$check_branch" 2>/dev/null && remote_ex=1
  branch_json="$(printf '{ "name": %s, "valid_format": %s, "local_exists": %s, "remote_exists": %s }' \
    "$(jstr "$check_branch")" "$(jbool $valid_fmt)" "$(jbool $local_ex)" "$(jbool $remote_ex)")"
  if [ "$valid_fmt" -eq 0 ] || [ "$local_ex" -eq 1 ] || [ "$remote_ex" -eq 1 ]; then
    rc=1
  fi
fi

printf '{\n'
printf '  "schema": "worktree-state/1",\n'
printf '  "toplevel": %s,\n' "$(jnull "$toplevel")"
printf '  "git_dir": %s,\n' "$(jnull "$git_dir")"
printf '  "common_dir": %s,\n' "$(jnull "$common_dir")"
printf '  "linked_worktree": %s,\n' "$(jbool $linked)"
printf '  "submodule_superproject": %s,\n' "$(jstr "$superproject")"
printf '  "detached": %s,\n' "$(jbool $detached)"
printf '  "bare": %s,\n' "$(jbool $bare)"
printf '  "main_checkout_root": %s,\n' "$(jnull "$main_root")"
printf '  "branch": %s,\n' "$(jnull "$branch")"
printf '  "dirty_count": %s,\n' "${dirty_count:-0}"
printf '  "dirty": %s,\n' "$(printf '%s\n' "$dirty_lines" | jarray)"
printf '  "worktrees": %s,\n' "$(printf '%s\n' "$wt_lines" | jarray)"
printf '  "worktrees_dir_ignored": %s,\n' "$(jbool $worktrees_ignored)"
printf '  "base": %s,\n' "$base_json"
printf '  "branch_check": %s\n' "$branch_json"
printf '}\n'

exit "$rc"
