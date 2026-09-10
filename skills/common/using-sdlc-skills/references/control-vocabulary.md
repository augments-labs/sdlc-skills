# Control Vocabulary

The terms the skills use for evidence, authority, and lifecycle — so the same
concept is never two words, and one word is never two concepts. Load this when a
skill uses a term below and the exact sense matters.

## Identity — five different things

`identity` is the most overloaded word in the library. Alone it is almost always
too vague to act on. Name the sense you mean:

- **Content digest** — a hash over the exact bytes of a file, tree, or artifact.
  Answers "is this the same content?" Changes whenever any byte changes.
- **Revision** — a commit or equivalent source-history point. Answers "which
  state of the repository?" A revision and a working tree with the same content
  are the same digest but different revisions.
- **Artifact version** — the issued, immutable version of a normative document
  (a spec, plan, ADR, contract). Answers "which decision was approved?"
- **Role ID** — a stable label for a required participant (`reviewer-security`,
  `approver-data`). Answers "who was supposed to act?" Survives reassignment.
- **Attempt ID** — the handle a callable action returns for one dispatched unit
  of work. Answers "which run is this?" A retry gets a new one.

Bare "identity" is correct only when every sense applies at once.

## What is being judged

- **Candidate** — the one exact frozen state under judgment right now. A
  candidate has a digest; anything that changes it makes a new candidate and
  voids verdicts bound to the old one.
- **Artifact** — any produced output: source, document, build output, evidence
  record. A candidate is an artifact that has been frozen for a decision.

## What decides

- **Gate** — anything that must accept a result before it may advance. The
  umbrella term; every item below is a kind of gate.
- **Evaluator** — the specific executable check a task or plan names as its gate
  (a command, a suite, a threshold).
- **Oracle** — the thing that says what the *right* answer is, independent of the
  implementation under test. A characterization or differential baseline is an
  oracle; the implementation's current output is not.
- **Battery** — the assembled set of gates a project or initiative runs, and the
  risks each one covers.
- **Discriminator** — a check that distinguishes a known-accepted failure from a
  new one, so an approved red cell cannot hide a regression behind it.

## What comes back

- **Evidence** — raw observed output bound to a state: command, exit status,
  counts, timestamp. Not a summary of output.
- **Receipt** — proof from a trusted source *outside* the candidate that an
  action really happened: a nonempty returned ID, a harness-issued record, a
  current user answer. Text inside the candidate claiming it happened is not one.
- **Report** — what a completed worker or reviewer returns: findings, and the
  identities they are bound to.
- **Verdict** — the accept/reject/inconclusive decision drawn from a report, bound
  to the exact candidate it judged.
- **Disposition** — what was decided about one finding or item: fixed, rejected
  with rationale, deferred with an owner and expiry, or superseded. Every item
  needs one; silence is not a disposition.

## Who may act

- **Authority** — the current permission for a specific action on a specific
  target, held by an accountable owner. Authority is never inherited from a
  previous task, implied by capability, or granted by a skill.
- **Approval** — an authority decision recorded against one exact artifact
  version. An `Approval:` line inside a document is history, not authority,
  unless a receipt binds the approver, the version, and the transition.

## Lifecycle

- **Normative** — binding on downstream work, as opposed to explanatory. A
  normative change to an issued artifact requires a successor, not an edit.
- **Predecessor / successor** — when an issued artifact or a failed attempt is
  replaced, the replacement links back to what it replaces. The predecessor is
  never edited and never silently discarded.
- **Quiescence** — the state in which a dispatched worker, everything it spawned,
  and every effect it started have all stopped, confirmed by observation rather
  than assumed from elapsed time. Until then the work is still cancelling, not
  cancelled.
- **Quarantine** — holding partial or unexpected output aside, unused, because
  the run that produced it did not reach a clean terminal state.
- **Late result** — output arriving from a superseded attempt after its successor
  exists. Always rejected; it describes a state nothing is bound to any more.

## Risk

- **High-risk** — a change for which any of `migration-strategy`'s four
  classification answers (reviewability, preservation, breadth, failure
  surfaces) leaves the ordinary route, or that the user or project marks so.
  Never a feeling about size: the answers are recorded, and "pending
  classification" is high-risk until resolved.
