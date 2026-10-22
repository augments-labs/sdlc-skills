---
name: large-scale-changes
description: "Applies one mechanical change across many files, packages, or owners with a script, and splits the result into shards each owner can review, merge, and revert alone. Use when writing or running a codemod, or when the user says migrate every call site, rename this everywhere, bump X across all packages, roll out this lint rule or config everywhere, or split this into PRs per owner. Skip a change that fits one reviewable PR, and skip restructuring code whose shape is the problem, which refactor-architecture owns."
---

# Large-Scale Changes

The script is the change; its output is evidence. Review the script and a
sample, regenerate instead of merging, and ship one shard per owner. This
skill never decides how many PRs to open or whom to ping, never deprecates
an interface other teams call, and never redesigns structure.

## When to use

- One known transformation (an API migration, a rename, a dependency bump,
  a lint rule or config rollout) touches more files, packages, or owners
  than one PR can carry.
- **Skip** a change that fits one reviewable PR: do it by hand under
  `test-driven-development`.
- **Skip** code whose shape is the problem: `refactor-architecture` owns
  that. It may hand a slice here once the slice is one mechanical change.

## Step 1: Pin the change and its boundary

1. Write the transformation as one sentence: from what, to what, over which
   paths. List the paths it never touches: generated, vendored, and lockfile
   paths, each with the tool that regenerates it.
2. If the change removes or renames an interface that code outside this
   repository calls, **REQUIRED SUB-SKILL:** invoke `deprecating-an-api`. It
   owns the marker, the date, and the removal; this skill migrates the
   callers in this repository in bulk and returns to it.
3. If the change is a dependency bump: read the changelog of every version
   between the current one and the target, not only the target's, and list
   each breaking change as part of the transformation. Keep one target
   version per package-manager workspace unless the user says otherwise.
4. **REQUIRED SUB-SKILL:** invoke `using-git-worktrees` for one workspace
   on the base the shards will target. The script lives there, in the
   repository, under the project's scripts path.

## Step 2: Write the script, then prove it on a sample

1. If the pattern depends on context (a type, an import, a scope, the shape
   of an argument), transform the syntax tree or use the language's own
   refactoring tool; regex over text changes the wrong lines.
2. **REQUIRED SUB-SKILL:** invoke `test-driven-development` for the script
   with three fixtures: an input and its expected output; a second run over
   that output that changes nothing; an excluded path left untouched.
3. Run the script on a small, varied sample: a handful of files from
   different packages, including the oddest cases found. Read every hunk.
   If a hunk is wrong, fix the script and rerun; never edit the output.
4. Run it over the whole scope. Review the script, the sample, and a per
   package count of changed files; read the full diff only where a count is
   not what the script predicts.

## Step 3: Commit in layers

1. Put each script run's output in one commit whose message names the script
   and its revision. Put every hand edit (a case the script could not decide)
   in a separate commit. Put formatting churn in its own commit or leave it
   out.
2. If a lockfile changes, regenerate it with the package manager and read
   its diff: a transitive dependency that moved is part of the change and
   goes in the report. Never hand-edit a lockfile.
3. If the change turns a check red once it is switched on (a lint rule, a
   strict compiler option, a config that fails the build), the switch-on
   ships last, as its own change, after every shard has merged. Until then
   it runs as a warning or not at all.

## Step 4: Shard per owner

1. Split by the project's ownership file, or by package when there is none.
   Open `assets/shard-manifest.md` before the first shard branch is cut,
   and fill one row per shard.
2. Each shard must build and pass its tests alone, against the current base,
   in any merge order. If a shard needs another shard's change, that shared
   part is not a shard: ship it first as its own change and build the
   shards on it.
3. Produce each shard by rerunning the script restricted to the shard's
   paths on its own branch, never by picking hunks out of the full run. Cut
   each shard's branch from the manifest's base in its own worktree
   yourself, recorded as a task-owned resource in the workspace record;
   `using-git-worktrees` run here would reuse this worktree.
