#!/usr/bin/env bash
# Offline tests for scripts/sh/check-eval-record.sh, the eval-record CI job.
#
# What this guards: a pull request that changes what a skill makes an agent
# do must name an eval record of exactly its skill text. The checker decides
# which records a change needs from the git trees alone, and accepts a record
# only when its identity matches the pull request's trees and every run in it
# was scored. Each rejection below is pinned next to the near-miss that must
# pass, so a checker that over-matches goes red as well as one that misses.
#
# Deterministic on purpose: fixture git repositories and fixture records
# under a temporary directory removed on exit. No model runs, no network.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 2
ROOT="$PWD"

case "${1-}" in
  -h|--help)
    cat <<'EOF'
tests/run-check-eval-record.sh — offline unit checks for check-eval-record.sh.

Takes no arguments; builds a fixture repository with one skill and fixture
eval records, then runs the checker against changes to that skill. Never
mutates the checkout and never reads the network.

  --help    this text

Exit codes: 0 every check passed · 1 at least one failed · 2 not run from the
repo, or jq is missing
EOF
    exit 0;;
esac

S="$ROOT/scripts/sh/check-eval-record.sh"
[ -f "$S" ] || { echo "not run from the repository root" >&2; exit 2; }
command -v jq >/dev/null 2>&1 || { echo "jq is required" >&2; exit 2; }

fails=0
ok()  { echo "  ok    $1"; }
bad() { echo "  FAIL  $1"; fails=1; }

tmp="$(mktemp -d)" || exit 2
trap 'rm -rf "$tmp"' EXIT
repo="$tmp/repo"
evals="$tmp/evals"
mkdir -p "$repo" "$evals/results"

git -C "$repo" init -q
git -C "$repo" config user.email t@example.invalid
git -C "$repo" config user.name tester
git -C "$repo" config core.autocrlf false

skill=skills/common/foo
desc_line='description: "Does foo. Use when foo is asked for."'
write_skill() {  # <dir> <description line> <body line>
  mkdir -p "$repo/$1/assets" "$repo/$1/scripts"
  printf -- '---\nname: %s\n%s\n---\n\n# Foo\n\n%s\n' "$(basename "$1")" "$2" "$3" > "$repo/$1/SKILL.md"
  printf 'template\n' > "$repo/$1/assets/t.md"
  printf 'echo hi\n' > "$repo/$1/scripts/x.sh"
}
write_skill "$skill" "$desc_line" "Step one."
write_skill skills/common/gone "description: \"Gone.\"" "Old."
mkdir -p "$repo/notes"; printf 'doc\n' > "$repo/notes/a.md"
git -C "$repo" add -A
git -C "$repo" commit -qm base
git -C "$repo" branch -q base

# Each case starts from base on a fresh branch.
start() { git -C "$repo" checkout -q -B "case-$1" base; }
commit() { git -C "$repo" add -A && git -C "$repo" commit -qm "$1"; }
tree_at() { git -C "$repo" rev-parse "$1:$2"; }
desc_sha() {  # sha256 of the description line at <rev>:<skill dir>
  git -C "$repo" show "$1:$2/SKILL.md" | LC_ALL=C awk 'NR == 1 { if ($0 != "---") exit; next }
    $0 == "---" { printf "%s", d; exit } d == "" && /^description:/ { d = $0 }' | sha256
}
sha256() {
  if command -v sha256sum >/dev/null 2>&1; then sha256sum; else shasum -a 256; fi | cut -d' ' -f1
}

# bench <record dir> <skill> <plugin tree> <second arm> <baseline tree|null>
#       [runs_per_eval] [second pass_rate|null] [indeterminate] [needs_review]
# A record as the evals lab writes it: one row per run of eval e1 in each
# arm, each scored, then the arm summary. The optional arguments spoil it.
bench() {
  local d="$evals/results/$1"; mkdir -p "$d"
  jq -n --arg skill "$2" --arg pt "$3" --arg arm "$4" --arg bt "$5" \
    --argjson n "${6:-3}" --argjson pr2 "${7:-0.5}" --argjson ind "${8:-0}" --argjson nr "${9:-0}" '
    def row($c; $k; $p): {eval_id: "e1", configuration: $c, run_number: $k, outcome: "ok",
                          pass_rate: $p, passed: 1, failed: 1, needs_review: 0, total: 2};
    {metadata: {skill: $skill, harness: "fake", harness_version: null, model: null,
                eval_ids: ["e1"], configurations: ["with_skill", $arm], runs_per_eval: $n,
                plugin: {commit: "c0ffee", skill_tree: $pt},
                baseline: (if $bt == "null" then null else {commit: "c0ffee", skill_tree: $bt} end)},
     runs: ([range(1; $n + 1) as $k | row("with_skill"; $k; 0.9)]
            + [range(1; $n + 1) as $k | row($arm; $k; $pr2)]
            | .[0].needs_review = $nr
            | if $ind > 0 then .[0] |= (.outcome = "indeterminate" | .pass_rate = null) else . end),
     run_summary: ({with_skill: {pass_rate: {mean: 0.9, stddev: 0}, indeterminate_count: $ind}}
                   + {($arm): {pass_rate: (if $pr2 == null then null else {mean: $pr2, stddev: 0} end),
                               indeterminate_count: 0}}
                   + {delta: {pass_rate: 0.4}})}' > "$d/benchmark.json"
}
# trig <record dir> <skill> <description sha> [runs] [validation pass_rate|null]
trig() {
  local d="$evals/results/$1"; mkdir -p "$d"
  jq -n --arg skill "$2" --arg sha "$3" --argjson n "${4:-3}" --argjson vp "${5:-0.9}" '
    {metadata: {skill: $skill, harness: "fake", plugin: {commit: "c0ffee", skill_tree: "abc"},
                description_sha256: $sha, runs: $n, threshold: 0.5},
     splits: {train: {queries: 12, passed: 11, failed: 1, inconclusive: 0, pass_rate: 0.92},
              validation: {queries: 8, passed: 7, failed: 1, inconclusive: 0, pass_rate: $vp}},
     queries: []}' > "$d/triggering.json"
}
# spoil <src dir> <dst dir> <file> <jq filter> — a copy of a record, edited
spoil() {
  mkdir -p "$evals/results/$2"
  jq "$4" "$evals/results/$1/$3" > "$evals/results/$2/$3"
}

