# Skill catalogue

Every skill, by life-cycle phase, with one line on what it does. Every skill
is addressed as `sdlc-skills:<name>`; the phase is for organisation only and
is not part of the name.

Skills live under `skills/<phase>/<name>/` in the repository. The phase
folders are unnumbered, so they sort alphabetically on disk; the order below
is the canonical one. A large project may touch every phase. Most tasks use
a few skills.

## Planning

| Skill | What it does |
| --- | --- |
| `define-goals` | Pins down what a project is for: the objective, the stakeholders, how success is measured |
| `scoping` | Draws the boundary: what is in, what is out, and what is enough for the goal |
| `feasibility-check` | Checks whether an initiative can be delivered before you commit to it |

## Analysis

| Skill | What it does |
| --- | --- |
| `working-from-a-ticket` | Captures a ticket as read, with its acceptance criteria and what it leaves unclear, so the plan and the tests bind to it |
| `writing-specs` | Writes requirements, acceptance criteria, and edge cases for settled intent |

## Design

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

## Implementation

| Skill | What it does |
| --- | --- |
| `test-driven-development` | Makes a test fail for the right reason, then makes it pass |
| `executing-plans` | Runs an approved plan task by task in the current session |
| `subagent-driven-development` | Runs an approved plan through fresh subagents, with a reviewer on each task |
| `rollout-controls` | Builds the flag or kill switch and the rollout signals a staged release needs, under the release policy's terms or terms drafted for the release owner to accept |
| `adding-observability` | Instruments a change or a service so its operators can tell whether it works for users and find out why when it does not, through the project's existing facility, with each signal seen before it counts |
| `changing-a-live-schema` | Builds an ordinary schema change or backfill in phases so a live store keeps working for both code versions during a deploy and after a rollback, until the contract phase |

## Testing

| Skill | What it does |
| --- | --- |
| `verification-before-completion` | Runs the checks and reads their output before any claim that work is done |
| `requesting-code-review` | Gets an independent review of a change before it is pushed or merged |
| `receiving-code-review` | Checks review feedback on its merits before acting on it |
| `reviewing-a-pr` | Reviews a pull request someone else wrote and writes the findings for its author; you choose what gets posted |
| `security-audits` | Audits what an attacker could make a change do |
| `verification-strategy` | Designs which checks a project runs, what each catches, and when |
| `visual-ui-verification` | Checks a running interface across states, screen sizes, and themes |

## Deployment

| Skill | What it does |
| --- | --- |
| `finishing-a-branch` | Takes a finished branch through the choice you make: push, PR, merge, keep, or discard |
| `release-readiness` | Decides whether a build is safe to release, deploy, or publish |

## Maintenance

| Skill | What it does |
| --- | --- |
| `containing-an-incident` | Stops a failure that is reaching users before diagnosing it |
| `debugging` | Finds the cause of a bug before any fix is proposed |
| `post-mortem` | Explains how a failure got past the safeguards and what prevents a repeat |
| `diagnosing-a-session` | Reconstructs what an agent session did from its transcript, as a report and an interactive trace page |
| `complexity-audit` | Audits existing code for complexity it does not need |
| `refactor-architecture` | Restructures code whose shape makes every change expensive |
| `deprecating-an-api` | Retires an interface others call: the replacement first, a signal callers see, measured use, and the removal as its own change the owner accepts |
| `large-scale-changes` | Applies one mechanical change across many files, packages, or owners with a script, and splits the result into shards each owner can review, merge, and revert alone |

## Common

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

## Which skills load together

Some skills are meant to load as a pair, because each catches something the
other cannot see:

- `test-driven-development` and `yagni` both load before the first edit. The
  first catches a change with no observed failure behind it; the second
  catches a change that is larger than the task, which a green test cannot
  see.
- `mapping-the-codebase` and `debugging` both load for a bug in unfamiliar
  code. The first catches a boundary drawn too small, such as a caller
  reached through configuration; the second catches a fix with no
  established cause.
- `define-goals`, `scoping`, and `feasibility-check` write three sections of
  one project brief, and each is a separate decision you approve.
