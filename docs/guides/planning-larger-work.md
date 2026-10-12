# Planning larger work

A one-line fix does not need a brief. A new module, a migration, or a project
that will take many sessions does. This page shows what the agent produces
for work that is bigger than one change, and where you come in.

Example requests:

```text
We want to add usage-based billing. Let's start from the goals.
```

```text
Write a spec for the export feature we agreed on.
```

```text
Break the migration to the new queue into a plan.
```

Everything the agent writes here goes under `.sdlc-skills/` in your project
(see [The `.sdlc-skills/` folder](../concepts/project-artifacts.md)), and
every approval is yours.

## A project brief

For a new project or initiative, three skills write one brief, each its own
section:

- `define-goals` pins down what the project is for: the objective, who it
  is for, how success will be measured, and the guardrails. It pushes back
  on a list of features presented as goals and on a target with no baseline.
- `scoping` draws the boundary: what is in, what is out, and what is enough
  for the goal. Expect it to ask about the things teams cut to shrink a
  first release, such as compatibility, security, and rollback.
- `feasibility-check` asks whether the thing can be delivered at all, across
  technical, delivery, budget, operational, security, and dependency risk.
  It also asks the question nobody likes: does an existing tool, a
  configuration change, or not building at all do the job?

Each section is a decision you approve. The agent skips `feasibility-check`
when the path is well trodden and the risk is plainly low.

## A spec

With intent settled, `writing-specs` turns it into requirements and
acceptance criteria, with the edge cases and assumptions written down. It is
one pass, not three: each requirement is written with its criterion beside
it. The agent will not write a spec while a material decision about what you
want is still open; it asks first.

## Designs and decisions

For work with structure to settle, the design skills each produce a document
you approve:

- `system-architecture` for components, boundaries, data flow, and failure
  handling.
- `data-model` for domain concepts, relationships, state transitions, and
  invariants.
- `ui-ux-design` for a screen's flow, states, layout, and visual direction.
- `architecture-decisions` for a hard-to-reverse choice, with the options
  weighed. The agent records one when you ask "should we use X or Y?" and
  also when a choice is made in passing.
- `migration-strategy` for a rewrite or migration where ordinary review and
  tests cannot show that behavior survived. It sets the conditions that must
  hold before the transformation starts.
- `coding-standards` for a project's naming, patterns, and vocabulary, once
  per project.

## A plan

`writing-plans` breaks approved work into ordered tasks, each with its
dependencies and a way to know it is done. The plan is a directory with an
index and one file per task. The agent shows you the index, with the plan's
path and version on the first line, followed by this choice:

```text
1. Approve, then choose an execution mode
2. Request changes
3. Reject
4. Cancel
```

For a high-risk plan, `reviewing-plans` sends the plan to an independent
reviewer before you see this block, and every blocker it returns is
resolved first. For other plans, the agent offers the review and you decide.

## Executing a plan

When you approve, the agent asks one more question: inline or delegated.

- **Inline** runs the plan in this session through `executing-plans`, task by
  task, through each task's own check.
- **Delegated** runs it through `subagent-driven-development`: a fresh
  subagent implements each task, a reviewer checks its diff, and a bounded
  fix loop handles what the reviewer finds. The agent in your session keeps
  every decision. This needs an agent with a subagent tool; see
  [Supported agents](../reference/agents.md).

An approved plan authorizes every task in it, so the agent does not stop to
check in after each one. It stops when a task needs a change to what was
approved, when no task can move forward, or when a high-risk entry gate has
not passed. A defect it finds outside
a task is logged and listed when the plan finishes, not fixed on the spot,
unless the plan says otherwise.

Each task's work goes through the same discipline as a single change: a
failing test first, verification, review at the plan's boundaries, and the
branch choice at the end. See [Building a feature](building-a-feature.md).

## Seeing where things stand

Ask "where does the project stand?" or "is the plan still in sync with the
spec?" and `viewing-artifacts` builds a local page from the artifact trail:
each brief, spec, design, and plan, its state, and what needs attention. It
reads the markers the other skills wrote and says "unknown" where there is
none.

## Handing over

If a session is ending with work unfinished, ask for a handoff. `handoff`
writes a note that a fresh session or another agent can continue from, with
what was done, what is pending, and where the artifacts are.
