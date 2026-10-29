#!/usr/bin/env bash
# Create the .sdlc-skills/ layout that references/artifact-layout.md
# defines, under a project root, or print an artifact's 7-character identity.
#
# Idempotent: an existing directory or file is left as it is. The one file it
# writes, evidence/.gitignore, keeps run records out of every commit once it
# is committed itself.

set -uo pipefail

usage() {
  cat <<'USAGE'
Usage: bash scripts/artifact-layout.sh [--root DIR]
       bash scripts/artifact-layout.sh --hash FILE [--section HEADING | --brief]

Create the .sdlc-skills/ layout under DIR (default: the current
directory): briefs/ specs/ designs/ plans/ audits/ post-mortems/
verification/ evidence/ handoffs/ views/. Write evidence/.gitignore when it
is absent; it ignores everything in evidence/ but itself. Never overwrite a file.

With --hash FILE, print the 7-character git hash-object identity of FILE:
  --hash FILE                      the whole file
  --hash FILE --section HEADING    from HEADING down to the next heading at the
                                   same or a higher level outside a code fence
  --hash FILE --brief              from the top of FILE down to its first ##
                                   heading outside a code fence

Options:
  --root DIR          Project root that holds .sdlc-skills/.
  --hash FILE         Compute the 7-character identity of FILE (read-only).
  --section HEADING   With --hash, hash only the named section (e.g. "## Scope").
  --brief             With --hash, hash only the brief's own text before "## ".
  --help              Show this message.

Output: each directory or file created, one per line, on stdout; with --hash,
the 7-character hex identity on stdout.

Exit codes:
  0  the layout is present, or the 7-character identity was printed
  1  a directory or file could not be created, or evidence/.gitignore exists
     without a * line followed by a !.gitignore line
  2  usage error, missing FILE, or --section matched 0 or more than 1 heading
  3  git is not on PATH (for --hash)
USAGE
}

root=.
hash_file=""
section=""
brief=0
root_set=0
while [ $# -gt 0 ]; do
  case "$1" in
    --root)
      [ $# -ge 2 ] || { echo "Error: --root needs a directory. Run with --help for usage." >&2; exit 2; }
      root=$2; root_set=1; shift 2;;
    --hash)
      [ $# -ge 2 ] && [ -n "${2:-}" ] || { echo "Error: --hash needs a FILE. Run with --help for usage." >&2; exit 2; }
      hash_file=$2; shift 2;;
    --section)
      [ $# -ge 2 ] && [ -n "${2:-}" ] || { echo "Error: --section needs a HEADING. Run with --help for usage." >&2; exit 2; }
      section=$2; shift 2;;
    --brief)
      brief=1; shift;;
    --help|-h) usage; exit 0;;
    *) echo "Error: unknown argument \"$1\". Run with --help for usage." >&2; exit 2;;
  esac
done

if [ -n "$hash_file" ]; then
  [ "$root_set" -eq 0 ] || { echo "Error: --root cannot be combined with --hash." >&2; exit 2; }
  { [ -n "$section" ] && [ "$brief" -eq 1 ]; } && { echo "Error: --section and --brief are mutually exclusive." >&2; exit 2; }
  [ -f "$hash_file" ] || { echo "Error: \"$hash_file\" is not a readable file." >&2; exit 2; }
  command -v git >/dev/null 2>&1 || { echo "Error: git is not on PATH." >&2; exit 3; }
  if [ -n "$section" ]; then
    extracted="$(awk -v h="$section" '{t = $0; sub(/^ */, "", t); if (!z && t ~ /^([`][`][`]|~~~)/) {z = 1; match(t, /^([`]+|~+)/); o = substr(t, 1, RLENGTH)} else if (z && index(t, o) == 1 && t ~ /^([`]+|~+)[ \t]*$/) z = 0} !z && $0 == h {n++; f = 1; s = s $0 "\n"; next} f && !z && /^##? / {f = 0} f {b = b $0 "\n"; if (NF) {s = s b; b = ""}} END {if (n != 1) {printf "%d headings match\n", n > "/dev/stderr"; exit 2} printf "%s", s}' "$hash_file")" || exit 2
    printf '%s\n' "$extracted" | git hash-object --stdin | cut -c1-7
  elif [ "$brief" -eq 1 ]; then
    awk '{t = $0; sub(/^ */, "", t); if (!z && t ~ /^([`][`][`]|~~~)/) {z = 1; match(t, /^([`]+|~+)/); o = substr(t, 1, RLENGTH)} else if (z && index(t, o) == 1 && t ~ /^([`]+|~+)[ \t]*$/) z = 0} !z && /^## / {exit} {b = b $0 "\n"; if (NF) {printf "%s", b; b = ""}}' "$hash_file" | git hash-object --stdin | cut -c1-7
  else
    git hash-object "$hash_file" | cut -c1-7
  fi
  exit 0
fi

if [ -n "$section" ] || [ "$brief" -eq 1 ]; then
  echo "Error: --section and --brief require --hash FILE." >&2
  exit 2
fi

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
