#!/usr/bin/env bash
# Offline test for the OpenCode plugin adapter.
#
# What this guards: the plugin must register the canonical skills and inject
# the canonical router body as content, not as an errand. Like
# tests/run-session-start.sh it checks the injected text, but through the
# plugin's own hook functions instead of a shell envelope — OpenCode calls
# hooks, not scripts.
#
# Deterministic on purpose: hook logic (read a file, strip frontmatter, append
# system context, register a path) gets a unit check. Whether a resident router
# changes behaviour is a live question and is not claimed here.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 2

case "${1-}" in
  -h|--help)
    cat <<'EOF'
tests/run-opencode-plugin.sh — offline unit check for the OpenCode adapter.

Takes no arguments; loads .opencode/plugins/sdlc-skills.js in Node with stub
inputs and checks skill registration and router injection.

  --help    this text

Exit codes: 0 every check passed · 1 at least one failed · 2 not run from the repo
            3 node is unavailable
EOF
    exit 0;;
esac

PLUGIN=.opencode/plugins/sdlc-skills.js
ROUTER=skills/common/using-sdlc-skills/SKILL.md
fails=0
ok()   { echo "  ok    $1"; }
bad()  { echo "  FAIL  $1"; fails=1; }

command -v node >/dev/null 2>&1 || { echo "needs \`node\`" >&2; exit 3; }
[ -f "$PLUGIN" ] || { bad "missing $PLUGIN (nothing registers the skills or injects the router)"; echo "---"; echo "opencode plugin offline tests: FAIL"; exit 1; }
[ -f "$ROUTER" ] || { bad "missing canonical router $ROUTER"; echo "---"; echo "opencode plugin offline tests: FAIL"; exit 1; }

node --check "$PLUGIN" 2>/dev/null || { bad "$PLUGIN does not parse"; echo "---"; echo "opencode plugin offline tests: FAIL"; exit 1; }
ok "plugin parses"

probe="$(mktemp -d)"
trap 'rm -rf "$probe"' EXIT

# Drive the plugin's real hooks with stub inputs; report one line per check as
# `ok <label>` or `bad <label> (<detail>)` so a failure names its hook.
node --input-type=module -e '
import fs from "node:fs";
const path = "./.opencode/plugins/sdlc-skills.js";
const mod = await import(new URL("file://" + process.cwd() + "/" + path).href);
const plugin = mod.default;
const report = (status, label, detail) => console.log((status ? "ok " : "bad ") + label + (detail ? " (" + detail + ")" : ""));
try {
  const hooks = await plugin({}, undefined);
  const names = Object.keys(hooks).sort();
  const allowed = ["config", "experimental.chat.system.transform", "experimental.session.compacting"].sort();
  const extra = names.filter((n) => !allowed.includes(n));
  const missing = allowed.filter((n) => !names.includes(n));
  report(extra.length === 0, "registers no tool, prompt, or turn-end hook", extra.join(","));
  report(missing.length === 0, "registers config, system injection, and compaction", missing.join(","));

  const cfg = {};
  await hooks["config"](cfg);
  const paths = (cfg.skills && cfg.skills.paths) || [];
  const hit = paths.find((p) => { try { return fs.existsSync(p + "/common/using-sdlc-skills/SKILL.md"); } catch { return false; } });
  report(!!hit, "config registers a skills path covering the canonical tree", paths.join(","));
  const cfg2 = JSON.parse(JSON.stringify({ skills: { paths: [...paths] } }));
  await hooks["config"](cfg2);
  report(cfg2.skills.paths.length === paths.length, "config registration is idempotent");

  const out = { system: [] };
  await hooks["experimental.chat.system.transform"]({}, out);
  const text = out.system.join("\n");
  const raw = fs.readFileSync("skills/common/using-sdlc-skills/SKILL.md", "utf8");
  const canonical = raw.replace(/^---\n[\s\S]*?\n---\n/, "");
  report(text.includes(canonical) && canonical.length > 0, "injects the canonical router body verbatim");
  report(!text.includes("name: using-sdlc-skills"), "strips YAML frontmatter");
  report(text.includes("<EXTREMELY_IMPORTANT>") && text.includes("</EXTREMELY_IMPORTANT>"), "wraps the router so it cannot read as optional");
  for (const probe of ["Catch one and stop", "\"Too simple\"", "| The thought | The reality |"]) {
    report(text.includes(probe), "router survives intact (" + probe.slice(0, 24) + ")");
  }
  for (const token of ["Task", "question", "todowrite", "skill"]) {
    report(text.includes(token), "binds the " + token + " action");
  }
  const before = out.system.length;
  await hooks["experimental.chat.system.transform"]({}, out);
  report(out.system.length === before, "re-injection is idempotent within a built system prompt");

  const compact = { context: [], prompt: undefined };
  await hooks["experimental.session.compacting"]({ sessionID: "s1" }, compact);
  report(compact.context.join("\n").includes("using-sdlc-skills"), "compaction carries the router forward");
  report(compact.prompt === undefined, "compaction keeps the default prompt");
} catch (err) {
  console.log("bad hooks threw instead of injecting (" + (err && err.message) + ")");
}
' >"$probe/report" 2>"$probe/err" || { bad "node probe crashed: $(head -c 300 "$probe/err")"; }

lines=0
while IFS= read -r line; do
  case "$line" in
    ok\ *) ok "${line#ok }" ; lines=$((lines+1)) ;;
    bad\ *) bad "${line#bad }"; lines=$((lines+1)) ;;
  esac
done <"$probe/report"
[ "$lines" -eq 0 ] && bad "node probe produced no results: $(head -c 300 "$probe/err")"

echo "--- fails loudly rather than injecting nothing"
stray="$(mktemp -d)"
cp "$PLUGIN" "$stray/stray-plugin.js"
if node --input-type=module -e "
import('file://$stray/stray-plugin.js').then(async (m) => {
  const hooks = await m.default({}, undefined);
  await hooks['experimental.chat.system.transform']({}, { system: [] });
  console.log('injected without a router');
}).catch((err) => { console.error('refused: ' + (err && err.message)); process.exit(1); }
" >/dev/null 2>&1; then
  bad "injects router text with no skills tree beside the plugin"
else
  ok "refuses to inject when the router file cannot be found"
fi
rm -rf "$stray"

echo "---"
[ "$fails" -eq 0 ] && { echo "opencode plugin offline tests: PASS"; exit 0; }
echo "opencode plugin offline tests: FAIL"; exit 1
