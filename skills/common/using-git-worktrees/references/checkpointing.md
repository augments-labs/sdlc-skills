# Checkpointing a task branch

Read this when the task will make more than one commit.

## The unit

A checkpoint is one coherent piece a reviewer could accept or reject on its
own — not a finished feature. If the project's smallest real gate can accept
it, it can be a checkpoint, and it is committed then rather than at the end.
Waiting for the final candidate leaves one terminal commit that cannot be
reviewed or reverted in pieces, and every good intermediate state gone.

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
