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
  on a list of features presented as goals and on an outcome with no source
  or date. A baseline nobody has measured is written as unmeasured, with who
  takes the first reading and by when.
- `scoping` draws the boundary: what is in, what is out, and what is enough
  for the goal. Expect it to ask about the things teams cut to shrink a
  first release, such as compatibility, security, and rollback.
- `feasibility-check` asks whether the thing can be delivered at all, across
  technical, delivery, budget, operational, security, data, and dependency
  risk.
  It also asks the question nobody likes: does an existing tool, a
  configuration change, or not building at all do the job?

Each section is a decision you approve. The agent skips `feasibility-check`
only when the brief already has a feasibility section that fills every risk
row from evidence and leaves no project-stopping risk unrated. A risk nobody can
rate yet becomes a condition on a go-if, and when you choose that option the
agent settles it with a `prototyping` spike. A change to an approved scope is
written as a new section beside the old one for you to approve; once you do,
work under the specs and plans bound to the old scope stops until their
owners check them again.

When the goal is settled but more than one way to reach it is plausible,
`brainstorming` writes its own section: several approaches, each produced
under a different constraint (the smallest change, a clean slate, not
building at all), each checked against the same cited facts about your code,
and a comparison against the goals you approved. It uses parallel agents when
your harness has them and asks before writing the approaches itself when it
does not. You choose the approach; the agent only recommends one, and nothing
is specified or built until you do.

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
  per project or again when the conventions have drifted.

## The project's checks

Before high-risk work, or when the tests you have do not catch real defects,
`verification-strategy` designs the project's battery of checks: which risk
each check covers, when it runs, and what it blocks. Ask "how should we test
this project?" or "what should CI run?". It writes an assurance matrix under
`.sdlc-skills/verification/`.

A check counts as executable only after the agent has watched it fail: green,
red on a defect introduced on purpose, green again once the defect is
removed. Anything else is recorded as planned or blocked. An independent
reviewer challenges the matrix before you see it, and then you choose:

```text
1. Approve the battery
2. Request changes
3. Reject the strategy
4. Cancel
```

The agent approves nothing here itself: thresholds, omissions, and
exceptions are yours to accept. A single feature does not need this; its
plan and its tests carry the proof.

## A plan

`writing-plans` breaks approved work into ordered tasks, each with its
dependencies and a way to know it is done. Before writing any task, the
agent maps the code the plan will change with `mapping-the-codebase`: who
calls it, what it owns, and where its boundaries are, including callers
reached through configuration or generated code. Each task's files come from
that map, not from the design. The plan is a directory with an
index and one file per task. The agent shows you the index, with the plan's
path and version on the first line, followed by one choice that covers both
approval and how the plan runs:

```text
1. Approve — inline, in this session
2. Approve — delegated, a subagent per task
3. Approve — delegated, in waves
4. Approve — inline, in a new session
5. Request changes
6. Reject
7. Cancel
```

Options 2 and 3 appear only when your agent has a subagent tool, the plan
has no phases or shards, and the work is in a git project. A delegated run
needs local commits, so the agent asks for permission to commit if it does
not have it, and on a no it hands the choice of mode back to you.

For a high-risk plan, `reviewing-plans` sends the plan to an independent
reviewer before you see this block, and every blocker it returns gets a
recorded decision first: corrected in a new version of the plan, refuted with
evidence, or put to you with the plan. For other plans, the agent offers the
review and you decide.

## Executing a plan

The option you approve with sets how the plan runs:

- **Inline** runs the plan in this session through `executing-plans`, task by
  task, through each task's own check.
- **Inline, in a new session** prints a one-line prompt; paste it into a
  fresh session and the plan runs there through `executing-plans`, with the
  planning conversation left behind. The agent recommends this for a large
  plan or when this session has already been summarized.
- **Delegated**, one task at a time or in waves, runs it through
  `subagent-driven-development`: a fresh subagent implements each task, a
  reviewer checks its diff, and a bounded fix loop handles what the reviewer
  finds. The agent in your session keeps every decision. This needs an agent
  with a subagent tool and a git project; see [Supported
  agents](../reference/agents.md).

An approved plan authorizes every task in it, so the agent does not stop to
check in after each one. When the code differs from what the plan
expected, such as a file the plan missed, a different signature, or a check
that needs correcting, the agent makes the change, records it as a ruling,
and keeps going, as long as every requirement the task traces still holds.
You get the list of rulings, each with what it costs if wrong, when the plan
finishes. The agent stops to ask you again only when a task needs a change
to the plan's goal, a requirement, its acceptance check, its constraints, or
an approved migration or assurance contract, or, on a high-risk plan, any
change its migration rules treat as normative, such as an interface or
ownership change; when no task can move forward;
or when a high-risk entry gate has not passed. In a delegated run it also
stops before an act that cannot be undone, one that touches secrets,
permissions, or a trust boundary, one that takes effect outside the
worktree, and a requirement that reads two ways or a product or architecture
choice the approved documents do not settle. When a task's fix loop uses up
its rounds without converging, it hands you that task as blocked, with what
each round changed. A defect it finds outside
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
