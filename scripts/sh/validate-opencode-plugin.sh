#!/usr/bin/env bash
# Structural validator for the repo-local OpenCode plugin adapter.
# Flags and exit codes: --help.

set -uo pipefail
cd "$(dirname "$0")/../.." || exit 2

case "${1-}" in
  -h|--help)
    cat <<'EOF'
scripts/sh/validate-opencode-plugin.sh — structural gate for the OpenCode adapter.

Takes no arguments. Checks the plugin parses, imports nothing external,
points at the canonical skills without forking them, exports both the 1.x
hook factory and the 2.x { id, setup } plugin, binds the harness's real tools
for each generation, and injects the router only through session-start
mechanisms.

  --help    this text

Exit codes: 0 the adapter is consistent · 1 violations printed above
            2 not run from the repo · requires `jq` and `node`
EOF
    exit 0;;
esac

fail=0
err() { printf '  FAIL: %s\n' "$1"; fail=1; }

plugin=".opencode/plugins/sdlc-skills.js"
tools_doc=".opencode/references/opencode-tools.md"
pkg="package.json"
# OpenCode 2.x refuses a configured file path and resolves a directory to
# <dir>/server.js or <dir>/index.js, so the package entry is this root file.
entry="index.js"
tmpout="$(mktemp)"
tmperr="$(mktemp)"
trap 'rm -f "$tmpout" "$tmperr"' EXIT

echo "• $plugin"
if [ ! -f "$plugin" ]; then
  err "missing OpenCode plugin (an install would register no skills and inject no router)"
else
  command -v node >/dev/null || { echo "  FAIL: node is required to validate $plugin"; exit 1; }
  node --check "$plugin" >/dev/null 2>&1 || err "$plugin does not parse — OpenCode would load no hook from it"

  # Zero-dependency by design: the adapter may use the Node standard library
  # only. A bare `require(` / `from "` outside node: is an external package.
  while IFS= read -r imp; do
    case "$imp" in
      node:*|"node:fs"|"node:path"|"node:url") ;;
      *) err "$plugin imports '$imp' — the adapter must stay dependency-free" ;;
    esac
  done < <(grep -oE "(require\(['\"][^'\"]+['\"]|from ['\"][^'\"]+['\"])" "$plugin" |
           sed -E "s/^(require\(|from )['\"]//; s/['\"]$//" | sort -u)

  # The adapter points at the canonical tree; it must not fork skill content.
  # A SKILL.md copy under .opencode/ is a second source of truth an edit to
  # skills/ silently stops shipping.
  if [ -n "$(find .opencode -name SKILL.md 2>/dev/null)" ]; then
    err ".opencode/ carries SKILL.md copies — the adapter must point at skills/, never fork it"
  fi
  grep -q 'common/using-sdlc-skills/SKILL.md' "$plugin" \
    || err "$plugin does not read the canonical router (an edit to the skill would silently stop shipping)"
  grep -q 'cfg.skills' "$plugin" && grep -q 'skills.paths\|skills\["paths"\]\|paths' "$plugin" \
    || err "$plugin does not register skills.paths — an install would inject a router for skills that never load"

  # One file, two runtime contracts. 1.x finds the hook factory by scanning
  # named exports; 2.x calls `default.setup(ctx)` and never the factory. A
  # module that drops either export is silently inert on that generation.
  echo "• dual 1.x / 2.x export shape"
  node --input-type=module -e '
    const m = await import(new URL("file://" + process.cwd() + "/'"$entry"'").href);
    const fail = (s) => { console.log(s); process.exitCode = 1; };
    if (typeof m.sdlcSkillsPlugin !== "function") fail("no named export sdlcSkillsPlugin — OpenCode 1.x would find no hook factory");
    const d = m.default;
    if (!d || typeof d !== "object") fail("default export is not the 2.x plugin object — OpenCode 2.x would register nothing");
    else {
      if (d.id !== "sdlc-skills") fail("default export has no id — OpenCode 2.x identifies plugins by id");
      if (typeof d.setup !== "function") fail("default export has no setup — OpenCode 2.x calls setup(ctx) and nothing else");
      if (d.server !== m.sdlcSkillsPlugin) fail("default.server is not the named hook factory");
    }
  ' > "$tmpout" 2>"$tmperr"
  probe_rc=$?
  # Only the probe's own stdout names a contract violation. A runtime that
  # prints an ExperimentalWarning or a deprecation notice on stderr is not a
  # violation, so stderr is surfaced only when the probe actually failed.
  while IFS= read -r line; do [ -n "$line" ] && err "$line"; done < "$tmpout"
  if [ "$probe_rc" -ne 0 ] && [ ! -s "$tmpout" ]; then
    err "the export-shape probe exited $probe_rc: $(head -c 300 "$tmperr")"
  fi

  echo "• OpenCode session-start-only activation"
  for hook in '"experimental.chat.system.transform"' '"experimental.session.compacting"'; do
    grep -q "$hook" "$plugin" || err "$plugin is missing $hook"
  done
  for banned in 'tool.execute' 'permission.ask' 'command.execute' '"event"' \
                'chat.message' 'chat.params' 'chat.headers' 'shell.env' \
                'tool.definition' 'tool:' 'provider:' 'auth:'; do
    grep -q "$banned" "$plugin" && err "$plugin registers $banned — routing belongs in session-start context, not tool or turn hooks"
  done
  if ! bash tests/run-opencode-plugin.sh >/dev/null; then
    err "tests/run-opencode-plugin.sh failed"
  fi

  echo "• OpenCode injected text (scanner trigger-words)"
  for f in "$plugin" "$tools_doc"; do
    if [ ! -f "$f" ]; then
      err "$f: missing, so the text it injects cannot be scanned"
    elif grep -qiE '\bultrathink\b' "$f"; then
      err "$f: harness scanner trigger-word"
    fi
  done
