---
name: eliminating-corrections
description: "Turns a correction a human made to the agent's work into the strongest proportionate way of making that class of mistake impossible, automatic, or caught. Use when the user corrects what the agent did or how it did it, says no, don't do that, that's wrong, it should be like this, I told you this before, or stop doing this, reverts an edit the agent made, repeats a review comment on a later change, or asks how to stop this kind of mistake from happening again. Skip a bug whose cause is unknown, a failure that reached production, and a one-off preference that cannot recur."
---

# Eliminating Corrections

A correction fixes one instance. The class of mistake behind it stays open
until something that needs nobody's memory closes it: a shape that cannot
hold the wrong state, a tool that writes the right one, or a check that
fails on the wrong one. A rule is what remains when none of those fits, and
a reviewer is what remains after that. Propose the highest rung that fits
the class, in writing, and build nothing until the user chooses.

## When to use

- The user corrects what you did or how you did it: "no, don't do that",
  "that's wrong, it should be X", "I told you this before", an edit of yours
  reverted, a review comment that comes back on a later change.
- The user asks how to stop a kind of mistake from happening again.
- **Skip** a bug whose technical cause is unknown; invoke `debugging`.
- **Skip** a failure that reached users or production, lost work, or
  failed a whole work cycle; `post-mortem` owns why the safeguards missed it
  and runs its own audit of them.
- **Skip** when the user wants to know what the session did and why;
  `diagnosing-a-session` reconstructs that from the transcript.
- **Skip** a one-off: a preference stated for this task with no second
  instance in sight. Apply it and say in one sentence why it is one.

## Step 1: Honor the correction

1. Before applying anything, record the wrong state: the commit that holds
   it, or its hunk saved to a scratch file outside the work tree. For a
   mistake in how you acted, record the exact command or tool call. If the
   user already reverted it, recover the hunk from the history or from your
   own earlier output. It is the one input a check in Step 5 must fail on,
   and applying the correction overwrites it.
