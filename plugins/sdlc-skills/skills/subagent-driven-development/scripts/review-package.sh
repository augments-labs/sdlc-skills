#!/usr/bin/env bash
# Assemble what a task reviewer reads: the diff itself, the paths it touches, and
# an index naming both.
#
# Read-only with respect to the repository. Writes only under --out.

set -uo pipefail

usage() {
  cat <<'EOF'
Usage: bash scripts/review-package.sh --repo DIR --base REV --head REV --out DIR [OPTIONS]

Assemble one task's review package: diff.patch, files.txt, and package.md naming
both. A reviewer given the package reads the change; a reviewer given a summary
of the change reviews the summary.

Options:
  --repo DIR   the worktree the work was done in
  --base REV   the revision the task started from
  --head REV   the revision the worker returned
  --out DIR    where the three files are written
  --task FILE  the task file, named in package.md as the contract to judge against
  --help       show this message

Exit codes:
  0  package written; its directory is on stdout
  1  the range is empty — there is nothing to review
  2  bad arguments, not a git repository, or --out cannot be written
  3  base is not an ancestor of head
EOF
}

repo=""; base=""; head_rev=""; out=""; task=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --repo) repo="${2-}"; shift 2;;
    --base) base="${2-}"; shift 2;;
    --head) head_rev="${2-}"; shift 2;;
    --out)  out="${2-}"; shift 2;;
    --task) task="${2-}"; shift 2;;
    -h|--help) usage; exit 0;;
    *) echo "unknown argument: $1 (see --help)" >&2; exit 2;;
  esac
done

for pair in "repo:--repo" "base:--base" "head_rev:--head" "out:--out"; do
  var="${pair%%:*}"; flag="${pair#*:}"
  [ -n "${!var}" ] || { echo "$flag is required (see --help)" >&2; exit 2; }
done

[ -d "$repo" ] || { echo "no directory at $repo" >&2; exit 2; }
inside="$(git -C "$repo" rev-parse --is-inside-work-tree 2>/dev/null)"
[ "$inside" = "true" ] || { echo "$repo is not a git worktree" >&2; exit 2; }

for rev in "$base" "$head_rev"; do
  git -C "$repo" rev-parse --verify --quiet "$rev^{commit}" >/dev/null
  rc=$?
  [ "$rc" -eq 0 ] || { echo "not a commit in $repo: $rev" >&2; exit 2; }
done

git -C "$repo" merge-base --is-ancestor "$base" "$head_rev" || {
  echo "review-package: $base is not an ancestor of $head_rev" >&2; exit 3; }

names="$(git -C "$repo" diff --name-only "$base" "$head_rev")"
rc=$?
[ "$rc" -eq 0 ] || { echo "git diff failed between $base and $head_rev" >&2; exit 2; }
if [ -z "$names" ]; then
  echo "nothing changed between $base and $head_rev — there is no package to build" >&2
  exit 1
fi

mkdir -p "$out" 2>/dev/null || { echo "cannot create $out" >&2; exit 2; }

git -C "$repo" diff "$base" "$head_rev" > "$out/diff.patch"
rc=$?
[ "$rc" -eq 0 ] || { echo "cannot write $out/diff.patch" >&2; exit 2; }
printf '%s\n' "$names" > "$out/files.txt" || { echo "cannot write $out/files.txt" >&2; exit 2; }

count="$(printf '%s\n' "$names" | grep -c .)"
{
  printf '# Review package\n\n'
  printf '| Field | Value |\n| --- | --- |\n'
  printf '| Base | `%s` |\n' "$base"
  printf '| Head | `%s` |\n' "$head_rev"
  printf '| Worktree | `%s` |\n' "$repo"
  printf '| Files changed | %s |\n' "$count"
  if [ -n "$task" ]; then printf '| Task contract | `%s` |\n' "$task"; fi
  printf '\n'
  printf -- '- `diff.patch` — the change itself. Read it; it is the candidate.\n'
  printf -- '- `files.txt` — every path the change touches, one per line.\n'
  if [ -n "$task" ]; then printf -- '- `%s` — what the change was asked to do.\n' "$task"; fi
} > "$out/package.md" || { echo "cannot write $out/package.md" >&2; exit 2; }

printf '%s\n' "$out"
exit 0