body="$tmp/body.txt"
run() {  # <expected exit> <label> [extra args...]; body is $body
  local want="$1" label="$2"; shift 2
  local out code
  out="$(cd "$repo" && bash "$S" --base "${BASE:-base}" --head HEAD --evals "$evals" --body "$body" "$@" 2>&1)"
  code=$?
  if [ "$code" = "$want" ]; then ok "$label"; else bad "$label (expected exit $want, got $code)"; printf '%s\n' "$out" | sed 's/^/        /'; fi
  last_out="$out"
}
has() {  # <label> <fixed string> — the last run's output names it
  if printf '%s\n' "$last_out" | grep -qF -- "$2"; then ok "$1"; else bad "$1 (no '$2' in output)"; printf '%s\n' "$last_out" | sed 's/^/        /'; fi
}

echo "--- changes that need no record"
start docs; printf 'more\n' >> "$repo/notes/a.md"; commit docs
: > "$body"
run 0 "a change outside skills/ needs no record"

start script; printf 'echo bye\n' >> "$repo/$skill/scripts/x.sh"; commit script
run 0 "a change to a skill's scripts/ alone needs no record"

start revert; printf 'x\n' >> "$repo/$skill/assets/t.md"; commit touch
git -C "$repo" checkout -q base -- "$skill"; commit revert
run 0 "a skill touched and restored on the branch needs no record"

start notes-note; printf 'more\n' >> "$repo/notes/a.md"; commit notes
printf 'Eval record: results/nowhere\n' > "$body"
run 0 "a bad record line on a pull request that changes no skill only notes it"
has "the bad line is reported as a note" "note: results/nowhere"

echo "--- every file the agent reads counts"
: > "$body"
start assets; printf 'x\n' >> "$repo/$skill/assets/t.md"; commit assets
run 1 "a change to a skill's assets/ needs a record"
has "it names the skill" "foo (skills/common/foo) needs an evaluation record"
bench assets-ok foo "$(tree_at HEAD "$skill")" old_skill "$(tree_at base "$skill")"
printf 'Eval record: results/assets-ok\n' > "$body"
run 0 "an assets/ change with a matching record passes"

: > "$body"
start refs; mkdir -p "$repo/$skill/references"; printf 'ref\n' > "$repo/$skill/references/r.md"; commit refs
run 1 "a change to a skill's references/ needs a record"

start rename-out; git -C "$repo" mv "$skill/assets/t.md" skills/common/gone/assets/t2.md; commit rename-out
run 1 "a file moved from one skill to another needs records for both"
has "the skill the file left is named" "foo (skills/common/foo)"
has "the skill the file joined is named" "gone (skills/common/gone)"

start twofiles; printf 'x\n' >> "$repo/$skill/assets/t.md"; printf 'y\n' > "$repo/$skill/assets/u.md"; commit twofiles
: > "$body"
run 1 "two changed files in one skill fail"
n="$(printf '%s\n' "$last_out" | grep -c 'foo (skills/common/foo) needs an evaluation record')"
if [ "$n" = 1 ]; then ok "the skill is named once"; else bad "the skill is named once (named $n times)"; fi

start rename-scripts; git -C "$repo" mv "$skill/assets/t.md" "$skill/scripts/t.md"; commit rename-scripts
run 1 "a file moved from assets/ to scripts/ still changes what the agent reads"

start nonascii; printf 'x\n' > "$repo/$skill/assets/caf"$'\303\251'".md"; commit nonascii
run 1 "a change to a file with a non-ASCII name is seen"

echo "--- a body change needs an evaluation record of exactly its text"
start body; write_skill "$skill" "$desc_line" "Step one, changed."; commit body
H="$(tree_at HEAD "$skill")"; B="$(tree_at base "$skill")"

: > "$body"
run 1 "a body change with no record line fails"
has "the failure names the skill and the record kind it needs" "foo (skills/common/foo) needs an evaluation record"

