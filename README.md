# SDLC skills

SDLC skills is a cross-platform library of engineering skills for coding agents,
organized by the phases of the software development life cycle. Skills guide the
work; external checks and accountable decisions govern its results.

## Philosophy

- **Toolbox, not pipeline.** Phase folders help discovery. Use the skills that
  apply to the current task; their preconditions and handoffs determine the path.
- **Earn every line.** Keep instructions concise and load supporting files when
  needed. Reuse a current skill body already in context. Discipline skills keep
  the pressure controls their behavioral evidence supports.
- **Portable instructions.** Skills use capability tiers and portable actions.
  Adapters bind them to each harness; discovery and behavior still need evidence
  from that environment.
- **Claims need evidence.** Executable checks support correctness claims;
  revision-bound decisions or controlled rubrics govern judgment and authority.
  Scale effort through each skill's own rules, preserving required gates.

Every skill here is a standard **Agent Skills** skill — a directory holding a
`SKILL.md` with YAML frontmatter, loadable by any compliant agent, needing no
bespoke loader or house file format. Where a house rule in this repository
conflicts with the standard, the standard wins and the house rule is the bug.
What the standard requires, where the gate enforces it, and where this library
is deliberately stricter is recorded in
[`docs/agent-skills-conformance.md`](docs/agent-skills-conformance.md).

The deeper rationale—why claims leave a non-deterministic generator through
external evidence or decision gates—is in
[`docs/philosophy.md`](docs/philosophy.md); when a phase is one
skill versus several is in
[`docs/skill-granularity.md`](docs/skill-granularity.md).

## The SDLC phases

Skills live under `skills/<phase>/<name>/`. The folders are unnumbered (they sort alphabetically on disk); the canonical order is:

1. **planning** — feasibility, scope, and goals → a project brief
2. **analysis** — the detailed requirements: what the software must do → a spec
3. **design** — architecture, interfaces, and the build plan
4. **implementation** — build it
5. **testing** — does it work, and is it good?
6. **deployment** — ship it
7. **maintenance** — debug and evolve after ship

Plus **common** — phase-agnostic and meta skills (authoring skills, communication, handoff).

A skill is invoked as `sdlc-skills:<name>` regardless of which phase folder holds it — the phase is organization for humans, not part of the address.

## Available skills

