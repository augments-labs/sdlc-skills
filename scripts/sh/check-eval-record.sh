#!/usr/bin/env bash
# check-eval-record.sh — does a pull request name an eval record of exactly
# the skill text it changes?
#
# For each skill whose SKILL.md, assets/ or references/ the pull request
# changes, it works out which records the change needs from the git trees
# alone, then reads the records the pull request body names, one
# `Eval record: results/<dir>` line each, from a checkout of the evals
# repository:
#
#   - a description line that changed, or a new skill: a triggering record
#     (triggering.json) whose description_sha256 is the SHA-256 of the head's
#     description line, with 3 or more runs and a scored validation split;
#   - any other change to those files: an evaluation record (benchmark.json)
#     whose plugin.skill_tree is the skill's tree at the head, measured
#     against the base's tree (old_skill) or, for a new skill, against no
#     skill (without_skill), with 3 or more runs per eval and every run
#     scored: no null pass rate, no indeterminate run, no assertion awaiting
#     review;
#   - a removed skill: no record can measure it, so it passes only with
#     --exempt.
#
# It proves a scored run exists on that exact text, not that the numbers are
# good: it prints them for a reviewer. No model runs and no network is read.
set -uo pipefail

usage() {
  cat <<'EOF'
check-eval-record.sh — check that a pull request names an eval record of
exactly the skill text it changes.

  --base REV    the commit the pull request merges into
  --head REV    the pull request's head commit
  --evals DIR   a checkout of the evals repository (reads DIR/results/)
  --body FILE   the pull request body, read for `Eval record: results/<dir>`
  --exempt      the maintainer's no-eval label is on the pull request: report
                what would be required, and pass
  --help        this text

Run from the root of this repository's checkout, with both commits present.

Exit codes: 0 every changed skill has its records, or --exempt · 1 a record
is missing or does not match · 2 a usage error, an unknown revision, a
missing input, or jq is missing
EOF
}

base="" head="" evals="" body="" exempt=0
while [ $# -gt 0 ]; do
  case "$1" in
    --base) base="${2-}"; shift 2 || { usage >&2; exit 2; };;
    --head) head="${2-}"; shift 2 || { usage >&2; exit 2; };;
    --evals) evals="${2-}"; shift 2 || { usage >&2; exit 2; };;
    --body) body="${2-}"; shift 2 || { usage >&2; exit 2; };;
    --exempt) exempt=1; shift;;
    -h|--help) usage; exit 0;;
    *) echo "unknown argument: $1" >&2; usage >&2; exit 2;;
  esac
done
[ -n "$base" ] && [ -n "$head" ] && [ -n "$evals" ] && [ -n "$body" ] \
  || { usage >&2; exit 2; }
command -v jq >/dev/null 2>&1 || { echo "jq is required" >&2; exit 2; }
for rev in "$base" "$head"; do
  git rev-parse -q --verify "$rev^{commit}" >/dev/null \
    || { echo "unknown revision: $rev" >&2; exit 2; }
done
[ -d "$evals/results" ] || { echo "no results/ under $evals" >&2; exit 2; }
[ -f "$body" ] || { echo "no pull request body at $body" >&2; exit 2; }

sha256() {
  if command -v sha256sum >/dev/null 2>&1; then sha256sum; else shasum -a 256; fi | cut -d' ' -f1
}
# The first frontmatter line that begins `description:`, without its newline:
# the definition the evals repository hashes into description_sha256.
desc_line() {  # <rev> <skill dir>
  git show "$1:$2/SKILL.md" 2>/dev/null | LC_ALL=C awk '
    NR == 1 { if ($0 != "---") exit; next }
    $0 == "---" { printf "%s", d; exit }
    d == "" && /^description:/ { d = $0 }'
}
# Everything else the agent reads: SKILL.md without that line, assets/, references/.
rest_of() {  # <rev> <skill dir>
  git show "$1:$2/SKILL.md" 2>/dev/null | LC_ALL=C awk '
    NR == 1 { fm = ($0 == "---"); print; next }
    fm && $0 == "---" { fm = 0 }
    fm && !seen && /^description:/ { seen = 1; next }
    { print }'
  echo "assets $(git rev-parse -q --verify "$1:$2/assets" 2>/dev/null)"
  echo "references $(git rev-parse -q --verify "$1:$2/references" 2>/dev/null)"
}
has_skill() { git cat-file -e "$1:$2/SKILL.md" 2>/dev/null; }

