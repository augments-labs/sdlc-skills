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
cd "$(dirname "$0")/../.." || exit 2

case "${1-}" in
  -h|--help)
    cat <<'EOF'
scripts/sh/token-budget.sh — approximate context cost of the always-loaded surface.

  --max N   flag any SKILL.md body over N approx-tokens (default: report only)
  --help    this text

Tokens are approximated as characters/4 — a portable proxy for drift and
comparison, not a billing figure. Discipline skills legitimately run large; see
writing-skills before tightening one.

Exit codes: 0 report printed, nothing over --max
            1 at least one body exceeded --max · 2 not run from the repo
EOF
    exit 0;;
esac

max=0
[ "${1:-}" = "--max" ] && max="${2:-0}"

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
