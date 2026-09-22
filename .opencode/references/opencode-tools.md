# OpenCode tool binding for dispatched work

Part of the OpenCode adapter, not of any skill. The shipped skills say "the real
callable action" and require a returned receipt; they never name a harness tool.
This file is where that action is named for this harness, so a renamed or removed
tool changes an adapter file and no skill body.

## The calls a dispatch needs

The tool surface changed between OpenCode generations, so there are two
tables. The adapter injects whichever matches the generation that loaded it,
and both are kept because one plugin file serves both.

### OpenCode 1.x

| Contract step | OpenCode call | What the adapter binds |
| --- | --- | --- |
| Decide | `question` | A decision put to the user is one question at a time with labelled options. Rendering options as plain text never closes a decision. |
| Track | `todowrite` | Multi-step work is tracked as a todo list. |
| Dispatch | `Task` | The filled packet or role brief is the whole prompt to a subagent. A cold worker gets exactly the packet: the task, the base revision, what it owns, what it must not touch, what to read, and the observable that means done. Pasting session history in place of those fields is prohibited by the skill. |
| Invoke | `skill` | Skills load by catalogue name. Reading a skill file with `read` is not invoking it. |

### OpenCode 2.x

Measured against 2.0.13. The top-level agent's tools are `edit`, `glob`,
`grep`, `question`, `read`, `shell`, `skill`, `subagent`, `webfetch`,
`websearch`, `write`, and `execute`. A `general` subagent gets that set
without `question` and `subagent`; an `explore` subagent gets `glob`, `grep`,
`read`, `webfetch`, and `websearch` only, so it cannot write.

| Contract step | OpenCode call | What the adapter binds |
| --- | --- | --- |
| Decide | `question` | Present on 2.0.13, for the top-level agent only. A decision put to the user is one question at a time with labelled options. Rendering options as plain text never closes a decision. |
| Track | none | This generation exposes no todo tool. Multi-step work is tracked in the task's own written artifact — a plan or report file — rather than in harness state, so nothing is lost when the transcript is replaced. |
| Run a command | `shell` | Shell commands run through `shell`. |
| Dispatch | `subagent` | Takes `agent`, `description`, and `prompt`, and returns the child session's ID so the same worker can be continued. The filled packet or role brief is the whole prompt. A cold worker gets exactly the packet: the task, the base revision, what it owns, what it must not touch, what to read, and the observable that means done. Pasting session history in place of those fields is prohibited by the skill. |
| Invoke | `skill` | Skills load by catalogue name. Reading a skill file with `read` is not invoking it. |

## Cold start is the point of the filled brief

A worker that inherits turn history inherits the coordinator's assumptions, and
its report then agrees with them. The brief gives it exactly the packet and
nothing else.

## Tier binding

State the packet's `TIER` (`small | medium | large`) explicitly in the subagent
prompt; never a vendor model name. The tier binds to the agent's `model`: a
subagent without its own `model` inherits the invoking agent's. Writing a tier
in the prompt selects nothing by itself — the harness binds it through the agent
configuration. If the build exposes no model choice, say so and use a fallback
the user's preferences permit; never report an override that was not applied.

## Role binding

`subagent-driven-development` ships three role briefs. Where the installed build
exposes a subagent whose contract covers the role, dispatch that subagent with
the filled brief; otherwise dispatch a general subagent with the same brief. The
brief is the specification, the agent is only the runtime carrying it.

| Role | Bind to | Fallback |
| --- | --- | --- |
| implementer | `general` | the general-purpose subagent carrying the role prompt |
| task-reviewer, re-reviewer | `explore`, which cannot write | a general subagent carrying the role prompt, which forbids every edit, commit, and push in the brief; the dispatch is recorded as the unenforced fallback binding, and the report is accepted only after the coordinator inspects the workspace for writes it did not authorize |

On 2.x these are the `agent` argument to `subagent`; on 1.x they are the
subagent the `Task` tool is pointed at. The role names are the same in both.

## When the build exposes none of this

Availability is a property of the installed build and its configuration, and it
changes between versions. An uncallable action is `not dispatched`. Name the
call attempted and what this environment would need to make it callable, ask the
user once, and record the answer as the written assignment. Never describe a
fan-out that returned no receipt, and never quietly do the work instead.
