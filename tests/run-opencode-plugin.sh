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
// Export shape only: the module now serves both generations, so the 1.x hook
// factory is the named export and `default` is the 2.x plugin object. Every
// pre-existing 1.x assertion below is unchanged. One assertion below is new:
// the array-shaped `skills` check, which covers the guard the dual-contract
// module put in the `config` hook.
const plugin = mod.sdlcSkillsPlugin ?? mod.default;
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
  // 2.x models `skills` as an array. A host that calls the factory with that
  // shape must get it back untouched, not grown a `paths` property.
  const cfg3 = { skills: [] };
  await hooks["config"](cfg3);
  report(Array.isArray(cfg3.skills) && cfg3.skills.length === 0 && !("paths" in cfg3.skills),
    "config leaves an array-shaped skills config untouched", JSON.stringify(cfg3));

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

# --- OpenCode 2.x contract -------------------------------------------------
# 2.x loads a plugin directory and calls `default.setup(ctx)`; the 1.x hook
# factory is never invoked (measured on 2.0.13). The stub `ctx` below mirrors
# the real 2.x surface: `skill.transform(cb)` hands the callback a draft with
# `add`, and `session.hook("context", h)` hands `h` an event carrying
# `sessionID`, `messages`, `system`, and `tools`. A throw escaping either
# callback takes the session down on the real harness, so the checks assert
# the plugin swallows a rejected payload rather than propagating it.
echo "--- OpenCode 2.x setup contract"
# A copy of the plugin with no skills tree beside it, and one with a tree of
# unreadable skills, for the stray cases below.
stray2="$probe/stray2"
mkdir -p "$stray2/.opencode/plugins"
cp "$PLUGIN" "$stray2/.opencode/plugins/sdlc-skills.js"
stray3="$probe/stray3"
mkdir -p "$stray3/.opencode/plugins" "$stray3/skills/x/no-frontmatter" \
         "$stray3/skills/x/no-name" "$stray3/skills/x/empty-body"
cp "$PLUGIN" "$stray3/.opencode/plugins/sdlc-skills.js"
printf 'just a body, no frontmatter at all\n' > "$stray3/skills/x/no-frontmatter/SKILL.md"
printf -- '---\ndescription: has no name\n---\nbody\n' > "$stray3/skills/x/no-name/SKILL.md"
printf -- '---\nname: empty-body\ndescription: has no body\n---\n\n' > "$stray3/skills/x/empty-body/SKILL.md"
STRAY2="$stray2" STRAY3="$stray3" node --input-type=module -e '
import fs from "node:fs";
const mod = await import(new URL("file://" + process.cwd() + "/.opencode/plugins/sdlc-skills.js").href);
const report = (status, label, detail) => console.log((status ? "ok " : "bad ") + label + (detail ? " (" + detail + ")" : ""));

// The plugin swallows its own failures by design, so silence is not evidence:
// capture its diagnostics and assert the happy path emits none and each
// failure path emits exactly its own.
const logged = [];
const realError = console.error;
console.error = (...args) => { logged.push(args.map(String).join(" ")); };
const drain = () => { const out = logged.filter((l) => l.includes("sdlc-skills:")); logged.length = 0; return out; };

// The count is measured from the tree, never hard-coded: adding a skill must
// not break this check.
const countSkills = (dir) => fs.readdirSync(dir, { withFileTypes: true }).reduce(
  (n, e) => n + (e.isDirectory() ? countSkills(dir + "/" + e.name) : (e.name === "SKILL.md" ? 1 : 0)), 0);
const expected = countSkills("skills");

report(typeof mod.sdlcSkillsPlugin === "function", "exports the 1.x hook factory as a named export");
const def = mod.default;
report(!!def && typeof def === "object" && !Array.isArray(def), "default export is the 2.x plugin object", typeof def);
report(!!def && def.id === "sdlc-skills", "2.x plugin declares its id", def && String(def.id));
report(!!def && typeof def.setup === "function", "2.x plugin exposes setup");
report(typeof mod.sdlcSkillsPlugin === "function" && !!def && def.server === mod.sdlcSkillsPlugin, "default.server is the same hook factory");

