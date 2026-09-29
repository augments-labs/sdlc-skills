# SDLC skills

SDLC skills is a library of engineering skills for coding agents. It covers the
whole software development life cycle, from the first conversation about goals
to debugging in production, and it works with several agents from one set of
files.

A skill is a short set of instructions your agent loads when a situation calls
for it: how to write a plan, how to find the cause of a bug, what to check
before calling work done. You install the library once and the agent picks the
skills that fit the task in front of it.

## Table of contents

- [How it works](#how-it-works)
- [Installation](#installation)
- [A typical workflow](#a-typical-workflow)
- [When a session goes wrong](#when-a-session-goes-wrong)
- [Available skills](#available-skills)
- [Philosophy](#philosophy)
- [Documentation](#documentation)
- [Contributing](#contributing)
- [License](#license)
- [Acknowledgements](#acknowledgements)

## How it works

When a session starts, the plugin gives your agent a small routing skill called
`using-sdlc-skills`. It instructs the agent to look through the catalogue and
load the skills that match what you asked for, before it answers or touches
anything. On Grok Build and Muse Code this needs one manual step, described in
their installation sections.

Ask for a new feature and a well-behaved agent sets up an isolated worktree, writes a
failing test first, and keeps the change to what you asked for. Report a bug
and it looks for the cause before it proposes a fix. When it thinks the work is
finished, it runs the checks and reads their output before it says so, then
asks for a review and asks you what to do with the branch.

You do not have to call skills by name, although you can. Every skill is
addressed as `sdlc-skills:<name>`.

Two things are worth knowing up front:

- **It is a toolbox.** Nothing forces a task through every phase. A one-line
  fix does not get a project brief. Each skill states when it applies and when
  to skip it.
- **The skills guide the agent. Your checks decide the result.** These are
  instructions to a non-deterministic agent, and nothing enforces that a skill
  is invoked. A skill can steer an agent toward running the tests, but only
  the tests can tell you the code works. Keep your CI, reviews, and release
  controls in place.

## Installation

Installation differs by agent. If you use more than one, install the library
in each.

Some agents install from a local copy of this repository. For those, clone it
first:

```bash
git clone https://github.com/augments-labs/sdlc-skills.git
```

### Claude Code

1. Register the marketplace:

   ```text
   /plugin marketplace add augments-labs/sdlc-skills
   ```

2. Install the plugin:

   ```text
   /plugin install sdlc-skills@augments-labs
   ```

### Codex CLI

Codex installs from a local clone.

1. Register the clone as a marketplace:

   ```bash
   codex plugin marketplace add /path/to/sdlc-skills
   ```

2. Install the plugin:

   ```bash
   codex plugin add sdlc-skills@augments-labs-dev
   ```

### Kimi Code

1. Install from this repository:

   ```text
   /plugins install https://github.com/augments-labs/sdlc-skills
   ```

   You can also use the `/plugins` manager and its Custom tab.

2. Reload:

   ```text
   /reload
   ```

### OpenCode

Add the plugin to your `opencode.json`, either the global one or the project
one, then restart OpenCode. The key is named differently in the two
generations.

OpenCode 1.x:

```json
{
  "plugin": ["sdlc-skills@git+https://github.com/augments-labs/sdlc-skills.git"]
}
```

OpenCode 2.x:

```json
{
  "plugins": ["sdlc-skills@git+https://github.com/augments-labs/sdlc-skills.git"]
}
```

To use a local clone instead, name `.opencode/plugins/sdlc-skills.js` inside
the clone on 1.x, or the clone directory itself on 2.x.

If the skills do not show up, run `opencode run --print-logs` on 1.x or
`opencode run --standalone --print-logs` on 2.x, and look for the line that
names the plugin entry point.

### Grok Build

Grok installs from a local clone and needs one extra file, because it has no
session-start hook that can hand the routing skill to the agent.

1. Install the plugin:

   ```bash
   grok plugin install /path/to/sdlc-skills --trust
   ```

2. Create `$GROK_HOME/rules/using-sdlc-skills.md` (the default location is
   `~/.grok/rules/`) containing this line:

   ```text
   Invoke the `using-sdlc-skills` skill before acting.
   ```

### Muse Code

Muse installs from a local clone. From inside the clone, run:

```bash
bash scripts/sh/install-muse-skills.sh
```

To remove the skills later:

```bash
bash scripts/sh/install-muse-skills.sh --remove
```

Muse 1.3.0 does not load plugins, so this installs the skills one by one and
the agent can see them, but nothing hands it the routing skill. Start each
session by asking the agent to invoke `using-sdlc-skills`.

A Muse build that ships plugin support installs `.muse-plugin/plugin.json`
instead, which declares the session-start hook. This has not been observed on
a real build.

### pi

pi installs from a local clone:

```bash
pi install /path/to/sdlc-skills
```

Add `-l` to register it for the current project only.

### Other agents

Every skill follows the open Agent Skills format: a directory with a `SKILL.md`
file and YAML frontmatter. An agent that reads that format can load them.
[`docs/harness-support.md`](docs/harness-support.md) explains what an
integration needs beyond making the files visible.

### Check that it works

Start a new session and ask for something that should trigger a skill, such as
"fix this bug" or "let's plan this feature". The agent should say which skill
it is using before it starts. If it does not, ask it to invoke
`using-sdlc-skills`, and see the notes for your agent in
[`docs/harness-support.md`](docs/harness-support.md).

## A typical workflow

Skills live under `skills/<phase>/<name>/`. The phase folders are unnumbered,
so they sort alphabetically on disk. The order below is the canonical one. The
phase is for organization only and is not part of a skill's address.

A large project may touch every phase. Most tasks use a few skills.

1. **Planning.** `define-goals`, `scoping`, and `feasibility-check` turn an
   idea into a project brief: what it is for, what is in and out, and whether
   it can be delivered.
2. **Analysis.** `writing-specs` turns settled intent into requirements and
   acceptance criteria.
3. **Design.** `system-architecture`, `data-model`, and `ui-ux-design` shape
   the solution. `writing-plans` breaks it into tasks, and `reviewing-plans`
   gets a second opinion on a risky plan before you approve it.
4. **Implementation.** `using-git-worktrees`, a common skill, isolates the
   work.
   `executing-plans` runs the plan in the current session, or
   `subagent-driven-development` hands each task to a fresh subagent.
   `test-driven-development` and `yagni`, another common skill, keep each
   change tested and no larger than it needs to be.
5. **Testing.** `verification-before-completion` runs the checks before any
   claim that work is done. `requesting-code-review` and
   `receiving-code-review` handle the review.
6. **Deployment.** `finishing-a-branch` asks what to do with the branch: push,
   open a PR, merge, keep, or discard. `release-readiness` decides whether a
   build is safe to ship.
7. **Maintenance.** `debugging` finds the cause of a bug before any fix.
   `containing-an-incident` and `post-mortem` handle failures that reach users.

## When a session goes wrong

Sometimes an agent skips a step, does something nobody asked for, or loses
track of the task. Ask it "why did you do that?" or "what went wrong in
yesterday's session?" and it uses `diagnosing-a-session`.

The skill reads the recorded transcript of the session without changing
anything, and reports what happened in order, with the transcript line behind
every claim. You get a written report and a local page to explore: the
findings, a timeline of the session, and the detail of each event, with a
walkthrough of how each finding came about.

## Available skills

### Planning

| Skill | What it does |
| --- | --- |
| `define-goals` | Pins down what a project is for: the objective, the stakeholders, how success is measured |
| `scoping` | Draws the boundary: what is in, what is out, and what is enough for the goal |
| `feasibility-check` | Checks whether an initiative can be delivered before you commit to it |

### Analysis

| Skill | What it does |
| --- | --- |
| `writing-specs` | Writes requirements, acceptance criteria, and edge cases for settled intent |

### Design

| Skill | What it does |
| --- | --- |
| `system-architecture` | Designs components, boundaries, data flow, and failure handling |
| `data-model` | Defines domain concepts, relationships, state transitions, and invariants |
| `ui-ux-design` | Designs an interface's flow, states, layout, and visual direction before it is built |
| `coding-standards` | Settles a project's naming, patterns, and vocabulary |
| `architecture-decisions` | Records a hard-to-reverse technical decision and the options weighed |
| `migration-strategy` | Plans how a rewrite or migration keeps behavior through cutover and rollback |
| `writing-plans` | Breaks approved work into ordered tasks, each with a way to know it is done |
| `reviewing-plans` | Gets an independent review of a plan before you approve it |

### Implementation

| Skill | What it does |
| --- | --- |
| `test-driven-development` | Makes a test fail for the right reason, then makes it pass |
| `executing-plans` | Runs an approved plan task by task in the current session |
| `subagent-driven-development` | Runs an approved plan through fresh subagents, with a reviewer on each task |

### Testing

| Skill | What it does |
| --- | --- |
| `verification-before-completion` | Runs the checks and reads their output before any claim that work is done |
| `requesting-code-review` | Gets an independent review of a change before it is pushed or merged |
| `receiving-code-review` | Checks review feedback on its merits before acting on it |
| `security-audits` | Audits what an attacker could make a change do |
| `verification-strategy` | Designs which checks a project runs, what each catches, and when |
| `visual-ui-verification` | Checks a running interface across states, screen sizes, and themes |

### Deployment

| Skill | What it does |
| --- | --- |
| `finishing-a-branch` | Takes a finished branch through the choice you make: push, PR, merge, keep, or discard |
| `release-readiness` | Decides whether a build is safe to release, deploy, or publish |

### Maintenance

| Skill | What it does |
| --- | --- |
| `containing-an-incident` | Stops a failure that is reaching users before diagnosing it |
| `debugging` | Finds the cause of a bug before any fix is proposed |
| `post-mortem` | Explains how a failure got past the safeguards and what prevents a repeat |
| `diagnosing-a-session` | Reconstructs what an agent session did from its transcript, as a report and an interactive trace page |
| `complexity-audit` | Audits existing code for complexity it does not need |
| `refactor-architecture` | Restructures code whose shape makes every change expensive |

### Common

These skills are not tied to a phase. They live in `skills/common/`.

| Skill | What it does |
| --- | --- |
| `using-sdlc-skills` | Routes each task to the skills it needs |
| `clarifying-intent` | Asks the questions that settle what you want before work is built on a guess |
| `prototyping` | Answers an uncertain question with a throwaway prototype |
| `mapping-the-codebase` | Maps how a region of code fits together before it is changed |
| `using-git-worktrees` | Creates an isolated worktree for a task and checkpoints work there |
| `dispatching-parallel-agents` | Splits independent work across parallel agents |
| `yagni` | Keeps a change to what the task needs, and makes sure that part is complete |
| `handoff` | Writes a handoff so another session or agent can continue unfinished work |
| `viewing-artifacts` | Shows the state of briefs, specs, designs, plans, and execution in a local viewer |
| `writing-skills` | Guides writing and editing the skills in this library |

## Philosophy

- **Toolbox, not pipeline.** Use the skills that fit the task. Each skill
  states its own preconditions and what comes next.
- **Claims need evidence.** "It works" is backed by a check that ran, and an
  approval is a decision somebody made. An agent's confidence is neither.
- **Every line earns its place.** Skills stay short, and supporting files load
  only when they are needed.
- **Portable.** Skills name no vendor, model, or tool. Each agent's adapter
  binds them to what that agent provides.

[`docs/philosophy.md`](docs/philosophy.md) explains the reasoning.

## Documentation

| Document | What it covers |
| --- | --- |
| [`docs/philosophy.md`](docs/philosophy.md) | Why skills guide the work and external checks judge it |
| [`docs/activation.md`](docs/activation.md) | How the agent finds and loads skills, and what that does not guarantee |
| [`docs/harness-support.md`](docs/harness-support.md) | How each supported agent is integrated, and how to add another |
| [`docs/skill-granularity.md`](docs/skill-granularity.md) | When a phase is one skill and when it is several |
| [`docs/testing.md`](docs/testing.md) | The checks this repository runs and what each one proves |
| [`docs/agent-skills-conformance.md`](docs/agent-skills-conformance.md) | How the library follows the Agent Skills format |

## Contributing

Contributions are welcome. The short version:

1. Fork the repository and create a branch from `dev`.
2. Make one focused change that solves a problem you actually hit.
3. If you are changing a skill, follow the `writing-skills` skill.
4. Run the checks:

   ```bash
   bash scripts/sh/validate-skills.sh
   ```

5. Open a pull request against `dev` and fill in the template.

[`CONTRIBUTING.md`](CONTRIBUTING.md) has the full guide, and
[`docs/testing.md`](docs/testing.md) explains the checks.

## License

MIT. See [`LICENSE`](LICENSE).

## Acknowledgements

This library draws on prior work from across the coding-agent community:

- [**Superpowers**](https://github.com/obra/superpowers): a complete software
  development methodology for coding agents.
- [**Matt Pocock skills**](https://github.com/mattpocock/skills): agent skills
  for real engineering.
- [**Ponytail**](https://github.com/DietrichGebert/ponytail): the "laziest
  senior dev" discipline that inspired the `yagni` skill.
