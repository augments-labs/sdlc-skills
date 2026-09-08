# SDLC skills

A collection of rigorous, phase-organized and context-routed SDLC skills that
tether autonomous agents to real engineering gates.

SDLC skills is a cross-platform library of **opt-in engineering skills** for coding agents, organized by the phases of the software development life cycle. It gives agents real engineering discipline while staying lean and leaving *you* in control of the process.

## Philosophy

- **Toolbox, not pipeline.** The skills are tools you reach for when they apply — the phase folders are a map for discovery, not a sequence you must walk in order. What is *not* optional is reaching for the one that fits: skipping a skill that applies is the mistake the library exists to prevent. You own the path; the routing keeps you from walking past the tool you needed.
- **Earn every line.** A skill loads into context each time it fires, so it carries only what changes behavior; templates, examples, and rationale live in sibling files loaded on demand. Low token cost is a consequence of that discipline — not a goal that overrides correctness, so discipline skills keep what they need to hold the line under pressure.
- **Any harness, any model.** Skills refer to capability *tiers* (small / medium / large), never vendor model names, and assume no specific harness's tooling — so the same skill behaves the same wherever it is loaded. Claude Code, Codex CLI, and Kimi Code CLI all have adapter tests; behavioral pressure records are still added per harness.
- **Alongside intelligence, not in its way.** Executable correctness claims leave
  the model through executable gates; judgment and authority leave through
  explicit revision-bound decisions or controlled rubrics. A skill never turns
  confidence into its own verdict. Otherwise it defers to contextual judgment,
  and every skill states when to *skip* it so ceremony scales down.

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
| common | `writing-skills` | The lean format every skill follows, and how to prove a skill actually works |
| planning | `define-goals` | At project kickoff — pin the objective and measurable success criteria into the project brief |
| planning | `scope-it` | Draw the boundary — what's in, what's explicitly out, the MVP cut |
| planning | `feasibility-check` | Assess whole-initiative achievability and give the accountable owner an evidence-bound go / no-go / go-if recommendation |
| analysis | `spec-it` | Turn a goal or feature into a requirements spec — testable requirements, acceptance criteria, edge cases |
| common | `interview-me` | Resolve only material unknowns the codebase cannot answer, and require direct answers for decisions rather than inferring approval |
| common | `prototyping` | Answer one uncertain design or feasibility question with a throwaway spike, then delete it |
| common | `zoom-out` | Before changing unfamiliar code, go up a layer and map the relevant modules and their callers in the project's own vocabulary |
| common | `handoff` | Write a durable, resumable handoff when a session ends — goal, state, decisions, gotchas, and the one concrete next step |
| common | `using-task-branches` | Establish an owned branch/workspace, proven base and baseline, and isolated runtime state before edits, then checkpoint locally as the work goes; integration and cleanup remain separate decisions |
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
| testing | `verifying-completion` | Bind a real check and its raw output to the exact state, artifact, environment, platform, and build mode before making a claim |
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
| maintenance | `complexity-audit` | Audit a bounded existing module or codebase for accidental complexity through read-only, evidence-bound keep, simplify, remove, decision, and investigate findings |
| maintenance | `refactor-architecture` | Improve measured structural friction under a falsified preservation gate and reversible, reviewable slices |

Every SDLC phase ships at least one skill, alongside the cross-cutting `common/` tools.

## Status

Early and growing. All seven SDLC phases — planning, analysis, design,
implementation, testing, deployment, and maintenance — now ship at least one
working skill, alongside the nine `common` skills: orientation, skill-authoring,
scope discipline, and the cross-cutting tools (interviewing, prototyping,
zoom-out, handoff, task branches, and parallel dispatch).

Three harnesses have adapters:

| Harness | Adapter | Routing support |
| --- | --- | --- |
| Claude Code | `.claude-plugin/` | `SessionStart` router injection |
| Codex CLI | `plugins/sdlc-skills/`, listed in `.agents/plugins/marketplace.json` | bundled `SessionStart` router |
| Kimi Code | `.kimi-plugin/` | session-start router and tool bindings |

`AGENTS.md` and `GEMINI.md` symlink to `CLAUDE.md`, so a harness that reads its
own instructions file gets the same guidance from one source.

