#!/usr/bin/env bash
# Walk a plan's tasks in index order and resolve every path each task's
# Files line names against a base revision: a path a task edits or deletes
# must exist at the base or be created by an earlier task, and a path a
# task creates must not already exist. Read-only.
#
# This is the deterministic half of the walk writing-plans asks for before a
# plan is presented. A Files list written from a design names the files the
# design discusses; this script catches the ones that are not there.

set -uo pipefail

usage() {
  cat <<'USAGE'
Usage: bash scripts/plan-files.sh [--base REV] [--repo DIR] PLAN_DIR

Read PLAN_DIR/00-index.md, take its task rows in order, and for each task
file read the **Files:** line. A task whose state is cancelled, superseded,
done, or done with concerns is skipped: its effects are in REV or never
will be. Every backticked path on the line is resolved against REV in the
repository, in task order:

  `path` or `path (edit)`      must exist at REV or be created by an earlier task
  `path (new)`                 must not exist at REV nor be created earlier
  `path (delete)`              must exist; no later task may name it without (new)

Prints one line per walked task, "ok" or "gap", then a summary line. Each
gap is also written to stderr with the task that owns it. A walked task
with no **Files:** line, or none that names a path, is a gap. Writes
nothing.

Options:
  --base REV   the revision to resolve against (default: HEAD)
  --repo DIR   the repository the paths are relative to (default: the
               repository that contains PLAN_DIR)
  --help       Show this message.

Exit codes:
  0  every path resolves
  1  at least one path does not resolve
  2  usage error, the index or a listed task file is missing, DIR is not a
     git repository, or REV does not resolve in it
USAGE
}

base="HEAD"; repo=""; dir=""
while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0;;
    --base) [ $# -ge 2 ] || { echo "Error: --base needs a revision." >&2; exit 2; }; base="$2"; shift 2;;
    --repo) [ $# -ge 2 ] || { echo "Error: --repo needs a directory." >&2; exit 2; }; repo="$2"; shift 2;;
    -*) echo "Error: unknown option $1. Run with --help for usage." >&2; exit 2;;
    *) [ -z "$dir" ] || { echo "Error: expected one PLAN_DIR. Run with --help for usage." >&2; exit 2; }; dir="$1"; shift;;
  esac
done
[ -n "$dir" ] || { echo "Error: PLAN_DIR is required. Run with --help for usage." >&2; exit 2; }
index="$dir/00-index.md"
[ -f "$index" ] || { echo "Error: $index not found." >&2; exit 2; }
[ -n "$repo" ] || repo="$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null)" ||
  { echo "Error: $dir is not inside a git repository; pass --repo." >&2; exit 2; }
git -C "$repo" rev-parse --is-inside-work-tree >/dev/null 2>&1 ||
  { echo "Error: $repo is not a git repository." >&2; exit 2; }
rev="$(git -C "$repo" rev-parse --verify --quiet "${base}^{commit}")" ||
  { echo "Error: revision $base does not resolve in $repo." >&2; exit 2; }

# Task rows under "## Tasks": "- [ ] `ID` — title · `file.md` · `state`".
rows="$(awk '
  /^[[:space:]]*(```|~~~)/ { in_fence = !in_fence; next }
  in_fence { next }
  /^## / { in_tasks = ($0 ~ /^## Tasks[[:space:]]*$/) }
  in_tasks && /^- \[[ xX]\] `[^`]+`/ {
    line = $0
    n = split(line, bt, "`")
    if (n < 7) next
    id = bt[2]; tf = bt[n - 3]; st = bt[n - 1]
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", st)
    print id "\t" tf "\t" st
  }' "$index")"
[ -n "$rows" ] || { echo "Error: no task rows under ## Tasks in $index." >&2; exit 2; }

# One record per path, in task order: id<TAB>action<TAB>path.
paths=""
while IFS=$'\t' read -r id tf st; do
  case "$st" in cancelled|superseded|done|"done with concerns") continue;; esac
  f="$dir/$tf"
  [ -f "$f" ] || { echo "Error: task $id lists $tf, which is missing from $dir." >&2; exit 2; }
  rec="$(awk -v id="$id" '
    /^\*\*Files:\*\*/ {
      rest = $0; sub(/^\*\*Files:\*\*/, "", rest)
      while (match(rest, /`[^`]+`/)) {
        fp = substr(rest, RSTART + 1, RLENGTH - 2)
        rest = substr(rest, RSTART + RLENGTH)
        act = "edit"
        if (match(rest, /^[[:space:]]*\([^)]*\)/)) {
          m = tolower(substr(rest, RSTART, RLENGTH)); gsub(/[[:space:]()]/, "", m)
          if (m == "new" || m == "create" || m == "created") act = "new"
          else if (m == "delete" || m == "deleted" || m == "remove" || m == "removed") act = "delete"
        }
        if (fp != "" && fp !~ /^\{\{/) print id "\t" act "\t" fp
      }
    }' "$f")"
  [ -n "$rec" ] || rec="$id"$'\t'"none"$'\t'
  paths="${paths}${rec}"$'\n'
done <<ROWS
$rows
ROWS

gaps=0; npaths=0; ntasks=0; cur=""; cur_ok=1
declare -A created=() deleted=()
flush() { [ -n "$cur" ] && { ntasks=$((ntasks + 1)); echo "$cur $([ "$cur_ok" = 1 ] && echo ok || echo gap)"; }; }
while IFS=$'\t' read -r id act fp; do
  [ -n "$id" ] || continue
  if [ "$id" != "$cur" ]; then flush; cur="$id"; cur_ok=1; fi
  npaths=$((npaths + 1))
  at_base=0; git -C "$repo" cat-file -e "$rev:$fp" 2>/dev/null && at_base=1
  live=0
  if [ -n "${created[$fp]+x}" ]; then live=1
  elif [ "$at_base" = 1 ] && [ -z "${deleted[$fp]+x}" ]; then live=1; fi
  case "$act" in
    none)
      npaths=$((npaths - 1))
      echo "gap: task $id has no Files line naming a path." >&2
      gaps=$((gaps + 1)); cur_ok=0;;
    edit)
      if [ "$live" = 0 ]; then
        if [ -n "${deleted[$fp]+x}" ]; then echo "gap: task $id edits $fp, which task ${deleted[$fp]} deletes." >&2
        else echo "gap: task $id edits $fp, which is not at $base and no earlier task creates." >&2; fi
        gaps=$((gaps + 1)); cur_ok=0
      fi;;
    new)
      if [ "$live" = 1 ]; then
        if [ -n "${created[$fp]+x}" ]; then echo "gap: task $id creates $fp, which task ${created[$fp]} already creates." >&2
        else echo "gap: task $id creates $fp, which already exists at $base." >&2; fi
        gaps=$((gaps + 1)); cur_ok=0
      else created[$fp]="$id"; unset "deleted[$fp]"; fi;;
    delete)
      if [ "$live" = 0 ]; then
        echo "gap: task $id deletes $fp, which is not at $base and no earlier task creates." >&2
        gaps=$((gaps + 1)); cur_ok=0
      else deleted[$fp]="$id"; unset "created[$fp]"; fi;;
  esac
done <<PATHS
$paths
PATHS
flush
echo "tasks=$ntasks paths=$npaths gaps=$gaps base=$base"
[ "$gaps" -eq 0 ] && exit 0 || exit 1
