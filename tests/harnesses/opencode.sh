#!/usr/bin/env bash
# OpenCode CLI adapter. Sourced by tests/run-plugin-smoke.sh — never executed
# directly.
#
# This file holds only what is true of the `opencode` CLI's install: how the
# plugin is loaded and what the harness reports it resolved.
#
# Two generations install the same plugin differently, so the major version
# decides. 1.x takes a plugin FILE under `plugin`; 2.x takes a plugin
# DIRECTORY under `plugins` and resolves `<dir>/index.js` inside it, refusing
# a file path outright. What each generation can then be asked about its
# skills differs too, and that is the split below.

adapter_check() {
  command -v opencode >/dev/null 2>&1 || { echo "no \`opencode\` CLI on PATH" >&2; return 3; }
  # `opencode --version` prints e.g. `opencode v2.0.13`; keep only the number.
  opencode_version="$(opencode --version 2>/dev/null | head -1 | tr -cd '0-9.')"
  opencode_major="${opencode_version%%.*}"
  case "$opencode_major" in
    1|2) ;;
    *) echo "unrecognised \`opencode\` version: ${opencode_version:-none}" >&2; return 3;;
  esac
}

# OpenCode loads a plugin from the checkout, so the checkout is the whole
# install: the plugin resolves its skills from its own location. The isolated
# config home carries only the plugin entry — no credentials.
adapter_install() { # $1 plugin source
  harness_home="$(mktemp -d)"
  mkdir -p "$harness_home/xdg/opencode"
  plugin_dir="$1"
  echo "  ok    opencode v$opencode_version — ${opencode_major}.x plugin contract"

  if [ "$opencode_major" = "1" ]; then
    printf '{"$schema":"https://opencode.ai/config.json","plugin":["%s/.opencode/plugins/sdlc-skills.js"]}' \
      "$1" > "$harness_home/xdg/opencode/opencode.json"
    opencode_prove_passive_1x "$1" || return 1
    return 0
  fi

  printf '{"$schema":"https://opencode.ai/config.json","plugins":["%s"]}' \
    "$1" > "$harness_home/xdg/opencode/opencode.json"
  # 2.x has no offline skill listing (below), so the installed plugin is proved
  # to LOAD instead — which a filesystem count cannot show either.
  opencode_prove_loaded "$1" || return 1
  opencode_prove_passive_2x "$1" || return 1
  # Declared only for 1.x: on 2.x the runner must fall back to its layout count,
  # and an inventory that reported the canonical names from anywhere but the
  # harness would be a fabricated pass.
  unset -f adapter_component_inventory
  return 0
}

# DISCOVERY on 2.x: boot the CLI against the isolated home and read back the
# harness's own "loading plugin" line naming the entry point it resolved.
#
# Plugins load while the server starts, before any model turn, so this needs no
# credentials and no network — the run is killed the moment the line appears,
# and its exit status is deliberately ignored. `</dev/null` is required: the CLI
# blocks on stdin without it. `opencode serve` is not an alternative; it loads
# no plugins at all.
opencode_prove_loaded() { # $1 plugin source
  local log="$harness_home/boot.log" needle="entrypoint=file://$1/index.js"
  local pid waited=0
  env -i PATH="$PATH" HOME="$harness_home" XDG_CONFIG_HOME="$harness_home/xdg" TERM=dumb \
    opencode run --standalone --print-logs "hi" </dev/null >/dev/null 2>"$log" &
  pid=$!
  while [ "$waited" -lt 60 ]; do
    grep -a -q -F "$needle" "$log" 2>/dev/null && break
    kill -0 "$pid" 2>/dev/null || break
    sleep 1; waited=$((waited + 1))
  done
  kill "$pid" 2>/dev/null; wait "$pid" 2>/dev/null

  if ! grep -a -q -F "$needle" "$log"; then
    echo "opencode never logged the plugin as loaded from $1" >>"$errlog"
    sed 's/^/  /' "$log" >>"$errlog"
    return 1
  fi
  if grep -a -q -F "sdlc-skills:" "$log"; then
    echo "the plugin reported errors while loading:" >>"$errlog"
    grep -a -F "sdlc-skills:" "$log" | sed 's/^/  /' >>"$errlog"
    return 1
  fi
  echo "  ok    harness loaded the plugin from $1/index.js"
  # LIMIT, stated rather than worked around: 2.0.13 exposes no skill listing
  # without a model call. `debug skill` is gone, and `opencode serve` — whose
  # API does list skills — loads no plugins, so its listing is always empty.
  # What follows this line is therefore a count of the tree the harness was
  # pointed at, not an inventory the harness reported.
  echo "  ok    2.x skill inventory unavailable offline — load proved, contents not listed"
  return 0
}

