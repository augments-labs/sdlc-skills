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
{{tier}}, {{report}}, {{inputs}}, {{report-template}}.

A brief that still holds a placeholder is never printed as if it were ready: a
worker reads the literal braces as its instruction and implements nothing. That
is exit 1, and it is the check this script exists for.

{{report-template}} is filled last, after every other placeholder is checked
for leftovers, from ROLE-report.md beside ROLE.md in --roles (implementer.md's
slot reads implementer-report.md). A role template without the slot renders
exactly as before. When the slot is present, its report file missing or
unreadable is exit 2, not exit 1: a role template without a report template to
insert is a setup defect, not a half-filled brief.

Exit codes:
  0  the brief is complete and on stdout
  1  a placeholder was left unfilled
  2  bad arguments, unknown role, or a file that cannot be read
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

# An empty value leaves its placeholder standing, so the check below stops a
# half-filled brief rather than dispatching one with a hole where the tier goes.
fill() {
  [ -n "$2" ] || return 0
  text="${text//\{\{$1\}\}/$2}"
}
fill task-file "$task"
fill task-body "$body"
fill workspace "$workspace"
fill base "$base"
fill tier "$tier"
fill report "$report"
fill inputs "$inputs"

# {{report-template}} is checked for leftovers as if already filled: it is
# filled last, below, from a file this brief's own worker never supplies, so
# it never belongs on the same "half-filled brief" failure as the seven
# placeholders above. Checking a copy — never mutating $text here — keeps the
# literal slot in place for the substitution that follows.
checked="${text//\{\{report-template\}\}/}"
case "$checked" in
  *'{{'*)
    printf '%s\n' "$checked" | grep -o '{{[^}]*}}' | sort -u | while IFS= read -r p; do
      echo "unfilled placeholder: $p" >&2
    done
    exit 1;;
esac

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
