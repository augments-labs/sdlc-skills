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

Ask for a new feature and a well-behaved agent sets up an isolated worktree,
writes a failing test first, and keeps the change to what you asked for. Report
a bug and it looks for the cause before it proposes a fix. When it thinks the
work is finished, it runs the checks and reads their output before it says so,
then asks for a review and asks you what to do with the branch.

You do not have to call skills by name, although you can. Every skill is
addressed as `sdlc-skills:<name>`. That name is stable: a skill keeps its name
in every minor and patch update, so a skill you invoke by name keeps working. A
rename or removal only comes in a major version, with the
[changelog](CHANGELOG.md) saying how to update.

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
in each. The [installing guide](docs/guides/installing.md) adds updating,
removing, and the notes for each agent.

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

### pi

pi installs from a local clone:

```bash
pi install /path/to/sdlc-skills
```

Add `-l` to register it for the current project only.

### Devin

Devin installs the plugin directory inside this repository, not the repository
root. Sign in first (`devin auth login`), then run:

```bash
devin plugins install augments-labs/sdlc-skills#plugins/sdlc-skills
```

This adds the plugin to your personal plugins, which follow your account to
other machines. To install from a local clone on this machine only:

```bash
devin plugins install --local /path/to/sdlc-skills/plugins/sdlc-skills
```

### Antigravity

Antigravity installs the plugin directory inside this repository, not the
repository root:

```bash
agy plugin install https://github.com/augments-labs/sdlc-skills/tree/main/plugins/sdlc-skills
```

To install from a local clone instead:

```bash
agy plugin install /path/to/sdlc-skills/plugins/sdlc-skills
```

Antigravity runs no session-start hook from a plugin, so the plugin ships a
rule telling the agent to invoke `using-sdlc-skills` before acting.

### Hermes

```bash
hermes plugins install augments-labs/sdlc-skills --enable
```

During the install, Hermes asks whether to install Node dependencies because
the repository has a `package.json`. Answer no: the plugin needs none.

### Cursor

Cursor loads plugins cloned into its local plugins folder:

```bash
git clone https://github.com/augments-labs/sdlc-skills.git ~/.cursor/plugins/local/sdlc-skills
```

Cursor ignores a symlink there that points outside that folder, so clone into
it rather than linking an existing clone. To update, run `git pull` inside it.

### Other agents

Every skill follows the open Agent Skills format: a directory with a `SKILL.md`
file and YAML frontmatter. An agent that reads that format can load them.
[Using the skills on another agent](docs/guides/other-agents.md) shows what
you can set up yourself.

### Check that it works

Start a new session and ask for something that should trigger a skill, such as
"fix this bug" or "let's plan this feature". The agent should say which skill
it is using before it starts. If it does not, ask it to invoke
`using-sdlc-skills`. [Your first session](docs/guides/first-session.md) has
more to try, and [Supported agents](docs/reference/agents.md) lists what each
agent gets and its known limits.

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

The [skill catalogue](docs/reference/skills.md) lists every skill with one
line on what it does, including the common skills that belong to no phase.

## Documentation

The [documentation index](docs/README.md) lists every page. The ones most
people need first:

| Page | What it covers |
| --- | --- |
| [Installing, updating, and removing](docs/guides/installing.md) | The steps for each supported agent, and what each one does with the files |
| [Your first session](docs/guides/first-session.md) | How to check the skills loaded, how to call one by name, and the folder the agent creates |
| [Building a feature](docs/guides/building-a-feature.md) | From the request to a reviewed branch |
| [Fixing a bug](docs/guides/fixing-a-bug.md) | How the agent finds the cause before it proposes a fix |
| [When a session goes wrong](docs/guides/when-a-session-goes-wrong.md) | Getting a cited account of what a session did |
| [Skills guide, your checks decide](docs/concepts/skills-and-gates.md) | Why the library relies on your tests, reviews, and decisions |
| [Skill catalogue](docs/reference/skills.md) | Every skill, by phase |
| [Supported agents](docs/reference/agents.md) | What each agent gets and its known limits |

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

[`CONTRIBUTING.md`](CONTRIBUTING.md) has the full guide, including what each
check proves, how the agent adapters are built, and the design decisions
behind the library.

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