| Phase | Skill | What it does |
| ----- | ----- | ------------ |
| common | `using-sdlc-skills` | Route from the current task state and real preconditions; high-risk transformations cannot bypass their migration and assurance entry gates |
| common | `writing-skills` | Author concise skills and evaluate their behavior |
| common | `viewing-artifacts` | View the state and consistency of briefs, specs, designs, plans, and execution in a local artifact viewer |
| planning | `define-goals` | At project kickoff — pin the objective and measurable success criteria into the project brief |
| planning | `scoping` | Draw the boundary — what's in, what's explicitly out, the MVP cut |
| planning | `feasibility-check` | Assess whole-initiative achievability and give the accountable owner an evidence-bound go / no-go / go-if recommendation |
| analysis | `writing-specs` | Turn a goal or feature into a requirements spec — testable requirements, acceptance criteria, edge cases |
| common | `clarifying-intent` | Resolve only material unknowns the codebase cannot answer, and require direct answers for decisions rather than inferring approval |
| common | `prototyping` | Answer one uncertain design or feasibility question with a throwaway spike, then delete it |
| common | `mapping-the-codebase` | Before changing unfamiliar code, go up a layer and map the relevant modules and their callers in the project's own vocabulary |
| common | `handoff` | Write a durable, resumable handoff when a session ends — goal, state, decisions, gotchas, and the one concrete next step |
| common | `using-git-worktrees` | Create an owned, gitignored git worktree on a proven base with a real baseline and isolated runtime state before edits, then checkpoint locally as the work goes; integration and cleanup remain separate decisions |
| common | `dispatching-parallel-agents` | Fan out independent work only with exclusive ownership and isolated state, then inspect raw results and run a combined gate |
| common | `yagni` | Build exactly the accepted scope—neither speculative additions nor incomplete delivery—and preserve inherited correctness, compatibility, recovery, and assurance commitments |
| design | `system-architecture` | Design the target system—traceable components, trust/data paths, failure and recovery behavior, operational views, and justified seams |
| design | `data-model` | Model the domain's concepts, relationships, state transitions, and invariants — stored or not — before the code that manipulates them |
| design | `ui-ux-design` | Design user flows, visual direction, layout, unhappy states, and evidence-backed interface alternatives before implementation |
| design | `coding-standards` | Set the project's conventions and domain vocabulary so all contributors write code like one author |
| design | `architecture-decisions` | Record significant, hard-to-reverse choices as ADRs — options weighed, decision, why the alternatives were rejected |
| design | `migration-strategy` | Define preservation, translation, partition, convergence, cutover, abort, and rollback contracts for high-risk transformations |
| design | `writing-plans` | Convert approved inputs into independently loadable contracts; high-risk plans may build missing gates first but cannot start target phases before entry |
| implementation | `test-driven-development` | Let a failing behavior gate lead new behavior and a deliberately falsified independent green oracle lead preservation work |
| implementation | `executing-plans` | Advance a directly approved plan through evaluator-backed task, shard, phase, and integrated state transitions |
| implementation | `subagent-driven-development` | Run an approved plan's tasks through a cold implementer, an independent task reviewer, and a re-reviewer, each carrying only its filled brief |
| testing | `verification-before-completion` | Bind a real check and its raw output to the exact state, artifact, environment, platform, and build mode before making a claim |
| testing | `requesting-code-review` | Freeze an exact candidate and challenge it with risk-scaled independent review, including separate equivalence and adversarial roles for high-risk transformations |
| testing | `receiving-code-review` | Inventory and verify every revision-bound finding, resolve conflicts by evidence, and re-review any changed candidate |
| testing | `security-audits` | Audit the changed attack surface and trust boundaries with threat-specific gates; a separate fixer cannot self-approve the security verdict |
| testing | `verification-strategy` | Design a project- or initiative-wide risk-to-gate matrix: thresholds, environments, cadence, evidence, ownership, promotion wiring, and failure response |
| testing | `visual-ui-verification` | Drive an integrated GUI or TUI across accepted visual conditions, inspect candidate-bound frames, and return a calibrated evidence-backed verdict |
| deployment | `finishing-a-branch` | Classify the real checkout, finalize only with authorized history changes, verify the integrated result, and make explicit integration and owned-cleanup decisions |
| deployment | `release-readiness` | Judge an immutable artifact set for one named promotion; later stages consume observed canary/soak evidence rather than borrowing readiness from an earlier verdict |
| maintenance | `containing-an-incident` | Stop live user impact with the narrowest reversible lever, prove it stopped from the outside signal, and record the mitigation as reversible debt before diagnosing |
| maintenance | `debugging` | Establish causal root cause through deterministic or quantified probabilistic evidence before changing behavior |
| maintenance | `post-mortem` | Reconstruct the escape path and carry owned corrective controls through falsification, enforcement, rollout, and effectiveness review |
| maintenance | `diagnosing-a-session` | Reconstruct from a session's own transcript what the run actually did, read-only, and report where it went wrong with a transcript line behind every claim |
| maintenance | `complexity-audit` | Audit a bounded existing module or codebase for accidental complexity through read-only, evidence-bound keep, simplify, remove, decision, and investigate findings |
| maintenance | `refactor-architecture` | Improve measured structural friction under a falsified preservation gate and reversible, reviewable slices |

## Installation and support

The catalogue contains 38 skills across all seven phases and `common/`.

Six harnesses have adapters:

| Harness | Adapter | Routing support |
| --- | --- | --- |
| Claude Code | `.claude-plugin/` | `SessionStart` router injection |
| Codex CLI | `plugins/sdlc-skills/`, listed in `.agents/plugins/marketplace.json` | bundled `SessionStart` router |
| Kimi Code | `.kimi-plugin/` | session-start router and tool bindings |
| OpenCode | `.opencode/`, entered through the root `index.js` | 1.x: system-context router injection and tool bindings. 2.x: skill registration plus router injection into the first user message. The install test proves a listed skill inventory on 1.x and a loaded plugin on 2.x |
| Grok Build | reads `.claude-plugin/plugin.json` and `hooks/hooks.json` as installed — no separate manifest | no session-start hook on 1.0.40 reaches the prompt; a `$GROK_HOME/rules/` file nudges `using-sdlc-skills` first as a global rule instead of an injected router body |
| Muse Code | `.muse-plugin/` for a build with plugin support; `scripts/sh/install-muse-skills.sh` installs skill by skill on a build without it | the manifest declares a `SessionStart` hook, but 1.3.0 loads no plugin, so the per-skill route gives discovery only — the router skill is listed and has to be invoked |

