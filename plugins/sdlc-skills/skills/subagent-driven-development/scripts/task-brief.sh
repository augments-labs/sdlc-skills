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

Placeholders filled: {{task-file}}, {{task-body}}, {{workspace}}, {{base}},
{{tier}}, {{report}}, {{inputs}}, {{report-template}}. Every value is inserted
literally: an & in a task file, a report, or any other value is never expanded
to the matched slot text.

A brief that still holds one of this script's own placeholders is never
printed as if it were ready: a worker reads the literal braces as its
instruction and implements nothing. That is exit 1, and it is the check this
script exists for. The check looks only for this script's own placeholder
names — a `{{...}}` that belongs to the task's own content (an example, a
quoted snippet) is not this script's placeholder and passes through unfilled.

{{report-template}} is filled last, after every other placeholder is checked
for leftovers, from ROLE-report.md beside ROLE.md in --roles (implementer.md's
slot reads implementer-report.md). A role template without the slot renders
exactly as before. When the slot is present, its report file missing or
unreadable is exit 2, not exit 1: a role template without a report template to
insert is a setup defect, not a half-filled brief.

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
fill task-file "$task"
fill task-body "$body"
fill workspace "$workspace"
fill base "$base"
fill tier "$tier"
fill report "$report"
fill inputs "$inputs"

# The leftover check is scoped to this script's own placeholder names, never
# to any '{{' — a task's own content may legitimately carry a literal
# {{something}} (an example, a template snippet quoted in the task body) and
# that must reach the worker unchanged, not be mistaken for a half-filled
# brief. {{report-template}} is not in this list: it is optional and, when
# present, is filled separately below, never subject to this failure.
leftover=""
for name in task-file task-body workspace base tier report inputs; do
  case "$text" in
    *"{{$name}}"*)
      echo "unfilled placeholder: {{$name}}" >&2
      leftover=1;;
  esac
done
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

printf '%s\n' "$text"
exit 0
