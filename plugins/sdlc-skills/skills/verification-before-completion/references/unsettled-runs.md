# Verification Before Completion — Unsettled Runs

A check whose run did not finish cleanly, or whose state moved underneath it,
has no settled row yet. Read this before recording one.

## The run timed out, failed partway, or is in the background

- Wait or poll its exact process or task ID until it exits and every effect
  it started has stopped. Elapsed time proves nothing.
- Save the result at a path that names this attempt, and point the row at
  that path.
- Ignore output arriving after this attempt's result was recorded or after a
  later attempt started, and any log from before this attempt or from
  another run: it describes a state nothing is bound to.
- If it fails again with nothing changed, diagnose or return pending. Never
  rerun until one passes.

## The check changed something it should not have

- Restore what it changed and rerun, or record the row as pending. A result
  taken over a mutated state binds to nothing.

## The state moved (`--compare` exited nonzero)

- Exit 1, or exit 5 when content sits outside the commit, means the source
  changed between capture and now. Identify the writer first — a tool, a
  formatter, a generated file, a line-ending normalization — then recapture
  from Step 1.4. Never commit to make the identities match.
- Exit 2 to 4 means no identity could be read: bad arguments or an
  unresolvable root (2), a missing tool (3), a failed git step or an edit git
  hides (4). The script's stderr names the cause. No row binds until it is
  resolved.
- Any nonzero exit leaves the claim pending.
