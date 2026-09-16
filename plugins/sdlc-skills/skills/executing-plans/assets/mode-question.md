# Mode question

Ask this when a plan version is approved and its `External decision ledger` row
records no `mode:`. Offer option 2 only when the harness has a subagent action
and the index holds no phases or shards, and recommend it whenever it is offered: a fresh worker per task keeps the
plan's context out of the build. `executing-plans` owns the inline loop and
`subagent-driven-development` the delegated one; the answer picks which is
invoked.
Ask through the harness's user-input action when one exists, else print the
block as text; end the turn. Rendering the question collects an answer — never
infer one; `clarifying-intent` owns a reply that names no option.

```text
Plan {{version}} is approved. How should it run?

1. Inline — every task in this session
2. Delegated — one fresh subagent per task, in sequence

{{one sentence on the context trade-off}}
Recommendation: {{delegated when offered, else inline}} — {{one sentence}}.
```

Record the answer on that version's ledger row as `mode: inline` or
`mode: delegated`. A row for another version settles nothing here.
