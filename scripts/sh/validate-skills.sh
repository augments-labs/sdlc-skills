#!/usr/bin/env bash
# Structural validator for SDLC skills.
# Enforces the authoring rules in CLAUDE.md across every skill in skills/.
# Flags and exit codes: --help.

set -uo pipefail
cd "$(dirname "$0")/../.." || exit 2

strict=""
[ $# -le 1 ] || { echo "at most one argument (see --help)" >&2; exit 2; }
case "${1-}" in
  -h|--help)
    cat <<'EOF'
scripts/sh/validate-skills.sh — structural gate for every skill in skills/.

Checks frontmatter shape, line and description budgets, directory layout,
resolvable reference paths, absent external references and vendor model names,
and that each plugin manifest parses as JSON and registers every skill. CI runs
this on every push and PR.

  --strict  fail on the policy checks check-skill.sh otherwise reports as
            warnings, reference-load-condition included
  --help    this text

Exit codes: 0 every skill passed · 1 violations printed above the summary
            2 not run from the repo, or an unknown argument · requires `jq`
EOF
    exit 0;;
  --strict) strict=--strict ;;
  "") ;;
  *) echo "unknown argument: $1 (see --help)" >&2; exit 2 ;;
esac

fail=0
note() { printf '  %s\n' "$1"; }
err()  { printf '  FAIL: %s\n' "$1"; fail=1; }

# Patterns that must never appear in shipped skills (see CLAUDE.md).
EXT_REFS='superpowers|obra|mattpocock|pocock|ousterhout|github\.com|https?://|#[0-9]{2,}'
VENDORS='\b(haiku|sonnet|opus|claude|gpt-?[0-9o]|gemini|flash|llama|mistral|openai|anthropic)\b'
# Skill text is part of the harness's scan surface: a literal trigger-word in a
# body can hijack the session (fire a thinking mode, trip an injection detector)
# every time the skill loads. Keep shipped text inert to keyword scanners.
SCANNER_TRIGGERS='\bultrathink\b'
# A skill whose name matches a common built-in slash command gets mis-invoked —
# the harness or model picks the wrong one. Names must not shadow them.
SHADOWED_COMMANDS='^(review|init|compact|clear|help|config|status|commit|test|run|plan|resume|doctor|login|logout|memory|mcp|model|agents|hooks|settings|todos|cost|export|bug|vim)$'