skills="$(git diff --name-only "$base...$head" -- skills/ \
  | LC_ALL=C grep -E '^skills/[^/]+/[^/]+/(SKILL\.md$|assets/|references/)' \
  | cut -d/ -f1-3 | LC_ALL=C sort -u)"
git diff --quiet "$base...$head" -- skills/ 2>/dev/null
[ $? -le 1 ] || { echo "cannot diff $base...$head" >&2; exit 2; }

# The records the body names. A malformed line is reported, never guessed at.
records=() problems=()
while IFS= read -r line || [ -n "$line" ]; do
  line="${line%$'\r'}"
  case "$line" in "Eval record:"*) ;; *) continue;; esac
  path="${line#Eval record:}"
  path="$(printf '%s' "$path" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//; s#/$##')"
  if ! printf '%s' "$path" | LC_ALL=C grep -Eq '^results/[A-Za-z0-9][A-Za-z0-9._-]*$' \
     || [ "${path#*..}" != "$path" ]; then
    problems+=("a record line names no results/<dir>: $(printf '%s' "$path" | LC_ALL=C tr -cd 'A-Za-z0-9._/ -' | cut -c1-80)")
    continue
  fi
  if [ -f "$evals/$path/benchmark.json" ] || [ -f "$evals/$path/triggering.json" ]; then
    records+=("$path")
  else
    problems+=("$path: the evals repository holds no benchmark.json or triggering.json there")
  fi
done < "$body"

