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
| planning | `scope-it` | Draw the boundary — what's in, what's explicitly out, the MVP cut |
| planning | `feasibility-check` | Assess whole-initiative achievability and give the accountable owner an evidence-bound go / no-go / go-if recommendation |
| analysis | `spec-it` | Turn a goal or feature into a requirements spec — testable requirements, acceptance criteria, edge cases |
| common | `interview-me` | Resolve only material unknowns the codebase cannot answer, and require direct answers for decisions rather than inferring approval |
| common | `prototyping` | Answer one uncertain design or feasibility question with a throwaway spike, then delete it |
| common | `zoom-out` | Before changing unfamiliar code, go up a layer and map the relevant modules and their callers in the project's own vocabulary |
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
| maintenance | `complexity-audit` | Audit a bounded existing module or codebase for accidental complexity through read-only, evidence-bound keep, simplify, remove, decision, and investigate findings |
| maintenance | `refactor-architecture` | Improve measured structural friction under a falsified preservation gate and reversible, reviewable slices |

## Installation and support

The catalogue contains 36 skills across all seven phases and `common/`.

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

## Proactive skill use

Each adapter supplies the full `using-sdlc-skills` body through its session-start
mechanism. The router requires applicable skills to load before action;
catalogue names and descriptions identify candidates, while explicit requests
and loaded skill handoffs also direct invocation. Current bodies already in
context can be reused.

This is an instruction to a non-deterministic agent, not enforced invocation.
Project tests, review, CI, and release controls govern whether results advance.
See [`docs/activation.md`](docs/activation.md) for the distinction.

Adapters register no tool, prompt, or turn-end hooks and do not re-inject after
compaction. The current lifecycle policy, its evidence limits, and the packaging
step that keeps the Codex mirror current are documented once in
[`docs/harness-support.md`](docs/harness-support.md).

## Contributing and testing

Read [`CLAUDE.md`](CLAUDE.md) before changing the library. It defines the PR
requirements, authoring policy, and structural gate. For skill changes, use
`writing-skills` and run only the behavioral scenarios relevant to the change.
Report passes, failures, and inconclusive runs: a passing sample cannot erase a
reported failure or prove that a skill is unnecessary. See
[`docs/testing.md`](docs/testing.md) for what each test can establish.

## Acknowledgements

This library draws on prior art and ongoing work from across the
multi-agent ecosystem:

- [**Superpowers**](https://github.com/obra/superpowers) —
  A complete software development methodology for coding agents.
- [**Matt Pocock skills**](https://github.com/mattpocock/skills) —
  Agent skills for real engineering.
- [**Ponytail**](https://github.com/DietrichGebert/ponytail) —
  The "laziest senior dev" discipline that inspired the `yagni` skill.