bench body-ok foo "$H" old_skill "$B"
printf 'Some text.\nEval record: results/body-ok\n' > "$body"
run 0 "a body change with a matching old_skill record passes"

printf 'Eval record: results/body-ok\r\n' > "$body"
run 0 "a record line with a CRLF ending is read"

printf 'Eval record: results/body-ok/\n' > "$body"
run 0 "a record line with a trailing slash is read"
printf 'Eval record: results/body-ok \t\n' > "$body"
run 0 "trailing whitespace on a record line is ignored"
printf 'Eval record: x/results/body-ok\n' > "$body"
run 1 "a record path not under results/ is a bad line"
has "the bad line is named as such" "names no results/<dir>"

bench body-stale foo "$B" old_skill "$B"
printf 'Eval record: results/body-stale\n' > "$body"
run 1 "a record of another skill text (the base's) fails"
has "the failure says the plugin tree does not match" "plugin.skill_tree"

bench body-wrongbase foo "$H" old_skill "$H"
printf 'Eval record: results/body-wrongbase\n' > "$body"
run 1 "a record whose baseline is not the base's skill text fails"

bench body-noskill foo "$H" without_skill null
printf 'Eval record: results/body-noskill\n' > "$body"
run 1 "an edited skill measured against no skill fails (it needs old_skill)"

bench body-other bar "$H" old_skill "$B"
printf 'Eval record: results/body-other\n' > "$body"
run 1 "a record of another skill fails"

bench body-onerun foo "$H" old_skill "$B" 1
printf 'Eval record: results/body-onerun\n' > "$body"
run 1 "a record with one run per eval fails"
bench body-tworuns foo "$H" old_skill "$B" 2
printf 'Eval record: results/body-tworuns\n' > "$body"
run 1 "a record with two runs per eval fails"

bench body-pending foo "$H" old_skill "$B" 3 null
printf 'Eval record: results/body-pending\n' > "$body"
run 1 "a record with an unscored arm (a null pass rate) fails"

bench body-indet foo "$H" old_skill "$B" 3 0.5 1
printf 'Eval record: results/body-indet\n' > "$body"
run 1 "a record with an indeterminate run fails"

bench body-review foo "$H" old_skill "$B" 3 0.5 0 2
printf 'Eval record: results/body-review\n' > "$body"
run 1 "a record with an assertion awaiting review fails"

printf 'Eval record: results/body-stale\nEval record: results/body-ok\n' > "$body"
run 0 "one matching record among several named passes"

printf 'Eval record: results/body-ok' > "$body"
run 0 "a record line with no final newline is read"
printf '    Eval record: results/body-ok\n' > "$body"
run 1 "an indented record line (the template's example) is not read"
printf 'Eval record: results/body-ok\nEval record: results/missing\n' > "$body"
run 1 "a bad record line fails even when every skill has its record"
has "the bad line is named" "results/missing"
run 0 "a bad record line passes under --exempt" --exempt

spoil body-ok run-unscored benchmark.json '(.runs[] | select(.configuration == "old_skill" and .run_number == 2)).pass_rate = null'
printf 'Eval record: results/run-unscored\n' > "$body"
run 1 "a record with one unscored run fails, though its arm mean is scored"
has "it says a run has no score" "no score"

spoil body-ok with-unscored benchmark.json '(.runs[] | select(.configuration == "with_skill" and .run_number == 3)).pass_rate = null'
printf 'Eval record: results/with-unscored\n' > "$body"
run 1 "an unscored with_skill run fails"

spoil body-ok base-indet benchmark.json '(.runs[] | select(.configuration == "old_skill" and .run_number == 1)) |= (.outcome = "indeterminate" | .pass_rate = null)'
printf 'Eval record: results/base-indet\n' > "$body"
run 1 "an indeterminate run in the old_skill arm fails"

spoil body-ok late-review benchmark.json '.runs[-1].needs_review = 1'
printf 'Eval record: results/late-review\n' > "$body"
run 1 "one assertion awaiting review in the last run fails"

spoil body-ok no-runs benchmark.json 'del(.runs)'
printf 'Eval record: results/no-runs\n' > "$body"
run 1 "a record with no runs fails"

spoil body-ok short-eval benchmark.json 'del(.runs[0])'
printf 'Eval record: results/short-eval\n' > "$body"
run 1 "an eval with two runs in one arm fails, whatever runs_per_eval says"

spoil body-ok short-old benchmark.json 'del(.runs[] | select(.configuration == "old_skill" and .run_number == 1))'
printf 'Eval record: results/short-old\n' > "$body"
run 1 "an eval with two runs in the old_skill arm fails"

spoil body-ok second-eval benchmark.json '.metadata.eval_ids += ["e2"]'
printf 'Eval record: results/second-eval\n' > "$body"
run 1 "a listed eval with no runs fails"

spoil body-ok no-eval-ids benchmark.json '.metadata.eval_ids = []'
printf 'Eval record: results/no-eval-ids\n' > "$body"
run 1 "a record that lists no eval fails"

spoil body-ok split-evals benchmark.json '.metadata.eval_ids += ["e2"] | (.runs[] | select(.run_number == 1)).eval_id = "e2"'
printf 'Eval record: results/split-evals\n' > "$body"
run 1 "three runs per arm split across two evals, short in each, fail"

