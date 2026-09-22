// pi extension. Registers the canonical skills directory with pi's own
// resource discovery and appends the `using-sdlc-skills` router body to the
// system prompt once per turn, re-appending after compaction. This is pi's
// binding of the same router `.opencode/plugins/sdlc-skills.js` carries for
// OpenCode: same source file, same frontmatter strip, its own envelope — see
// AGENTS.md, New harness support.
import { readFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const extensionDir = dirname(fileURLToPath(import.meta.url));
const pluginRoot = resolve(extensionDir, "..", "..");
const skillsDir = resolve(pluginRoot, "skills");
const routerPath = resolve(skillsDir, "common/using-sdlc-skills/SKILL.md");

const PREAMBLE =
  "The `using-sdlc-skills` entry skill is loaded below — apply it before any\n" +
  "answer, question, exploration, or tool call that begins the work. Skills\n" +
  "load through the real skill-loading action; reading this text is not\n" +
  "invoking one.\n\n";

// Read fresh every call rather than cached at import time, so a router edit
// mid-process is picked up on the next turn or compaction.
function loadRouterBody() {
  let raw;
  try {
    raw = readFileSync(routerPath, "utf8");
  } catch (err) {
    throw new Error(
      "sdlc-skills: could not read router at " + routerPath + ": " + err.message,
      { cause: err }
    );
  }
  const body = raw.replace(/^---\n[\s\S]*?\n---\n/, "");
  if (!body.trim()) {
    throw new Error("sdlc-skills: router body is empty at " + routerPath);
  }
  return body;
}

// Idempotent on the router body itself: a text already carrying it is left
// alone rather than growing a duplicate on every turn or compaction.
function appendRouterOnce(current) {
  const body = loadRouterBody();
  if (current.includes(body)) return current;
  const block = PREAMBLE + body;
  return current ? current + "\n\n" + block : block;
}

export default function (pi) {
  pi.on("resources_discover", () => {
    return { skillPaths: [skillsDir] };
  });

  pi.on("before_agent_start", (event) => {
    const options = event.systemPromptOptions;
    options.appendSystemPrompt = appendRouterOnce(options.appendSystemPrompt ?? "");
  });

  // Compaction replaces the transcript with a summary; nothing injected at
  // session start survives it, so the router is carried into the saved
  // compaction entry's own summary the same way.
  pi.on("session_compact", (event) => {
    const entry = event && event.compactionEntry;
    if (!entry || typeof entry.summary !== "string") {
      throw new Error(
        "sdlc-skills: session_compact carried no summary string; router not re-injected"
      );
    }
    entry.summary = appendRouterOnce(entry.summary);
  });
}
