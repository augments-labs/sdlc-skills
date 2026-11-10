# Reviewing and shipping

The work is done, or nearly. This page covers what happens between "the
tests pass" and "it is on the main branch": the checks, the review, the
choice of what to do with the branch, and the release decision.

Example requests:

```text
Review this before I push.
```

```text
Is this ready to merge?
```

```text
What should we do with this branch?
```

```text
Can we release this build?
```

## Verification comes first

Before any review, `verification-before-completion` makes sure the claim
"it works" has something behind it. The agent lists everything the request
asked for and marks each item delivered, pending, blocked, or declined. An
item with several variants, such as a sync and an async path or two
platforms, gets a line for each, so one finished variant cannot stand for
the others. It runs the checks your project requires, reads their raw
output, and records which version of the code they ran against. If the code
changed after a check ran, the check does not count.

The result is a short ledger: what passed, on what state, and what is still
open. A required check that did not run turns the whole result red, however
green the rest looks.

## The review

`requesting-code-review` takes one frozen version of the change and gets an
independent verdict on it. "Independent" means a reviewer that is not the
agent that wrote the code.

How deep the review goes:

- **Standard** is the default: one reviewer reads the whole change. A
  specialist is added when the change matches a trigger, for example a new
  or changed interface, error handling that could hide a failure, or tests
  that should pin behavior.
- **Deep** adds a security role and an adversarial pass. Separately, a change
  that alters a trust boundary is not ready until a security review clears
  it, and high-risk transformations follow their own review rules.
- **Shallow** is a self-review. The agent never picks it on its own; it is
  used only when you, your project's policy, or the plan assigns it in
  writing. Tell the agent if that is what you want:

  ```text
  Self-review is fine for this one.
  ```

On agents with a subagent tool, the reviewer is a fresh agent that returns a
written report. Where there is no such tool, the agent asks you once whether
to self-review (labelled as such), to hand the change to someone you name,
or to leave the work pending. The self-review choice is not offered when the
review has to be independent, such as a security review.

The agent reads each report through `receiving-code-review`. It does not
apply feedback blindly: each point is checked against the code, accepted or
pushed back on with a reason, and a review round that keeps asking for the
same thing is bounded rather than repeated forever. A finding that a trust
boundary changed blocks readiness until a security review clears it.

To review a pull request someone else opened, ask for it by number
(`Review PR 42`): `reviewing-a-pr` reads that PR's exact head, runs the same
independent review on it without executing its code, writes the findings for
the author, and posts nothing (no approval, no request for changes, no
comment) until you choose what to post.

## What to do with the branch

With verification and review done, `finishing-a-branch` reads the state of
the branch and offers the transitions that state allows:

```text
Branch fix/stale-cache → main. Gates: all green. Review: ready.

1. Commit and keep
2. Push the branch
3. Push and open a PR
4. Integrate locally into main
5. Keep as-is

Recommendation: ...
```

Things to know about this menu:

- The agent waits for one of the listed entries. Praise, "looks good", a
  new constraint, a partial answer, or a decision about something else gets
  the menu again.
- Green checks and a ready review do not authorize anything by themselves.
  The push, the PR, or the merge happens because you chose it.
- If the branch has already been pushed, rewriting its history (squash,
  rebase, amend) needs your direct permission for each. The agent never
  force-pushes as a repair.
- If a pull request already exists, only the transitions that PR's state
  and your project's policy permit are offered. For a merged PR that means
  cleaning up what the task owns, or keeping things as they are.
- When opening a PR, the agent prepares the description from your project's
  contribution rules and PR template, and adds the check results, the review
  verdict, and what was not verified wherever the template has no place for
  them. A project with no template gets the skill's own: why, what changes,
  the checks run on that exact candidate, the review verdict, risk and
  rollback, what was not verified, and what is left for the reviewer to
  decide.

## Discarding work

Discard is never on the menu. If you want to throw the branch away, ask for
it by name. The agent then shows exactly what would be deleted (the branch
and its unique commits, staged, unstaged, and untracked changes, ignored
files, which nothing brings back, the worktree, any remote branch or PR) and
whether the rest is recoverable, and it asks you to type a
confirmation that names the candidate, using the candidate ID the agent
shows, such as `discard 9c41e07a2b5d18f3`. "Yes", "go ahead", or picking a
numbered option does not count, and if anything changes before the deletion
the agent shows a new list and asks again.

## Releasing

Pushing and merging are not releasing. When the result is something that
runs or ships (a deployable build, a package, a published artifact), the
agent hands over to `release-readiness`, which decides whether that exact
build is safe to release, and on what evidence. Ask for it directly when you
are at that point:

```text
Is build 2.4.0 ready to release?
```

## Finishing a plan

If the work was running under a plan (see
[Planning larger work](planning-larger-work.md)), the review and the branch
choice happen at the plan's own boundaries, and the executing skill owns
when they run. You still make the branch choice.
