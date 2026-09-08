#!/usr/bin/env bash
# Offline test for the session-start context injection.
#
# What this guards: the router must arrive as CONTENT, not as an errand. A
# pointer ("invoke using-sdlc-skills first") is one discretionary tool call away
# from being skipped, and skipping it is the failure this library exists to
# prevent — measured, in a real session, by the agent maintaining this repo.
# Injecting the router body removes the step that can be skipped.
#
# Deterministic on purpose: this is script logic (read a file, strip
# frontmatter, escape JSON, pick an envelope), so it gets a unit check. Whether
# a resident router actually changes behaviour is a live question and is not
# claimed here.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 2

case "${1-}" in
  -h|--help)
    cat <<'EOF'
tests/run-session-start.sh — offline unit check for the session-start injection.

Takes no arguments; runs scripts/sh/session-start.sh under each harness
envelope and checks the router body arrives as content.

  --help    this text

Exit codes: 0 every check passed · 1 at least one failed · 2 not run from the repo
EOF
    exit 0;;
esac

S=scripts/sh/session-start.sh
ROUTER=skills/common/using-sdlc-skills/SKILL.md
fails=0
ok()   { echo "  ok    $1"; }
bad()  { echo "  FAIL  $1"; fails=1; }
check(){ if [ "$2" = "$3" ]; then ok "$1"; else bad "$1 (expected '$3', got '$2')"; fi; }

# Every harness reads the injected text out of its own envelope; extract with
# the same query the harness would use, so a broken envelope fails here.
ctx() { # $1 jq path, rest: env assignments + args
  local path="$1"; shift
  env "$@" bash "$S" 2>/dev/null | jq -r "$path // empty" 2>/dev/null
}

echo "--- adapters activate only at session start"
for config in hooks/hooks.json plugins/sdlc-skills/hooks/hooks.json; do
  if jq -e '.hooks | keys == ["SessionStart"]' "$config" >/dev/null 2>&1; then
    ok "$config: only SessionStart is registered"
  else
    bad "$config: expected SessionStart as the sole hook event"
  fi
done
if jq -e '.sessionStart.skill == "using-sdlc-skills" and ((.hooks // []) | length == 0)' \
    .kimi-plugin/plugin.json >/dev/null 2>&1; then
  ok "Kimi: sessionStart.skill is the sole activation mechanism"
else
  bad "Kimi: expected the session-start router without lifecycle hooks"
fi

echo "--- emits valid JSON in every envelope"
for spec in \
  'CLAUDE_PLUGIN_ROOT=/p|.hookSpecificOutput.additionalContext|claude' \
  'CURSOR_PLUGIN_ROOT=/p|.additional_context|cursor' \
  'CODEX_HOME=/p|.hookSpecificOutput.additionalContext|codex'
do
  IFS='|' read -r envvar path label <<<"$spec"
  out="$(env "$envvar" bash "$S" 2>/dev/null)"
  if printf '%s' "$out" | jq -e . >/dev/null 2>&1; then
    ok "$label: valid JSON"
  else
    bad "$label: not valid JSON"
  fi
  body="$(printf '%s' "$out" | jq -r "$path // empty" 2>/dev/null)"
  [ -n "$body" ] && ok "$label: envelope carries context at $path" \
                 || bad "$label: no context at $path"
done

echo "--- injects the ROUTER BODY, not a pointer to it"
body="$(ctx '.hookSpecificOutput.additionalContext' CLAUDE_PLUGIN_ROOT=/p)"

# Distinguishing content: prose that exists ONLY in the router body. A pointer
# can name the skill; it cannot carry the authority rule or the red-flag table.
for probe in \
  'Routing lives in the skills:the distributed-routing authority statement' \
  'Entering the chain:the entry procedure' \
  'means the gate accepted, not confidence:the mental model' \
  'Catch one and stop:the red-flag table' \
  'Instructions priority:the precedence section'
