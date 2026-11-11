#!/usr/bin/env bash
# check-eval-record.sh — does a pull request name an eval record of exactly
# the skill text it changes?
#
# For each skill whose SKILL.md, assets/ or references/ the pull request
# changes since its merge base, it works out which records the change needs
# from the git trees alone, then reads the records the pull request body
# names, one `Eval record: results/<dir>` line each, from a checkout of the
# evals repository:
#
#   - a description line that changed, or a new skill: a triggering record
#     (triggering.json) whose description_sha256 is the SHA-256 of the head's
#     description line, with 3 or more runs, a validation split, and no
#     inconclusive query in any split;
#   - any other change to those files, or a new skill: an evaluation record
#     (benchmark.json) whose plugin.skill_tree is the skill's whole directory
#     tree at the head, measured against the merge base's tree (old_skill)
#     or, for a new skill, against no skill (without_skill), with 3 or more
#     runs of every eval in each arm, each run scored: a numeric pass rate,
#     not indeterminate, no assertion awaiting review;
#   - a removed skill: no record can measure it, so it passes only with
#     --exempt;
#   - a skill the base changed after the merge base: the merge would hold
#     text no record measured, so the branch is rebased and measured again;
#   - a symbolic link or a submodule anywhere under skills/ at the head but
#     inside a skill's scripts/ (a link file, or a link or submodule that is
#     itself assets/, references/, a skill, or a phase), a SKILL.md added or
#     changed under skills/ anywhere but skills/<phase>/<name>/, or a
#     changed path whose name has a newline: text no record can name, so it
#     passes only with --exempt.
#
# It checks that a record declares exactly that text and was fully scored,
# not that the numbers are good: it prints them for a reviewer. No model
# runs and no network is read.
set -uo pipefail
# Paths are matched as bytes: under a UTF-8 locale a name that is not valid
# UTF-8 would slip past every pattern below.
export LC_ALL=C

usage() {
  cat <<'EOF'
check-eval-record.sh — check that a pull request names an eval record of
exactly the skill text it changes.

  --base REV    the commit the pull request merges into; records are measured
                against its merge base with --head
  --head REV    the pull request's head commit
  --evals DIR   a checkout of the evals repository (reads DIR/results/)
  --body FILE   the pull request body, read for `Eval record: results/<dir>`
  --exempt      the maintainer's no-eval label is on the pull request: report
                what would be required, and pass
  --help        this text

Run from the root of this repository's checkout, with both commits present.

Exit codes: 0 every changed skill has its records, or --exempt · 1 a record
is missing or does not match · 2 a usage error, an unknown revision, no
merge base, a diff that fails, a tree it cannot list, a temp file it
cannot make, a missing input, or jq is missing
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
# Records are measured against the text the branch started from.
mb="$(git merge-base "$base" "$head" 2>/dev/null)" \
  || { echo "no merge base between $base and $head" >&2; exit 2; }

sha256() {
  if command -v sha256sum >/dev/null 2>&1; then sha256sum; else shasum -a 256; fi | cut -d' ' -f1
}
# The first frontmatter line that begins `description:`, without its newline:
# the definition the evals repository hashes into description_sha256
# (lab_description_sha256 in its lib/pin.sh); the two must stay identical.
desc_line() {  # <rev> <skill dir>
  git show "$1:$2/SKILL.md" 2>/dev/null | LC_ALL=C awk '
    NR == 1 { if ($0 != "---") exit; next }
    $0 == "---" { printf "%s", d; exit }
    d == "" && /^description:/ { d = $0 }'
}
# The rest of what the agent reads as text: SKILL.md without exactly the line
# desc_line found (all of it when desc_line found none, so an unhashable
# description still counts as a change), and the assets/ and references/
# trees. scripts/ is left out: a script's own offline test covers it.
rest_of() {  # <rev> <skill dir>
  local d; d="$(desc_line "$1" "$2")"
  git show "$1:$2/SKILL.md" 2>/dev/null | D="$d" LC_ALL=C awk '
    !seen && ENVIRON["D"] != "" && $0 == ENVIRON["D"] { seen = 1; next }
    { print }'
  echo "assets $(git rev-parse -q --verify "$1:$2/assets" 2>/dev/null)"
  echo "references $(git rev-parse -q --verify "$1:$2/references" 2>/dev/null)"
}
has_skill() { git cat-file -e "$1:$2/SKILL.md" 2>/dev/null; }

# --no-renames lists both ends of a move; quotePath=false keeps a non-ASCII
# path matchable instead of quoted. The list is read NUL-separated: a newline
# in a name would otherwise split it into lines no pattern matches.
list="" tree=""
trap 'rm -f ${list:+"$list"} ${tree:+"$tree"}' EXIT
list="$(mktemp)" && tree="$(mktemp)" \
  || { echo "cannot make a temp file" >&2; exit 2; }
git -c core.quotePath=false diff --no-renames --name-only -z "$mb" "$head" -- skills/ > "$list" \
  || { echo "cannot diff $mb $head" >&2; exit 2; }
changed=() unmet=()
while IFS= read -r -d '' f; do
  case "$f" in *$'\n'*)
    unmet+=("a changed path under skills/ has a newline in its name: ${f//$'\n'/\\n}"); continue;;
  esac
  # A SKILL.md anywhere else is text an agent may read that no record names;
  # removing one is the remedy, so only one the head still holds fails.
  if [[ "$f" =~ (^|/)SKILL\.md$ ]] && ! [[ "$f" =~ ^skills/[^/]+/[^/]+/(SKILL\.md$|assets/|references/|scripts/) ]] \
     && git cat-file -e "$head:$f" 2>/dev/null; then
    unmet+=("$f is not at skills/<phase>/<name>/SKILL.md: move it there, or a maintainer applies no-eval")
  fi
  changed+=("$f")
