# Package-manager bumps

Read before a dependency bump under npm, pnpm, yarn, Go modules, or pip with
hashes. Each has a form of bump that looks applied and changes nothing, or
breaks an install elsewhere.

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
