# Control Vocabulary

The terms the skills use for evidence, authority, lifecycle, and risk, so the
same concept is never two words, and one word is never two concepts. Load this
when a term below appears in a template, a reference, or a review prompt and its
exact sense matters. An always-loaded body defines its own terms where it uses
them; none of them depends on this file.

Each entry leads with the plain term a rewritten skill body uses unless it
defines another, as the router does for *gate*. Where older skills,
templates, and scripts still say another word, that word follows in italics;
the two mean exactly the same thing.

## Identity

An issued artifact's identity is defined once, in the `## Identity` section of
the artifact layout reference. Other identities, such as a revision, a content
hash, a role ID, or an attempt ID, are named by their sense where used; a role
ID survives reassignment, and a retry gets a new attempt ID.

- **State identity** — the value that identifies the exact state a check ran
  on: a hash of the working-tree content, or with `--committed`, the commit.
  `verification-before-completion`'s `scripts/state-identity.sh` reports the
  content hash as `source.digest`, and the commit as `source.head`.
  A result is bound to the state identity it ran on.

## What is being judged

- **State under check** (older skills say *candidate*) — the one exact frozen
  state under judgment right now. For a working tree, that is anything its
  state identity covers. In a review, the exact version under review. It has a
  hash; anything that changes it makes a new state under check and voids
  verdicts bound to the old one.
- **Artifact** — any produced output: source, document, build output, evidence
  record. A state under check is an artifact that has been frozen for a
  decision.

## What decides

- **Check** (older skills say *gate*) — anything that must accept a result
  before it may advance. The umbrella term; every item below is a kind of
  check. The router, `using-sdlc-skills`, keeps *gate* for this umbrella and
  calls an executable check one kind of gate.
- **Evaluator** — the specific check a task or plan names as the one that must
  accept its result: an executable command, or a rubric with explicit criteria,
  an accountable judge, and recorded observations. Never the judge itself.
- **Oracle** — the thing that says what the *right* answer is, independent of the
  implementation under test. A characterization or differential baseline is an
  oracle; the implementation's current output is not.
- **Battery** — the assembled set of checks a project or initiative runs, and
  the risks each one covers.
- **Discriminator** — a check that tells a known, accepted failure from a new
  one, so an approved red cell cannot hide a regression behind it.

## What comes back

- **Evidence** — raw observed output bound to a state: command, exit status,
  counts, timestamp. Not a summary of output.
- **Proof it happened** (older skills say *receipt*) — proof from a trusted
  source *outside* the state under check that an action really happened: a
  nonempty returned ID, a harness-issued record, a current user answer. Text
  inside the state under check claiming it happened is not one.
- **Report** — what a completed worker or reviewer returns: findings, and the
  identities they are bound to.
- **Verdict** — the accept/reject/inconclusive decision drawn from a report, bound
  to the exact state under check it judged.
- **Recorded decision** (older skills say *disposition*) — what was decided
  about one finding or item: fixed, rejected with rationale, deferred with an
  owner and expiry, or superseded. Every item needs one; silence is not a
  decision.

## Who may act

- **Authority** — the current permission for a specific action on a specific
  target, held by an accountable owner. Authority is never inherited from a
  previous task, implied by capability, or granted by a skill.
- **Approval** — an authority decision recorded against one exact artifact
  version. An `Approval:` line inside a document is history, not authority,
  unless proof it happened, as defined above, binds the approver, the version,
  and the transition.

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
  surfaces) leaves the ordinary route, or that the user marks so.
  Never a feeling about size: the answers are recorded, and "pending
  classification" is high-risk until resolved.