fi

echo "• $pkg (npm-installable plugin package)"
if [ ! -f "$pkg" ]; then
  err "missing $pkg — a git package spec has nothing to install, so the plugin never loads"
else
  command -v jq >/dev/null || { echo "  FAIL: jq is required to validate $pkg"; exit 1; }
  jq -e . "$pkg" >/dev/null 2>&1 || err "$pkg does not parse as JSON"
  [ "$(jq -r '.name // ""' "$pkg")" = "sdlc-skills" ] || err "$pkg name is not sdlc-skills"
  [ "$(jq -r '.type // ""' "$pkg")" = "module" ] || err "$pkg must set type module for the ESM plugin"
  main="$(jq -r '.main // ""' "$pkg")"
  [ -n "$main" ] || err "$pkg has no main entry — the installer would not know which file is the plugin"
  [ -n "$main" ] && [ ! -f "$main" ] && err "$pkg main entry '$main' points nowhere"
  # 2.x resolves an installed package through main and a local checkout through
  # <dir>/index.js. Both land on the root entry, so main must name it.
  [ "$main" = "$entry" ] \
    || err "$pkg main is '$main', not '$entry' — OpenCode 2.x resolves a plugin directory to <dir>/index.js and refuses a configured file path"
  [ -f "$entry" ] || err "missing $entry — an OpenCode 2.x install would resolve the plugin directory to nothing"
  for dep in dependencies devDependencies peerDependencies optionalDependencies; do
    jq -e ".$dep | length > 0" "$pkg" >/dev/null 2>&1 && err "$pkg declares $dep — the adapter must stay dependency-free"
  done
  pkg_v="$(jq -r '.version // ""' "$pkg")"
  claude_v="$(grep -m1 -oE '"version"[[:space:]]*:[[:space:]]*"[^"]+"' .claude-plugin/plugin.json | sed -E 's/.*"([^"]+)"$/\1/')"
  [ -n "$pkg_v" ] || err "$pkg has no version"
  [ -n "$pkg_v" ] && [ -n "$claude_v" ] && [ "$pkg_v" != "$claude_v" ] && err "$pkg version $pkg_v != manifest version $claude_v"
fi

echo "• $tools_doc (tool binding)"
if [ ! -f "$tools_doc" ]; then
  err "missing $tools_doc — the adapter would bind the dispatch action nowhere"
else
  # One table per generation: the 2.x surface has no todo tool and renames the
  # dispatch call, so a single table would misbind one of the two.
  for heading in '## OpenCode 1.x' '### OpenCode 1.x' '## OpenCode 2.x' '### OpenCode 2.x'; do
    case "$heading" in *' 1.x') gen=1;; *) gen=2;; esac
    grep -qF "$heading" "$tools_doc" && eval "seen_$gen=1"
  done
  [ "${seen_1-}" = 1 ] || err "$tools_doc has no OpenCode 1.x heading — one table cannot bind both generations"
  [ "${seen_2-}" = 1 ] || err "$tools_doc has no OpenCode 2.x heading — one table cannot bind both generations"
  # Scoped to the generation's own section, and matched in table-cell form.
  # A bare word check passes on prose and on the *other* table — `subagent`
  # appears in the 1.x dispatch row — so deleting every row of a table would
  # leave the gate green while the adapter bound nothing.
  section() { # $1 heading
    awk -v h="$1" '$0 == h { inside = 1; next } inside && /^#/ { exit } inside' "$tools_doc"
  }
  for gen in '1.x:Task question todowrite skill' '2.x:subagent shell skill question'; do
    heading="### OpenCode ${gen%%:*}"
    section "$heading" > "$tmpout"
    if [ ! -s "$tmpout" ]; then
      err "$tools_doc has no rows under '$heading' — that generation binds nothing"
      continue
    fi
    for token in ${gen#*:}; do
      grep -qF "| \`$token\`" "$tmpout" \
        || err "$tools_doc has no \`$token\` row under '$heading' (OpenCode ${gen%%:*})"
    done
  done
  grep -q 'no todo tool' "$tools_doc" \
    || err "$tools_doc does not state that OpenCode 2.x exposes no todo tool"
  grep -q 'small | medium | large' "$tools_doc" \
    || err "$tools_doc does not bind the capability tier without vendor model names"
fi

echo ""
if [ "$fail" -eq 0 ]; then
  echo "✓ OpenCode plugin adapter passes structural validation"
else
  echo "✗ OpenCode plugin adapter violations found"
fi
exit "$fail"
