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
points at the canonical skills without forking them, binds the harness's real
tools, and injects the router only through session-start mechanisms.

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

echo "• $tools_doc (tool binding)"
if [ ! -f "$tools_doc" ]; then
  err "missing $tools_doc — the adapter would bind the dispatch action nowhere"
else
  for token in Task question todowrite skill; do
    grep -q "$token" "$tools_doc" || err "$tools_doc does not bind $token"
  done
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
