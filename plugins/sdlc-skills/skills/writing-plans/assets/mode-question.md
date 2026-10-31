# Mode question

Ask this when a plan version is approved and its `External decision ledger`
row records no `mode:`. Offer options 2 and 3 only when the harness has a
subagent action and the index holds no phases or shards. Recommend by the
plan's shape, the first offered option that holds, never by default: option
3 when the plan's task list shows two or more ready tasks that each span
several files and whose files, state, and outputs are disjoint; option 2
when most tasks span several files and are self-contained enough that
keeping them out of this session's context is worth every fresh worker
re-reading the brief, the skills, and the code before its first edit; else
option 4 when the plan has eight or more tasks or this session has already
been summarized once, since an inline run then starts from a window that is
mostly planning history; else option 1. Because the approved plan and its
ledger row are on disk, delegated mode and option 4 both leave planning-phase
context behind: the executor in a new session reads everything it needs from
the plan directory.
`executing-plans` owns the inline loop and `subagent-driven-development` the
delegated one; the answer picks which is invoked. Ask this and end the turn;
`clarifying-intent` owns a reply that names no option. Record the answer
by appending a new approved row for the exact version, in the shape
`writing-plans` Step 4.5 gives, carrying `mode: inline` (options 1 and 4),
`mode: delegated`, or, for option 3, `mode: delegated` plus `waves: yes`;
never edit the existing row, and a row for another version settles nothing
here. On option 4, after the row is written, print the prompt its line
shows with the path filled in, and end the turn; invoke no executor, and
nothing runs in this session.

```text
Plan {{version}} is approved. How should it run?

1. Inline — every task in this session
   Keeps this session's context; you review each task's diff yourself; a compaction re-reads the whole plan.
2. Delegated — one fresh subagent per task, in sequence
   Starts each task fresh, keeping this session's planning context out of the build; each worker re-reads the code before its first edit, and a dispatched reviewer reads each task's diff, so small tasks run slower than inline; a compaction only re-checks the controller's ledger.
3. Delegated, in waves — every ready task whose files, state, and outputs are disjoint dispatches together
   Each task still gets its own subagent and reviewer; the merged state is re-gated before any of them is done.
4. Inline, in a new session — paste this into a fresh session and run it there: `Run the approved plan at {{absolute path of 00-index.md}} in inline mode.`
   Same loop as option 1, started from a window that holds the plan and not the conversation that produced it; this session ends its turn and runs nothing.

{{one sentence on the context trade-off}}
Recommendation: {{in waves when two or more ready tasks each span several files and are disjoint; else delegated when most tasks span several files and are self-contained; else inline in a new session when the plan has eight or more tasks or this session was summarized; else inline}} — {{one sentence}}.
```
