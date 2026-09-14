#!/usr/bin/env bash
# Token-budget report for the always-loaded context — deterministic, files only.
#
# "Earn every line" is enforced as a LINE budget by validate-skills.sh. This is
# its companion: it reports the actual CONTEXT COST of the always-loaded
# surface — every SKILL.md body, plus the SessionStart router injection that
# loads once per context epoch. It turns "lean" from a line-count proxy into a
# number you can watch.
#
# No model is called (the library is harness- and model-agnostic), so tokens are
# APPROXIMATED as chars/4 — a portable rough proxy, not an exact count. Use it
# for relative comparison and drift, not as a billing figure.
#
# Flags and exit codes: --help.
#
# CI runs this with --max 5000 (see .github/workflows/validate.yml) — aligned
# with the house body budget. Below it, ≈2000 remains the house
# target a body is expected to justify in review; this report is the number
# that justification argues from. The gate sat at 1600 while bodies were
# written in a telegraphic register; a body that spells its rules out in
# sentences costs more tokens for the same rules, and a ceiling fitted to the
# compressed prose would have forbidden decompressing them. Exceeding the CI
# max means tighten the skill — or raise the budget deliberately, in the same
# diff, where a reviewer can see it.
#
# This is the chars/4 estimator. check-skill.sh scores bodies against the
# house 5000-token limit using words x 1.3; compare each estimator only with
# its own prior values. This script measures full SKILL.md files.

