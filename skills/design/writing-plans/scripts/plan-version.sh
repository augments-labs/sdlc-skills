#!/usr/bin/env bash
# Print a plan's version: git hash-object over its index, with every task
# checkbox and state label normalized, followed by every task file the index
# lists, in order. With --check-contract or --verify, also validate task
# contracts and the external decision ledger. Read-only.
#
# The version binds approval to the plan's content, not to a line the index
# declares about itself: mirroring task progress leaves it unchanged, and any
# edit to the index or to a task contract changes it.

set -uo pipefail

usage() {
  cat <<'USAGE'
Usage: bash scripts/plan-version.sh [--check-contract | --verify] PLAN_DIR

Print the plan's version, 7 hex characters: git hash-object --stdin over
PLAN_DIR/00-index.md with every task checkbox normalized to "[ ]" and every
state label to "todo", followed by each task file the task list names, in
order. Read-only; writes nothing.

Options:
  --check-contract   Validate task-contract invariants (Consumes matches an
                     earlier task's Produces, Depends on names existing
                     non-cancelled tasks, Implementation disciplines is filled)
                     and print version, phases_or_shards, and file overlap lines.
  --verify           Run --check-contract and verify that the plan's external
                     decision ledger has an unclosed approved decision row for
                     the printed version; also print state, mode, and waves.
  --help             Show this message.

Exit codes:
  0  version printed (and contract/ledger checks passed when requested)
  1  --verify found no decision row for this version, or the latest decision
     row for this version is not approved (pending, rejected, cancelled,
     superseded, or changes requested)
  2  usage error, the index or a listed task file is missing, a checkbox row
     under ## Tasks does not parse (indented, missing its backticked file,
     text after its state label, an unlisted state), a task row sits
     outside ## Tasks, or a code fence never closes
  3  git is not on PATH
  4  --check-contract or --verify found a task-contract violation (missing
     Implementation disciplines, unknown or cancelled Depends on, or Consumes
     naming a token no earlier task Produces)
USAGE
}

mode_flag="version"
dir=""
while [ "$#" -gt 0 ]; do
  case "${1-}" in
    -h|--help) usage; exit 0;;
    --check-contract) mode_flag="contract"; shift;;
    --verify) mode_flag="verify"; shift;;
    -*) echo "Error: unknown option \"$1\". Run with --help for usage." >&2; exit 2;;
    *)
      [ -z "$dir" ] || { echo "Error: expected one PLAN_DIR. Run with --help for usage." >&2; exit 2; }
      dir="${1%/}"; shift;;
  esac
done
[ -n "$dir" ] || { echo "Error: PLAN_DIR is required. Run with --help for usage." >&2; exit 2; }
command -v git >/dev/null 2>&1 || { echo "Error: git is not on PATH." >&2; exit 3; }
index="$dir/00-index.md"
[ -f "$index" ] || { echo "Error: $index not found." >&2; exit 2; }

