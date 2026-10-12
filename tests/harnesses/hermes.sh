#!/usr/bin/env bash
# Hermes Agent adapter. Sourced by tests/run-plugin-smoke.sh — never executed
# directly.

adapter_check() {
  command -v hermes >/dev/null 2>&1 || { echo "no \`hermes\` CLI on PATH" >&2; return 3; }
}

# Isolated home, installed the way `hermes plugins install <repo> --enable`
# installs it for a real user, without login.
#
# `hermes plugins install` refuses a bare path and CLONES the HEAD of a git
# source, so a file:// URL to the checkout would test the last
# commit, not the tree under test. The working tree is snapshotted into a
# throwaway repo named `sdlc-skills` first — Hermes names the install after
# the repo when the root carries no manifest — and that snapshot is what gets
# installed.
#
# No --force: the install-time security scan must pass on its own, as it does
# for a real user. --yes-deps answers the Python dependency question for a
# headless run (there are none); the Node question for package.json is skipped
# without a TTY, which is the right answer — it declares no dependencies.
#
# Network, once: a HERMES_HOME outside ~/.hermes is its own data root, and
# Hermes syncs a Python environment into it on first launch (~30 s, ~400 MB,
# all inside the throwaway home). Every probe after that is offline.
# HOME is overridden alongside HERMES_HOME so nothing reads the operator's home.
adapter_install() { # $1 plugin source
  harness_home="$(mktemp -d)"
  local snap="$harness_home/src/sdlc-skills"
  mkdir -p "$snap"
  (cd "$1" && git ls-files -z --cached --others --exclude-standard |
    while IFS= read -r -d '' f; do [ -e "$f" ] && printf '%s\0' "$f"; done |
    tar --null -T - -cf -) | tar -x -C "$snap" 2>>"$errlog" || {
    echo "could not snapshot $1 (see $errlog)" >&2; return 1; }
  git -C "$snap" init -q >>"$errlog" 2>&1 &&
    git -C "$snap" add -A >>"$errlog" 2>&1 &&
    git -C "$snap" -c user.name=smoke -c user.email=smoke@localhost \
      commit -qm snapshot >>"$errlog" 2>&1 || {
    echo "could not commit the snapshot (see $errlog)" >&2; return 1; }

  env -i PATH="$PATH" HOME="$harness_home" HERMES_HOME="$harness_home" \
    hermes plugins install "file://$snap" --enable --yes-deps \
    </dev/null >>"$errlog" 2>&1 || {
    echo "hermes plugins install failed (see $errlog)" >&2; return 1; }
  plugin_dir="$harness_home/plugins/sdlc-skills"

  # ROUTING PROBE: the router reaches the model as plugin system-prompt
  # sections. `prompt-size` assembles a fresh session's system prompt offline,
  # and Hermes logs each section it renders — and each it skips for size — to
  # the home's agent.log. Every part must render and none may be skipped.
  local log="$harness_home/logs/agent.log" rendered skipped
  env -i PATH="$PATH" HOME="$harness_home" HERMES_HOME="$harness_home" \
    hermes prompt-size --json </dev/null >/dev/null 2>>"$errlog" || {
    echo "hermes prompt-size failed (see $errlog)" >&2; return 1; }
  rendered="$(grep -c 'Session plugin prompt section: id=sdlc-skills\.router-' "$log" 2>/dev/null)"
  skipped="$(grep 'Plugin system prompt section sdlc-skills\.' "$log" 2>/dev/null)"
  if [ "${rendered:-0}" -gt 0 ] && [ -z "$skipped" ]; then
    echo "  ok    router renders into the session system prompt ($rendered section(s), offline)"
  else
    { echo "rendered=$rendered"; echo "$skipped"; } >>"$errlog"
    echo "router sections did not render into the system prompt (see $errlog)" >&2
    return 1
  fi
}

# DISCOVERY: `hermes prompt-size --json` builds the system prompt for a fresh
# session offline (no API call) and itemises its skill index. Report the names
# Hermes attributes to this plugin's namespace — the same index the model sees.
adapter_component_inventory() { # $1 installed plugin dir (unused)
  local out
  out="$(env -i PATH="$PATH" HOME="$harness_home" HERMES_HOME="$harness_home" \
    hermes prompt-size --json </dev/null 2>>"$errlog")" || {
    echo "hermes prompt-size failed (see $errlog)" >&2; return 1; }
  jq -r '.skills_breakdown[].name | select(startswith("sdlc-skills:")) | ltrimstr("sdlc-skills:")' \
    <<<"$out" 2>>"$errlog" || {
    echo "hermes prompt-size output did not parse (see $errlog)" >&2; return 1; }
}
