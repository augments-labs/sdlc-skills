#!/usr/bin/env bash
# Claude Code adapter. Sourced by the runners under tests/ — behavioural,
# plugin-smoke, and trigger-eval — never executed directly.
#
# This file holds only what is true of the `claude` CLI: how skills are loaded,
# how it is invoked, how an activation is detected, and what a run costs.
# Anything harness-agnostic belongs in the dispatcher, not here.

adapter_name='claude-code'

source_claude_home="${CLAUDE_CONFIG_DIR:-${HOME:-}/.claude}"

adapter_check() {
  command -v claude >/dev/null 2>&1 || { echo "no \`claude\` CLI on PATH" >&2; return 3; }
}

# Claude Code loads a plugin tree directly, so `--plugin-dir` is the whole
# install — an empty source is the NONE arm and passes no flag.
#
# The isolated home is a separate job, and this adapter used to skip it. It did
# not, and a NONE arm on an operator with sdlc-skills installed loaded the
# skills anyway: `~/.claude/plugins/` is read regardless of `--plugin-dir`. The
# runner's contamination guard caught it, so the result was refused rather than
# scored — but the arm that is supposed to answer "is this skill worth its
# context" was simply unavailable on the primary harness.
#
# So: an isolated CLAUDE_CONFIG_DIR per run, exactly as CODEX_HOME and
# KIMI_CODE_HOME already do. Credentials are copied in because a run has to
# authenticate; `settings.json` deliberately is NOT, because it carries the
# SessionStart hook that injects the router — copying it would re-contaminate
# the arm through the other door. An operator authenticating by environment
# variable needs no file, and the copy is skipped without complaint.
#
# Every invocation below reads `harness_home`, so adapter_install must run
# first. All three runners already call it before anything else.
adapter_install() { # $1 plugin source ("" = NONE arm, load nothing)
  harness_home="$(mktemp -d)"
  [ -f "$source_claude_home/.credentials.json" ] &&
    cp "$source_claude_home/.credentials.json" "$harness_home/.credentials.json"
  plugin_dir="$1"
  return 0
}

# DISCOVERY: ask Claude Code to resolve the plugin exactly as a session would
# and return the skill names from its component inventory. A filesystem count
# cannot prove that the manifest entries were accepted by the harness.
adapter_component_inventory() { # $1 plugin source
  env CLAUDE_CONFIG_DIR="$harness_home" claude --plugin-dir "$1" plugin details sdlc-skills 2>>"$errlog" |
    awk '/^  Skills \([0-9]+\)/ {
      sub(/^  Skills \([0-9]+\)[[:space:]]+/, "")
      gsub(/,[[:space:]]*/, "\n")
      print
    }'
}

# DETECTION: only a structured `Skill` tool_use in an ASSISTANT event counts.
# The SessionStart nudge text and the init manifest both contain `sdlc-skills:`
# tokens; a raw grep matches those and reports a phantom activation. The first
# cut of this harness did exactly that.
adapter_chain() {
  jq -r 'select(.type=="assistant") | .message.content[]?
         | select(.type=="tool_use" and .name=="Skill") | .input.skill' "$1" 2>/dev/null
}