# A task row reads: - [ ] `ID` — title · `file.md` · `state`
# The task file is the backticked .md token just before the state label.
states='todo|in progress|done|done with concerns|blocked|needs context|cancelled|superseded'
# A task row is any list-item checkbox under ## Tasks, at any indentation. A row
# there that does not parse, or a parsed row outside that section, would change
# what the version covers without a word, so either one fails. Lines inside a
# fenced code block are examples: they neither open a section nor count as rows,
# and the task files come only from the rows this pass accepts. A fence that
# never closes fails too, so nothing after it hides. A backtick run followed by
# another backtick on its line is inline code, never a fence.
scan='
  {n++; R[n] = $0; l = $0; sub(/[ \t\r]+$/, "", l); L[n] = l; u = l; sub(/^ */, "", u); U[n] = u}
  END {
    for (i = n; i >= 1; i--) {
      B[i] = cb; T[i] = ct
      if (U[i] ~ /^[`]+$/ && length(U[i]) > cb) cb = length(U[i])
      if (U[i] ~ /^~+$/ && length(U[i]) > ct) ct = length(U[i])
    }
    for (i = 1; i <= n; i++) {
      l = L[i]; u = U[i]
      if (z) { if (index(u, o) == 1 && u ~ /^([`]+|~+)$/) z = 0; continue }
      if (u ~ /^([`][`][`]+[^`]*$|~~~)/) {
        match(u, /^([`]+|~+)/); r = substr(u, 1, RLENGTH)
        if ((substr(r, 1, 1) == "~" ? T[i] : B[i]) >= RLENGTH) { z = 1; o = r; continue }
        if (want == "errors") print "  line " i ": a code fence opens here and never closes"
        continue
      }
      if (l ~ /^## /) { t = (l == "## Tasks"); continue }
      ok = (l ~ ("^- \\[[ xX]\\] .*`[^`]+\\.md`[^`]*`(" st ")`$"))
      if (want == "files") {
        if (t && ok) { f = l; sub(/`[^`]+`$/, "", f); match(f, /`[^`]+\.md`[^`]*$/); f = substr(f, RSTART + 1); sub(/`.*/, "", f); print f }
        continue
      }
      if (want == "rows") {
        if (t && ok) {
          id = l; sub(/^- \[[ xX]\] [ \t]*`/, "", id); sub(/`.*/, "", id)
          st_val = l; sub(/.*`/, "", st_val); st_val = l; match(st_val, /`[^`]+`$/); st_val = substr(st_val, RSTART + 1, RLENGTH - 2)
          f = l; sub(/`[^`]+`$/, "", f); match(f, /`[^`]+\.md`[^`]*$/); f = substr(f, RSTART + 1); sub(/`.*/, "", f)
          print id "\t" f "\t" st_val
        }
        continue
      }
      if (t && !ok && l ~ /^[ \t]*([-*+]|[0-9]+[.)])[ \t]+\[[ xX]\]/) print "  " R[i]
      else if (!t && ok) print "  " R[i] "  (outside ## Tasks)"
    }
  }'
task_files=$(awk -v st="$states" -v want=files "$scan" "$index")
bad=$(awk -v st="$states" -v want=errors "$scan" "$index")
if [ -z "$task_files" ] || [ -n "$bad" ]; then
  echo "Error: $index needs every checkbox row under ## Tasks to read - [ ] \`ID\` — title · \`file.md\` · \`state\`, with nothing after the state, and no task row outside it:" >&2
  [ -z "$bad" ] || printf '%s\n' "$bad" >&2
  exit 2
fi
while IFS= read -r f; do
  [ -f "$dir/$f" ] || { echo "Error: task file $dir/$f not found." >&2; exit 2; }
done <<FILES
$task_files
FILES

version="$(
  {
    sed -E 's/^- \[[ xX]\] (.*)`('"$states"')`[[:space:]]*$/- [ ] \1`todo`/' "$index"
    while IFS= read -r f; do
      printf '\n=== %s\n' "$f"
      cat "$dir/$f"
    done <<FILES
$task_files
FILES
  } | tr -d '\r' | git hash-object --stdin | cut -c1-7
)"

if [ "$mode_flag" = "version" ]; then
  echo "$version"
  exit 0
fi

# Contract check across index and listed task files.
rows="$(awk -v st="$states" -v want=rows "$scan" "$index")"
contract_out="$(awk -v dir="$dir" '
  function trim(s) { sub(/^[ \t\r]+/, "", s); sub(/[ \t\r]+$/, "", s); return s }
  BEGIN {
    err = 0
  }
  FILENAME == ARGV[1] {
    split($0, parts, "\t")
    id = parts[1]; tf = parts[2]; st = parts[3]
    idx_order[++ntasks] = id
    task_file[id] = dir "/" tf
    task_state[id] = st
    known_task[id] = ntasks
    next
  }
  FILENAME == ARGV[2] {
    l = $0; sub(/\r$/, "", l)
    if (l ~ /^##+ *(Phases|Shards|Phase queues)/) phases = 1
    next
  }
  END {
    for (k = 1; k <= ntasks; k++) {
      id = idx_order[k]
      f = task_file[id]
      has_disc = 0; in_cons = 0; in_prod = 0
      delete req_tokens
      nreq = 0
      while ((getline line < f) > 0) {
        sub(/\r$/, "", line)
        if (line ~ /^\*\*Implementation disciplines:\*\*/) {
          v = line; sub(/^\*\*Implementation disciplines:\*\*/, "", v); v = trim(v)
          if (v != "" && v !~ /^`?\{\{/) has_disc = 1
        }
        if (line ~ /^\*\*Depends on:\*\*/) {
          v = line; sub(/^\*\*Depends on:\*\*/, "", v); v = trim(v)
          if (tolower(v) !~ /^none([^a-z0-9_]|$)/) {
            rest = v
            while (match(rest, /`[^`]+`/)) {
              dep = substr(rest, RSTART + 1, RLENGTH - 2)
              rest = substr(rest, RSTART + RLENGTH)
              if (!(dep in known_task)) {
                printf "Error: task %s Depends on unknown task %s.\n", id, dep > "/dev/stderr"
                err = 1
              } else if (task_state[dep] == "cancelled") {
                printf "Error: task %s Depends on cancelled task %s.\n", id, dep > "/dev/stderr"
                err = 1
              }
            }
          }
        }
        if (line ~ /^\*\*Files:\*\*/) {
          rest = line; sub(/^\*\*Files:\*\*/, "", rest)
          while (match(rest, /`[^`]+`/)) {
            fp = substr(rest, RSTART + 1, RLENGTH - 2)
            rest = substr(rest, RSTART + RLENGTH)
            if (fp != "" && fp !~ /^\{\{/) {
              if (!seen_file_task[fp SUBSEP id]++) {
                if (file_owners[fp] == "") {
                  file_list[++nfiles] = fp
                  file_owners[fp] = id
                  file_count[fp] = 1
                } else {
                  file_owners[fp] = file_owners[fp] "," id
                  file_count[fp]++
                }
              }
            }
          }
        }
        if (line ~ /^[ \t]*-[ \t]*\*\*Consumes:\*\*/) {
          in_cons = 1; in_prod = 0
          v = line; sub(/^[ \t]*-[ \t]*\*\*Consumes:\*\*/, "", v); v = trim(v)
          if (tolower(v) ~ /^(nothing|none)([^a-z0-9_]|$)/) { in_cons = 0 }
          else {
            rest = v
            while (match(rest, /`[^`]+`/)) {
              tok = substr(rest, RSTART + 1, RLENGTH - 2)
              rest = substr(rest, RSTART + RLENGTH)
              if (!(tok in known_task)) req_tokens[++nreq] = tok
            }
          }
          continue
        }
        if (line ~ /^[ \t]*-[ \t]*\*\*Produces:\*\*/) {
          in_cons = 0; in_prod = 1
          v = line; sub(/^[ \t]*-[ \t]*\*\*Produces:\*\*/, "", v); v = trim(v)
          if (tolower(v) ~ /^(nothing|none)([^a-z0-9_]|$)/) { in_prod = 0 }
          else {
            rest = v
            while (match(rest, /`[^`]+`/)) {
              tok = substr(rest, RSTART + 1, RLENGTH - 2)
              rest = substr(rest, RSTART + RLENGTH)
              produced[tok] = 1
              sp = index(tok, " ")
              if (sp > 1) produced[substr(tok, 1, sp - 1)] = 1
            }
          }
          continue
        }
        if (line ~ /^## / || line ~ /^\*\*[A-Za-z]/) { in_cons = 0; in_prod = 0 }
        if (in_cons) {
          rest = line
          while (match(rest, /`[^`]+`/)) {
            tok = substr(rest, RSTART + 1, RLENGTH - 2)
            rest = substr(rest, RSTART + RLENGTH)
            if (!(tok in known_task)) req_tokens[++nreq] = tok
          }
        }
        if (in_prod) {
          rest = line
          while (match(rest, /`[^`]+`/)) {
            tok = substr(rest, RSTART + 1, RLENGTH - 2)
            rest = substr(rest, RSTART + RLENGTH)
            produced[tok] = 1
            sp = index(tok, " ")
            if (sp > 1) produced[substr(tok, 1, sp - 1)] = 1
          }
        }
      }
      close(f)
      if (!has_disc) {
        printf "Error: task %s has empty Implementation disciplines.\n", id > "/dev/stderr"
        err = 1
      }
      for (r = 1; r <= nreq; r++) {
        tok = req_tokens[r]
        ok_prod = (tok in produced)
        if (!ok_prod) {
          sp = index(tok, " ")
          if (sp > 1 && (substr(tok, 1, sp - 1) in produced)) ok_prod = 1
        }
        if (!ok_prod) {
          printf "Error: task %s Consumes `%s`, which no earlier task Produces.\n", id, tok > "/dev/stderr"
          err = 1
        }
      }
    }
    if (err) exit 4
    printf "phases_or_shards=%s\n", (phases ? "yes" : "no")
    for (i = 1; i <= nfiles; i++) {
      fp = file_list[i]
      if (file_count[fp] > 1) printf "overlap=%s:%s\n", fp, file_owners[fp]
    }
  }
' <(printf '%s\n' "$rows") "$index")"
rc=$?
[ "$rc" -eq 0 ] || exit "$rc"

if [ "$mode_flag" = "contract" ]; then
  echo "version=$version"
  printf '%s\n' "$contract_out"
  exit 0
fi

# --verify: check the External decision ledger for an unclosed approved decision row.
ledger="$dir/00-index.ledger.md"
if [ ! -f "$ledger" ]; then
  ext_led="$(awk '/^- \*\*External decision ledger:\*\*/ { if (match($0, /`[^`]+`/)) print substr($0, RSTART + 1, RLENGTH - 2); exit }' "$index")"
  [ -n "$ext_led" ] && [ -f "$ext_led" ] && ledger="$ext_led"
fi
if [ ! -f "$ledger" ]; then
  echo "Error: decision ledger $ledger not found for version $version." >&2
  exit 1
fi

ledger_out="$(awk -F'|' -v want="$version" '
  function trim(s) { sub(/^[ \t\r]+/, "", s); sub(/[ \t\r]+$/, "", s); return s }
  /^\|/ {
    id = trim($2); sec = trim($3); st = trim($5); ev = trim($6)
    if (id == want && sec == "") {
      found = 1
      last_st = st
      last_ev = ev
    }
  }
  END {
    if (!found) {
      printf "Error: no decision row for version %s in ledger.\n", want > "/dev/stderr"
      exit 1
    }
    if (last_st != "approved" || last_ev == "") {
      printf "Error: version %s is not approved (latest decision row state: %s).\n", want, last_st > "/dev/stderr"
      exit 1
    }
    mode = "unset"
    if (last_ev ~ /mode:[ \t]*delegated/) mode = "delegated"
    else if (last_ev ~ /mode:[ \t]*inline/) mode = "inline"
    waves = (last_ev ~ /waves:[ \t]*yes/) ? "yes" : "no"
    printf "state=approved\nmode=%s\nwaves=%s\n", mode, waves
  }
' "$ledger")" || exit 1

echo "version=$version"
printf '%s\n' "$ledger_out"
printf '%s\n' "$contract_out"
exit 0
