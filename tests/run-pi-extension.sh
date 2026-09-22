#!/usr/bin/env bash
# Offline test for the pi extension adapter.
#
# What this guards: the extension must register the canonical skills
# directory and append the canonical router body to pi's system prompt as
# content, not as an errand — mirroring tests/run-opencode-plugin.sh, through
# the extension's own handler functions instead of a shell envelope, since pi
# calls handlers, not scripts.
#
# Deterministic on purpose: hook logic (read a file, strip frontmatter, append
# to the system prompt, register a path) gets a unit check. Whether a resident
# extension changes behaviour on a live pi session is not claimed here.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 2

case "${1-}" in
  -h|--help)
    cat <<'EOF'
tests/run-pi-extension.sh — offline unit check for the pi adapter.

Takes no arguments; loads .pi/extensions/sdlc-skills.js in Node with a stub
`pi` whose `on` collects handlers, and checks skill-path registration and
system-prompt injection.

  --help    this text

Exit codes: 0 every check passed · 1 at least one failed · 2 not run from the repo
            3 node is unavailable
EOF
    exit 0;;
esac

EXTENSION=.pi/extensions/sdlc-skills.js
ROUTER=skills/common/using-sdlc-skills/SKILL.md
fails=0
ok()   { echo "  ok    $1"; }
bad()  { echo "  FAIL  $1"; fails=1; }

command -v node >/dev/null 2>&1 || { echo "needs \`node\`" >&2; exit 3; }
[ -f "$EXTENSION" ] || { bad "missing $EXTENSION (nothing registers the skills or injects the router)"; echo "---"; echo "pi extension offline tests: FAIL"; exit 1; }
[ -f "$ROUTER" ] || { bad "missing canonical router $ROUTER"; echo "---"; echo "pi extension offline tests: FAIL"; exit 1; }

node --check "$EXTENSION" 2>/dev/null || { bad "$EXTENSION does not parse"; echo "---"; echo "pi extension offline tests: FAIL"; exit 1; }
ok "extension parses"

probe="$(mktemp -d)"
trap 'rm -rf "$probe"' EXIT

# Drive the extension's real handlers with stub inputs; report one line per
# check as `ok <label>` or `bad <label> (<detail>)` so a failure names its hook.
node --input-type=module -e '
import fs from "node:fs";
const path = "./.pi/extensions/sdlc-skills.js";
const mod = await import(new URL("file://" + process.cwd() + "/" + path).href);
const factory = mod.default;
const report = (status, label, detail) => console.log((status ? "ok " : "bad ") + label + (detail ? " (" + detail + ")" : ""));

try {
  const handlers = {};
  const stub = { on: (event, handler) => { (handlers[event] ??= []).push(handler); } };
  await factory(stub);

  const names = Object.keys(handlers).sort();
  const allowed = ["resources_discover", "before_agent_start", "session_compact"].sort();
  const extra = names.filter((n) => !allowed.includes(n));
  const missing = allowed.filter((n) => !names.includes(n));
  report(extra.length === 0, "registers no event outside the three bound", extra.join(","));
  report(missing.length === 0, "registers resources_discover, before_agent_start, and session_compact", missing.join(","));

  const discover = await handlers["resources_discover"][0]({ type: "resources_discover", cwd: process.cwd(), reason: "startup" }, {});
  const paths = (discover && discover.skillPaths) || [];
  const hit = paths.find((p) => { try { return fs.existsSync(p + "/common/using-sdlc-skills/SKILL.md"); } catch { return false; } });
  report(!!hit, "resources_discover registers a path covering the canonical router", paths.join(","));

  const raw = fs.readFileSync("skills/common/using-sdlc-skills/SKILL.md", "utf8");
  const canonical = raw.replace(/^---\n[\s\S]*?\n---\n/, "");

  const event = { type: "before_agent_start", systemPromptOptions: { appendSystemPrompt: "" } };
  await handlers["before_agent_start"][0](event, {});
  const once = event.systemPromptOptions.appendSystemPrompt;
  report(once.includes(canonical) && canonical.length > 0, "appends the canonical router body verbatim");
  report(!once.includes("name: using-sdlc-skills"), "strips YAML frontmatter");
  const occurrences = once.split(canonical).length - 1;
  report(occurrences === 1, "router body appears exactly once", String(occurrences));

  await handlers["before_agent_start"][0](event, {});
  report(event.systemPromptOptions.appendSystemPrompt === once, "a second before_agent_start call is idempotent");

  const compactEvent = { type: "session_compact", compactionEntry: { summary: "prior summary" }, fromExtension: false, reason: "manual", willRetry: false };
  await handlers["session_compact"][0](compactEvent, {});
  report(compactEvent.compactionEntry.summary.includes(canonical), "session_compact re-appends the router into the compaction summary");
  await handlers["session_compact"][0](compactEvent, {});
  const compactOccurrences = compactEvent.compactionEntry.summary.split(canonical).length - 1;
  report(compactOccurrences === 1, "a second session_compact call is idempotent", String(compactOccurrences));
} catch (err) {
  console.log("bad handlers threw instead of registering/injecting (" + (err && err.message) + ")");
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
cp "$EXTENSION" "$stray/stray-extension.js"
if node --input-type=module -e "
import('file://$stray/stray-extension.js').then(async (m) => {
  const handlers = {};
  const stub = { on: (event, handler) => { (handlers[event] ??= []).push(handler); } };
  await m.default(stub);
  await handlers['before_agent_start'][0]({ type: 'before_agent_start', systemPromptOptions: { appendSystemPrompt: '' } }, {});
  console.log('injected without a router');
}).catch((err) => { console.error('refused: ' + (err && err.message)); process.exit(1); }
" >/dev/null 2>&1; then
  bad "injects router text with no skills tree beside the extension"
else
  ok "throws when the router file cannot be found"
fi
rm -rf "$stray"

echo "---"
[ "$fails" -eq 0 ] && { echo "pi extension offline tests: PASS"; exit 0; }
echo "pi extension offline tests: FAIL"; exit 1
