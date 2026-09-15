#!/usr/bin/env bash
# Create the .sdlc-skills/ layout that references/artifact-layout.md
# defines, under a project root.
#
# Idempotent: an existing directory or file is left as it is. The one file it
# writes, evidence/.gitignore, keeps run records out of every commit once it
# is committed itself.

set -uo pipefail

usage() {
  cat <<'USAGE'
Usage: bash scripts/artifact-layout.sh [--root DIR]

Create the .sdlc-skills/ layout under DIR (default: the current
directory): briefs/ specs/ designs/ plans/ audits/ post-mortems/
verification/ evidence/ handoffs/ views/. Write evidence/.gitignore when it
is absent; it ignores everything in evidence/ but itself. Never overwrite a file.

Options:
  --root DIR   Project root that holds .sdlc-skills/.
  --help       Show this message.

Output: each directory or file created, one per line, on stdout.

Exit codes:
  0  the layout is present
  1  a directory or file could not be created, or evidence/.gitignore exists
     without a * line followed by a !.gitignore line
  2  usage error
USAGE
}

root=.
while [ $# -gt 0 ]; do
  case "$1" in
    --root)
      [ $# -ge 2 ] || { echo "Error: --root needs a directory. Run with --help for usage." >&2; exit 2; }
      root=$2; shift 2;;
    --help|-h) usage; exit 0;;
    *) echo "Error: unknown argument \"$1\". Run with --help for usage." >&2; exit 2;;
  esac
done
[ -d "$root" ] || { echo "Error: \"$root\" is not a directory." >&2; exit 2; }

base="$root/.sdlc-skills"
for d in briefs specs designs plans audits post-mortems verification evidence handoffs views; do
  [ -d "$base/$d" ] && continue
  mkdir -p -- "$base/$d" 2>/dev/null || { echo "Error: cannot create $base/$d" >&2; exit 1; }
  echo "$base/$d"
done

ignore="$base/evidence/.gitignore"
if [ -e "$ignore" ] || [ -L "$ignore" ]; then
  [ -f "$ignore" ] || { echo "Error: $ignore exists but is not a file" >&2; exit 1; }
  # An existing file is never rewritten, but it must still ignore run records
  # and not itself: git reads the last matching line, and a CRLF line matches
  # as if the CR were not there.
  lines=$(awk '{sub(/\r$/, "")} $0 == "*" {s = NR} $0 == "!.gitignore" {k = NR} END {print s + 0, k + 0}' "$ignore") ||
    { echo "Error: cannot read $ignore" >&2; exit 1; }
  star=${lines% *}; keep=${lines#* }; missing=""
  [ "$star" -gt 0 ] || missing="*"
  [ "$keep" -gt 0 ] || missing="${missing:+$missing and }!.gitignore"
  [ -z "$missing" ] || { echo "Error: $ignore exists but lacks the line(s) $missing, so run records are not ignored; add them (this script never overwrites a file)" >&2; exit 1; }
  [ "$star" -lt "$keep" ] || { echo "Error: $ignore has its last * line after its last !.gitignore line, so git ignores the file itself; move !.gitignore below it (this script never overwrites a file)" >&2; exit 1; }
else
  { printf '*\n!.gitignore\n' > "$ignore"; } 2>/dev/null || { echo "Error: cannot write $ignore" >&2; exit 1; }
  echo "$ignore"
fi
exit 0
