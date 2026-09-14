#!/usr/bin/env bash
# Trigger-collision gate for SDLC skills: reports every clause that two or more
# skill descriptions share verbatim. Flags and exit codes: --help.

set -uo pipefail
cd "$(dirname "$0")/../.." || exit 2

usage() {
  cat <<'USAGE'
scripts/sh/validate-trigger-collisions.sh — trigger phrases shared between skill descriptions.

Splits every description into clauses at commas, semicolons, and periods,
case-folds them, and reports each clause of two or more words that more than
one description contains, one per line; nothing prints when there is none:

  phrase: skill-a, skill-b

It matches whole clauses only: the same trigger worded differently, or inside a
longer clause, is not caught. The floor is two words because descriptions are
plain sentences with no trigger list, so a shared trigger is a short clause.

  --strict    exit 1 when any clause is shared (default: report only)
  --help      this text

Exit codes: 0 no collision, or report only · 1 a collision under --strict
            2 bad arguments, or no skills to read
USAGE
}

strict=0
for arg in "$@"; do
  case "$arg" in
    --strict) strict=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown argument: $arg (see --help)" >&2; exit 2 ;;
  esac
done
export LC_ALL=C

mapfile -t files < <(find skills -name SKILL.md 2>/dev/null | sort)
[ "${#files[@]}" -gt 0 ] || { echo "no SKILL.md under skills/" >&2; exit 2; }

# One "clause<TAB>skill" row per clause of two or more words.
rows=""
for f in "${files[@]}"; do
  name="$(basename "$(dirname "$f")")"
  case "$name" in ''|*[!a-z0-9-]*) continue ;; esac
  fm_end=$(awk 'NR>1 && /^---[[:space:]]*$/{print NR; exit}' "$f")
  # The description parser from validate-skills.sh, plus the block-scalar and
  # quote stripping that check-skill.sh applies.
  d=$(awk -v e="${fm_end:-0}" '
        NR>=e{exit}
        /^description:/{found=1; sub(/^description:[[:space:]]*/,""); printf "%s", $0; next}
        found && /^[a-z_-]+:/{exit}
        found{printf " %s", $0}' "$f" | sed 's/^[>|][-+]*//; s/^[[:space:]]*//; s/^["'\'']//; s/["'\''][[:space:]]*$//')
  rows="$rows$(printf '%s\n' "$d" | awk -v skill="$name" '
        { n = split(tolower($0), c, /[,;.]/)
          for (i = 1; i <= n; i++) {
            gsub(/[[:space:]]+/, " ", c[i]); sub(/^ /, "", c[i]); sub(/ $/, "", c[i])
            if (split(c[i], w, " ") >= 2) print c[i] "\t" skill
          } }')
"
done

if ! report="$(printf '%s' "$rows" | sort -u | awk -F'\t' '
    NF < 2 { next }
    $1 != prev { if (n > 1) print out; prev = $1; out = $1 ": " $2; n = 1; next }
    { out = out ", " $2; n++ }
    END { if (n > 1) print out }')"; then
  echo "the collision report could not be built" >&2; exit 2
fi

[ -z "$report" ] || printf '%s\n' "$report"
if [ "$strict" = 1 ] && [ -n "$report" ]; then exit 1; fi
exit 0