const makeCtx = (opts = {}) => {
  const added = [];
  const hooks = {};
  return {
    added, hooks,
    ctx: {
      skill: { transform: async (cb) => { if (opts.transformThrows) throw new Error("transform unavailable"); cb({ add: (s) => { if (opts.reject && opts.reject(s)) throw new Error("rejected payload"); added.push(s); }, list: () => added.slice() }); return { dispose: async () => {} }; } },
      session: {
        hook: async (name, handler) => { if (opts.hookThrows) throw new Error("hook unavailable"); hooks[name] = handler; return { dispose: async () => {} }; },
        get: async ({ sessionID }) => { if (opts.getThrows) throw new Error("no such session"); return (opts.records || {})[sessionID] ?? { id: sessionID }; },
      },
    },
  };
};

try {
  const { added, hooks, ctx } = makeCtx({ records: { top: { id: "top" }, child: { id: "child", parentID: "top" } } });
  await def.setup(ctx);
  report(added.length === expected, "registers every skill on disk through draft.add", added.length + " of " + expected);
  const complete = added.filter((s) => s && ["id", "name", "description", "path", "content"].every((k) => typeof s[k] === "string" && s[k].length > 0));
  report(complete.length === added.length && added.length > 0, "every draft.add payload sets id, name, description, path and content", (added.length - complete.length) + " incomplete");
  const router = added.find((s) => s.id === "using-sdlc-skills");
  report(!!router && router.content.includes("Catch one and stop"), "the registered router carries the canonical body");
  report(!!router && !router.content.startsWith("---"), "registered skill content has its frontmatter stripped");
  report(added.every((s) => fs.existsSync(s.path)), "every registered skill path exists on disk");

  report(typeof hooks.context === "function", "registers a session context hook", Object.keys(hooks).join(","));
  const raw = fs.readFileSync("skills/common/using-sdlc-skills/SKILL.md", "utf8");
  const canonical = raw.replace(/^---\n[\s\S]*?\n---\n/, "");

  const topEvent = { sessionID: "top", system: [], messages: [{ role: "user", content: [{ type: "text", text: "hello" }] }], tools: {} };
  await hooks.context(topEvent);
  const userText = JSON.stringify(topEvent.messages.filter((m) => m.role === "user"));
  report(userText.includes(JSON.stringify(canonical).slice(1, -1)), "injects the canonical router into the first user message");
  report(topEvent.system.length === 0, "injects nothing as a system message on 2.x", String(topEvent.system.length));
  for (const token of ["subagent", "shell", "skill"]) {
    report(userText.includes(token), "binds the 2.x " + token + " action");
  }
  const injectedText = topEvent.messages[0].content[0].text;
  await hooks.context(topEvent);
  const occurrences = userText === JSON.stringify(topEvent.messages.filter((m) => m.role === "user")) ? 1 : 2;
  report(occurrences === 1, "context injection is idempotent within a session");

  // A contributor quoting the README heading of this repository writes the
  // router sentinel in plain prose. Sniffing for it cancels the router for the
  // whole session, silently, so the dedupe keys on the opening of the injected
  // block instead — text a user does not type by accident.
  for (const [label, content] of [
    ["string", "please update the # SDLC skills section of the README"],
    ["parts", [{ type: "text", text: "please update the # SDLC skills section of the README" }]],
  ]) {
    const quoted = { sessionID: "quote-" + label, system: [], messages: [{ role: "user", content }], tools: {} };
    await hooks.context(quoted);
    report(JSON.stringify(quoted.messages).includes("<EXTREMELY_IMPORTANT>"),
      "injects when the first user message quotes the sentinel (" + label + " content)");
  }
  const dupParts = { sessionID: "dup-parts", system: [], messages: [{ role: "user", content: [{ type: "text", text: injectedText }] }], tools: {} };
  await hooks.context(dupParts);
  report(dupParts.messages[0].content.length === 1,
    "does not re-inject a message that already carries the block (parts content)", String(dupParts.messages[0].content.length));
  const dupString = { sessionID: "dup-string", system: [], messages: [{ role: "user", content: injectedText }], tools: {} };
  await hooks.context(dupString);
  report(dupString.messages[0].content === injectedText,
    "does not re-inject a message that already carries the block (string content)");

  // Content the plugin cannot reach into must be reported, not passed over.
  const oddEvent = { sessionID: "odd", system: [], messages: [{ role: "user", content: { blocks: [] } }], tools: {} };
  await hooks.context(oddEvent);
  report(drain().length === 1, "unreachable message content logs one sdlc-skills: line");

  const childEvent = { sessionID: "child", system: [], messages: [{ role: "user", content: [{ type: "text", text: "hello" }] }], tools: {} };
  await hooks.context(childEvent);
  report(!JSON.stringify(childEvent.messages).includes("EXTREMELY_IMPORTANT"), "does not inject into a child session");

  const empty = { sessionID: "top2", system: [], messages: [], tools: {} };
  await hooks.context(empty);
  report(empty.messages.some((m) => m.role === "user" && JSON.stringify(m).includes("EXTREMELY_IMPORTANT")), "appends a user message when the session has none");

  // A swallowed throw satisfies every negative assertion above, so the happy
  // path has to prove nothing was swallowed.
  report(drain().length === 0, "the happy path logs no sdlc-skills: diagnostic");
} catch (err) {
  console.log("bad 2.x setup threw instead of registering (" + (err && err.message) + ")");
}

