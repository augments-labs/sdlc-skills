# Checkpointing a task branch

Read this when the task will make more than one commit.

## The unit

A checkpoint is one coherent piece a reviewer could accept or reject on its
own — not a finished feature. If the project's smallest real gate can accept
it, it can be a checkpoint, and it is committed then rather than at the end.

## Stage by path

Stage and commit a checkpoint by the explicit paths this task changed, never
with `git add -A`, `git add .`, or `git commit -a`. A path that was already
staged or modified before the task began (the workspace record's Inventory,
right column) stays out of the commit. If a path you changed was already
modified before the task began, stop and ask: a path-limited commit takes the
whole file, including the earlier edits. A path-limited commit leaves anything
else in the index staged and uncommitted:

```bash
git add -- {{task-changed-paths}}
git commit -m "{{message}}" -- {{task-changed-paths}}
git show --stat --format= HEAD   # expect: only {{task-changed-paths}}
```

## The authority is recorded once per task

A local commit needs the user's answer or a project policy. Neither recorded →
ask once for this task, print the question, and keep the work uncommitted until
the answer arrives:

```text
May I commit locally on this branch as I go? Checkpoints stay local — nothing
is pushed, published, or merged without a separate decision.

1. Yes — commit after each independently testable piece
2. No — leave the work uncommitted until I say otherwise
```

Record the answer in the workspace record's local-commit-authority field,
quoted, and never ask again for this task.

Being able to run `git commit` is not that authority: a commit runs hooks and
signing, and it shapes history that later work reads.

## What a checkpoint does not grant

A checkpoint claims nothing. It is neither review nor integration, and nothing
reads it as done. Push, publication, integration, discard, deletion, history
rewrite, and cleanup are a separate decision with its own owner, taken after
the candidate is ready — never from inside the checkpoint loop.
