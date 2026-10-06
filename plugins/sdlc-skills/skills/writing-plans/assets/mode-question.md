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
option 1.
`executing-plans` owns the inline loop and `subagent-driven-development` the
delegated one; the answer picks which is invoked. Ask through the harness's
user-input action when one exists, else print the block as text; end the
turn. Rendering the question collects an answer — never infer one;
`clarifying-intent` owns a reply that names no option. Record the answer on
the exact version's ledger row as `mode: inline`, `mode: delegated`, or, for
option 3, `mode: delegated` plus `waves: yes`; a row for another version
settles nothing here.

```text
Plan {{version}} is approved. How should it run?

1. Inline — every task in this session
   Keeps this session's context; you review each task's diff yourself; a compaction re-reads the whole plan.
2. Delegated — one fresh subagent per task, in sequence
   Starts each task fresh, keeping this session's context out of the build; each worker re-reads the code before its first edit, and a dispatched reviewer reads each task's diff, so small tasks run slower than inline; a compaction only re-checks the controller's ledger.
3. Delegated, in waves — every ready task whose files, state, and outputs are disjoint dispatches together
   Each task still gets its own subagent and reviewer; the merged state is re-gated before any of them is done.

{{one sentence on the context trade-off}}
Recommendation: {{in waves when two or more ready tasks each span several files and are disjoint; else delegated when most tasks span several files and are self-contained; else inline}} — {{one sentence}}.
```