spoil body-ok no-skill benchmark.json '.metadata.skill = null'
printf 'Eval record: results/no-skill\n' > "$body"
run 1 "a record that names no skill fails"
has "the near miss is explained" "names no skill"

mkdir -p "$evals/results/empty-bench"; : > "$evals/results/empty-bench/benchmark.json"
printf 'Eval record: results/empty-bench\n' > "$body"
run 1 "an empty benchmark.json fails"
has "it says the record is unreadable" "not a readable record"

mkdir -p "$evals/results/two-docs"
cat "$evals/results/body-ok/benchmark.json" "$evals/results/body-ok/benchmark.json" > "$evals/results/two-docs/benchmark.json"
printf 'Eval record: results/two-docs\n' > "$body"
run 1 "a benchmark.json holding two documents fails"

printf 'Eval record: results/missing\n' > "$body"
run 1 "a record the evals checkout does not hold fails"
has "it says the directory is missing" "results/missing: the evals repository holds no"
mkdir -p "$evals/results/hollow"
printf 'Eval record: results/hollow\n' > "$body"
run 1 "a record directory with no record file in it fails"

printf 'Eval record: results/../../etc\n' > "$body"
run 1 "a record path that leaves results/ is refused"
printf 'Eval record: body-ok\n' > "$body"
run 1 "a record line not under results/ is refused"

: > "$body"
run 0 "--exempt passes a body change with no record" --exempt
has "an exempt run says so" "no-eval"

echo "--- a description change needs a triggering record of exactly its line"
start desc; write_skill "$skill" 'description: "Does foo better. Use when foo is asked for."' "Step one."; commit desc
D="$(desc_sha HEAD "$skill")"
trig desc-ok foo "$D"
printf 'Eval record: results/desc-ok\n' > "$body"
run 0 "a description-only change with a matching triggering record passes"

trig desc-stale foo "$(desc_sha base "$skill")"
printf 'Eval record: results/desc-stale\n' > "$body"
run 1 "a triggering record of the base's description fails"

trig desc-onerun foo "$D" 1
printf 'Eval record: results/desc-onerun\n' > "$body"
run 1 "a triggering record with one run per query fails"

trig desc-unscored foo "$D" 3 null
printf 'Eval record: results/desc-unscored\n' > "$body"
run 1 "a triggering record whose validation split scored nothing fails"

trig desc-tworuns foo "$D" 2
printf 'Eval record: results/desc-tworuns\n' > "$body"
run 1 "a triggering record with two runs per query fails"

trig desc-other bar "$D"
printf 'Eval record: results/desc-other\n' > "$body"
run 1 "a triggering record of another skill fails"

spoil desc-ok desc-inc-train triggering.json '.splits.train.inconclusive = 1'
printf 'Eval record: results/desc-inc-train\n' > "$body"
run 1 "a triggering record with an inconclusive train query fails"
has "it says a query is inconclusive" "inconclusive"
spoil desc-ok desc-inc-missing triggering.json 'del(.splits.validation.inconclusive)'
printf 'Eval record: results/desc-inc-missing\n' > "$body"
run 1 "a split that does not say how many queries were inconclusive fails"
spoil desc-ok desc-inc-val triggering.json '.splits.validation.inconclusive = 2'
printf 'Eval record: results/desc-inc-val\n' > "$body"
run 1 "a triggering record with an inconclusive validation query fails"
spoil desc-ok desc-hold triggering.json '.splits.holdout = {queries: 4, passed: 4, failed: 0, inconclusive: 0, pass_rate: 1}'
printf 'Eval record: results/desc-hold\n' > "$body"
run 0 "a triggering record with a conclusive holdout split passes"
spoil desc-ok desc-noval triggering.json 'del(.splits.validation)'
printf 'Eval record: results/desc-noval\n' > "$body"
run 1 "a triggering record with no validation split fails"

mkdir -p "$evals/results/empty-trig"; printf '  \n' > "$evals/results/empty-trig/triggering.json"
printf 'Eval record: results/empty-trig\n' > "$body"
run 1 "a whitespace-only triggering.json fails"

H2="$(tree_at HEAD "$skill")"; B2="$(tree_at base "$skill")"
bench desc-bench foo "$H2" old_skill "$B2"
printf 'Eval record: results/desc-bench\n' > "$body"
run 1 "a description change with only an evaluation record fails"

echo "--- a change to both needs both records"
start both; write_skill "$skill" 'description: "Does foo best."' "Step two."; commit both
bench both-bench foo "$(tree_at HEAD "$skill")" old_skill "$(tree_at base "$skill")"
trig both-trig foo "$(desc_sha HEAD "$skill")"
printf 'Eval record: results/both-bench\n' > "$body"
run 1 "a body and description change with only the evaluation record fails"
printf 'Eval record: results/both-bench\nEval record: results/both-trig\n' > "$body"
run 0 "a body and description change with both records passes"

