#!/usr/bin/env bash
# Handoff-cycle gate for SDLC skills: reports every pair of skills that hand off
# to each other. Flags, environment, and exit codes: --help.

set -uo pipefail

usage() {
  cat <<'USAGE'
scripts/sh/validate-skill-graph.sh — handoff cycles between the skills in skills/.

Reads every SKILL.md and takes a handoff from: invoke `x`; a REQUIRED SUB-SKILL
naming `x`; → `x`; or a sentence that names `x` and says invoke. A block that
opens with Skip is a boundary redirect, not a handoff. Two skills that hand off
to each other form a cycle, printed one per line; nothing prints when there is
none:

  cycle: a↔b      not listed in scripts/sh/data/allowed-cycles.txt
  allowed: a↔b    listed there

  --strict    exit 1 when a cycle is not allowed (default: report only)
  --targets   print every handoff target instead, as file<TAB>target, read with
              the same grammar from every .md of every skill (SKILL.md,
              references/, assets/), whether or not it names a skill
  --help      this text

Environment:
  SKILLS_ROOT   the tree to read instead of skills/

Exit codes: 0 no disallowed cycle, report only, or --targets printed
            1 a disallowed cycle under --strict
            2 bad arguments, or a tree or allow-list that cannot be read
USAGE
}

strict=0; targets=0
for arg in "$@"; do
  case "$arg" in
    --strict) strict=1 ;;
    --targets) targets=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown argument: $arg (see --help)" >&2; exit 2 ;;
  esac
done

if [ -n "${SKILLS_ROOT:-}" ]; then
  root="$(cd "$SKILLS_ROOT" 2>/dev/null && pwd)" || { echo "SKILLS_ROOT is not a directory: $SKILLS_ROOT" >&2; exit 2; }
fi
cd "$(dirname "$0")/../.." || exit 2
root="${root:-skills}"
allow=scripts/sh/data/allowed-cycles.txt
# Byte-wise matching and ordering, so every awk and locale reports the same pairs.
export LC_ALL=C

[ -r "$allow" ] || { echo "cannot read $allow" >&2; exit 2; }
mapfile -t files < <(find "$root" -name SKILL.md 2>/dev/null | sort)
[ "${#files[@]}" -gt 0 ] || { echo "no SKILL.md under $root" >&2; exit 2; }

# Only kebab-case directory names count as skills, so nothing else is printed.
names=""
for f in "${files[@]}"; do
  n="$(basename "$(dirname "$f")")"
  case "$n" in ''|*[!a-z0-9-]*) ;; *) names="$names $n" ;; esac
done

# The cycle report reads SKILL.md only; --targets reads every .md of each skill.
scan=("${files[@]}")
[ "$targets" = 1 ] && mapfile -t scan < <(find "$root" -name '*.md' 2>/dev/null | sort)

# One line per handoff: "from<TAB>to" between two skills, or under --targets
# "file<TAB>target" for any target. A block is a paragraph or list item with its
# wrapped lines joined, so a name on the next line still counts.
if ! edges="$(awk -v names="$names" -v targets="$targets" '
  function edge(to) {
    if (targets) { print file "\t" to; return }
    if ((from in skill) && (to in skill) && to != from) print from "\t" to
  }
  function flush(   b, s, i, t, rest, n, parts, k) {
    b = block; block = ""
    if (b == "") return
    s = b; sub(/^[[:space:]]*([0-9]+[.]|[-*])?[[:space:]]*([*][*])?/, "", s)
    if (tolower(substr(s, 1, 4)) == "skip") return
    rest = b
    while ((i = index(rest, "→")) > 0) {
      rest = substr(rest, i + length("→")); t = rest; sub(/^[[:space:]]*/, "", t)
      if (match(t, /^`[^`]+`/)) edge(substr(t, 2, RLENGTH - 2))
    }
    n = split(b, parts, /[.!?;][[:space:]]+/)
    for (k = 1; k <= n; k++) {
      t = tolower(parts[k])
      if (t !~ /(^|[^a-z])invoke([^a-z]|$)/ && index(t, "required sub-skill") == 0) continue
      rest = parts[k]
      while (match(rest, /`[^`]+`/)) { edge(substr(rest, RSTART + 1, RLENGTH - 2)); rest = substr(rest, RSTART + RLENGTH) }
    }
  }
  BEGIN { n = split(names, a, " "); for (i = 1; i <= n; i++) skill[a[i]] = 1 }
  FNR == 1 { flush(); file = FILENAME; n = split(FILENAME, p, "/"); from = p[n - 1]; fence = 0; fm = ($0 ~ /^---[[:space:]]*$/); if (fm) next }
  fm { if ($0 ~ /^---[[:space:]]*$/) fm = 0; next }
  /^[[:space:]]*```/ { flush(); fence = !fence; next }
  fence { next }
  /^[[:space:]]*$/ || /^[[:space:]]*#/ { flush(); next }
  /^[[:space:]]*([0-9]+[.]|[-*])[[:space:]]/ { flush() }
  { block = (block == "" ? $0 : block " " $0) }
  END { flush() }
' "${scan[@]}")"; then
  echo "the handoff scan could not run" >&2; exit 2
fi

if [ "$targets" = 1 ]; then
  [ -z "$edges" ] || printf '%s\n' "$edges" | sort -u
  exit 0
fi

if ! report="$(printf '%s\n' "$edges" | sort -u | awk -F'\t' -v allowfile="$allow" '
  BEGIN {
    while ((getline line < allowfile) > 0) {
      i = index(line, "↔"); if (i == 0) continue
      a = substr(line, 1, i - 1); b = substr(line, i + length("↔"))
      gsub(/[[:space:]]/, "", a); gsub(/[[:space:]]/, "", b)
      ok[a SUBSEP b] = 1; ok[b SUBSEP a] = 1
    }
  }
  NF == 2 { e[$1 SUBSEP $2] = 1 }
  END {
    for (k in e) {
      split(k, p, SUBSEP)
      if (p[1] < p[2] && ((p[2] SUBSEP p[1]) in e)) {
        kind = ((p[1] SUBSEP p[2]) in ok) ? "allowed" : "cycle"
        print kind ": " p[1] "↔" p[2]
      }
    }
  }' | sort)"; then
  echo "the cycle report could not be built" >&2; exit 2
fi

[ -z "$report" ] || printf '%s\n' "$report"
if [ "$strict" = 1 ] && grep -q '^cycle: ' <<<"$report"; then exit 1; fi
exit 0