do
  needle="${probe%%:*}"; desc="${probe#*:}"
  case "$body" in
    *"$needle"*) ok "carries $desc" ;;
    *)           bad "missing $desc ('$needle')" ;;
  esac
done

echo "--- stays in sync with the canonical skill (no drift-prone copy)"
# The body after frontmatter must appear verbatim. If session-start.sh ever
# holds its own copy, an edit to the skill silently stops shipping.
canonical="$(awk 'NR==1 && $0=="---" {fm=1; next} fm && $0=="---" {fm=0; next} !fm' "$ROUTER")"
if [ -n "$canonical" ] && [ "${body#*"$canonical"}" != "$body" ]; then
  ok "injected text contains the canonical router body verbatim"
else
  bad "injected text is not the canonical router body (drifted or truncated)"
fi

echo "--- frontmatter is stripped"
case "$body" in
  *'name: using-sdlc-skills'*) bad "leaks YAML frontmatter (name:)" ;;
  *)                           ok "no YAML frontmatter" ;;
esac
case "$body" in
  *'description: Use at every task opening'*) bad "leaks YAML frontmatter (description:)" ;;
  *)                                          ok "no trigger description" ;;
esac

echo "--- wrapped so the harness cannot read it as optional"
case "$body" in
  *'<EXTREMELY_IMPORTANT>'*'</EXTREMELY_IMPORTANT>'*) ok "wrapped in EXTREMELY_IMPORTANT" ;;
  *) bad "not wrapped in <EXTREMELY_IMPORTANT>...</EXTREMELY_IMPORTANT>" ;;
esac

echo "--- JSON escaping survives the body's own punctuation"
# The router contains double quotes, backticks and a markdown table. A naive
# escape corrupts the envelope; jq round-tripping the exact bytes proves it did
# not. (Encoding, not wording — this cannot be satisfied by rewording the skill.)
case "$body" in
  *'"Too simple"'*) ok 'round-trips embedded double quotes' ;;
  *)                bad 'embedded double quotes did not survive escaping' ;;
esac
case "$body" in
  *'| The thought | The reality |'*) ok 'round-trips the markdown table' ;;
  *)                                 bad 'markdown table did not survive escaping' ;;
esac

echo "--- event name is reported back to the harness"
check "default event is SessionStart" \
  "$(env CLAUDE_PLUGIN_ROOT=/p bash "$S" 2>/dev/null | jq -r '.hookSpecificOutput.hookEventName // empty')" \
  "SessionStart"
check "PostCompact invocation is skipped entirely (compact re-injection is retired)" \
  "$(env KIMI_CODE_HOME=/p bash "$S" PostCompact 2>/dev/null)" \
  ""

echo "--- resolves the router in the FLAT Codex plugin mirror too"
# The canonical tree is skills/<phase>/<name>/SKILL.md; the Codex plugin mirror
# is deliberately flat, skills/<name>/SKILL.md. An installed Codex plugin runs
# the injector from inside that mirror, so a single hard-coded canonical path
# ships a router that resolves in the repo and nowhere a user actually installs.
flat="$(mktemp -d)"
mkdir -p "$flat/scripts/sh" "$flat/skills/using-sdlc-skills"
cp "$S" "$flat/scripts/sh/session-start.sh"
cp "$ROUTER" "$flat/skills/using-sdlc-skills/SKILL.md"
flat_out="$(env CLAUDE_PLUGIN_ROOT=/p bash "$flat/scripts/sh/session-start.sh" 2>/dev/null)"
flat_body="$(printf '%s' "$flat_out" | jq -r '.hookSpecificOutput.additionalContext // empty' 2>/dev/null)"
case "$flat_body" in
  *'Catch one and stop'*) ok "flat mirror: injects the router body" ;;
  *)                      bad "flat mirror: no router body (plugin install would inject nothing)" ;;
esac
rm -rf "$flat"

