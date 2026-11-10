# Reworking existing code

The code works, and it is in the way: more complicated than the job needs,
shaped so that one change touches six files, carrying an interface you want
gone, or needing the same edit in four hundred places. This page covers the
four skills for that work. Each one measures before it changes anything, and
the decision to change stays with you.

Example requests:

```text
Is the notification module over-engineered? Don't change anything yet.
```

```text
Every new report type means edits in six files. Restructure the package.
```

```text
Deprecate the v1 export endpoint.
```

```text
Rename get_user to fetch_user everywhere, one PR per team.
```

## Is it more complicated than it needs to be?

The first request loads `complexity-audit`. It is a diagnosis: it changes no
code and approves nothing.

The agent pins the code it audits to one revision and lists what is there:
code, dependencies, configuration, build and test machinery, generated
sources, things wired together at run time, and consumers outside the
project. It then hands the audit to an independent, read-only auditor. Where
it cannot dispatch one, it asks you how to proceed;
[Supported agents](../reference/agents.md) describes that question.

The report goes under `.sdlc-skills/audits/`. Each finding is one row with a
decision: `keep`, `simplify`, `remove`, `decision` (someone accountable has
to choose), or `investigate`. What to expect:

- A claim covers only what was audited. A statement about the whole
  repository needs you to ask for the whole repository; otherwise the report
  names the part it read.
- "Nothing calls this" does not mark code for removal. Code that could be
  reached through configuration, reflection, generated code, or an outside
  consumer stays `investigate` until that is ruled out. A module called only
  by its own tests counts as having no caller.
- Tests and rollback machinery are not treated as overhead while a check or
  a recovery guarantee depends on them.
- If the code has uncommitted changes and git does not ignore the report's
  path, the agent stops and asks for a checkpoint commit, or for a report
  path that is ignored or outside the repository.

To act on a finding, ask for it. An accepted structural finding goes to
`refactor-architecture`; a change to behavior goes through the ordinary
feature or bug route.

## Restructuring

`refactor-architecture` changes the shape of code without changing what it
does. It starts by measuring: which change is expensive, how many files it
touches, who calls what. Friction nobody measured is treated as a
preference, not as a reason.

Before any edit, in a worktree, the agent sets up tests that pin the current
behavior and checks that they can fail: green on the code as it is, red on a
deliberate change, green again once that change is undone. Then it writes a
structural proposal under `.sdlc-skills/designs/` and asks:

```text
1. Approve under the preservation gate
2. Request changes
3. Reject and retain the current structure
4. Cancel
```

The agent never picks the structure itself. After approval it works in
slices: move one piece, migrate its callers, run the preservation tests,
compare against the measurements in the proposal, and keep the green state.
If behavior changes, it stops; a behavior change is a different piece of
work.

What to expect:

- A new abstraction needs evidence: behavior that repeats and has a stable
  owner, or a real external boundary. "We might need a second
  implementation" is not evidence.
- Before it removes, moves, or renames anything, the agent looks for every
  path that could still reach it, including the name used as a string (a
  dynamic import, a CI path filter, an ownership pattern). If it cannot be
  sure, the code stays, or waits for an approved removal from
  `deprecating-an-api`.
- When ordinary review and tests could not make the change reviewable and
  recoverable, or when you mark the work high-risk, the agent first gets a
  `migration-strategy` contract and a `verification-strategy` battery
  approved. [Planning larger work](planning-larger-work.md) covers both.

## Retiring an interface others call

`deprecating-an-api` handles a function, endpoint, response field, CLI flag,
config key, event, or metric name that something outside this repository
depends on. Deprecating and removing are two changes, and only the second
one breaks anyone. If every caller is in this repository and a search finds
them all, none of this applies: the agent changes the callers and the
interface together.

The order is fixed:

1. **Measure.** The agent lists the callers a search finds and treats that
   list as a lower bound. If nothing counts calls per caller, it adds a count
   and ships it first. Use that nothing measures is written as `unknown`,
   never as zero.
2. **Replace.** The replacement ships, tested and documented, before the old
   interface is marked. Where it can, the old path calls the new one, so the
   two cannot drift apart.
3. **Signal.** The deprecation goes where a caller will see it: the
   language's deprecation marker, the `Deprecation` and `Sunset` response
   headers, a warning on the error stream for a flag or config key, the
   schema's own deprecation field for generated clients. A changelog line
   alone is not a signal. The sunset date comes from your deprecation policy;
   without one, the agent asks you for it. This change removes nothing.
4. **Decide.** After the sunset date the agent reads the count again. If use
   is above zero or unknown and the old path can be switched off and on, it
   asks the owner whether to run one short brownout. Then it puts the removal
   to the owner, with the measured use and who breaks:

   ```text
   1. Remove: ship the removal change
   2. Hold until {{condition}}: keep the old path and the signal
   ```

The removal is its own change, and it does not ship without the owner's
recorded answer, even when measured use is zero. The record lives under
`.sdlc-skills/designs/`.

A stored data shape (a column, a field) is a different case:
`changing-a-live-schema` owns it, and
[Building a feature](building-a-feature.md) describes it.

## One change across many files

`large-scale-changes` is for one mechanical transformation too big for one
pull request: an API migration, a rename, a dependency bump, a lint rule
rolled out everywhere. The script is the change, and its output is evidence.

- The agent writes the transformation as a script and tests it with three
  fixtures: an input and its expected output, a second run that changes
  nothing, and an excluded path left untouched.
- It runs the script on a small, varied sample and reads every hunk. A wrong
  hunk is fixed in the script, never in the output.
- Script output, hand edits, and formatting go in separate commits. A
  lockfile is regenerated by the package manager, never edited by hand.
- The result is split into one shard per owner, from your ownership file, or
  per package when there is none. Each shard builds and passes its tests
  alone, in any merge order.
- A rule that would turn the build red once it is on (a lint rule, a strict
  compiler option) is switched on last, after every shard has merged.

Every shard goes through the checks and a review first. Opening the pull
requests is then your decision, asked once for the whole batch, with the
shard manifest (under `.sdlc-skills/designs/`) in front of you:

```text
1. Open one pilot shard first; open the rest after it merges
2. Open every shard now
```

While shards are open, the agent keeps them current by rerunning the script
when the base branch moves; it never merges generated changes by hand. After
the last shard merges, it reruns the script over everything to catch call
sites added in the meantime and ships them as one more shard.

If the change removes or renames an interface that outside code calls, the
deprecation above owns the marker, the date, and the removal; this skill
moves the callers inside the repository.

## Related guides

- The contracts a high-risk restructuring waits for:
  [Planning larger work](planning-larger-work.md).
- What happens to each branch once the work is done:
  [Reviewing and shipping](reviewing-and-shipping.md).
