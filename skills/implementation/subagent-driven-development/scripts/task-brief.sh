#!/usr/bin/env bash
# Render one role brief from a role template and a plan task file.
#
# Read-only. The rendered brief goes to stdout.

set -uo pipefail

usage() {
  cat <<'EOF'
Usage: bash scripts/task-brief.sh --task FILE --role ROLE --roles DIR [OPTIONS]

Render one role brief by filling the role template with this task's paths, and
refuse to render one that is still incomplete.

Options:
  --task FILE       the plan task file this brief is about
  --role ROLE       implementer | task-reviewer | re-reviewer
  --roles DIR       directory holding ROLE.md — the skill's assets/
  --workspace PATH  absolute path of the worktree the worker reads and writes
  --base REV        the revision the work starts from
  --tier TIER       small | medium | large
  --report FILE     where the worker writes its report
  --input PATH      another file the worker must read; repeatable, may be omitted
  --help            show this message

Placeholders filled: {{task-file}}, {{workspace}}, {{base}}, {{tier}},
{{report}}, {{inputs}}, {{report-template}}, {{task-body}}. Every value is
inserted literally: an & in a task file, a report, or any other value is
never expanded to the matched slot text.

{{task-file}}, {{workspace}}, {{base}}, {{tier}}, {{report}}, and {{inputs}}
are filled first, on the template shell alone — the task's own content is not
yet in it. A brief that still holds one of those, or any other unrecognized
{{...}}, is never printed as if it were ready: a worker reads the literal
braces as its instruction and implements nothing. That is exit 1, and it is
the check this script exists for. The check looks for whatever {{...}} is
still in the shell at that point, not a fixed name list, so a mistyped or
renamed slot in a role template is caught the same as a known one left
unfilled. {{report-template}} and {{task-body}} are exempt from that check:
both are intentionally still open here and are filled next, in order.

{{report-template}} is filled next, from ROLE-report.md beside ROLE.md in
--roles (implementer.md's slot reads implementer-report.md). A role template
without the slot renders exactly as before. When the slot is present, its
report file missing or unreadable is exit 2, not exit 1: a role template
without a report template to insert is a setup defect, not a half-filled
brief.

{{task-body}} is filled last, once every other slot is filled and checked and
the report template is in place. Nothing in the task's own content is ever
matched against this script's placeholder names, filled, rewritten, or
refused: a task body that quotes `{{workspace}}` or `{{report-template}}`
reaches the worker exactly as written. An empty task body still leaves
{{task-body}} standing, which is still exit 1.

A role template may carry its whole brief inside one fenced block: a line
that is exactly ````markdown, and a later line that is exactly ````. When it
does, only the lines between those two markers are ever a candidate for the
rendered brief — the template's own preamble and the fence markers are
structure, not content, and never reach stdout. A template with no such fence
renders exactly as it always has. A template with more than one such opening
fence line is refused: the script cannot tell which fenced block is the
brief, so it exits 2 rather than guess. A fence opened but never closed is
refused the same way.

Exit codes:
  0  the brief is complete and on stdout
  1  one of this script's own placeholders was left unfilled
  2  bad arguments, unknown role, a file that cannot be read, or a template
     whose fenced brief is malformed (more than one fence, or an unterminated
     one)
EOF
}

task=""; role=""; roles=""; workspace=""; base=""; tier=""; report=""; inputs=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --task)      task="${2-}"; shift 2;;
    --role)      role="${2-}"; shift 2;;
    --roles)     roles="${2-}"; shift 2;;
    --workspace) workspace="${2-}"; shift 2;;
    --base)      base="${2-}"; shift 2;;
    --tier)      tier="${2-}"; shift 2;;
    --report)    report="${2-}"; shift 2;;
    --input)     [ -n "${2-}" ] || { echo "--input needs a path" >&2; exit 2; }
                 inputs="${inputs}${inputs:+$'\n'}- ${2}"; shift 2;;
    -h|--help)   usage; exit 0;;
    *) echo "unknown argument: $1 (see --help)" >&2; exit 2;;
  esac
done

[ -n "$task" ]  || { echo "--task is required (see --help)" >&2; exit 2; }
[ -n "$role" ]  || { echo "--role is required (see --help)" >&2; exit 2; }
[ -n "$roles" ] || { echo "--roles is required (see --help)" >&2; exit 2; }
[ -f "$task" ]  || { echo "no task file at $task" >&2; exit 2; }