2. **REQUIRED SUB-SKILL:** when the correction arrives as review findings
   (a reviewer's report, a PR comment), invoke `receiving-code-review`
   first; it verifies them and owns their fix. Only a finding it records as
   verified enters Step 2.
3. Otherwise, apply the correction to the instance in front of you, as
   given, before anything below. A correction the user gives is a user
   instruction: it outranks the plan, skill, or file text that led you the
   other way.
4. If it cannot be applied as given (the thing it names does not exist, or
   it contradicts a check that is green), say what blocks it in one sentence
   and end the turn. Never argue past that sentence.
5. If applying it changes behavior, invoke `test-driven-development` and
   `yagni` first, as for any edit.
6. The apology is not the end of the turn. Go to Step 2 in the same task.

## Step 2: Name the class

1. Write four lines from evidence, not from a memory of what you intended:

   ```text
   Did: {{what you produced or did, with its path or command}}
   Corrected to: {{what the user wants instead, in their words}}
   Cause: {{missing context | misleading text in a skill, plan, doc, or comment | no check on the path | a design that allows both | a default that chose wrong}}, at {{where}}
   Class: {{one sentence that matches the next instance of this mistake and not its neighbours}}
   ```

2. Find the cause by reading: the file you were in, the instruction you
   followed, the check that did not run. If a skill, plan, doc, or comment
   said the wrong thing, quote it. That text is a cause, whatever else is.
3. If the cause is not visible in this conversation, write `Cause: not
   visible` and go on; the class is named from what was done and what was
   corrected, and the ladder's top rungs close a class without its cause.
4. Test the class sentence against a neighbour: a nearby case that must not
   count. A class as narrow as the instance ("don't hard-code the tenant in
   `orders.py`") matches nothing next time; one as wide as "be careful with
   queries" matches everything, and nothing can close it.
5. If no second instance is plausible, this is the one-off the skip names.
   Report that in one sentence and stop; no skill is needed here.

## Step 3: Climb the ladder

Start at the top. For each rung, answer in one line: can this class be
closed here, and what would it cost to build, to run, and to keep? Stop at
the highest rung whose cost fits the class, where the class's cost is how
often it recurs times what an instance costs to find and undo. Keep the line
for every rung above the one you choose; "not possible" needs its reason.

1. **Remove the possibility.** Change the design or the data structure so
   the wrong state cannot be written: a type that cannot hold the bad value,
   a constructor that demands the field, a function that takes the right
   thing so the wrong thing has no entry, a surface deleted. Nobody
   remembers anything.
2. **Make the right result automatic.** A safe default, a derived value, or
   a formatter or auto-fix that writes the right output on the path where
   the mistake is made, so it is overwritten instead of noticed. It counts
   only when nobody chooses to run it: in the code path itself, or run by
   CI. A generator or codemod someone must remember to run is a one-time
   fix; keep the class closed with a lower rung, usually rung 3.
3. **Catch it with a deterministic check.** A test, lint rule, type check,
   or validator that fails on the wrong state and passes on the right one,
   run where nobody can skip it: CI, on every change. Run the same check
   earlier too when a late catch is expensive, as a pre-commit hook or as a
   hook in the harness that refuses the tool call, where the harness has
   one. The earlier run shortens the loop; the CI run is the enforcement. A
   hook without the CI run is not this rung, with one exception: a mistake
   in how you acted (a command run without asking) leaves no file state for
   CI to fail on. A harness hook that refuses the action is then the
   strongest check; propose it with a rung-5 rule for harnesses without one.
4. **Assert or watch at runtime.** An assertion, a guard that fails loudly,
   or an alert, only for a class no fixture can show because it depends on
   real data, real volume, or real time. It catches after shipping, so it
   sits below a check that catches before.
5. **Write a rule for the agent.** Put it where the agent is when it errs:
   a comment or module doc on the line the next agent reads before making
   the mistake, or a step in the skill that fires at that moment. A general
   instructions file is the last place: it is read once at session start,
   far from the mistake, among everything else read then. Text that caused
   the mistake is corrected or removed before any rule is added beside it. A
   rule holds only as well as it is read; that is why it is this low.
6. **Ask a reviewer to look for it.** An item in a review checklist or in
   the brief the project hands its reviewers. It holds only while someone
   reads, and the reviewer is often the same model that made the mistake.
   The last rung, never the first considered.

One correction is one observation. A rung 1 that rewrites a module for a
mistake made once is not the highest rung that fits; a rung 3 that costs ten
lines of test is proportionate to any class seen twice. Say which it is.

You took the tenant ID from the request body; the user corrected it to the
session's tenant, and the same comment came back on an earlier change. Rung
1: a query helper that takes the session and reads the tenant from it, with
the raw-ID helper removed, touches thirty call sites: proportionate to a
class seen twice whose instances each leak data across tenants. Rung 3, a
lint rule for the raw-ID helper, is cheaper but leaves the helper callable;
it is the fallback if the user declines the refactor.

## Step 4: Put the choice to the user

1. Ask this and end the turn; `clarifying-intent` owns what closes it.
   Build nothing before the answer.

   ```text
   Correction: {{what was corrected, one line}}
   Class: {{the class sentence}}
   Cause: {{one line}}
   Rejected above the recommendation: {{rung}}: {{reason, one line}}; {{one entry per rung}}

   1. Build rung {{n}}: {{what gets built}}, {{cost to build, run, and keep}}
   2. Build rung {{the next lower rung that fits}} instead: {{what gets built}}, {{cost}}
   3. Build rung {{m}}, the highest that is possible, at its cost: {{cost}}
   4. Close this instance only: no class to close

   Recommendation: option 1 — {{one sentence}}.
   ```

   Leave out option 2 when no lower rung fits, and option 3 when the
   recommendation is already the highest rung possible; the entries that
   remain keep their numbers.
2. A rung above the recommendation is the user's cost to accept; build it
   as chosen. Under option 4, say nothing more; the ladder stays in this
   conversation if the class returns.
3. When the user named the rung in the correction itself ("add it to the
   instructions file"), build that rung and name the higher rungs that were
   possible in one line, without asking again.

## Step 5: Build the chosen rung through its owner

1. Rungs 1 and 2 are a change to the product. **REQUIRED SUB-SKILLS:**
   invoke `architecture-decisions` first when the change is hard to
   reverse; then `test-driven-development` and `yagni` for the change. For
   a codemod that touches many files or owners, invoke `large-scale-changes`.
2. Rung 3 is a detector. **REQUIRED SUB-SKILL:** invoke
   `test-driven-development`; its detector rule applies: in the same test,
   pin the input the check must flag and a near-miss it must pass. The input
   it must flag is the state from Step 1.1, not a made-up example. A check
   never seen red on that state does not close the class. When the rung adds
   a job to CI or changes what CI runs for the whole project, invoke
   `verification-strategy`; one more test in an existing suite does not.
3. Rung 4 is a signal. **REQUIRED SUB-SKILL:** invoke `adding-observability`
   for an alert or a metric; an assertion in product code is a behavior
   change under rung 1's owners.
4. Rung 5 in a skill goes through **REQUIRED SUB-SKILL:** `writing-skills`,
   which owns the format and the proof that it changes behavior. A comment
   or module doc is a plain edit: put it on the line read before the
   mistake, and name the mistake it prevents, not the correction's date.
5. Rung 6 is an edit to the project's review checklist or reviewer brief.
   Say in the reply that it holds only while someone reads it.
6. Write the four lines and the chosen rung into the commit message of
   what you built, so the next instance of the class starts from them. Then
   return to the task the correction interrupted.

## When you are tempted to just remember

| The thought | The reality |
| --- | --- |
| "I'll keep that in mind" | Memory ends with the session. The next session makes the mistake again. |
| "I'll add a line to the instructions file" | That is rung 5, chosen without climbing. Rungs 1 to 4 have not been looked at. |
| "Sorry, fixed it" | The instance is fixed. The class is open until Step 4 is asked. |
| "Too small to be worth a test" | Small is the size of the fix, not of the class. Ten lines of test fit any class seen twice. |
| "It's just how the user likes it" | A preference that recurs is a convention; a formatter or lint rule holds it without anyone remembering. A preference that cannot recur is the skip. |
| "A test for this would be awkward" | Awkward to test means the surface should go: that is rung 1. |
| "Review will catch it" | Review is the last rung. It holds only while someone reads. |
| "It can't be a check, so a rule it is" | Say why each higher rung fails, in writing. "Can't" without the reason is a guess. |
| "The check I wrote passes, so it works" | A check never seen red on the mistake has proved nothing. |
| "The user said just remember this" | They asked for the class closed. The note is rung 5; they have not seen rungs 1 to 4. |

## Red flags

Stop and go back to the step named:

- Your reply to the correction ends with "noted" or an instructions-file
  edit and no class sentence: Step 2.
- You chose a rung with no written line for the rungs above it: Step 3.
- You are building before the user answered: Step 4.
- The check exists but was never run on the state from Step 1.1: Step 5.
- The rule is going into a general instructions file while the mistake
  happens inside one module: Step 3, rung 5.

## Gotchas

- A check written from the corrected code passes on its first run and has
  never met the mistake. The failing input is where Step 1.1 saved it;
  restore it in a scratch copy for the red run, then
  run the check on the corrected state for the green. Prevents a detector
  that has only ever seen good input.
- A pre-commit hook is absent on a fresh clone and skipped with
  `--no-verify`; a harness hook runs only in that harness. Where the
  mistake leaves file state, either shortens the loop and neither enforces.
  Prevents a hook proposed as "the check" that leaves the class open
  everywhere the hook is not installed.
- A correction that contradicts a skill, plan, or doc you followed is
  evidence that the text is wrong, not that you misread it. Left alone, the
  next session follows it the same way. Prevents a rule added beside the
  text that caused the mistake.
- "Remember this" names the outcome the user wants, not the rung. Taking it
  as a request for a memory note skips the ladder. Prevents a rung-5 answer
  to a rung-1 problem.

## Common mistakes

- Instead of running the ladder on an ordinary bug with an unknown cause,
  find the cause first; the ladder needs a named class, and a guess at the
  cause names the wrong one.
- Instead of carrying the ladder into a production escape, let
  `post-mortem` run its audit of every safeguard; this skill looks at one
  class and one correction.