echo "--- the Codex plugin's OWN hook command produces the router"
# Not a grep for the script name: a hook entry that mentions the right file can
# still be inert — wrong variable, wrong relative path, unreadable router. So
# read the command out of the shipped hooks file and RUN it, with only what the
# harness actually provides (PLUGIN_ROOT, and a session cwd that is not the
# plugin). If this passes, an install injects the router; if it fails, the
# plugin ships a hook that does nothing.
pkg=plugins/sdlc-skills
pkg_hooks="$pkg/hooks/hooks.json"

if ! jq -e . "$pkg_hooks" >/dev/null 2>&1; then
  bad "plugin hooks file is missing or not valid JSON ($pkg_hooks)"
else
  ok "plugin hooks file is valid JSON"
  pkg_abs="$(cd "$pkg" && pwd)"
  elsewhere="$(mktemp -d)"
  if jq -e '.hooks | has("PostCompact")' "$pkg_hooks" >/dev/null; then
    bad "Codex plugin registers PostCompact (compact re-injection is retired, and that output cannot carry context)"
  else
    ok "Codex plugin registers no PostCompact hook"
  fi
  if jq -e '.hooks.SessionStart[0] | has("matcher")' "$pkg_hooks" >/dev/null; then
    bad "Codex SessionStart hook must stay unfiltered — the injector itself drops source=compact"
  else
    ok "Codex SessionStart hook is unfiltered; the injector drops source=compact"
  fi

  cmd="$(jq -r '.hooks.SessionStart[0].hooks[0].command // empty' "$pkg_hooks")"
  if [ -z "$cmd" ]; then
    bad "plugin hooks declare no SessionStart command"
  else
    # Run the shipped command from an unrelated session cwd with a startup
    # payload: a command that only works from the repository root ships a hook
    # that does nothing on an install.
    startup_input='{"cwd":"/w","hook_event_name":"SessionStart","model":"test","permission_mode":"default","session_id":"s1","source":"startup","transcript_path":null}'
    hook_out="$(cd "$elsewhere" && printf '%s' "$startup_input" | \
      env PLUGIN_ROOT="$pkg_abs" bash -c "$cmd" 2>/dev/null)"
    hook_body="$(printf '%s' "$hook_out" | jq -r '.hookSpecificOutput.additionalContext // empty' 2>/dev/null)"
    case "$hook_body" in
      *'Catch one and stop'*) ok "SessionStart source=startup injects the entry-skill body from an arbitrary cwd" ;;
      *)                      bad "SessionStart source=startup injected no entry-skill body (an install would route nothing)" ;;
    esac

    # Codex reports compaction as SessionStart source=compact. Loaded context
    # survives compaction, so the injector must skip that invocation entirely;
    # re-injecting the same body would be redundant cost.
    compact_input='{"cwd":"/w","hook_event_name":"SessionStart","model":"test","permission_mode":"default","session_id":"s1","source":"compact","transcript_path":null}'
    compact_out="$(cd "$elsewhere" && printf '%s' "$compact_input" | \
      env PLUGIN_ROOT="$pkg_abs" bash -c "$cmd" 2>/dev/null)"
    check "SessionStart source=compact is skipped entirely (compact re-injection is retired)" \
      "$compact_out" ""
  fi
  rm -rf "$elsewhere"
fi

echo "--- fails loudly rather than injecting nothing"
# A silent empty injection is the worst outcome: routing quietly stops and no
# test notices. Missing router => nonzero exit.
tmp="$(mktemp -d)"; cp "$S" "$tmp/session-start.sh"
if ( cd "$tmp" && env CLAUDE_PLUGIN_ROOT=/p bash ./session-start.sh >/dev/null 2>&1 ); then
  bad "exits 0 when the router file cannot be found"
else
  ok "exits nonzero when the router file cannot be found"
fi
rm -rf "$tmp"

echo "---"
[ "$fails" -eq 0 ] && { echo "session-start offline tests: PASS"; exit 0; }
echo "session-start offline tests: FAIL"; exit 1