done < "$list"
skills="$(printf '%s\n' "${changed[@]+"${changed[@]}"}" \
  | grep -E '^skills/[^/]+/[^/]+/(SKILL\.md$|assets(/|$)|references(/|$))' \
  | cut -d/ -f1-3 | LC_ALL=C sort -u)"
# A symbolic link or a submodule lets text outside the skill change under it
# unseen, so any under skills/ fails, changed or not: a link file, or a link
# or submodule that is itself assets/, references/, a skill or a phase. Only
# a skill's scripts/, which no record measures, may hold one.
git ls-tree -r -z "$head" -- skills/ > "$tree" \
  || { echo "cannot list $head" >&2; exit 2; }
while IFS= read -r -d '' e; do
  case "${e%% *}" in
    120000) kind="a symbolic link" fix="replace it with what it points to" ;;
    160000) kind="a submodule" fix="replace it with the files it holds" ;;
    *) continue ;;
  esac
  p="${e#*$'\t'}"
  [[ "$p" =~ ^skills/[^/]+/[^/]+/scripts/ ]] \
    || unmet+=("${p//$'\n'/\\n} is $kind: a record measures a skill's own files, so $fix")
done < "$tree"

# The records the body names. A malformed line is reported, never guessed at.
records=() problems=() seen=" " asked=0
while IFS= read -r line || [ -n "$line" ]; do
  line="${line%$'\r'}"
  case "$line" in "Eval record:"*) ;; *) continue;; esac
  path="${line#Eval record:}"
  path="$(printf '%s' "$path" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//; s#/$##')"
  if ! printf '%s' "$path" | grep -Eq '^results/[A-Za-z0-9][A-Za-z0-9._-]*$' \
     || [ "${path#*..}" != "$path" ]; then
    problems+=("a record line names no results/<dir>: $(printf '%s' "$path" | tr -cd 'A-Za-z0-9._/ -' | cut -c1-80)")
    continue
  fi
  # A record named twice is read once: the body is untrusted and its size is
  # the cost. Only a valid path is remembered, so it holds no space.
  case "$seen" in *" $path "*) continue;; esac
  seen="$seen$path "
  if [ -f "$evals/$path/benchmark.json" ] || [ -f "$evals/$path/triggering.json" ]; then
    records+=("$path")
  else
    problems+=("$path: the evals repository holds no benchmark.json or triggering.json there")
  fi
done < "$body"