# PASSIVE DISCOVERY on 2.x: same boot-log mechanism as opencode_prove_loaded,
# but against a second isolated home whose opencode.json carries no `plugins`
# entry at all, and with the CLI's cwd set to the checkout — so whatever the
# harness reports loading got there through its own auto-discovery, not
# through the config this adapter writes for the explicit-config proof above.
#
# The needle differs from opencode_prove_loaded's: a config-named `plugins`
# entry resolves through the installed package's `index.js` (see adapter_check's
# header comment and the root index.js), but passive discovery — if it happens
# at all — resolves the file under `.opencode/plugins/` directly, never
# touching `index.js`.
#
# Either outcome is a measurement, not a failure: the explicit route this
# adapter writes above is the documented install, so finding no passive load
# is exactly as informative as finding one. What fails is a probe that could
# not run at all — no boot log to read back.
opencode_prove_passive_2x() { # $1 plugin source (the checkout)
  local passive_home; passive_home="$(mktemp -d)"
  mkdir -p "$passive_home/xdg/opencode"
  printf '{"$schema":"https://opencode.ai/config.json"}' \
    > "$passive_home/xdg/opencode/opencode.json"
  local log="$passive_home/passive-boot.log" needle="entrypoint=file://$1/.opencode/plugins/sdlc-skills.js"
  local pid waited=0 orig_pwd="$PWD"

  cd "$1" || {
    echo "cannot cd to $1 for the 2.x passive probe" >>"$errlog"
    rm -rf "$passive_home"; return 1
  }
  env -i PATH="$PATH" HOME="$passive_home" XDG_CONFIG_HOME="$passive_home/xdg" TERM=dumb \
    opencode run --standalone --print-logs "hi" </dev/null >/dev/null 2>"$log" &
  pid=$!
  while [ "$waited" -lt 60 ]; do
    grep -a -q -F "$needle" "$log" 2>/dev/null && break
    kill -0 "$pid" 2>/dev/null || break
    sleep 1; waited=$((waited + 1))
  done
  kill "$pid" 2>/dev/null; wait "$pid" 2>/dev/null
  cd "$orig_pwd" || true

  if [ ! -s "$log" ]; then
    echo "opencode never produced a boot log for the 2.x passive probe" >>"$errlog"
    rm -rf "$passive_home"
    return 1
  fi

  if grep -a -q -F "$needle" "$log"; then
    echo "  ok    2.x passive discovery loaded .opencode/plugins from the checkout"
  else
    echo "  ok    2.x passive discovery does not load a plugin file under .opencode/plugins (measured; explicit config required)"
  fi
  rm -rf "$passive_home"
  return 0
}

# PASSIVE DISCOVERY on 1.x: same shape as the 2.x probe above, using the
# `debug skill` mechanism adapter_component_inventory already relies on
# instead of a boot log, since that is what 1.x exposes offline. A second
# isolated home carries no `plugin` entry, and the CLI's cwd is set to the
# checkout, so any skill it reports came from its own `.opencode/plugins/`
# auto-discovery.
#
# Unexercised on this machine — no 1.x `opencode` binary is on PATH here — so
# this arm has not produced a measurement; it runs the moment one is.
opencode_prove_passive_1x() { # $1 plugin source (the checkout)
  local passive_home; passive_home="$(mktemp -d)"
  mkdir -p "$passive_home/xdg/opencode"
  printf '{"$schema":"https://opencode.ai/config.json"}' \
    > "$passive_home/xdg/opencode/opencode.json"
  local out="$passive_home/skills.json" orig_pwd="$PWD" found

  cd "$1" || {
    echo "cannot cd to $1 for the 1.x passive probe" >>"$errlog"
    rm -rf "$passive_home"; return 1
  }
  env -i PATH="$PATH" HOME="$passive_home" XDG_CONFIG_HOME="$passive_home/xdg" \
    opencode debug skill >"$out" 2>>"$errlog"
  cd "$orig_pwd" || true

  if [ ! -s "$out" ]; then
    echo "opencode produced no \`debug skill\` output for the 1.x passive probe" >>"$errlog"
    rm -rf "$passive_home"
    return 1
  fi

  found="$(jq -r --arg root "$1" \
    '.[] | select(.location | startswith($root)) | .name' "$out" 2>>"$errlog")" || {
    echo "1.x passive probe's \`debug skill\` output did not parse (see $errlog)" >>"$errlog"
    rm -rf "$passive_home"
    return 1
  }

  if [ -z "$found" ]; then
    echo "  ok    1.x passive discovery does not load a plugin file under .opencode/plugins (measured; explicit config required)"
  else
    echo "  ok    1.x passive discovery loaded .opencode/plugins from the checkout"
  fi
  rm -rf "$passive_home"
  return 0
}

# DISCOVERY on 1.x: ask OpenCode to resolve the skills exactly as a session
# would and return the skill names from its own listing. A filesystem count
# cannot prove that the registered path was accepted by the harness.
#
# Two harness quirks live here. `debug skill` truncates piped stdout at 64 KiB,
# so the output is staged through a file first — a pipe sees only the first
# few skills. And the listing covers every visible skill including built-ins,
# so only entries located under the installed plugin source are reported.
adapter_component_inventory() { # $1 plugin source
  local out="$harness_home/skills.json"
  env -i PATH="$PATH" HOME="$harness_home" XDG_CONFIG_HOME="$harness_home/xdg" \
    opencode debug skill >"$out" 2>>"$errlog" || {
    echo "debug skill failed (see $errlog)" >&2; return 1; }
  jq -r --arg root "$1" \
    '.[] | select(.location | startswith($root)) | .name' "$out" 2>>"$errlog" || {
    echo "debug skill output did not parse (see $errlog)" >&2; return 1; }
}
