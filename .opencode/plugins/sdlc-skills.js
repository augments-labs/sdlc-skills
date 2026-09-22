import { existsSync, readdirSync, readFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const pluginRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const skillsDir = resolve(pluginRoot, "skills");
const routerPath = resolve(skillsDir, "common/using-sdlc-skills/SKILL.md");
const bindingsDoc = resolve(pluginRoot, ".opencode/references/opencode-tools.md");

const ROUTER_SENTINEL = "# SDLC skills";
const BINDINGS_SENTINEL = "# SDLC skills tool bindings (OpenCode)";
// On 1.x the sentinel is matched against `output.system`, which only the
// harness and its plugins write. On 2.x the same match would run against user
// prose, where `# SDLC skills` is an ordinary thing to type — a contributor
// asking about this repository's README heading would cancel the router for
// the whole session, silently. The 2.x dedupe therefore keys on the injected
// block's own opening.
const INJECTED_OPENING = "<EXTREMELY_IMPORTANT>\n" + ROUTER_SENTINEL;

function loadRouter() {
  let raw;
  try {
    raw = readFileSync(routerPath, "utf8");
  } catch {
    throw new Error("sdlc-skills: router not found at " + routerPath);
  }
  const body = raw.replace(/^---\n[\s\S]*?\n---\n/, "");
  if (!body.trim()) {
    throw new Error("sdlc-skills: router body is empty at " + routerPath);
  }
  return (
    "<EXTREMELY_IMPORTANT>\n" +
    ROUTER_SENTINEL +
    "\n\nThe full `using-sdlc-skills` entry skill follows. It is ALREADY LOADED — apply\n" +
    "it directly and do not spend a tool call re-invoking it. Every skill in the\n" +
    "catalogue is listed with its trigger in your skill tool; invoke skills through\n" +
    "the real skill-loading action, since reading a skill file is not invoking it.\n" +
    "Each loaded skill's own preconditions, skips, and handoffs are the routing\n" +
    "authority — follow them.\n\nApply this before any answer or action, including questions and exploration,\n" +
    "and before any tool that begins the work.\n\n" +
    body +
    "\n</EXTREMELY_IMPORTANT>"
  );
}

// The tool names differ by OpenCode generation, so the bindings text does too.
// `.opencode/references/opencode-tools.md` carries both tables in full; this is
// the short form injected into the session.
function loadBindings(generation) {
  const common =
    BINDINGS_SENTINEL +
    "\n\nSkills load through the `skill` tool by catalogue name; reading a skill file\n" +
    "with `read` is not invoking it.\n";
  const tail =
    "State the capability tier (`small | medium | large`) in the prompt;\n" +
    "never a vendor model name.\n" +
    "Dispatch, tier, and role bindings in full: " +
    bindingsDoc +
    "\nAn uncallable action is not dispatched: name the action attempted and what\n" +
    "would make it callable, ask the user once, and record the answer as the written\n" +
    "assignment.";

  if (generation === "2.x") {
    return (
      common +
      "A decision put to the user goes through the `question` tool, one question at a\n" +
      "time; rendering options as plain text never closes a decision.\n" +
      "This generation exposes no todo tool, so multi-step work is tracked in the\n" +
      "task's own written artifact — a plan or report file — not in harness state.\n" +
      "Delegated implementation, review, exploration, or planning goes through the\n" +
      "`subagent` tool, where `agent: \"general\"` carries implementation and\n" +
      "`agent: \"explore\"` carries read-only review and exploration and cannot\n" +
      "write. Shell commands run\n" +
      "through the `shell` tool. The filled brief is the specification; a review role\n" +
      "that lands on an agent able to write forbids every edit, commit, and push in\n" +
      "the brief, and the coordinator inspects the workspace before accepting the\n" +
      "report.\n" +
      tail
    );
  }
  return (
    common +
    "A decision put to the user goes through the `question` tool, one question at a\n" +
    "time; rendering options as plain text never closes a decision.\n" +
    "Multi-step work is tracked with the `todowrite` tool.\n" +
    "Delegated implementation, review, exploration, or planning goes through the\n" +
    "`Task` tool to a subagent: `general` carries implementation, `explore` carries\n" +
    "read-only review and exploration. The filled brief is the specification; a review\n" +
    "role that lands on an agent able to write forbids every edit, commit, and push\n" +
    "in the brief, and the coordinator inspects the workspace before accepting the\n" +
    "report. " +
    tail
  );
}

// --- OpenCode 1.x: the hook factory ----------------------------------------
//
// 1.x discovers plugins by scanning the module's named exports for functions,
// so this is exported by name as well as being `default.server`.
export const sdlcSkillsPlugin = async () => {
  return {
    config: async (cfg) => {
      if (!existsSync(routerPath)) {
        throw new Error("sdlc-skills: router not found at " + routerPath);
      }
      // Defensive, not a live path: 2.0.13 calls `setup` and never this
      // factory. But `skills` is an array there, with no `paths` under it, so
      // a host that did call the factory with a 2.x-shaped config would have
      // it corrupted. Leave that shape alone.
      if (Array.isArray(cfg.skills)) return;
      cfg.skills = cfg.skills ?? {};
      cfg.skills.paths = cfg.skills.paths ?? [];
      if (!cfg.skills.paths.includes(skillsDir)) {
        cfg.skills.paths.push(skillsDir);
      }
    },
    "experimental.chat.system.transform": async (_input, output) => {
      const present = (output.system ?? []).join("\n");
      if (!present.includes(ROUTER_SENTINEL)) {
        output.system.push(loadRouter());
      }
      if (!present.includes(BINDINGS_SENTINEL)) {
        output.system.push(loadBindings("1.x"));
      }
    },
    "experimental.session.compacting": async (_input, output) => {
      output.context.push(loadRouter());
      output.context.push(loadBindings("1.x"));
    },
  };
};

// --- OpenCode 2.x: setup(ctx) ----------------------------------------------

// The tree is `skills/<phase>/<name>/SKILL.md`, not flat.
function findSkillFiles(dir) {
  let entries;
  try {
    entries = readdirSync(dir, { withFileTypes: true });
  } catch (err) {
    // An empty catalogue looks exactly like a correct one from the harness
    // side, so the directory that could not be read is named.
    console.error("sdlc-skills: cannot read " + dir + " (" + (err && err.message) + ")");
    return [];
  }
  const found = [];
  for (const entry of entries) {
    const full = resolve(dir, entry.name);
    if (entry.isDirectory()) found.push(...findSkillFiles(full));
    else if (entry.name === "SKILL.md") found.push(full);
  }
  return found.sort();
}

// The shipped frontmatter is exactly `name:` and `description:`, each on one
// line, so a full YAML parser would buy nothing a dependency-free adapter can
// spend. A file that does not match is skipped rather than guessed at.
function readSkill(path) {
  const skip = (why) => {
    console.error("sdlc-skills: skipped " + path + " (" + why + ")");
    return undefined;
  };
  let raw;
  try {
    raw = readFileSync(path, "utf8");
  } catch (err) {
    return skip(err && err.message);
  }
  const front = raw.match(/^---\n([\s\S]*?)\n---\n/);
  if (!front) return skip("no frontmatter block");
  const field = (key) => {
    const hit = front[1].match(new RegExp("^" + key + ":\\s*(.+?)\\s*$", "m"));
    if (!hit) return undefined;
    const value = hit[1].trim();
    return value.replace(/^"([\s\S]*)"$/, "$1").replace(/^'([\s\S]*)'$/, "$1");
  };
  const name = field("name");
  const description = field("description");
  const content = raw.slice(front[0].length);
  if (!name) return skip("frontmatter has no name");
  if (!description) return skip("frontmatter has no description");
  if (!content.trim()) return skip("body is empty");
  return { id: name, name, description, path, content };
}

// A session's parent lookup is cached so the context hook does not re-ask on
// every turn. Bounded, because a long-lived server sees unboundedly many
// sessions.
const SESSION_CACHE_LIMIT = 256;
const childSessions = new Map();

async function isChildSession(ctx, sessionID) {
  if (childSessions.has(sessionID)) return childSessions.get(sessionID);
  let child = false;
  try {
    const record = await ctx.session.get({ sessionID });
    child = !!(record && record.parentID);
  } catch (err) {
    // Fail open: a lookup that cannot answer must not silence the router. It
    // must not pass in silence either — this is the branch that would inject
    // the router into every child session.
    console.error("sdlc-skills: session lookup failed for " + sessionID + " (" + (err && err.message) + ")");
    child = false;
  }
  if (childSessions.size >= SESSION_CACHE_LIMIT) {
    childSessions.delete(childSessions.keys().next().value);
  }
  childSessions.set(sessionID, child);
  return child;
}

// 2.x hands the context hook the messages it is about to send. The router goes
// into the first user message: this generation's system prompt is not a plugin
// surface, and a system message is not where the router belongs here.
function injectIntoMessages(messages, text) {
  const first = messages.find((m) => m && m.role === "user");
  if (!first) {
    messages.push({ role: "user", content: [{ type: "text", text }] });
    return;
  }
  if (typeof first.content === "string") {
    if (first.content.includes(INJECTED_OPENING)) return;
    first.content = text + "\n\n" + first.content;
    return;
  }
  if (!Array.isArray(first.content)) {
    console.error("sdlc-skills: first user message content is " + typeof first.content + ", not text — router not injected");
    return;
  }
  if (first.content.some((p) => p && typeof p.text === "string" && p.text.includes(INJECTED_OPENING))) return;
  first.content.unshift({ type: "text", text });
}

// Every callback below is wrapped: a throw escaping one of these takes the
// whole plugin — and, for the context hook, the session running it — down.
export const setup = async (ctx) => {
  // 1.x calls `setup` too, with a context that carries none of this surface —
  // and a 1.x named-export scan calls it as a hook factory, so the empty hook
  // set it gets back has to be iterable rather than `undefined`.
  if (typeof ctx?.skill?.transform !== "function" || typeof ctx?.session?.hook !== "function") return {};

  const skills = findSkillFiles(skillsDir)
    .map(readSkill)
    .filter((s) => s !== undefined);

  try {
    await ctx.skill.transform((draft) => {
      for (const skill of skills) {
        try {
          draft.add(skill);
        } catch (err) {
          console.error("sdlc-skills: skipped " + skill.path + " (" + (err && err.message) + ")");
        }
      }
    });
  } catch (err) {
    console.error("sdlc-skills: skill registration failed (" + (err && err.message) + ")");
  }

  try {
    await ctx.session.hook("context", async (event) => {
      try {
        if (!event || !Array.isArray(event.messages)) return;
        if (await isChildSession(ctx, event.sessionID)) return;
        injectIntoMessages(event.messages, loadRouter() + "\n\n" + loadBindings("2.x"));
      } catch (err) {
        console.error("sdlc-skills: context injection skipped (" + (err && err.message) + ")");
      }
    });
  } catch (err) {
    console.error("sdlc-skills: context hook registration failed (" + (err && err.message) + ")");
  }
};

export default { id: "sdlc-skills", server: sdlcSkillsPlugin, setup };