mapfile -t skills < <(find skills -name SKILL.md | sort)
[ ${#skills[@]} -eq 0 ] && { echo "no skills found under skills/"; exit 2; }

# Shared format and policy checks are delegated to the checker this library
# ships (see the per-skill loop). It has to exist and answer --help here. In the
# loop, a non-zero exit that reports no fail row is itself a FAIL naming the
# checker, the skill, the exit code, and the first diagnostic, so a checker that
# crashes fails the gate instead of passing every skill in silence.
CONFORMANCE=skills/common/writing-skills/scripts/check-skill.sh
[ -f "$CONFORMANCE" ] || { echo "missing $CONFORMANCE — the skill-format checks are delegated to it"; exit 2; }
bash "$CONFORMANCE" --help >/dev/null 2>&1 || { echo "$CONFORMANCE does not run"; exit 2; }
conformance_err=$(mktemp) || { echo "could not create a file for $CONFORMANCE diagnostics"; exit 2; }
trap 'rm -f "$conformance_err"' EXIT

for skill in "${skills[@]}"; do
  dir=$(dirname "$skill")
  name_dir=$(basename "$dir")
  echo "• $skill"

  # Delegate the shared format and policy profile: required field extraction,
  # names, sizes, links, presentation, and executable script help. This is not
  # full YAML/optional-metadata validation. Preserve warnings as well as errors,
  # and the checker's exit status: non-zero with no fail row is a crash.
  conformance_rows=$(bash "$CONFORMANCE" ${strict:+"$strict"} "$dir" 2>"$conformance_err")
  conformance_status=$?
  conformance_fails=0
  while IFS=$'\t' read -r level check detail; do
    case "$level" in
      fail) err  "$check: $detail"; conformance_fails=1 ;;
      warn) note "warn: $check: $detail" ;;
    esac
  done <<<"$conformance_rows"
  if [ "$conformance_status" -ne 0 ] && [ "$conformance_fails" = 0 ]; then
    conformance_diag=$(grep -m1 . "$conformance_err" || printf '%s\n' "$conformance_rows" | grep -m1 .)
    err "$CONFORMANCE exited $conformance_status on $dir with no fail row: ${conformance_diag:-no output}"
  fi

  fname=$(awk -F': ' '/^name:/{print $2; exit}' "$skill")

  # name must not shadow a common harness slash command.
  [ -n "$fname" ] && echo "$fname" | grep -qiE "$SHADOWED_COMMANDS" && err "name '$fname' shadows a common harness command — rename to avoid mis-invocation"

  # Advisory house size targets keep a multi-skill catalogue concise; exceeding
  # these targets produces warnings, separate from the enforced profile limits.
  #
  # The line target was once a hard failure at 120, and that was a mistake with a
  # visible cost: authors bought line count by dropping articles and verbs until
  # the prose read as a noun stack. Compression is not concision. A body that
  # needs 140 clear lines should take them; see docs/agent-skills-conformance.md.
  lines=$(wc -l < "$skill")
  [ "$lines" -gt 200 ] && note "warn: $lines lines (>200; well over the house target — is every line earning its place?)"

  words=$(wc -w < "$skill")
  tokens=$(( words * 13 / 10 ))
  [ "$tokens" -gt 2500 ] && note "warn: ~$tokens tokens (>2500; over the house target)"

  # No external references, vendor model names, or <angle> placeholders — in every
  # .md of the skill, RECURSIVELY (covers references/ and scripts/ subfolders).
  # The external-reference, vendor, and trigger-word scans read the raw text: a
  # backticked URL, issue, model name, or trigger word still ships and still
  # reaches a keyword scanner. Only the placeholder check skips inline code
  # spans, where a literal <tag> can be what the text is about.
  while IFS= read -r f; do
    raw=$(cat "$f")
    body=$(sed 's/`[^`]*`//g' "$f")   # inline code spans removed, for the placeholder check
    # The Agent Skills specification is the one external host a skill may cite:
    # strip only its scheme and host so a path is still scanned, and fail closed
    # when sed cannot run the edit.
    if ! scanned=$(printf '%s\n' "$raw" | sed -E 's@https?://agentskills\.io([/?#[:space:])>])@\1@g; s@https?://agentskills\.io$@@'); then
      err "$(basename "$f"): external-reference scan could not run"
    elif grep -qiE "$EXT_REFS" <<<"$scanned"; then
      err "$(basename "$f"): external reference (repo/issue/URL) — state the principle directly"
    fi
    printf '%s\n' "$raw" | grep -qiE "$VENDORS"         && err "$(basename "$f"): vendor model name — use a capability tier (small|medium|large)"
    printf '%s\n' "$raw" | grep -qiE "$SCANNER_TRIGGERS" && err "$(basename "$f"): harness scanner trigger-word — rephrase so a keyword scan can't hijack the session"
    echo "$body" | grep -qE  '<[a-z][a-z0-9 -]*>' && err "$(basename "$f"): bare <angle> placeholder — use {{double-curly}}"
    # The .sdlc-skills/ output location is mandatory (overridable only by the user),
    # never an optional "default" — keep the convention from drifting back.
    grep -nE '\.sdlc-skills/' "$f" | grep -qi 'default' && err "$(basename "$f"): frames an .sdlc-skills/ path as a 'default' — that location is mandatory (overridable only by the user), not a default"
  done < <(find "$dir" -name '*.md')
done

# Cross-skill routing lives in skill text: a precondition, boundary, or handoff
# names its peer in backticks, in SKILL.md and in the references/ and assets/
# files it loads. A rename or removal must not leave stale names behind — a
# handoff to a skill that no longer exists routes nowhere, silently. Two rules
# cover every .md of every skill:
# - a backticked kebab-case token is a skill name or on name_allowlist;
# - a single-word handoff target is a skill name or on handoff_allowlist.
#   Handoffs are read with the graph gate's own grammar
#   (validate-skill-graph.sh --targets), so the two gates agree on what one is.
echo "• backticked skill names and handoff targets resolve to skills on disk"
skill_names="$(find skills -mindepth 3 -maxdepth 3 -name SKILL.md -exec dirname {} \; | xargs -n1 basename | sort -u)"
name_allowlist='common-dir git-dir integrated-regression description-yaml reference-depth reference-load-condition
  blocked-preserved cancellation-requested closed-preserved discard-pending materialized-kept outcome-unknown
  comment-accuracy silent-failures test-coverage type-design'
handoff_allowlist='inconclusive satisfied'
while IFS=: read -r file token; do
  printf '%s\n' "$skill_names" | grep -qx "$token" && continue
  printf '%s\n' $name_allowlist | grep -qx "$token" && continue
  err "$file: backticked \`$token\` matches no skill on disk (stale cross-reference, or add it to name_allowlist)"