if [ -z "$skills" ] && [ ${#unmet[@]} -eq 0 ]; then
  echo "eval-record: this pull request changes no skill's SKILL.md, assets/ or references/; no record is needed."
  [ ${#problems[@]} -eq 0 ] || printf 'note: %s\n' "${problems[@]}"
  exit 0
fi

# Why a record does not measure this change, or "ok" when it does. Anything
# else, an empty or unparsable file included, is a reason it does not.
record_why() {  # <file> <kind> <jq program> [jq args...]
  local file="$1" kind="$2" prog="$3" out; shift 3
  # Exactly one JSON document: an empty file or a second document is not a record.
  if [ "$(jq -n '[inputs] | length' "$file" 2>/dev/null)" != 1 ] \
    || ! out="$(jq -n -r "$@" 'input | '"$prog" "$file" 2>/dev/null)" || [ -z "$out" ]; then
    out="its $kind is not a readable record"
  fi
  printf '%s\n' "$out"
}
eval_why() {  # <file> <skill> <head tree> <arm> <base tree>
  record_why "$1" benchmark.json '
    ([.runs[]? | select(.configuration == "with_skill" or .configuration == $arm)]) as $r
    | if (.metadata.skill | type) != "string" then "it names no skill (metadata.skill)"
    elif .metadata.skill != $skill then "it measures \(.metadata.skill), not \($skill)"
    elif .metadata.plugin.skill_tree != $head then
      "its plugin.skill_tree \(.metadata.plugin.skill_tree) is not \($skill) at the head (\($head))"
    elif .metadata.configurations[1] != $arm then
      "its second arm is \(.metadata.configurations[1]), and this change needs \($arm)"
    elif $arm == "old_skill" and .metadata.baseline.skill_tree != $base then
      "its baseline.skill_tree \(.metadata.baseline.skill_tree) is not \($skill) at the merge base (\($base))"
    elif ((.metadata.runs_per_eval | numbers) // 0) < 3 then
      "runs_per_eval is \(.metadata.runs_per_eval); a record uses 3 or more"
    elif ($r | length) == 0 then "it holds no run of with_skill or \($arm)"
    elif any($r[]; .outcome != "ok") then
      "\([$r[] | select(.outcome != "ok")] | length) run(s) are indeterminate"
    elif any($r[]; (.pass_rate | type) != "number") then
      "\([$r[] | select((.pass_rate | type) != "number")] | length) run(s) have no score (a null pass rate: an eval with no assertions, or one not graded)"
    elif any($r[]; (.needs_review // 0) != 0) then
      "\([$r[] | .needs_review // 0] | add) assertion result(s) await review"
    elif [(.metadata.eval_ids // [])[] as $e | ("with_skill", $arm) as $c
          | [$r[] | select(.eval_id == $e and .configuration == $c)] | length] | (length == 0 or any(. < 3)) then
      "an eval has fewer than 3 runs in an arm"
    elif [.run_summary.with_skill, .run_summary[$arm]] | any(.pass_rate == null) then
      "an arm has no scored run (a null pass rate)"
    else "ok" end' --arg skill "$2" --arg head "$3" --arg arm "$4" --arg base "$5"
}
eval_numbers() {  # <file> <arm>
  jq -r --arg arm "$2" '"with_skill \(.run_summary.with_skill.pass_rate.mean), \($arm) \(.run_summary[$arm].pass_rate.mean), delta \(.run_summary.delta.pass_rate), runs_per_eval \(.metadata.runs_per_eval)"' "$1"
}
trig_why() {  # <file> <skill> <description sha256>
  record_why "$1" triggering.json '
    if (.metadata.skill | type) != "string" then "it names no skill (metadata.skill)"
    elif .metadata.skill != $skill then "it measures \(.metadata.skill), not \($skill)"
    elif .metadata.description_sha256 != $sha then
      "its description_sha256 is not the SHA-256 of \($skill)'"'"'s description line at the head (\($sha))"
    elif ((.metadata.runs | numbers) // 0) < 3 then "runs is \(.metadata.runs); a record uses 3 or more"
    elif (.splits.validation | type) != "object" then "it has no validation split"
    elif any(.splits[]; .inconclusive != 0) then
      "a split has inconclusive queries, or does not say how many (inconclusive: \([.splits[] | .inconclusive] | map(tostring) | join(", ")))"
    elif .splits.validation.pass_rate == null then "its validation split scored no query"
    else "ok" end' --arg skill "$2" --arg sha "$3"
}
trig_numbers() {  # <file>
  jq -r '[.splits | to_entries[] | "\(.key) \(.value.pass_rate) (\(.value.passed)/\(.value.queries))"] | join(", ")' "$1"
}

need() {  # <kind> <skill dir> <skill> <head tree> <arm> <base tree> <description sha>
  local kind="$1" dir="$2" name="$3" why found="" reasons=() rec file
  for rec in "${records[@]+"${records[@]}"}"; do
    if [ "$kind" = evaluation ]; then file="$evals/$rec/benchmark.json"; else file="$evals/$rec/triggering.json"; fi
    [ -f "$file" ] || continue
    if [ "$kind" = evaluation ]; then why="$(eval_why "$file" "$name" "$4" "$5" "$6")"
    else why="$(trig_why "$file" "$name" "$7")"; fi
    if [ "$why" = ok ]; then found="$rec"; break; fi
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
  asked=1
  if [ "$kind" = evaluation ]; then
    if [ "$5" = old_skill ]; then
      unmet+=("$name ($dir) needs an evaluation record of its head tree $4 against its merge-base tree $6 (old_skill)")
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
    if has_skill "$mb" "$dir"; then
      unmet+=("$name ($dir) is removed: no record can measure that, so it passes only with the maintainer's no-eval label")
    fi
    continue
  fi
  if [ "$(git rev-parse -q --verify "$base:$dir" 2>/dev/null)" != "$(git rev-parse -q --verify "$mb:$dir" 2>/dev/null)" ]; then
    unmet+=("$name ($dir) changed on the base after this branch left it: rebase onto the base and measure the rebased text")
    continue
  fi
  head_tree="$(git rev-parse "$head:$dir")"
  head_desc="$(desc_line "$head" "$dir")"
  if [ -n "$head_desc" ]; then sha="$(printf '%s' "$head_desc" | sha256)"; else sha="none (no description line)"; fi
  if has_skill "$mb" "$dir"; then
    arm=old_skill; base_tree="$(git rev-parse "$mb:$dir")"
    [ "$(desc_line "$mb" "$dir")" = "$head_desc" ]; desc_changed=$?
    [ "$(rest_of "$mb" "$dir")" = "$(rest_of "$head" "$dir")" ]; rest_changed=$?
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
if [ "$asked" = 1 ]; then
  echo "eval-record: name each record in the pull request body as 'Eval record: results/<dir>', after it is on the evals repository's main."
else
  echo "eval-record: fix what is listed above, or a maintainer applies the no-eval label."
fi
exit 1