// A rejected payload must skip that one skill, not disable the plugin.
try {
  const { added, ctx } = makeCtx({ reject: (s) => s.id === "yagni" });
  await def.setup(ctx);
  report(added.length > 0 && !added.some((s) => s.id === "yagni"), "a rejected draft.add payload skips one skill without throwing", String(added.length));
  report(drain().length === 1, "a rejected draft.add payload logs one sdlc-skills: line");
} catch (err) {
  console.log("bad a rejected draft.add payload escaped the callback (" + (err && err.message) + ")");
}

// A host surface that throws must leave the plugin inert, not the session dead,
// and a failing skill transform must not cost the router its context hook.
for (const opt of ["transformThrows", "hookThrows"]) {
  const { hooks, ctx } = makeCtx({ [opt]: true });
  try {
    await def.setup(ctx);
    report(true, "setup returns without throwing when " + opt);
    if (opt === "transformThrows") {
      report(typeof hooks.context === "function", "a failing skill transform still leaves the context hook registered");
    }
  } catch (err) {
    report(false, "setup returns without throwing when " + opt, err && err.message);
  }
  report(drain().length === 1, "a failing " + opt + " logs one sdlc-skills: line");
}

// The parent lookup fails open: an unanswerable lookup must not silence the
// router, and must not pass in silence either.
try {
  const { hooks, ctx } = makeCtx({ getThrows: true });
  await def.setup(ctx);
  drain();
  const ev = { sessionID: "lookup-fails", system: [], messages: [{ role: "user", content: "hello" }], tools: {} };
  await hooks.context(ev);
  report(JSON.stringify(ev.messages).includes("<EXTREMELY_IMPORTANT>"), "a failing session lookup fails open and still injects");
  report(drain().length === 1, "a failing session lookup logs one sdlc-skills: line");
} catch (err) {
  report(false, "a failing session lookup fails open and still injects", err && err.message);
}

// The 1.x stray case at the end of this file has a 2.x twin: no skills tree
// beside the plugin. Nothing registers, nothing is injected, and the reason is
// on the record rather than inferred from an empty result.
try {
  const strayMod = await import(new URL("file://" + process.env.STRAY2 + "/.opencode/plugins/sdlc-skills.js").href);
  const { added, hooks, ctx } = makeCtx();
  drain();
  await strayMod.default.setup(ctx);
  report(added.length === 0, "no skills tree registers no skill", String(added.length));
  report(drain().some((l) => l.includes(process.env.STRAY2 + "/skills")), "a missing skills tree is logged by path");
  const ev = { sessionID: "stray-2x", system: [], messages: [{ role: "user", content: "hello" }], tools: {} };
  const before = JSON.stringify(ev.messages);
  await hooks.context(ev);
  report(JSON.stringify(ev.messages) === before, "no skills tree leaves the messages untouched");
  report(drain().length === 1, "a router that cannot be read logs one sdlc-skills: line");
} catch (err) {
  report(false, "a 2.x plugin with no skills tree stays inert without throwing", err && err.message);
}