if [ -z "$skills" ]; then
  echo "eval-record: this pull request changes no skill's SKILL.md, assets/ or references/; no record is needed."
  [ ${#problems[@]} -eq 0 ] || printf 'note: %s\n' "${problems[@]}"
  exit 0
fi

# Why an evaluation record does not measure this change; empty when it does.
eval_why() {  # <file> <skill> <head tree> <arm> <base tree>
  jq -r --arg skill "$2" --arg head "$3" --arg arm "$4" --arg base "$5" '
    if .metadata.skill != $skill then "it measures \(.metadata.skill), not \($skill)"
    elif .metadata.plugin.skill_tree != $head then
      "its plugin.skill_tree \(.metadata.plugin.skill_tree) is not \($skill) at the head (\($head))"
    elif .metadata.configurations[1] != $arm then
      "its second arm is \(.metadata.configurations[1]), and this change needs \($arm)"
    elif $arm == "old_skill" and .metadata.baseline.skill_tree != $base then
      "its baseline.skill_tree \(.metadata.baseline.skill_tree) is not \($skill) at the base (\($base))"
    elif ((.metadata.runs_per_eval | numbers) // 0) < 3 then
      "runs_per_eval is \(.metadata.runs_per_eval); a record uses 3 or more"
    elif [.run_summary.with_skill, .run_summary[$arm]] | any(.pass_rate == null) then
      "an arm has no scored run (a null pass rate)"
    elif [.run_summary.with_skill, .run_summary[$arm]] | any((.indeterminate_count // 0) > 0) then
      "a run is indeterminate"
    elif ([.runs[]? | .needs_review // 0] | add // 0) > 0 then
      "\([.runs[] | .needs_review // 0] | add) assertion result(s) await review"
    else "" end' "$1" 2>/dev/null || echo "its benchmark.json is not a readable record"
}
eval_numbers() {  # <file> <arm>
  jq -r --arg arm "$2" '"with_skill \(.run_summary.with_skill.pass_rate.mean), \($arm) \(.run_summary[$arm].pass_rate.mean), delta \(.run_summary.delta.pass_rate), runs_per_eval \(.metadata.runs_per_eval)"' "$1"
}
trig_why() {  # <file> <skill> <description sha256>
  jq -r --arg skill "$2" --arg sha "$3" '
    if .metadata.skill != $skill then "it measures \(.metadata.skill), not \($skill)"
    elif .metadata.description_sha256 != $sha then
      "its description_sha256 is not the SHA-256 of \($skill)'"'"'s description line at the head (\($sha))"
    elif ((.metadata.runs | numbers) // 0) < 3 then "runs is \(.metadata.runs); a record uses 3 or more"
    elif .splits.validation.pass_rate == null then "its validation split scored no query"
    else "" end' "$1" 2>/dev/null || echo "its triggering.json is not a readable record"
}
trig_numbers() {  # <file>
  jq -r '[.splits | to_entries[] | "\(.key) \(.value.pass_rate) (\(.value.passed)/\(.value.queries))"] | join(", ")' "$1"
}

unmet=()
need() {  # <kind> <skill dir> <skill> <head tree> <arm> <base tree> <description sha>
  local kind="$1" dir="$2" name="$3" why found="" reasons=() rec file
  for rec in "${records[@]+"${records[@]}"}"; do
    if [ "$kind" = evaluation ]; then file="$evals/$rec/benchmark.json"; else file="$evals/$rec/triggering.json"; fi
    [ -f "$file" ] || continue
    if [ "$kind" = evaluation ]; then why="$(eval_why "$file" "$name" "$4" "$5" "$6")"
    else why="$(trig_why "$file" "$name" "$7")"; fi
    if [ -z "$why" ]; then found="$rec"; break; fi
    # A record of another skill is not a near miss for this one.
    case "$why" in "it measures "*) ;; *) reasons+=("$rec: $why");; esac
  done
  if [ -n "$found" ]; then
    if [ "$kind" = evaluation ]; then
      echo "ok    $name: evaluation record $found ($(eval_numbers "$evals/$found/benchmark.json" "$5"))"
    else
      echo "ok    $name: triggering record $found ($(trig_numbers "$evals/$found/triggering.json"))"
    fi
    return
  fi
  if [ "$kind" = evaluation ]; then
    if [ "$5" = old_skill ]; then
      unmet+=("$name ($dir) needs an evaluation record of its head tree $4 against its base tree $6 (old_skill)")
    else
      unmet+=("$name ($dir) needs an evaluation record of its head tree $4 against no skill (without_skill)")
    fi
  else
    unmet+=("$name ($dir) needs a triggering record of its head description line (description_sha256 $7)")
  fi
  local r
  for r in "${reasons[@]+"${reasons[@]}"}"; do unmet+=("  not $r"); done
}

while IFS= read -r dir; do
  [ -n "$dir" ] || continue
  name="${dir##*/}"
  if ! has_skill "$head" "$dir"; then
    if has_skill "$base" "$dir"; then
      unmet+=("$name ($dir) is removed: no record can measure that, so it passes only with the maintainer's no-eval label")
    fi
    continue
  fi
  head_tree="$(git rev-parse "$head:$dir")"
  head_desc="$(desc_line "$head" "$dir")"
  if [ -n "$head_desc" ]; then sha="$(printf '%s' "$head_desc" | sha256)"; else sha="none (no description line)"; fi
  if has_skill "$base" "$dir"; then
    arm=old_skill; base_tree="$(git rev-parse "$base:$dir")"
    [ "$(desc_line "$base" "$dir")" = "$head_desc" ]; desc_changed=$?
    [ "$(rest_of "$base" "$dir")" = "$(rest_of "$head" "$dir")" ]; rest_changed=$?
  else
    arm=without_skill; base_tree="no skill"; desc_changed=1; rest_changed=1
  fi
  if [ "$desc_changed" = 0 ] && [ "$rest_changed" = 0 ]; then
    echo "ok    $name: its SKILL.md, assets/ and references/ are the base's"
    continue
  fi
  [ "$rest_changed" = 0 ] || need evaluation "$dir" "$name" "$head_tree" "$arm" "$base_tree" "$sha"
  [ "$desc_changed" = 0 ] || need triggering "$dir" "$name" "$head_tree" "$arm" "$base_tree" "$sha"
done <<<"$skills"

[ ${#problems[@]} -eq 0 ] || printf 'note: %s\n' "${problems[@]}"
if [ ${#unmet[@]} -eq 0 ] && [ ${#problems[@]} -eq 0 ]; then
  echo "eval-record: every changed skill has its records."
  exit 0
fi
if [ ${#unmet[@]} -eq 0 ]; then
  echo "eval-record: a record line above names nothing; fix or remove it."
  [ "$exempt" = 1 ] && { echo "exempt: the no-eval label is on this pull request."; exit 0; }
  exit 1
fi
printf 'MISSING  %s\n' "${unmet[@]}"
if [ "$exempt" = 1 ]; then
  echo "exempt: the no-eval label is on this pull request, so the records above are not required."
  exit 0
fi
echo "eval-record: name each record in the pull request body as 'Eval record: results/<dir>', after it is on the evals repository's main."
exit 1
