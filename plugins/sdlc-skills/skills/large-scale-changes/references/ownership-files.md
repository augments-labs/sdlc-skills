# Ownership files

Read before splitting shards by a `CODEOWNERS` file. Both hosts resolve it in
ways that name the wrong reviewer or undercount the approvals a shard needs.

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