// A skill file the adapter cannot read is skipped. Which one, and why, has to
// be on the record: a silently shorter catalogue looks exactly like a correct
// one from the harness side.
try {
  const badMod = await import(new URL("file://" + process.env.STRAY3 + "/.opencode/plugins/sdlc-skills.js").href);
  const { added, ctx } = makeCtx();
  drain();
  await badMod.default.setup(ctx);
  report(added.length === 0, "an unreadable skill is skipped, not guessed at", String(added.length));
  const lines = drain();
  const named = ["no-frontmatter", "no-name", "empty-body"].filter((n) => lines.some((l) => l.includes(n + "/SKILL.md")));
  report(named.length === 3, "every skipped skill file is logged by path", named.join(",") || "none");
} catch (err) {
  report(false, "an unreadable skills tree stays inert without throwing", err && err.message);
}

// 1.x also calls setup, with a context that has none of the 2.x surface.
for (const [label, ctx] of [["empty", {}], ["1.x-shaped", { client: {}, $: () => {}, directory: ".", worktree: "." }]]) {
  try {
    await def.setup(ctx);
    report(true, "setup returns without throwing on a " + label + " ctx");
  } catch (err) {
    report(false, "setup returns without throwing on a " + label + " ctx", err && err.message);
  }
}

// 1.x discovery, emulated: it scans the module surface for functions and calls
// each one as a hook factory. That is the entry point this change altered, and
// no 1.x binary is available to observe it, so every function the package
// entry exposes must survive being called that way and hand back a hook set.
const entry = await import(new URL("file://" + process.cwd() + "/index.js").href);
const oneX = { client: {}, $: () => {}, directory: ".", worktree: "." };
for (const [name, value] of Object.entries(entry)) {
  if (typeof value !== "function") continue;
  try {
    const hooks = await value(oneX);
    report(!!hooks && typeof hooks === "object", "index.js export `" + name + "` returns a hook object to a 1.x-shaped scan", typeof hooks);
  } catch (err) {
    report(false, "index.js export `" + name + "` returns a hook object to a 1.x-shaped scan", err && err.message);
  }
}
console.error = realError;
' >"$probe/report2" 2>"$probe/err2" || { bad "2.x node probe crashed: $(head -c 300 "$probe/err2")"; }

lines2=0
while IFS= read -r line; do
  case "$line" in
    ok\ *) ok "${line#ok }" ; lines2=$((lines2+1)) ;;
    bad\ *) bad "${line#bad }"; lines2=$((lines2+1)) ;;
  esac
done <"$probe/report2"
[ "$lines2" -eq 0 ] && bad "2.x node probe produced no results: $(head -c 300 "$probe/err2")"

echo "--- fails loudly rather than injecting nothing"
stray="$(mktemp -d)"
cp "$PLUGIN" "$stray/stray-plugin.js"
if node --input-type=module -e "
import('file://$stray/stray-plugin.js').then(async (m) => {
  const hooks = await (m.sdlcSkillsPlugin ?? m.default)({}, undefined);
  await hooks['experimental.chat.system.transform']({}, { system: [] });
  console.log('injected without a router');
}).catch((err) => { console.error('refused: ' + (err && err.message)); process.exit(1); }
" >/dev/null 2>&1; then
  bad "injects router text with no skills tree beside the plugin"
else
  ok "refuses to inject when the router file cannot be found"
fi
rm -rf "$stray"

echo "--- error message includes system error code and actual path"
stray_err="$(mktemp -d)"
cp "$PLUGIN" "$stray_err/stray-plugin.js"
error_output=$(node --input-type=module -e "
import('file://$stray_err/stray-plugin.js').then(async (m) => {
  const hooks = await (m.sdlcSkillsPlugin ?? m.default)({}, undefined);
  await hooks['experimental.chat.system.transform']({}, { system: [] });
}).catch((err) => { console.error(err && err.message); process.exit(1); });
" 2>&1)
has_error_code=false
has_actual_path=false
if echo "$error_output" | grep -q 'ENOENT'; then
  has_error_code=true
fi
# Verify the message contains "cannot read router at" followed by a filesystem path
# (starting with /) before the colon that separates path from error reason
if echo "$error_output" | grep -qE 'cannot read router at /[^:]*:'; then
  has_actual_path=true
fi
if [ "$has_error_code" = true ] && [ "$has_actual_path" = true ]; then
  ok "error message contains both actual path and system error code"
else
  bad "error message missing content — has_error_code=$has_error_code has_actual_path=$has_actual_path: $error_output"
fi
rm -rf "$stray_err"

echo "---"
[ "$fails" -eq 0 ] && { echo "opencode plugin offline tests: PASS"; exit 0; }
echo "opencode plugin offline tests: FAIL"; exit 1
