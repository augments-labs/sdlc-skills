#!/usr/bin/env bash
# Muse Code CLI adapter. Sourced by tests/run-plugin-smoke.sh — never executed
# directly.

adapter_check() {
  command -v muse >/dev/null 2>&1 || { echo "no \`muse\` CLI on PATH" >&2; return 3; }
}

# Isolated home, installed the way scripts/sh/install-muse-skills.sh installs
# for a real user: one `muse skills install <dir> --scope user` per canonical
# skill directory, which copies each skill under the Muse config directory's
# `skills/`. Offline and without credentials — a local-path install touches no
# provider.
#
# `muse plugins` answers "plugins are not available in this build" on 1.3.0, so
# the native `.muse-plugin/plugin.json` route cannot be installed or validated
# here; the per-skill route is the one this build actually offers, so it is the
# one the smoke test drives.
#
# Both HOME and XDG_CONFIG_HOME point at the throwaway directory. Muse resolves
# its config directory from XDG_CONFIG_HOME when that is set and from HOME
# otherwise, and overriding only one of them would let the operator's real
# `~/.config/muse/skills/` answer for the tree under test. `MUSE_NO_AUTO_UPDATE`
# keeps the launcher from reaching the network on a first run in a fresh home.
#
# plugin_dir stays unset: nothing is copied to a plugin root here, so the
# throwaway home is where the installed skills live and what the runner should
# look under.
adapter_install() { # $1 plugin source
  harness_home="$(mktemp -d)"
  ( cd "$1" && env -i PATH="$PATH" HOME="$harness_home" \
      XDG_CONFIG_HOME="$harness_home/.config" MUSE_NO_AUTO_UPDATE=1 \
      bash scripts/sh/install-muse-skills.sh ) >>"$errlog" 2>&1 || {
    echo "install-muse-skills.sh failed (see $errlog)" >&2; return 1; }
}

# DISCOVERY: ask Muse what it loads at user scope in this isolated home. The
# install copies each skill into the config directory rather than registering
# the checkout, and `muse skills list --json` reports `provenance: null` for
# the copies, so there is no source path to filter on. The isolation is what
# makes the unfiltered list safe to trust: the throwaway home was empty before
# adapter_install ran, so every user-scope name in it came from this install,
# and run-plugin-smoke.sh compares that list against the canonical set.
adapter_component_inventory() {
  local out
  out="$(env -i PATH="$PATH" HOME="$harness_home" \
    XDG_CONFIG_HOME="$harness_home/.config" MUSE_NO_AUTO_UPDATE=1 \
    muse skills list --source user --json 2>>"$errlog")" || {
    echo "muse skills list failed (see $errlog)" >&2; return 1; }
  jq -r '.skills[].name' <<<"$out" 2>>"$errlog" || {
    echo "muse skills list output did not parse (see $errlog)" >&2; return 1; }
}