set -uo pipefail
# CHAINS_TOML is read relative to the caller, before moving to the repo root.
case "${CHAINS_TOML:-}" in ''|/*) ;; *) CHAINS_TOML="$PWD/$CHAINS_TOML" ;; esac
cd "$(dirname "$0")/../.." || exit 2

case "${1-}" in
  -h|--help)
    cat <<'EOF'
scripts/sh/token-budget.sh — approximate context cost of the always-loaded surface.

  --max N        flag any SKILL.md body over N approx-tokens (default: report only)
  --chain NAME   sum the body words of chain NAME's skills from docs/chains.toml
                 (references excluded) and exit 1 over its budget_words
  --help         this text

Environment:
  CHAINS_TOML    the chains file to read instead of docs/chains.toml

Tokens are approximated as characters/4 — a portable proxy for drift and
comparison, not a billing figure. Discipline skills legitimately run large; see
writing-skills before tightening one.

Exit codes: 0 report printed, nothing over --max or the chain's budget
            1 a body exceeded --max, or the chain exceeded its budget_words
            2 not run from the repo, or an unknown chain or unreadable chains file
EOF
    exit 0;;
esac

max=0
[ "${1:-}" = "--max" ] && max="${2:-0}"

# --chain NAME: the summed body words of one chain from docs/chains.toml,
# checked against its budget_words. Word counts, not the chars/4 estimate above.
if [ "${1:-}" = "--chain" ]; then
  chain="${2:-}"; toml="${CHAINS_TOML:-docs/chains.toml}"
  case "$chain" in ''|*[!a-z0-9-]*) echo "--chain takes a chain name of a-z, 0-9 and -" >&2; exit 2 ;; esac
  [ -r "$toml" ] || { echo "cannot read $toml" >&2; exit 2; }
  # The chains file is a small TOML subset: [name] tables holding a skills array
  # (on one line or several) and the integers recorded_words and budget_words.
  parsed="$(awk -v want="$chain" '
    function names(s) { while (match(s, /"[^"]*"/)) { print "skill\t" substr(s, RSTART + 1, RLENGTH - 2); s = substr(s, RSTART + RLENGTH) } }
    /^[[:space:]]*\[/ { t = $0; gsub(/[[:space:]]/, "", t); in_t = (t == "[" want "]"); if (in_t) found = 1; arr = 0; next }
    !in_t { next }
    arr { names($0); if ($0 ~ /\]/) arr = 0; next }
    /^[[:space:]]*skills[[:space:]]*=/ { names($0); if ($0 !~ /\]/) arr = 1; next }
    /^[[:space:]]*(recorded|budget)_words[[:space:]]*=/ { k = $0; sub(/_words.*/, "", k); gsub(/[[:space:]]/, "", k); v = $0; sub(/^[^=]*=[[:space:]]*/, "", v); sub(/[[:space:]]*$/, "", v); print k "\t" v; next }
    END { if (!found) print "missing" }
  ' "$toml")" || { echo "cannot parse $toml" >&2; exit 2; }
  budget=""; skills=()
  while IFS=$'\t' read -r kind val; do
    case "$kind" in
      missing) echo "no [$chain] table in $toml" >&2; exit 2 ;;
      skill) skills+=("$val") ;;
      budget) budget="$val" ;;
    esac
  done <<<"$parsed"
  case "$budget" in ''|*[!0-9]*) echo "[$chain] needs an integer budget_words" >&2; exit 2 ;; esac
  [ "${#skills[@]}" -gt 0 ] || { echo "[$chain] lists no skills" >&2; exit 2; }
  echo "token-budget: chain $chain  (body words, references excluded)"
  total=0
  for s in "${skills[@]}"; do
    case "$s" in ''|*[!a-z0-9-]*) echo "[$chain] lists a skill name outside a-z, 0-9 and -" >&2; exit 2 ;; esac
    f=""; for c in skills/*/"$s"/SKILL.md; do [ -f "$c" ] && f="$c"; done
    [ -n "$f" ] || { echo "[$chain] lists $s, which has no SKILL.md" >&2; exit 2; }
    w=$(awk 'NR==1 && $0=="---" {fm=1; next} fm && $0=="---" {fm=0; next} !fm' "$f" | wc -w | tr -d ' ')
    printf '  %6d  %s\n' "$w" "$s"
    total=$((total + w))
  done
  printf '  total %d words · budget %d\n' "$total" "$budget"
  [ "$total" -le "$budget" ] || { echo "✗ chain $chain is over budget by $((total - budget)) words"; exit 1; }
  exit 0
fi

approx() { local c; c=$(wc -m <"$1"); echo $(((c + 3) / 4)); }

# Measure what actually ships: run the injector and take the context it emits,
# rather than a copy that can drift from it. The injected text is the whole
# `using-sdlc-skills` body. This measures emitted text, not session billing.
nudge_src="scripts/sh/session-start.sh"
nudge="$(mktemp)"; trap 'rm -f "$nudge"' EXIT
if command -v jq >/dev/null 2>&1; then
  bash "$nudge_src" 2>/dev/null \
    | jq -r '.hookSpecificOutput.additionalContext // empty' > "$nudge" 2>/dev/null
fi
# jq-free fallback: the injected context is the router body plus a short preamble.
[ -s "$nudge" ] || awk 'NR==1 && $0=="---" {fm=1; next} fm && $0=="---" {fm=0; next} !fm' \
  skills/common/using-sdlc-skills/SKILL.md > "$nudge"

echo "token-budget: always-loaded context  (approx tokens ≈ chars/4, not exact)"
echo

nudge_t=0
[ -f "$nudge" ] && nudge_t=$(approx "$nudge")
printf 'SessionStart router injection (loaded EVERY session/epoch): %d approx tokens  [%s]\n\n' "$nudge_t" "$nudge_src"

# Collect per-skill costs.
names=()
toks=()
while IFS= read -r f; do
  name=$(awk -F': ' '/^name:/{print $2; exit}' "$f")
  [ -z "$name" ] && continue
  names+=("$name")
  toks+=("$(approx "$f")")
done < <(find skills -name SKILL.md | sort)

n=${#toks[@]}
total=0
mn=9999999
mx=0
for t in "${toks[@]}"; do
  total=$((total + t))
  ((t < mn)) && mn=$t
  ((t > mx)) && mx=$t
done
mean=$((total / (n > 0 ? n : 1)))

echo "Per-skill body (one loads when its skill fires), largest first:"
paste <(printf '%s\n' "${toks[@]}") <(printf '%s\n' "${names[@]}") |
  sort -k1,1 -rn |
  while IFS=$'\t' read -r t name; do
    flag=""
    { [ "$max" -gt 0 ] && [ "$t" -gt "$max" ]; } && flag="  ← over ${max}"
    printf '  %5d  %s%s\n' "$t" "$name" "$flag"
  done

echo
echo "Totals (approx tokens):"
printf '  router injection, every session . %d\n' "$nudge_t"
printf '  per-skill body ................... min %d · mean %d · max %d\n' "$mn" "$mean" "$mx"
printf '  typical session (router + 1 body) %d–%d\n' "$((nudge_t + mn))" "$((nudge_t + mx))"
printf '  whole catalogue (%d bodies) ...... %d  (only if every skill fired)\n' "$n" "$total"

# --max enforcement in a non-piped loop so the exit code is reliable.
if [ "$max" -gt 0 ]; then
  over=()
  for i in "${!toks[@]}"; do
    [ "${toks[$i]}" -gt "$max" ] && over+=("${names[$i]}")
  done
  if [ "${#over[@]}" -gt 0 ]; then
    echo
    echo "✗ ${#over[@]} body(ies) over --max ${max}: ${over[*]}"
    exit 1
  fi
fi
exit 0