echo "--- a new skill is measured against no skill"
start new; write_skill skills/build/newone 'description: "New one."' "Body."; commit new
NT="$(tree_at HEAD skills/build/newone)"
bench new-bench newone "$NT" without_skill null
trig new-trig newone "$(desc_sha HEAD skills/build/newone)"
printf 'Eval record: results/new-bench\nEval record: results/new-trig\n' > "$body"
run 0 "a new skill with a without_skill record and a triggering record passes"
bench new-old newone "$NT" old_skill "$NT"
printf 'Eval record: results/new-old\nEval record: results/new-trig\n' > "$body"
run 1 "a new skill measured against an old_skill arm fails"
printf 'Eval record: results/new-bench\n' > "$body"
run 1 "a new skill with no triggering record fails"

echo "--- a removed skill is the maintainer's call"
start removed; git -C "$repo" rm -rq skills/common/gone; commit removed
: > "$body"
run 1 "a removed skill fails without the exemption"
has "the failure names the removed skill" "gone"
run 0 "a removed skill passes with --exempt" --exempt

echo "--- the records measure the text the merge will hold"
git -C "$repo" checkout -q -B dev-moved base
write_skill "$skill" "$desc_line" "Step one, as dev has it now."; commit dev-moved
git -C "$repo" checkout -q -B dev-other base
printf 'x\n' >> "$repo/skills/common/gone/assets/t.md"; commit dev-other
start pr-on-old; write_skill "$skill" "$desc_line" "Step one, as the branch has it."; commit pr-on-old
bench moved-ok foo "$(tree_at HEAD "$skill")" old_skill "$(tree_at base "$skill")"
printf 'Eval record: results/moved-ok\n' > "$body"
BASE=dev-other run 0 "a base that moved in another skill keeps the branch-point record valid"
has "it compares nothing from the other skill" "ok    foo: evaluation record results/moved-ok"
BASE=dev-moved run 1 "a base that changed this skill since the branch point fails"
has "it asks for a rebase" "rebase"
has "the moved skill is named" "foo (skills/common/foo)"
BASE=dev-moved run 0 "--exempt passes a moved base" --exempt

# A closer that is not exactly `---` leaves the description unhashable; the
# change must still need a record, not pass as "the base's".
git -C "$repo" checkout -q -B dev-fence base
printf -- '---\nname: foo\n%s\n--- \n\n# Foo\n\nStep one.\n' "$desc_line" > "$repo/$skill/SKILL.md"; commit dev-fence
git -C "$repo" checkout -q -B case-fence dev-fence
printf -- '---\nname: foo\n%s\n--- \n\n# Foo\n\nStep one.\n' 'description: "Does foo, changed."' > "$repo/$skill/SKILL.md"; commit case-fence
: > "$body"
BASE=dev-fence run 1 "a description change under a closer with a trailing space still needs a record"

echo "--- a skill's text cannot hide from the checker"
start newline; write_skill "skills/common/ev"$'\n'"il" 'description: "Evil."' "Body."; commit newline
: > "$body"
run 1 "a changed path under skills/ with a newline in its name fails"
has "it says why" "has a newline in its name"
start spaced; write_skill "skills/common/sp aced" 'description: "Spaced."' "Body."; commit spaced
run 1 "a skill whose name has a space is checked like any other"
has "it names that skill" "sp aced (skills/common/sp aced) needs an evaluation record"

git -C "$repo" checkout -q -B link-base base
mkdir -p "$repo/outside" "$repo/$skill/references"; printf 'shared\n' > "$repo/outside/shared.md"
ln -s ../../../../outside/shared.md "$repo/$skill/references/link.md"; commit link-base
git -C "$repo" checkout -q -B case-link link-base
printf 'changed\n' >> "$repo/outside/shared.md"; commit case-link
BASE=link-base run 1 "a symbolic link in a skill's references/ fails even when only its target changed"
has "it names the link" "skills/common/foo/references/link.md is a symbolic link"
BASE=link-base run 0 "--exempt passes a symbolic link" --exempt

start flat; mkdir -p "$repo/skills/flat"; printf -- '---\nname: flat\ndescription: "Flat."\n---\n' > "$repo/skills/flat/SKILL.md"; commit flat
run 1 "a SKILL.md outside skills/<phase>/<name>/ fails"
has "it names the stray file" "skills/flat/SKILL.md is not at skills/<phase>/<name>/SKILL.md"
start nested; mkdir -p "$repo/$skill/references/example"; printf 'x\n' > "$repo/$skill/references/example/SKILL.md"; commit nested
run 1 "a SKILL.md inside a skill's references/ is that skill's change"
has "it needs the skill's record" "foo (skills/common/foo) needs an evaluation record"
if printf '%s\n' "$last_out" | grep -qF "is not at skills/<phase>/<name>/SKILL.md"; then
  bad "a SKILL.md inside references/ is not called stray"; else ok "a SKILL.md inside references/ is not called stray"; fi