done < <(find skills -name '*.md' -exec grep -oH '`[a-z][a-z]*\(-[a-z][a-z]*\)\{1,\}`' {} + | tr -d '\`' | sort -u)
if handoff_targets="$(bash scripts/sh/validate-skill-graph.sh --targets)"; then
  while IFS=$'\t' read -r file token; do
    case "$token" in ''|*[!a-z]*) continue ;; esac
    printf '%s\n' "$skill_names" | grep -qx "$token" && continue
    printf '%s\n' $handoff_allowlist | grep -qx "$token" && continue
    err "$file: handoff target \`$token\` matches no skill on disk (stale handoff, or add it to handoff_allowlist)"
  done <<<"$handoff_targets"
else
  err "validate-skill-graph.sh --targets could not run, so handoff targets were not checked"
fi

# Progressive-disclosure links are executable navigation for an agent. Resolve
# them in the canonical install tree; adapter-specific layouts run the same
# helper against their own tree.
echo "• skill reference paths resolve"
if ! bash scripts/sh/validate-skill-reference-paths.sh skills; then fail=1; fi

# Progressive disclosure only works if SKILL.md names the file and says when to
# open it. A support file nothing links to is dead weight the agent never finds.
# Both standard support directories are checked: references/ (documentation read
# on demand) and assets/ (templates the agent fills in).
echo "• every sibling reference is directly disclosed"
while IFS= read -r ref; do
  skill_dir="$(dirname "$(dirname "$ref")")"
  skill_file="$skill_dir/SKILL.md"
  ref_dir="$(basename "$(dirname "$ref")")"
  ref_name="$(basename "$ref")"
  grep -Fq "$ref_dir/$ref_name" "$skill_file" ||
    err "$ref: not referenced directly from $skill_file"
done < <(find skills \( -path '*/references/*.md' -o -path '*/assets/*.md' \) -type f | sort)

# The plan's version script and mode question ship with every skill that reads
# them, so each executor is self-contained; the copies must not drift.
for copy in executing-plans subagent-driven-development; do
  echo "• plan-version.sh: the $copy copy is byte-identical to writing-plans"
  cmp -s skills/design/writing-plans/scripts/plan-version.sh "skills/implementation/$copy/scripts/plan-version.sh" ||
    err "plan-version.sh: the writing-plans and $copy copies differ"

  echo "• mode-question.md: the $copy copy is byte-identical to writing-plans"
  cmp -s skills/design/writing-plans/assets/mode-question.md "skills/implementation/$copy/assets/mode-question.md" ||
    err "mode-question.md: the writing-plans and $copy copies differ"
done

# The checker enforces executable permission and successful `--help` as house
# policy. These additional house checks require direct disclosure in SKILL.md
# so the agent can find the script, and documented exit codes so it can act on
# the result. The standard does not require this interface.
echo "• every bundled script is disclosed and documents its exit codes"
while IFS= read -r s; do
  skill_file="$(dirname "$(dirname "$s")")/SKILL.md"
  name="$(basename "$s")"

  grep -Fq "scripts/$name" "$skill_file" ||
    err "$s: not named in $skill_file — an agent cannot run what it never sees"
  grep -q '^## Available scripts' "$skill_file" ||
    err "$skill_file: bundles scripts but has no '## Available scripts' section"

  { timeout 20 "$s" --help 2>/dev/null || timeout 20 bash "$s" --help 2>/dev/null; } | grep -qi 'exit code' ||
    err "$s: --help does not document its exit codes"
done < <(find skills -path '*/scripts/*' -type f | sort)