4. Opening the PRs and pinging the owners is the user's decision, once for
   the batch. Ask with the manifest in front of them and end the turn;
   `clarifying-intent` owns what closes it:

   ```text
   {{n}} shards for {{m}} owners, {{k}} files; manifest at {{path}}.

   1. Open one pilot shard first ({{shard}}); open the rest after it merges
   2. Open every shard now

   Recommendation: 1 — {{one sentence}}.
   ```

5. For each shard the answer covers, **REQUIRED SUB-SKILLS:** invoke
   `verification-before-completion` and `requesting-code-review` on the
   shard's revision, then `finishing-a-branch` with that answer as the
   direct instruction for its push-and-PR transition; do not ask again per
   shard while the shard's revision and PR title/body match what the
   manifest recorded when the question was asked. Write the revision, the
   link, and the state in the manifest. A shard whose revision or payload
   changes afterwards (Step 5) is asked again by `finishing-a-branch`.

## Step 5: Keep shards current until the last one merges

1. If the base moves under an open shard, merge the new base into the shard
   (a conflict in a file the script rewrites takes the base's whole file),
   rerun the script on the result for that shard's paths, and commit the new
   output on top. Never rebase or merge generated hunks by hand.
2. If a review changes the transformation, change the script, rerun it on
   every open shard, and record the script's new revision in the manifest.
3. Report the manifest with every shard's state. The change is done when
   every shard and the switch-on, if any, have merged; report anything else
   as in progress.

## Hard stops

- Hand-editing a lockfile, a generated file, or the script's output to fix
  what the script got wrong.
- Opening a PR or pinging an owner before the user's answer to the Step 4
  question.
- A shard that cannot build and pass its tests alone against the base.
- Rebasing or merging generated hunks by hand when the base has moved.

## Gotchas

- In a GitHub `CODEOWNERS` file the last matching pattern wins, a `!`
  negation or a `[ ]` range is invalid and that line is skipped without an
  error, and a path no pattern matches has no owner at all; the file read is
  the one on the PR's base branch. A shard split by the first match, or by
  a file on the task branch, names the wrong reviewer — shows when a shard
  for one team gets a review request from another, or from nobody.
- GitLab `CODEOWNERS` sections are enforced separately: the last matching
  entry in each section applies, so one path can need an approval from
  every section that matches it, and a `^[Section]` is optional on merge
  requests only. One shard per path owner undercounts the approvals a shard
  needs — shows when a merged-looking shard waits on a second section.
- npm `overrides`, pnpm `overrides`, and yarn `resolutions` are read only
  from the workspace root manifest; one written in a package's own
  manifest is ignored or warned on, and npm refuses an override of a direct
  dependency whose spec differs from the dependency's (use `$name` to point
  at it). A per-package override "bump" changes nothing — shows when the
  lockfile diff after the bump is empty.
- Go versions in `go.mod` are minimums under minimal version selection:
  `go get m@v` holds only until something requires a higher `m`, and a
  downgrade also downgrades every module that requires the removed
  versions. In a `go.work` workspace `go get` edits one main module at a
  time, so a bump across the workspace is one run per module — shows when
  a "bumped" module still builds against the old version.
- With pip, a `--hash` on any requirement turns hash-checking on for all of
  them, including every transitive dependency, and one entry without a hash
  fails the install; a package with wheels per platform needs a hash per
  wheel. A bump that rewrites one line of a hashed requirements file breaks
  installs on the other platforms — shows when CI on one platform passes
  and another fails on the same commit.

## Common mistakes

- Instead of taking zero remaining matches as proof that every caller
  moved, write what the script cannot see (other repositories, generated
  clients, names built from strings) in the manifest's Not covered section.
- Instead of one shard per directory or per file, make one per owner: a
  reviewer handed ten shards approves none of them.