start dup; printf 'x\n' >> "$repo/$skill/assets/t.md"; commit dup
bench dup-bad foo "$(tree_at base "$skill")" old_skill "$(tree_at base "$skill")"
printf 'Eval record: results/dup-bad\nEval record: results/dup-bad\n' > "$body"
run 1 "a record named twice still fails when it does not match"
n="$(printf '%s\n' "$last_out" | grep -cF 'not results/dup-bad:')"
if [ "$n" = 1 ]; then ok "a record named twice is checked once"; else bad "a record named twice is checked once (reported $n times)"; fi
bench dup-good foo "$(tree_at HEAD "$skill")" old_skill "$(tree_at base "$skill")"
printf 'Eval record: results/dup-good results/x\nEval record: results/dup-good\n' > "$body"
run 1 "a malformed record line still fails"
has "a malformed line that contains a valid one does not hide it" "ok    foo: evaluation record results/dup-good"
: > "$body"

# A link that is itself a directory, a skill, or a phase hides text as well
# as a file link does; only a skill's scripts/ may hold one.
git -C "$repo" checkout -q -B dirlink-base base
mkdir -p "$repo/outside-dir"; printf 'shared\n' > "$repo/outside-dir/a.md"
ln -s ../../../outside-dir "$repo/$skill/references"; commit dirlink-base
run 1 "adding a skill's references/ as a directory link fails"
has "it names the directory link" "skills/common/foo/references is a symbolic link"
has "it counts as the skill's change" "foo (skills/common/foo) needs an evaluation record"
git -C "$repo" checkout -q -B case-dirlink dirlink-base
printf 'changed\n' >> "$repo/outside-dir/a.md"; commit case-dirlink
BASE=dirlink-base run 1 "a directory link fails even when only its target changed"
has "it names the directory link" "skills/common/foo/references is a symbolic link"
start skilllink; ln -s foo "$repo/skills/common/bar"; commit skilllink
run 1 "a skill directory that is a link fails"
has "it names the skill link" "skills/common/bar is a symbolic link"
start phaselink; ln -s common "$repo/skills/linked"; commit phaselink
run 1 "a phase directory that is a link fails"
has "it names the phase link" "skills/linked is a symbolic link"
start scriptlink; ln -s x.sh "$repo/$skill/scripts/y.sh"; commit scriptlink
run 0 "a link inside a skill's scripts/ passes"

git -C "$repo" checkout -q -B stray-base base
mkdir -p "$repo/skills/flat"; printf -- '---\nname: flat\ndescription: "Flat."\n---\n' > "$repo/skills/flat/SKILL.md"; commit stray-base
git -C "$repo" checkout -q -B case-unstray stray-base
git -C "$repo" rm -q skills/flat/SKILL.md; commit case-unstray
BASE=stray-base run 0 "removing a stray SKILL.md passes"
start flat2; mkdir -p "$repo/skills/flat"; printf -- '---\nname: flat\ndescription: "Flat."\n---\n' > "$repo/skills/flat/SKILL.md"; commit flat2
run 1 "a layout failure alone still fails"
if printf '%s\n' "$last_out" | grep -qF "name each record"; then
  bad "a layout failure alone does not ask for record lines"; else ok "a layout failure alone does not ask for record lines"; fi

# The link scan must fail closed when git cannot list the head.
start lsfail; printf 'x\n' >> "$repo/$skill/scripts/x.sh"; commit lsfail
shim="$tmp/shim"; mkdir -p "$shim"
printf '#!/bin/sh\nfor a; do [ "$a" = ls-tree ] && exit 128; done\nexec %s "$@"\n' "$(command -v git)" > "$shim/git"
chmod +x "$shim/git"
out="$(cd "$repo" && env PATH="$shim:$PATH" bash "$S" --base base --head HEAD --evals "$evals" --body "$body" 2>&1)"; code=$?
if [ "$code" = 2 ]; then ok "a link scan git cannot run exits 2"; else bad "a link scan git cannot run exits 2 (got $code: $out)"; fi

# The path patterns are bytes, not characters: a name that is not valid
# UTF-8 is still seen under a UTF-8 locale.
utf8="$(locale -a 2>/dev/null | grep -iE '^(c|en_us)\.utf-?8$' | head -1)"
start badbyte
if [ -n "$utf8" ] && mkdir -p "$repo/skills/ph"$'\xff'"/baz/references" 2>/dev/null; then
  printf -- '---\nname: baz\ndescription: "Baz."\n---\n' > "$repo/skills/ph"$'\xff'"/baz/SKILL.md"
  ln -s ../../../../outside/shared.md "$repo/skills/ph"$'\xff'"/baz/references/l.md"; commit badbyte
  out="$(cd "$repo" && LC_ALL="$utf8" bash "$S" --base base --head HEAD --evals "$evals" --body "$body" 2>&1)"
  if printf '%s' "$out" | grep -qF "is a symbolic link"; then ok "a link in a skill whose path is not UTF-8 fails under $utf8"
  else bad "a link in a skill whose path is not UTF-8 fails under $utf8"; printf '%s\n' "$out" | sed 's/^/        /'; fi
  if printf '%s' "$out" | grep -qF "is not at skills/<phase>/<name>/SKILL.md"; then
    bad "that skill's SKILL.md is not called stray"; else ok "that skill's SKILL.md is not called stray"; fi
else
  echo "  skip  no UTF-8 locale, or the filesystem refuses a non-UTF-8 name"
fi

