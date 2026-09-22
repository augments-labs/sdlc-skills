#!/usr/bin/env bash
# Install smoke test — ONE runner for every harness. NO model call.
#
# Answers the question that comes before every other test: if a user installs
# SDLC skills the way this harness installs plugins, do the skills actually land
# where the CLI will look for them? A harness can pass every activation scenario
# against a working tree and still be broken for a real user whose install path
# differs — files present but never discovered is not a working integration.
#
# It drives `adapter_install`, the same function the live runners use, so it
# smokes the real path rather than a description of it.
#
# Flags and exit codes: --help.

set -uo pipefail
scriptdir="$(cd "$(dirname "$0")" && pwd)"
harnessdir="$(cd "$(dirname "$0")/harnesses" && pwd)"
cd "$scriptdir/.." || exit 2
repo="$PWD"

usage() {
  cat <<'EOF'
tests/run-plugin-smoke.sh — do the skills land where this harness looks? No model call.

  --harness NAME    claude-code | codex | kimi-code | opencode   (required)
  --help            this text

Exit codes: 0 every skill on disk was discovered after install
            1 install succeeded but skills are missing or misplaced
            2 bad or missing arguments · 3 harness adapter or tooling unavailable

Example:
  tests/run-plugin-smoke.sh --harness claude-code
EOF
}

harness=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0;;
    --harness) harness="$2"; shift 2;;
    *) echo "unknown argument: $1" >&2; exit 2;;
  esac
done
[ -n "$harness" ] || { echo "needs --harness claude-code|codex|kimi-code|opencode" >&2; exit 2; }
[ -f "$harnessdir/$harness.sh" ] || { echo "no harness adapter: $harness" >&2; exit 2; }
command -v jq >/dev/null 2>&1 || { echo "needs \`jq\`" >&2; exit 3; }
. "$harnessdir/$harness.sh"
adapter_check || exit 3

errlog="$(mktemp)"; harness_home=""; plugin_dir=""
trap '[ -n "$harness_home" ] && rm -rf "$harness_home"; rm -f "$errlog"' EXIT

canonical_names="$(find "$repo/skills" -name SKILL.md -printf '%h\n' |
  sed 's|.*/||' | sort -u)"
canonical="$(printf '%s\n' "$canonical_names" | grep -c .)"
fails=0
echo "harness : $harness"
echo "skills  : $canonical on disk"

if ! adapter_install "$repo"; then
  echo "  FAIL  install failed (see below)"; cat "$errlog" >&2; exit 1
fi
echo "  ok    install completed"

# Whatever the mechanism, the skills must be discoverable afterwards. Claude Code
# loads the tree in place, so plugin_dir is the answer; the others copy or
# register into an isolated home.
#
# The explicit plugin dir wins. This read `${harness_home:-$plugin_dir}` and only
# worked because Claude Code set no isolated home; the moment it did — for the
# NONE arm's sake — the same expression pointed this check at a config directory
# with no skills in it. An adapter can need both, and only one of them is where
# the tree lives.
root="${plugin_dir:-$harness_home}"
[ -n "$root" ] || { echo "  FAIL  adapter_install set neither harness_home nor plugin_dir"; exit 1; }

# What this harness reads after an install: the SKILL.md layout it loads, and the
# manifest that points at it. Both are harness-specific, so they are decided in
# one place rather than two.
#
# `layout` matters more than it looks. A bare `-name SKILL.md` count is not an
# assertion here: the repo carries the same 34 skills TWICE — phase-nested under
# `skills/<phase>/<name>/` for Claude Code and Kimi, and flat under
# `plugins/sdlc-skills/skills/<name>/` for Codex, whose plugin format has no
# phase level. Counting both reaches 68, which clears a threshold of 34 on the
# WRONG tree alone, so the check would pass with the tree the harness actually
# loads entirely missing. That is the one failure it exists to catch. The depth
# of the glob is what separates them.
case "$harness" in
  claude-code) layout='*/skills/*/*/SKILL.md'; manifest='.claude-plugin/plugin.json';;
  kimi-code)   layout='*/skills/*/*/SKILL.md'; manifest='.kimi-plugin/plugin.json';;
  # Codex installs only the flat plugin dir, and registers via the marketplace
  # rather than copying a manifest file we could look for.
  codex)       layout='*/skills/*/SKILL.md';   manifest='';;
  # OpenCode loads the tree in place through the plugin file, like Claude Code.
  opencode)    layout='*/skills/*/*/SKILL.md'; manifest='.opencode/plugins/sdlc-skills.js';;
  # Grok copies the install to an unpredictable path, so there is no manifest file to look for.
  grok)        layout='*/skills/*/*/SKILL.md'; manifest='';;
  # Muse installs skill by skill into its config dir, one flat directory per
  # skill and no phase level; that route copies files and writes no manifest.
  muse)        layout='*/muse/skills/*/SKILL.md'; manifest='';;
  # pi installs a local-path source by reference, not a copy, so the tree
  # stays at the checkout the `pi` key in package.json names.
  pi)          layout='*/skills/*/*/SKILL.md'; manifest='.pi/extensions/sdlc-skills.js';;
esac

if declare -F adapter_component_inventory >/dev/null 2>&1; then
  inventory="$(adapter_component_inventory "$plugin_dir" | grep . | sort -u)"
  found="$(printf '%s\n' "$inventory" | grep -c .)"
  missing="$(comm -23 <(printf '%s\n' "$canonical_names") <(printf '%s\n' "$inventory"))"
  extra="$(comm -13 <(printf '%s\n' "$canonical_names") <(printf '%s\n' "$inventory"))"
  if [ -z "$missing" ] && [ -z "$extra" ] && [ "$found" -eq "$canonical" ]; then
    echo "  ok    harness component inventory exposes all $found skills"
  else
    echo "  FAIL  harness component inventory does not match the canonical set"
    [ -n "$missing" ] && printf '%s\n' "$missing" | sed 's/^/        missing: /'
    [ -n "$extra" ] && printf '%s\n' "$extra" | sed 's/^/        extra:   /'
    [ -s "$errlog" ] && sed 's/^/        /' "$errlog" >&2
    fails=1
  fi
else
  found="$(find "$root" -path "$layout" 2>/dev/null | wc -l | tr -d ' ')"
  if [ "$found" -ge "$canonical" ]; then
    echo "  ok    $found SKILL.md discoverable after install ($layout)"
  else
    echo "  FAIL  only $found of $canonical skills at $layout under $root"; fails=1
  fi
fi

if [ -n "$manifest" ]; then
  if find "$root" -path "*/$manifest" 2>/dev/null | grep -q .; then
    echo "  ok    $manifest present after install"
  else
    echo "  FAIL  $manifest missing after install"; fails=1
  fi
fi

[ "$fails" -eq 0 ] && echo "plugin smoke: PASS" || echo "plugin smoke: FAIL"
exit "$fails"
