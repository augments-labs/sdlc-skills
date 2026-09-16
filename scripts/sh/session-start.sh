#!/usr/bin/env bash
# Inject the SDLC skills entry skill as session context.
#
# Usage: session-start.sh [HookEventName]   (default: SessionStart)
#
# Why the whole entry skill and not a pointer: a pointer costs ~90 tokens and
# buys a REQUEST that the agent invoke `using-sdlc-skills` before working. That
# request is one discretionary tool call away from being skipped, and it does
# get skipped — measured, in a real session, on exactly the task it governs.
# Injecting the body removes the skippable step: the entry mandate is simply
# resident, so there is nothing left to forget. It costs ~1.5k tokens once per
# context epoch instead of ~90, and it is re-applied wherever the harness
# reports the context was replaced — start, resume, clear, and compaction —
# never on a per-turn cadence.
#
# The text is READ from the canonical skill, never copied here: one source of
# truth, so editing the skill cannot silently stop shipping.
#
# Two install shapes exist and both must work. The canonical tree keeps skills
# under their SDLC phase (skills/common/...); the Codex plugin mirror flattens
# them (skills/<name>/...) because that manifest points at one directory. A
# single hard-coded path resolves in the repository and nowhere a user installs.
set -uo pipefail

event="${1:-SessionStart}"

# Compaction IS context loss. It replaces the transcript with a summary, and
# text injected at session start does not survive into what replaces it: this
# body is gone from the compacted context, which is the state the agent then
# works in. So compaction is re-injected like any other epoch boundary.
#
# It is re-injected through SessionStart, not a dedicated compaction event: the
# harnesses that report compaction report it as a SessionStart whose source is
# "compact", and that is the invocation whose output is added to the compacted
# context. A PostCompact-style hook fires for monitoring; its output is not
# added to any context, so answering it injects nothing and costs a run.
case "$event" in PostCompact) exit 0 ;; esac

script_dir="$(dirname "$0")"
plugin_root="$(cd "$script_dir/../.." 2>/dev/null && pwd)"

# Fail loudly. A silent empty injection is the worst outcome: routing quietly
# stops and nothing observes it.
if [ -z "$plugin_root" ]; then
    echo "session-start: cannot resolve plugin root from $script_dir" >&2
    exit 1
fi

canonical_path="skills/common/using-sdlc-skills/SKILL.md"
mirror_path="skills/using-sdlc-skills/SKILL.md"
router=""
for candidate_path in "$canonical_path" "$mirror_path"; do
    if [ -r "$plugin_root/$candidate_path" ]; then
        router="$plugin_root/$candidate_path"
        break
    fi
done

if [ -z "$router" ]; then
    echo "session-start: no router under $plugin_root ($canonical_path or $mirror_path)" >&2
    exit 1
fi

# Strip only the leading YAML frontmatter: `description` is a trigger for the
# skill catalogue, not context, and any `---` later in the body must survive.
body="$(awk 'NR==1 && $0=="---" {fm=1; next} fm && $0=="---" {fm=0; next} !fm' "$router")"
[ -n "$body" ] || { echo "session-start: router body is empty ($router)" >&2; exit 1; }

context="$(cat <<EOF
<EXTREMELY_IMPORTANT>
# SDLC skills

The full \`using-sdlc-skills\` entry skill follows. It is ALREADY LOADED — apply
it directly and do not spend a tool call re-invoking it. Every skill in the
catalogue is listed with its trigger in your Skill tool; invoke skills through
the real skill-loading action, since reading a skill file is not invoking it.
Each loaded skill's own preconditions, skips, and handoffs are the routing
authority — follow them.

Apply this before any answer or action, including questions and exploration,
and before any tool that begins the work.

$body
</EXTREMELY_IMPORTANT>
EOF
)"

# JSON-escape, in order: backslash, double-quote, then the control characters.
esc="$context"
esc="${esc//\\/\\\\}"
esc="${esc//\"/\\\"}"
esc="${esc//$'\n'/\\n}"
esc="${esc//$'\r'/\\r}"
esc="${esc//$'\t'/\\t}"

if [ -n "${CURSOR_PLUGIN_ROOT:-}" ]; then
    # Cursor-style hooks consume snake_case additional context.
    printf '{\n  "additional_context": "%s"\n}\n' "$esc"
elif [ -n "${COPILOT_CLI:-}" ]; then
    # SDK-style hooks consume top-level camelCase additional context.
    printf '{\n  "additionalContext": "%s"\n}\n' "$esc"
else
    # Claude Code and Codex consume the nested SessionStart envelope, including
    # the post-compaction invocation (source=compact), which reaches here like
    # any other source and is answered the same way.
    printf '{\n  "hookSpecificOutput": {\n    "hookEventName": "%s",\n    "additionalContext": "%s"\n  }\n}\n' "$event" "$esc"
fi