case "$role" in
  implementer|task-reviewer|re-reviewer) ;;
  *) echo "unknown role: $role (implementer | task-reviewer | re-reviewer)" >&2; exit 2;;
esac

template="$roles/$role.md"
[ -f "$template" ] || { echo "no role template at $template" >&2; exit 2; }

body="$(cat "$task")" || { echo "cannot read $task" >&2; exit 2; }
text="$(cat "$template")" || { echo "cannot read $template" >&2; exit 2; }
[ -n "$inputs" ] || inputs="(none)"

# The template may carry its whole brief inside one fenced block. Detected on
# the raw template text, before any fill below — the task's own pasted body
# can legitimately contain a line that looks like a fence marker, and that
# must never be mistaken for the template's own structure.
open_count="$(printf '%s\n' "$text" | grep -Fxc '````markdown')"
case "$open_count" in
  0) ;; # no fence: render the whole template, as always
  1)
    open_line="$(printf '%s\n' "$text" | grep -nFx '````markdown' | cut -d: -f1)"
    close_rel="$(printf '%s\n' "$text" | tail -n "+$((open_line + 1))" | grep -nFx '````' | head -1 | cut -d: -f1)"
    if [ -z "$close_rel" ]; then
      echo "template's fenced brief has no closing fence" >&2
      exit 2
    fi
    close_line=$((open_line + close_rel))
    text="$(printf '%s\n' "$text" | sed -n "$((open_line + 1)),$((close_line - 1))p")"
    ;;
  *)
    echo "template carries more than one fenced brief" >&2
    exit 2;;
esac

# An empty value leaves its placeholder standing, so the check below stops a
# half-filled brief rather than dispatching one with a hole where the tier goes.
# The replacement is quoted so bash's patsub_replacement (on by default, bash
# 5.2+) never reinterprets an unquoted & in $2 as the matched slot text — the
# value goes in exactly as given, in every bash this script runs under.
fill() {
  [ -n "$2" ] || return 0
  text="${text//\{\{$1\}\}/"$2"}"
}
# task-body is deliberately not filled here: it is the task's own content, and
# nothing in it may be matched against this script's placeholder names,
# filled, rewritten, or refused as unfilled. It is inserted last, below, once
# every other slot on the template shell alone is filled and checked.
fill task-file "$task"
fill workspace "$workspace"
fill base "$base"
fill tier "$tier"
fill report "$report"
fill inputs "$inputs"

# The leftover check runs on the template shell alone — task-body is not yet
# inserted, so nothing in the task's own content can be mistaken for a
# half-filled brief. It looks for whatever {{...}} is still standing, not a
# fixed name list, so a mistyped or renamed slot in a role template
# ({{worksapce}}, a future {{input-list}}) is caught the same as a known one
# left unfilled. {{task-body}} and {{report-template}} are excluded: both are
# intentionally still open at this point and are filled separately, below.
leftover=""
while IFS= read -r name; do
  case "$name" in
    task-body|report-template) ;;
    *)
      echo "unfilled placeholder: {{$name}}" >&2
      leftover=1;;
  esac
done < <(printf '%s' "$text" | grep -oE '\{\{[^{}]+\}\}' | sed -e 's/^{{//' -e 's/}}$//' | sort -u)
[ -z "$leftover" ] || exit 1

case "$text" in
  *'{{report-template}}'*)
    report_template="$roles/$role-report.md"
    # Read and check readability in one step: a missing file and an
    # unreadable one both fail `cat`, and the contract treats them alike.
    report_text="$(cat "$report_template" 2>/dev/null)" \
      || { echo "no report template at $report_template" >&2; exit 2; }
    # The replacement is quoted so bash's patsub_replacement (on by default,
    # bash 5.2+) never reinterprets an unquoted & in $report_text as the
    # matched slot text — the report's own content goes in exactly as read.
    text="${text//\{\{report-template\}\}/"$report_text"}"
    ;;
esac

# The task's own content is inserted last, after every other slot is filled,
# checked, and the report template is in place — so nothing in it is ever
# filled, rewritten, or refused as this script's own placeholder. An empty
# task body leaves {{task-body}} standing, which is still a half-filled brief.
fill task-body "$body"
case "$text" in
  *'{{task-body}}'*)
    echo "unfilled placeholder: {{task-body}}" >&2
    exit 1;;
esac

printf '%s\n' "$text"
exit 0
