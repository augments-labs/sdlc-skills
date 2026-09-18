import { existsSync, readFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const pluginRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const skillsDir = resolve(pluginRoot, "skills");
const routerPath = resolve(skillsDir, "common/using-sdlc-skills/SKILL.md");
const bindingsDoc = resolve(pluginRoot, ".opencode/references/opencode-tools.md");

const ROUTER_SENTINEL = "# SDLC skills";
const BINDINGS_SENTINEL = "# SDLC skills tool bindings (OpenCode)";

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

function loadBindings() {
  return (
    BINDINGS_SENTINEL +
    "\n\nSkills load through the `skill` tool by catalogue name; reading a skill file\n" +
    "with `read` is not invoking it.\n" +
    "A decision put to the user goes through the `question` tool, one question at a\n" +
    "time; rendering options as plain text never closes a decision.\n" +
    "Multi-step work is tracked with the `todowrite` tool.\n" +
    "Delegated implementation, review, exploration, or planning goes through the\n" +
    "`Task` tool to a subagent: `general` carries implementation, `explore` carries\n" +
    "read-only review and exploration. The filled brief is the specification; a review\n" +
    "role that lands on an agent able to write forbids every edit, commit, and push\n" +
    "in the brief, and the coordinator inspects the workspace before accepting the\n" +
    "report. State the capability tier (`small | medium | large`) in the prompt;\n" +
    "never a vendor model name.\n" +
    "Dispatch, tier, and role bindings in full: " +
    bindingsDoc +
    "\nAn uncallable action is not dispatched: name the action attempted and what\n" +
    "would make it callable, ask the user once, and record the answer as the written\n" +
    "assignment."
  );
}

export default async () => {
  return {
    config: async (cfg) => {
      if (!existsSync(routerPath)) {
        throw new Error("sdlc-skills: router not found at " + routerPath);
      }
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
        output.system.push(loadBindings());
      }
    },
    "experimental.session.compacting": async (_input, output) => {
      output.context.push(loadRouter());
      output.context.push(loadBindings());
    },
  };
};