# The governed preview (serve.py + start/stop wrappers) ships one copy per
# skill that offers it: skill-local resolution survives every adapter layout,
# and a cross-skill link would not. The copies must stay byte-identical —
# two drifting previews are two contracts.
echo "• preview scripts are identical across skills"
preview_dirs=$(find skills -path '*/scripts/serve.py' -type f -exec dirname {} \; | sort)
if [ -n "$preview_dirs" ]; then
  ref_dir=$(printf '%s\n' "$preview_dirs" | head -1)
  for d in $preview_dirs; do
    [ "$d" = "$ref_dir" ] && continue
    for f in "$ref_dir"/*; do
      name=$(basename "$f")
      [ -f "$d/$name" ] || { err "preview script missing: $d/$name"; continue; }
      cmp -s "$f" "$d/$name" || err "preview scripts drifted: $f vs $d/$name"
    done
  done
fi

# House layout: fill-in templates go in assets/; lookup guidance goes in
# references/. This makes the standard's suggested organization a local rule.
echo "• templates live in assets/, not references/"
while IFS= read -r ref; do
  # The file's own opening sentence is the honest classifier: a template tells
  # the agent to fill or copy it; documentation tells it what to know or check.
  opening="$(grep -m1 -v '^#\|^$' "$ref")"
  case "$opening" in
    [Ff]ill*|[Cc]opy\ this*|[Uu]se\ this\ template*|[Ww]rite\ the\ completed*|[Cc]reate\ one\ row*)
      err "$ref: opens as a fill-in template — house policy puts document templates in assets/";;
  esac
done < <(find skills -path '*/references/*.md' -type f | sort)

# The session-start text ships too, and is injected into every session, so a
# scanner trigger-word there fires constantly, not just when one skill loads.
# Both copies are read raw. The router body they wrap is scanned with its skill.
echo "• session-start injection (scanner trigger-words)"
for f in scripts/sh/session-start.sh plugins/sdlc-skills/scripts/sh/session-start.sh; do
  if [ ! -f "$f" ]; then
    err "$f: missing, so the text it injects cannot be scanned"
  elif grep -qiE "$SCANNER_TRIGGERS" "$f"; then
    err "$f: harness scanner trigger-word"
  fi
done

# Routing belongs in session-start context; no tool or turn-end hooks ship.
echo "• session-start-only activation"
if ! bash tests/run-session-start.sh >/dev/null; then
  err "tests/run-session-start.sh failed"
fi
for retired_script in \
  scripts/sh/implementation-remind.sh \
  scripts/sh/stop-nudge.sh \
  scripts/sh/stop-nudge-detect.sh \
  scripts/sh/stop-nudge-kimi.sh \
  tests/run-stop-nudge.sh \
  scripts/sh/implementation-guard.sh \
  scripts/sh/completion-guard.sh \
  tests/run-implementation-guard.sh \
  tests/run-completion-guard.sh \
  tests/run-plan-execution-contract.sh; do
  [ ! -e "$retired_script" ] || err "obsolete $retired_script still exists"
done

# Manifest sync: a harness discovers skills only through its manifest, so every
# leaf skill dir must be listed explicitly in the plugin's "skills" array — a
# skill missing from it silently fails to load; a dead entry points nowhere.
actual=$(printf '%s\n' "${skills[@]}" | sed 's|/SKILL.md$||; s|^|./|' | sort -u)
manifest=.claude-plugin/plugin.json
echo "• $manifest (skills array sync)"
if [ ! -f "$manifest" ]; then
  err "missing $manifest"
elif ! command -v jq >/dev/null 2>&1; then
  err "jq is required to read $manifest (the adapter checks below need it too)"
elif ! jq -e . "$manifest" >/dev/null 2>&1; then
  err "$manifest does not parse as JSON — a harness loads no skill from it"
else
  # Read the array itself: a grep over the whole file also matches paths under
  # a renamed or absent "skills" key, so the gate passed manifests no harness
  # can load.
  declared=$(jq -r '.skills[]? // empty' "$manifest" | sort -u)
  if [ -z "$declared" ]; then
    err "$manifest has no non-empty \"skills\" array — no skill would load"
  else
    missing=$(comm -23 <(printf '%s\n' "$actual") <(printf '%s\n' "$declared"))
    dead=$(comm -13 <(printf '%s\n' "$actual") <(printf '%s\n' "$declared"))
    [ -n "$missing" ] && while IFS= read -r m; do err "skill not in $manifest 'skills' (won't load): $m"; done <<< "$missing"
    [ -n "$dead" ]    && while IFS= read -r d; do err "$manifest 'skills' entry has no SKILL.md: $d"; done <<< "$dead"
  fi
fi

echo "• Codex adapter"
if ! bash scripts/sh/validate-codex-plugin.sh; then fail=1; fi

echo "• Kimi adapter"
if ! bash scripts/sh/validate-kimi-plugin.sh; then fail=1; fi

echo "• OpenCode adapter"
if ! bash scripts/sh/validate-opencode-plugin.sh; then fail=1; fi

# Version sync: the release version is declared in three manifests and bumped
# together in one release commit (see RELEASING.md). A half-done bump ships
# disagreeing versions, so any disagreement fails.
echo "• manifest versions agree"
versions=""
for manifest in .claude-plugin/plugin.json .claude-plugin/marketplace.json .kimi-plugin/plugin.json; do
  if [ ! -f "$manifest" ]; then err "missing $manifest"; continue; fi
  v=$(grep -m1 -oE '"version"[[:space:]]*:[[:space:]]*"[^"]+"' "$manifest" | sed -E 's/.*"([^"]+)"$/\1/')
  if [ -z "$v" ]; then err "$manifest: no \"version\" field"; continue; fi
  versions="$versions$v"$'\n'
done
distinct=$(printf '%s' "$versions" | sort -u | grep -c .)
[ "$distinct" -gt 1 ] && err "manifest versions disagree: $(printf '%s' "$versions" | sort -u | tr '\n' ' ')"

# Internal references: any repo-root docs/ or tests/ markdown path named in a
# shipped or meta file must exist — a broken link ships straight to users.
echo "• internal references (docs/ and tests/ paths resolve)"
while IFS=: read -r src ref; do
  [ -f "$ref" ] || err "$src: internal reference '$ref' does not exist"
done < <(grep -roE --include='*.md' --include='*.sh' \
           '(docs|tests)/[A-Za-z0-9._/-]+\.md' skills docs tests README.md CLAUDE.md | sort -u)

# Conformance record freshness. docs/agent-skills-conformance.md
# states how much headroom the library actually has against the standard's
# ceilings, and how many skills use each directory kind. Those are measurements
# of this tree, so they rot on any edit — and a conformance record with stale
# numbers is worse than one with none, because it reads as checked.
#
# This compares measurements, not limits. The ceilings themselves (1024, 500,
# 5000) live in check-skill.sh alone and are deliberately not restated here.
echo "• conformance record matches the tree"
CONF_DOC=docs/agent-skills-conformance.md
if [ ! -f "$CONF_DOC" ]; then
  err "$CONF_DOC is missing — the conformance record is part of the gate"
else
  max_desc=0; max_lines=0; max_tokens=0
  for skill in skills/*/*/SKILL.md; do
    fm_end=$(awk 'NR>1 && /^---[[:space:]]*$/{print NR; exit}' "$skill")
    d=$(awk -v e="${fm_end:-0}" '
             NR>=e{exit}
             /^description:/{found=1; sub(/^description:[[:space:]]*/,""); printf "%s", $0; next}
             found && /^[a-z_-]+:/{exit}
             found{printf " %s", $0}' "$skill" | sed 's/^"//; s/"$//')
    [ "${#d}" -gt "$max_desc" ] && max_desc=${#d}
    l=$(awk -v e="${fm_end:-0}" 'NR>e' "$skill" | wc -l | tr -d ' ')
    [ "$l" -gt "$max_lines" ] && max_lines=$l
    w=$(awk -v e="${fm_end:-0}" 'NR>e' "$skill" | wc -w | tr -d ' ')
    t=$(( w * 13 / 10 ))
    [ "$t" -gt "$max_tokens" ] && max_tokens=$t
  done
  n_refs=$(ls -d skills/*/*/references 2>/dev/null | wc -l | tr -d ' ')
  n_assets=$(ls -d skills/*/*/assets 2>/dev/null | wc -l | tr -d ' ')
  n_scripts=$(ls -d skills/*/*/scripts 2>/dev/null | wc -l | tr -d ' ')

  # Each claim is matched by a phrase unique to its row. A phrasing change that
  # breaks the match fails loudly rather than passing an unchecked number.
  conf_claim() {  # <label> <actual> <regex with one capture group>
    got=$(grep -oE "$3" "$CONF_DOC" | head -1 | grep -oE '[0-9]+' | head -1)
    if [ -z "$got" ]; then
      err "$CONF_DOC: no '$1' claim found — the gate cannot check it (expected a row matching /$3/)"
    elif [ "$got" != "$2" ]; then
      err "$CONF_DOC: states $1 = $got, tree says $2 — update the conformance record"
    fi
  }
  conf_claim "longest description"  "$max_desc"   'longest is [0-9]+ \|'
  conf_claim "longest body"         "$max_lines"  'longest is [0-9]+ \([0-9]+% of ceiling\)'
  conf_claim "largest body tokens"  "$max_tokens" 'largest is ~[0-9]+'
  conf_claim "references/ count"    "$n_refs"     '\| [0-9]+ skills; rubrics'
  conf_claim "assets/ count"        "$n_assets"   '\| [0-9]+ skills; every fill-in template'
  conf_claim "scripts/ count"       "$n_scripts"  '\| [0-9]+ skills — see below'
fi

echo ""
if [ "$fail" -eq 0 ]; then echo "✓ all skills pass structural validation"; else echo "✗ violations found"; fi
exit "$fail"
