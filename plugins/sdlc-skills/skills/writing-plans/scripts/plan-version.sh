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
  2  usage error, the index or a listed task file is missing, or a task row
     does not parse: indented, missing its backticked file, text after its
     state label, or an unlisted state
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
# A checkbox line, at any indentation, is a task row when it ends in a state
# label or opens with a backticked ID followed by another backticked token. One
# that fails to parse would otherwise drop its task out of the version silently.
candidates=$(grep -E '\[[ xX]\]([[:space:]]+`[^`]+`.*`[^`]+`|.*`('"$states"')`[[:space:]]*$)' "$index")
rows=$(printf '%s\n' "$candidates" | grep -c .)
parsed=$(printf '%s\n' "$task_files" | grep -c .)
if [ "$parsed" -eq 0 ] || [ "$parsed" -ne "$rows" ]; then
  echo "Error: $index has a task row that does not read - [ ] \`ID\` — title · \`file.md\` · \`state\`, with nothing after the state:" >&2
  printf '%s\n' "$candidates" | grep -vE '^- \[[ xX]\] .*`[^`]+\.md`[^`]*`('"$states"')`[[:space:]]*$' | sed 's/^/  /' >&2
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
