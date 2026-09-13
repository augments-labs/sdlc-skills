#!/usr/bin/env bash
# Check one skill directory with the library's format and policy profile.
# Field extraction handles this library's metadata shape, not all YAML or
# optional standard metadata. Uses system tools and executes bundled --help;
# checking an untrusted skill is therefore not a passive read-only operation.

set -uo pipefail

usage() {
  cat <<'EOF'
Usage: bash scripts/check-skill.sh [OPTIONS] SKILL_DIR

Check a skill directory with the library's format and policy profile.

Options:
  --format FORMAT   Output format: tsv, json (default: tsv)
  --quiet           Print nothing; report the verdict through the exit code
  --help            Show this message

Checks:
  SKILL.md exists and opens with a YAML frontmatter block
  name         present, 1-64 chars, lowercase [a-z0-9-], no leading/trailing
               hyphen, no `--`, and equal to the directory name
  description  present, non-empty, at most 1024 characters
  body         at most 500 lines and under 5000 tokens (recommended ceiling)
  references   every relative link from SKILL.md resolves inside the skill
  scripts      executes bundled scripts with --help; warns if not executable

Output (tsv):
  One row per finding: LEVEL <tab> CHECK <tab> DETAIL
  LEVEL is `fail` (fails this profile) or `warn` (allowed, worth knowing).
  This is field extraction, not full YAML/optional-metadata validation.
  Findings go to stdout; progress and errors go to stderr.

Exit codes:
  0  passes this profile (warnings may still be present)
  1  one or more `fail` findings
  2  bad arguments, or SKILL_DIR is not a directory
  3  a required tool is missing

Examples:
  bash scripts/check-skill.sh ../../planning/scope-it
  bash scripts/check-skill.sh --format json ~/my-skills/pdf-tools
EOF
}

format=tsv; quiet=0; dir=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --format) format="${2:-}"
              case "$format" in tsv|json) ;; *)
                echo "Error: --format must be one of: tsv, json. Received: \"${2:-}\"" >&2; exit 2;; esac
              shift 2;;
    --quiet)  quiet=1; shift;;
    --help|-h) usage; exit 0;;
    -*) echo "Error: unknown option \"$1\". Run with --help for usage." >&2; exit 2;;
    *)  [ -z "$dir" ] || { echo "Error: only one SKILL_DIR may be given (got \"$dir\" and \"$1\")." >&2; exit 2; }
        dir="$1"; shift;;
  esac
done

[ -n "$dir" ] || { echo "Error: SKILL_DIR is required. Run with --help for usage." >&2; exit 2; }
[ -d "$dir" ] || { echo "Error: not a directory: $dir" >&2; exit 2; }
command -v awk >/dev/null 2>&1 || { echo "Error: awk is not on PATH." >&2; exit 3; }

dir="${dir%/}"
skill="$dir/SKILL.md"
name_expected="$(basename "$dir")"

fails=0; warns=0
rows=""
finding() { # $1 level  $2 check  $3 detail
  [ "$1" = fail ] && fails=$((fails + 1)) || warns=$((warns + 1))
  rows="$rows$1	$2	$3
"
}

# --- SKILL.md and frontmatter -------------------------------------------------
if [ ! -f "$skill" ]; then
  finding fail skill-md "no SKILL.md in $dir"
