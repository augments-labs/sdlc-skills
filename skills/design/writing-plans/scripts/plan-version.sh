#!/usr/bin/env bash
# Print a plan's version: git hash-object over its index, with every task
# checkbox and state label normalized, followed by every task file the index
# lists, in order. Read-only.
#
# The version binds approval to the plan's content, not to a line the index
# declares about itself: mirroring task progress leaves it unchanged, and any
# edit to the index or to a task contract changes it.

set -uo pipefail

usage() {
  cat <<'USAGE'
Usage: bash scripts/plan-version.sh PLAN_DIR

Print the plan's version, 7 hex characters: git hash-object --stdin over
PLAN_DIR/00-index.md with every task checkbox normalized to "[ ]" and every
state label to "todo", followed by each task file the task list names, in
order. Read-only; writes nothing.

Exit codes:
  0  version printed
  2  usage error, the index or a listed task file is missing, a checkbox row
     under ## Tasks does not parse (indented, missing its backticked file,
     text after its state label, an unlisted state), or a task row sits
     outside ## Tasks
  3  git is not on PATH
USAGE
}

case "${1-}" in
  -h|--help) usage; exit 0;;
  '') echo "Error: PLAN_DIR is required. Run with --help for usage." >&2; exit 2;;
esac
[ "$#" -eq 1 ] || { echo "Error: expected one PLAN_DIR. Run with --help for usage." >&2; exit 2; }
dir=${1%/}
command -v git >/dev/null 2>&1 || { echo "Error: git is not on PATH." >&2; exit 3; }
index="$dir/00-index.md"
[ -f "$index" ] || { echo "Error: $index not found." >&2; exit 2; }

# A task row reads: - [ ] `ID` — title · `file.md` · `state`
# The task file is the backticked .md token just before the state label.
states='todo|in progress|done|done with concerns|blocked|needs context|cancelled|superseded'
task_files=$(sed -nE 's/^- \[[ xX]\] .*`([^`]+\.md)`[^`]*`('"$states"')`[[:space:]]*$/\1/p' "$index")
# A task row is any list-item checkbox under ## Tasks, at any indentation. A row
# there that does not parse, or a parsed row outside that section, would change
# what the version covers without a word, so either one fails. Lines inside a
# fenced code block are examples: they neither open a section nor count as rows.
bad=$(awk -v st="$states" '
  {l = $0; sub(/[ \t\r]+$/, "", l); u = l; sub(/^ */, "", u)}
  z {if (index(u, o) == 1 && u ~ /^([`]+|~+)$/) z = 0; next}
  u ~ /^([`][`][`]|~~~)/ {z = 1; match(u, /^([`]+|~+)/); o = substr(u, 1, RLENGTH); next}
  l ~ /^## / {t = (l == "## Tasks"); next}
  {ok = (l ~ ("^- \\[[ xX]\\] .*`[^`]+\\.md`[^`]*`(" st ")`$"))}
  t && !ok && l ~ /^[ \t]*([-*+]|[0-9]+[.)])[ \t]+\[[ xX]\]/ {print "  " $0}
  !t && ok {print "  " $0 "  (outside ## Tasks)"}' "$index")
if [ -z "$task_files" ] || [ -n "$bad" ]; then
  echo "Error: $index needs every checkbox row under ## Tasks to read - [ ] \`ID\` — title · \`file.md\` · \`state\`, with nothing after the state, and no task row outside it:" >&2
  [ -z "$bad" ] || printf '%s\n' "$bad" >&2
  exit 2
fi
while IFS= read -r f; do
  [ -f "$dir/$f" ] || { echo "Error: task file $dir/$f not found." >&2; exit 2; }
done <<FILES
$task_files
FILES

{
  sed -E 's/^- \[[ xX]\] (.*)`('"$states"')`[[:space:]]*$/- [ ] \1`todo`/' "$index"
  while IFS= read -r f; do
    printf '\n=== %s\n' "$f"
    cat "$dir/$f"
  done <<FILES
$task_files
FILES
} | tr -d '\r' | git hash-object --stdin | cut -c1-7