`AGENTS.md` is the canonical contributor guide. `GEMINI.md` symlinks to it and
`CLAUDE.md` is a short pointer to it, so a harness that reads its own
instructions file gets the same guidance from one source, even one that
refuses a symlinked instructions file.

Because the skills are portable Markdown invoked by name, other harnesses can
adopt them — each proven by its own tests when added; see
[`docs/harness-support.md`](docs/harness-support.md).

Install in Claude Code with `/plugin marketplace add augments-labs/sdlc-skills` then `/plugin install sdlc-skills@augments-labs`. For local Codex development, register this checkout as a marketplace with `codex plugin marketplace add /path/to/sdlc-skills`, then install `sdlc-skills@augments-labs-dev`. Install in Kimi Code with `/plugins install https://github.com/augments-labs/sdlc-skills` (or the `/plugins` manager, Custom tab), then `/reload`. Install in OpenCode with the same git package spec in `opencode.json` (global or project), then restart — the plugin installs through OpenCode's plugin manager and registers the canonical skills itself. The key differs by generation: `"plugin": ["sdlc-skills@git+https://github.com/augments-labs/sdlc-skills.git"]` on 1.x, `"plugins": ["sdlc-skills@git+https://github.com/augments-labs/sdlc-skills.git"]` on 2.x. A local checkout works too in place of the package spec: name its `.opencode/plugins/sdlc-skills.js` file on 1.x, and the checkout directory itself on 2.x, which refuses a file path and resolves `index.js` inside the directory. If the skills do not show up, run `opencode run --print-logs` on 1.x or `opencode run --standalone --print-logs` on 2.x and look for the line naming the plugin and the entry point it resolved. Install in Grok Build with `grok plugin install /path/to/sdlc-skills --trust` — Grok reads the Claude plugin manifest directly, so nothing extra is added to the checkout. Then add a rules file so the router gets a nudge: create `$GROK_HOME/rules/using-sdlc-skills.md` (default `~/.grok/rules/`) containing one line telling Grok to invoke `using-sdlc-skills` before acting. Grok has no session-start hook that reaches the system prompt on 1.0.40, so this is a standing rule, not an injected router body; `grok inspect` lists the file under Project Instructions once it is in place, which is the confirmation that the nudge is loaded. Install in Muse Code by running `bash scripts/sh/install-muse-skills.sh` from a checkout, which runs `muse skills install <dir> --scope user --force` once per skill and is safe to re-run; `bash scripts/sh/install-muse-skills.sh --remove` takes them back out. What that gets you is discovery: `muse skills list` shows all 37, and because 1.3.0 answers `plugins are not available in this build`, no hook runs and nothing injects the router — invoke `using-sdlc-skills` yourself at the start of a session. A build that does ship plugin support installs `.muse-plugin/plugin.json` instead and gets the same skill list plus the `SessionStart` hook, with no manual invocation.

## Proactive skill use

Each adapter supplies the full `using-sdlc-skills` body through its session-start
mechanism. The router requires applicable skills to load before action;
catalogue names and descriptions identify candidates, while explicit requests
and loaded skill handoffs also direct invocation. Current bodies already in
context can be reused.

This is an instruction to a non-deterministic agent, not enforced invocation.
Project tests, review, CI, and release controls govern whether results advance.
See [`docs/activation.md`](docs/activation.md) for the distinction.

Adapters register no tool, prompt, or turn-end hooks. They supply the router
again after compaction, which replaces the transcript rather than carrying
injected text forward. The current lifecycle policy, its evidence limits, and the packaging
step that keeps the Codex mirror current are documented once in
[`docs/harness-support.md`](docs/harness-support.md).

## Contributing and testing

Read [`AGENTS.md`](AGENTS.md) before changing the library. It defines the PR
requirements, authoring policy, and structural gate. For skill changes, use
`writing-skills` and run the gates. See [`docs/testing.md`](docs/testing.md) for
what each check establishes.

## Acknowledgements

This library draws on prior art and ongoing work from across the
multi-agent ecosystem:

- [**Superpowers**](https://github.com/obra/superpowers) —
  A complete software development methodology for coding agents.
- [**Matt Pocock skills**](https://github.com/mattpocock/skills) —
  Agent skills for real engineering.
- [**Ponytail**](https://github.com/DietrichGebert/ponytail) —
  The "laziest senior dev" discipline that inspired the `yagni` skill.