else
  first="$(head -1 "$skill")"
  if [ "$first" != "---" ]; then
    finding fail frontmatter "SKILL.md must open with '---' on line 1 (found: ${first:-<empty>})"
    fm_end=0
  else
    fm_end="$(awk 'NR>1 && /^---[[:space:]]*$/ {print NR; exit}' "$skill")"
    [ -n "$fm_end" ] || { finding fail frontmatter "frontmatter block is never closed with '---'"; fm_end=0; }
  fi

  if [ "${fm_end:-0}" -gt 0 ]; then
    fm="$(sed -n "2,$((fm_end - 1))p" "$skill")"

    # name
    name="$(printf '%s\n' "$fm" | awk -F: '/^name:/ {sub(/^[^:]*:[[:space:]]*/,""); print; exit}' \
            | sed 's/^["'\'']//; s/["'\'']$//; s/[[:space:]]*$//')"
    if [ -z "$name" ]; then
      finding fail name "frontmatter has no non-empty `name`"
    else
      len=${#name}
      [ "$len" -ge 1 ] && [ "$len" -le 64 ] || finding fail name "must be 1-64 characters (is $len)"
      case "$name" in
        *[!a-z0-9-]*) finding fail name "may contain only lowercase letters, digits, and hyphens: \"$name\"";;
      esac
      case "$name" in
        -*|*-) finding fail name "must not start or end with a hyphen: \"$name\"";;
      esac
      case "$name" in
        *--*) finding fail name "must not contain a double hyphen: \"$name\"";;
      esac
      [ "$name" = "$name_expected" ] || \
        finding fail name "must match the directory name: frontmatter \"$name\" vs directory \"$name_expected\""
    fi

    # description — may be quoted, folded, or block scalar; take everything up to
    # the next top-level key.
    desc="$(printf '%s\n' "$fm" | awk '
      /^description:/ {found=1; sub(/^description:[[:space:]]*/,""); print; next}
      found && /^[A-Za-z_][A-Za-z0-9_-]*:/ {exit}
      found {sub(/^[[:space:]]+/," "); print}
    ' | tr '\n' ' ' | sed 's/^[>|][-+]*//; s/^["'\'']//; s/["'\''][[:space:]]*$//; s/[[:space:]]\+/ /g; s/^ //; s/ $//')"
    if [ -z "$desc" ]; then
      finding fail description "frontmatter has no non-empty \`description\`"
    else
      dlen=${#desc}
      [ "$dlen" -le 1024 ] || finding fail description "must be at most 1024 characters (is $dlen)"
    fi
  fi

  # --- body size --------------------------------------------------------------
  body_lines="$(awk -v e="${fm_end:-0}" 'NR>e' "$skill" | wc -l | tr -d ' ')"
  [ "$body_lines" -le 500 ] || finding fail body-lines "body is $body_lines lines; the house ceiling is 500"
  # Token estimate: words plus punctuation runs, ~1.3x. Deliberately rough — it
  # only has to catch a body approaching 5000, not price a request.
  words="$(awk -v e="${fm_end:-0}" 'NR>e' "$skill" | wc -w | tr -d ' ')"
  tokens=$(( words * 13 / 10 ))
  [ "$tokens" -lt 5000 ] || finding fail body-tokens "body is ~$tokens tokens; the house ceiling is 5000"

  # --- presentation -------------------------------------------------------------
  # The guidance asks for concise, stepwise instructions an agent can scan, and
  # warns that an overly comprehensive skill makes the agent "struggle to extract
  # what's relevant". A wall of undifferentiated prose is that failure in its
  # most literal form, so measure the longest run of body lines carrying no
  # blank line, heading, or list marker. Tables and fenced blocks are exempt:
  # both are legitimately long and already structured.
  wall="$(awk -v e="${fm_end:-0}" '
    NR<=e            { next }
    /^[[:space:]]*```/ { fence = !fence; run=0; next }
    fence            { next }
    /^[[:space:]]*\|/ { run=0; next }
    /^[[:space:]]*#/  { if (run>max) {max=run; at=start} run=0; next }
    /^[[:space:]]*$/  { if (run>max) {max=run; at=start} run=0; next }
    /^[[:space:]]*([0-9]+\.|[-*])[[:space:]]/ { if (run>max) {max=run; at=start} run=1; start=NR; next }
    { if (run==0) start=NR; run++ }
    END              { if (run>max) {max=run; at=start} print max+0 "\t" at+0 }
  ' "$skill")"
  wall_len="${wall%%	*}"; wall_at="${wall##*	}"
  [ "${wall_len:-0}" -le 12 ] || \
    finding warn presentation "$wall_len unbroken lines starting at line $wall_at; break it into paragraphs, a list, or subsections"

  # --- references resolve ------------------------------------------------------
  # Every relative link target must exist, and must sit inside the skill.
  # Markdown links, plus bare `references/x.md` mentions in backticks — this
  # library cites support files both ways.
  # The third pattern matches the path itself rather than its delimiters,
  # because a backtick span is routinely wrapped across two lines and a
  # line-based match on the opening backtick then sees nothing.
  bt='`'
  targets="$( { grep -oE '\]\([^)]+\)' "$skill" 2>/dev/null | sed 's/^](//; s/)$//'
               grep -oE "${bt}(\.\./|references/|scripts/|assets/)[^${bt}]+${bt}" "$skill" 2>/dev/null | tr -d "$bt"
               grep -oE '(\.\./|references/|scripts/|assets/)[A-Za-z0-9._/-]+\.[A-Za-z0-9]+' "$skill" 2>/dev/null
             } | sort -u )"
  while IFS= read -r target; do
    [ -n "$target" ] || continue
    case "$target" in
      http*|mailto:*|'#'*) continue;;
    esac
    t="${target%%#*}"
    [ -n "$t" ] || continue
    if [ ! -e "$dir/$t" ]; then
      finding fail references "SKILL.md links \`$t\`, which does not exist in the skill"
    elif [ "${t#../}" != "$t" ]; then
      finding warn references "\`$t\` escapes the skill directory; it will not resolve wherever the skill is installed flat"
    fi
  done <<REFS
$targets
REFS
fi

# --- bundled scripts ----------------------------------------------------------
if [ -d "$dir/scripts" ]; then
  found_any=0
  while IFS= read -r s; do
    [ -n "$s" ] || continue
    found_any=1
    rel="${s#"$dir"/}"
    [ -x "$s" ] || finding warn scripts "$rel is not executable"
    # A script an agent cannot introspect is a script it will use wrong.
    if ! ( "$s" --help </dev/null >/dev/null 2>&1 || bash "$s" --help </dev/null >/dev/null 2>&1 ); then
      finding fail scripts "$rel does not answer \`--help\` successfully"
    fi
  done <<EOF
$(find "$dir/scripts" -maxdepth 1 -type f 2>/dev/null | sort)
EOF
  [ "$found_any" = 1 ] || finding warn scripts "scripts/ exists but contains no files"
fi

# --- report -------------------------------------------------------------------
if [ "$quiet" = 0 ]; then
  if [ "$format" = json ]; then
    printf '{ "skill": "%s", "fails": %s, "warns": %s, "findings": [' "$name_expected" "$fails" "$warns"
    first=1
    printf '%s' "$rows" | while IFS=$'\t' read -r lvl chk det; do
      [ -n "$lvl" ] || continue
      [ "$first" = 1 ] || printf ','
      first=0
      det="${det//\\/\\\\}"; det="${det//\"/\\\"}"
      printf '{"level":"%s","check":"%s","detail":"%s"}' "$lvl" "$chk" "$det"
    done
    printf '] }\n'
  else
    printf '%s' "$rows"
  fi
fi

[ "$fails" -gt 0 ] && exit 1
exit 0