# A submodule under skills/ is text from another repository that no record
# names, as a link is; only a skill's scripts/ may hold one.
start gitlink
git -C "$repo" update-index --add --cacheinfo "160000,$(git -C "$repo" rev-parse base),skills/common/sub"
git -C "$repo" commit -qm gitlink
run 1 "a skill directory that is a submodule fails"
has "it names the submodule" "skills/common/sub is a submodule"
start gitlink-scripts
git -C "$repo" update-index --add --cacheinfo "160000,$(git -C "$repo" rev-parse base),$skill/scripts/vendored"
git -C "$repo" commit -qm gitlink-scripts
run 0 "a submodule inside a skill's scripts/ passes"
git -C "$repo" checkout -q -f base

# The command CONTRIBUTING gives for running dev's copy must fail when it
# cannot get that copy, not run an empty script and exit 0, and must leave
# nothing behind in the caller's temp directory. It runs on a pull request's
# checkout, whose files and ref names the pull request decides: it must read
# the body from outside that checkout (a committed pr-body.md can be a link
# into .git/), and must take dev from this repository by commit, so that no
# branch or tag the pull request brings, under any name, changes which
# script runs or which base it checks against. The test serves dev from a
# local copy in place of the URL.
url=https://github.com/augments-labs/sdlc-skills.git
cmd="$(awk '/run `dev`.s copy/ { f = 1 } f && /^```bash$/ { b = 1; next } b && /^```$/ { exit } b { print }' "$ROOT/CONTRIBUTING.md")"
if [ -z "$cmd" ]; then bad "CONTRIBUTING has a command for running dev's copy"
elif [ "${cmd#*"$url"}" = "$cmd" ]; then bad "the dev's-copy command fetches dev from $url (got: $cmd)"; else
  up="$tmp/upstream.git"; git init -q --bare "$up"
  cmd="${cmd//"$url"/"$up"}"
  ln -s "$evals" "$tmp/sdlc-skills-evals"
  git -C "$repo" checkout -q -B devcopy base; mkdir -p "$repo/scripts/sh"; cp "$S" "$repo/scripts/sh/"; commit devcopy
  git -C "$repo" push -q "$up" devcopy:refs/heads/dev
  : > "$tmp/pr-body.md"
  dct="$tmp/devcopy-tmp"; mkdir -p "$dct"
  git -C "$repo" checkout -q -B case-devcopy devcopy; printf 'more\n' >> "$repo/notes/a.md"; commit case-devcopy
  out="$(cd "$repo" && TMPDIR="$dct" bash -c "$cmd" 2>&1)"; code=$?
  if [ "$code" = 0 ] && printf '%s' "$out" | grep -q '^eval-record:'; then ok "the dev's-copy command runs dev's copy"
  else bad "the dev's-copy command runs dev's copy (got $code: $out)"; fi
  # A pull request that changes a skill with no record and carries its own
  # script that passes everything. Each ref below points at its head: dev's
  # copy, checking against dev, fails it; the pull request's script, or a
  # base that resolves to the head itself, would pass it.
  git -C "$repo" checkout -q -B case-hostile devcopy
  printf 'echo hostile; exit 0\n' > "$repo/scripts/sh/check-eval-record.sh"
  printf 'more\n' >> "$repo/$skill/SKILL.md"; commit case-hostile
  d="$(git -C "$repo" rev-parse devcopy)"
  for ref in refs/heads/origin/dev refs/tags/origin/dev refs/remotes/origin/dev \
             refs/heads/refs/remotes/origin/dev refs/tags/refs/remotes/origin/dev \
             refs/heads/FETCH_HEAD refs/tags/FETCH_HEAD "refs/heads/$d" "refs/tags/$d"; do
    git -C "$repo" update-ref "$ref" case-hostile
    out="$(cd "$repo" && TMPDIR="$dct" bash -c "$cmd" 2>&1)"; code=$?
    if [ "$code" = 1 ] && printf '%s' "$out" | grep -q '^MISSING  foo (skills/common/foo) needs an evaluation record' \
       && ! printf '%s' "$out" | grep -q hostile
    then ok "the dev's-copy command runs dev's copy against dev past $ref"
    else bad "the dev's-copy command runs dev's copy against dev past $ref (got $code: $out)"; fi
    git -C "$repo" update-ref -d "$ref"
  done
  git -C "$repo" checkout -q case-devcopy
  git -C "$repo" push -q -f "$up" base:refs/heads/dev
  out="$(cd "$repo" && TMPDIR="$dct" bash -c "$cmd" 2>&1)"; code=$?
  if [ "$code" != 0 ]; then ok "the dev's-copy command fails when dev has no copy"
  else bad "the dev's-copy command fails when dev has no copy (got 0: $out)"; fi
  # A failed fetch leaves FETCH_HEAD empty, and git then reads a tag named
  # FETCH_HEAD: the command must stop at the fetch, not go on to resolve one.
  git -C "$repo" update-ref refs/tags/FETCH_HEAD case-hostile
  out="$(cd "$repo" && TMPDIR="$dct" bash -c "${cmd//"$up"/"$tmp/no-such-repo.git"}" 2>&1)"; code=$?
  if [ "$code" != 0 ] && ! printf '%s' "$out" | grep -q '^eval-record:' && ! printf '%s' "$out" | grep -q hostile
  then ok "the dev's-copy command fails when dev cannot be fetched"
  else bad "the dev's-copy command fails when dev cannot be fetched (got $code: $out)"; fi
  git -C "$repo" update-ref -d refs/tags/FETCH_HEAD
  left="$(ls -A "$dct")"
  if [ -z "$left" ]; then ok "the dev's-copy command leaves no temp file"
  else bad "the dev's-copy command leaves no temp file (left: $left)"; fi
  rm -rf "$up"; rm -f "$tmp/pr-body.md" "$tmp/sdlc-skills-evals"
fi

# Each temp file is removed even when a later one cannot be made.
mt="$tmp/mt"; mkdir -p "$mt/bin" "$mt/tmp"
printf '#!/bin/sh
if [ -e "%s/made" ]; then exit 1; fi
: > "%s/made"
exec %s "$@"
' "$mt" "$mt" "$(command -v mktemp)" > "$mt/bin/mktemp"
chmod +x "$mt/bin/mktemp"
out="$(cd "$repo" && env PATH="$mt/bin:$PATH" TMPDIR="$mt/tmp" bash "$S" --base base --head HEAD --evals "$evals" --body "$body" 2>&1)"; code=$?
left="$(ls -A "$mt/tmp")"
if [ "$code" = 2 ] && [ -z "$left" ]; then ok "a failed second mktemp exits 2 and leaves no temp file"
else bad "a failed second mktemp exits 2 and leaves no temp file (got $code, left: $left)"; fi
if printf '%s' "$out" | grep -q 'cannot make a temp file'; then ok "a failed mktemp says so"
else bad "a failed mktemp says so (got: $out)"; fi

git -C "$repo" checkout -q --orphan unrelated; git -C "$repo" rm -rqf . >/dev/null
printf 'x\n' > "$repo/x.md"; commit unrelated
run 2 "a head with no merge base with the base exits 2"
git -C "$repo" checkout -q case-body

echo "--- usage"
out="$(cd "$repo" && bash "$S" --base base 2>&1)"; code=$?
if [ "$code" = 2 ]; then ok "a missing argument exits 2"; else bad "a missing argument exits 2 (got $code)"; fi
out="$(cd "$repo" && bash "$S" --base nosuchrev --head HEAD --evals "$evals" --body "$body" 2>&1)"; code=$?
if [ "$code" = 2 ]; then ok "an unknown revision exits 2"; else bad "an unknown revision exits 2 (got $code)"; fi
exit2() {  # <label> <command...>
  local label="$1" code; shift
  (cd "$repo" && "$@") >/dev/null 2>&1; code=$?
  if [ "$code" = 2 ]; then ok "$label"; else bad "$label (got $code)"; fi
}
exit2 "an unknown argument exits 2" bash "$S" --base base --head HEAD --evals "$evals" --body "$body" --bogus
exit2 "a flag with no value exits 2" bash "$S" --base base --head HEAD --evals "$evals" --body
exit2 "a missing body file exits 2" bash "$S" --base base --head HEAD --evals "$evals" --body "$tmp/nope"
exit2 "an evals checkout with no results/ exits 2" bash "$S" --base base --head HEAD --evals "$tmp" --body "$body"
nojq="$tmp/nojq"; mkdir -p "$nojq"
for c in git awk sed grep cut sort tr sha256sum shasum cat env bash dirname head wc; do
  p="$(command -v "$c" 2>/dev/null)" && ln -sf "$p" "$nojq/$c"
done
out="$(cd "$repo" && env PATH="$nojq" bash "$S" --base base --head HEAD --evals "$evals" --body "$body" 2>&1)"; code=$?
if [ "$code" = 2 ] && printf '%s' "$out" | grep -q 'jq is required'; then ok "a machine without jq exits 2 and says so"
else bad "a machine without jq exits 2 and says so (got $code: $out)"; fi
out="$(bash "$S" --help 2>&1)"; code=$?
if [ "$code" = 0 ]; then ok "--help exits 0"; else bad "--help exits 0 (got $code)"; fi
# One phrase per `exit 2` in the script: a usage error (an unknown argument, a
# flag with no value), an unknown revision, no merge base, a diff or tree
# listing that fails, a temp file it cannot make, a missing input (no
# results/, no body), no jq.
# Only the exit-code paragraph counts, up to its blank line: the flag
# descriptions above it use some of the same words.
codes="$(printf '%s\n' "$out" | sed -n '/^Exit codes:/,/^$/p' | tr '\n' ' ' | tr -s ' ')"
for phrase in 'a usage error' 'an unknown revision' 'no merge base' 'a diff that fails' 'a tree it cannot list' 'a temp file it cannot make' 'a missing input' 'jq is missing'; do
  if printf '%s' "$codes" | grep -qF "$phrase"; then ok "--help names '$phrase' among the causes of exit 2"
  else bad "--help names '$phrase' among the causes of exit 2"; fi
done

echo
if [ "$fails" = 0 ]; then echo "all check-eval-record checks passed"; else echo "check-eval-record checks FAILED"; fi
exit "$fails"