# Normalize structured actions for cross-harness behavioural assertions.
adapter_behavioral_events() {
  jq -r 'select(.type=="assistant") | .message.content[]?
         | select(.type=="tool_use")
         | if .name=="Skill" then "SKILL " + (.input.skill // "")
           elif (.name=="Write" or .name=="Edit" or .name=="MultiEdit")
           then "EDIT " + (.input.file_path // .input.path // "")
           else empty end' "$1" 2>/dev/null
}

# DID IT RUN? The question is whether the run reached the model at all — not
# whether it finished. Those are different, and conflating them is a bug this
# check already made once: it keyed on the terminal `result` record, which a
# completed `claude -p` always emits, and a run we killed ourselves never does.
# A routing case that fired correctly came back inconclusive because our own
# --timeout cut the session off mid-turn: 24 lines, 9 assistant records, the
# expected skill in the chain, and no `result` record. Truncation is normal here.
#
# So the signal is an `assistant` record — the model spoke. A dead provider emits
# none. A run that exhausts --max-turns emits several and is scored as an
# ordinary miss, which is what it is.
#
# Exit status cannot serve: `claude` exits 1 on max-turns exhaustion, the same
# code as an auth failure, and every negative query runs to max-turns by design.
adapter_ran() {
  jq -e -s 'any(.[]; .type == "assistant")' >/dev/null 2>&1 <"$1"
}

# Read-only: the tool under test (Skill) plus read-only tools.
#
# The restriction that does the work is `--tools`, which sets which built-in
# tools EXIST. This was `--allowedTools` alone, which only pre-approves a
# permission prompt — so against an operator whose settings already
# auto-approve, there is no prompt to pre-approve and every tool stayed
# available. Runs executed Bash freely while this comment claimed they could
# not. The isolated home added in adapter_install now keeps the operator's
# `settings.json` out of the run, so an allow-list would in fact bind again —
# but `--tools` stays, because a guarantee that does not depend on which files
# were copied is the stronger one. `--allowedTools` stays for the opposite
# operator, whose default mode would otherwise prompt and hang.
adapter_run_activation() { # $1 workdir  $2 prompt  $3 stream  $4 extra flags...
  local wd="$1" prompt="$2" stream="$3"; shift 3
  # --max-turns bounds a run that never reaches the expected skill; without it a
  # miss burns a full session instead of stopping.
  ( cd "$wd" && exec timeout "$timeout_s" env CLAUDE_CONFIG_DIR="$harness_home" claude -p "$prompt" \
      --output-format stream-json --verbose "$@" \
      --max-turns "${maxturns:-6}" \
      --tools "Skill,Read,Glob,Grep" \
      --allowedTools Skill Read Glob Grep ) < /dev/null > "$stream" 2>>"$errlog"
}

adapter_activation_flags() {   # --working-tree loads live edits, not the install cache
  printf '%s\n' --plugin-dir "$repo"
}

# COST: the terminal `result` event carries the run's own totals. Sum all four
# token classes, not `input_tokens` alone — a skill's context cost lands almost
# entirely in cache creation and cache reads, so the one field that looks like
# "the input" is the one that hides what a skill charges. Field shape observed
# from a real stream, not assumed. Silent when no result event arrives, so a
# timed-out or refused run reports no number rather than a misleading zero.
adapter_usage() {
  jq -s 'map(select(.type == "result") | .usage) | last | select(. != null)
         | (.input_tokens // 0) + (.output_tokens // 0)
           + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0)' \
    "$1" 2>/dev/null
}

# TIER → MODEL. Scenarios name a capability tier, never a model; this is the
# one place the binding lives for this CLI. The aliases are the CLI's own, so a
# release that moves an alias moves the run with it.
adapter_model() { # $1 small|medium|large
  case "$1" in
    small)  echo haiku;;
    medium) echo sonnet;;
    large)  echo opus;;
    *) echo "unknown model tier: $1" >&2; return 2;;
  esac
}

# --model only when the scenario asked for a tier; otherwise the CLI's default.
adapter_model_flags() {
  [ -n "${scenario_model_tier:-}" ] || return 0
  printf '%s\n' --model "$(adapter_model "$scenario_model_tier")"
}

# WRITE access — a behavioural arm must be able to produce artifacts. Safe: the
# run happens in a disposable fixture copy under /tmp, never in this repo.
adapter_run_behavioral() { # $1 workdir  $2 opening file  $3 stream
  local plugin=() model=()
  [ -n "${plugin_dir:-}" ] && plugin=(--plugin-dir "$plugin_dir")
  mapfile -t model < <(adapter_model_flags)
  ( cd "$1" && exec timeout "$timeout_s" env CLAUDE_CONFIG_DIR="$harness_home" claude -p "$(cat "$2")" \
      --output-format stream-json --verbose \
      ${plugin[@]+"${plugin[@]}"} ${model[@]+"${model[@]}"} \
      --allowedTools Skill Read Glob Grep Write Edit Bash TodoWrite \
      --permission-mode acceptEdits ) < /dev/null > "$3" 2>>"$errlog"
}

# Continue the same behavioural session for scenarios whose failure only exists
# after an approval handoff. The session id comes from Claude's own structured
# stream; an absent id is an adapter error, not a fresh-session substitute.
adapter_continue_behavioral() { # $1 workdir  $2 prompt  $3 new stream  $4 prior stream
  local wd="$1" prompt="$2" out="$3" prior="$4" session_id plugin=() model=()
  session_id="$(jq -r 'select(.session_id? != null) | .session_id' "$prior" 2>/dev/null | head -1)"
  [ -n "$session_id" ] || { echo "Claude stream contains no resumable session id" >&2; return 2; }
  [ -n "${plugin_dir:-}" ] && plugin=(--plugin-dir "$plugin_dir")
  mapfile -t model < <(adapter_model_flags)
  ( cd "$wd" && exec timeout "$timeout_s" env CLAUDE_CONFIG_DIR="$harness_home" claude -p "$prompt" \
      --resume "$session_id" \
      --output-format stream-json --verbose \
      ${plugin[@]+"${plugin[@]}"} ${model[@]+"${model[@]}"} \
      --allowedTools Skill Read Glob Grep Write Edit Bash TodoWrite \
      --permission-mode acceptEdits ) < /dev/null > "$out" 2>>"$errlog"
}