Because the skills are portable Markdown invoked by name, other harnesses can
adopt them — each proven by its own tests when added; see
[`docs/harness-support.md`](docs/harness-support.md).

Install in Claude Code with `/plugin marketplace add augments-labs/sdlc-skills` then `/plugin install sdlc-skills@augments-labs`. For local Codex development, register this checkout as a marketplace with `codex plugin marketplace add /path/to/sdlc-skills`, then install `sdlc-skills@augments-labs-dev`. Install in Kimi Code with `/plugins install https://github.com/augments-labs/sdlc-skills` (or the `/plugins` manager, Custom tab), then `/reload`.

## Proactive Skill Use

A coding agent treats an installed skill library as available-but-optional and walks past it unless you name a skill. So SDLC skills pairs each adapter with the strongest honest routing support that harness can prove.

Every adapter injects the **full `using-sdlc-skills` entry-skill body** as session context — Claude Code and Codex through a `SessionStart` hook, Kimi Code through `sessionStart.skill` — re-applied only where the harness reports context was actually lost: start, resume, clear. No adapter re-injects after compaction, because compaction carries loaded context forward and re-injection would be redundant cost.

It used to inject a ~90-token *pointer* asking the agent to invoke the router before working. That is one discretionary tool call, and a discretionary call can be skipped — it was skipped on this very repository, on exactly the kind of task the router governs. Injecting the body costs ~1,500 approx tokens per context epoch and removes the skippable step: the routing rules are simply resident. The text is read from the canonical skill at runtime, never copied, so editing the skill cannot silently stop shipping it.

Session start is the only activation mechanism. No adapter registers
`PreToolUse`, `PostToolUse`, `Stop`, or other tool, prompt, or turn-end hooks.
The resident entry skill requires relevant skills to load before any response
or action, including preliminary questions and file checks. Catalogue names and
descriptions identify candidates; they do not replace the loaded instructions.
`scripts/sh/validate-skills.sh` checks this activation contract across adapters.

Routing remains an instruction to the agent. Project tests, review, CI, and
release gates establish whether the resulting artifacts can advance.

On Codex, SDLC skills ships a plugin adapter and local marketplace metadata, and the plugin bundles its own hooks (`plugins/sdlc-skills/hooks/hooks.json`) that run the same injector on `SessionStart`; the injector itself drops compact-source invocations, since Codex's hook cannot filter by source. The skills install through Codex, durable repo guidance still comes through `AGENTS.md`, and the Codex harness test observes activation by watching the agent read the installed `SKILL.md` file from the plugin cache.

On Kimi Code, SDLC skills ships a plugin manifest (`.kimi-plugin/plugin.json`)
whose `sessionStart.skill` loads the `using-sdlc-skills` router into every new
and resumed session, and whose `skillInstructions` bind the skills' tool language
to Kimi's real tools — including the dispatch action — whenever a plugin skill
loads. The manifest points at the canonical phase directories directly, with no
mirror.

It registers no `PostCompact` hook: compaction carries loaded context forward,
so re-applying the entry skill there would be redundant — see
[`docs/harness-support.md`](docs/harness-support.md).

The routing is **non-negotiable by default, not a gentle suggestion** where a
harness supports it. The discipline behind it — the rationalizations named as
signals to check rather than skip, the red-flags, the procedure — lives in the
`using-sdlc-skills` skill, and that is exactly the text the adapters inject;
`scripts/sh/session-start.sh` reads it from the skill rather than restating it.

Changing that injector or its activation policy is behavior-shaping work and must
be re-proved. See [`docs/activation.md`](docs/activation.md)
for how routing (firm persuasion) and enforcement (deterministic gates) fit
together. Harness hooks are adapter-specific; the skills themselves stay portable
Markdown.

## Acknowledgements

This library draws on prior art and ongoing work from across the
multi-agent ecosystem:

- [**Superpowers**](https://github.com/obra/superpowers) —
  A complete software development methodology for coding agents.
- [**Matt Pocock skills**](https://github.com/mattpocock/skills) —
  Agent skills for real engineering.
- [**Ponytail**](https://github.com/DietrichGebert/ponytail) —
  The "laziest senior dev" discipline that inspired the `yagni` skill.
