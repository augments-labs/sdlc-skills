# Releasing

How SDLC skills is versioned and how a release is cut. This is maintainer guidance, written for humans and AI agents alike — for contributing a change, see [`CONTRIBUTING.md`](CONTRIBUTING.md). Contributors never touch versions.

## Choosing the version

Versions follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html). For a skills library, the "public API" is the **skill surface**: which skills exist, their names (the invocation address — `sdlc-skills:<name>`), and how they install (the manifests).

- **Major** — the surface breaks: a skill is renamed or removed, or the invocation/manifest structure changes. Anything that invokes or installs the library must adapt.
- **Minor** — the surface grows, backwards-compatibly: a new skill, a new harness adapter.
- **Patch** — the surface is unchanged; existing skills behave better: trigger descriptions, discipline bodies, sibling files, docs, test records.

The tie-breaker when unsure: does a user gain something *new to reach for* (minor), or does something they already reached for *now work better* (patch)? Behaviour-shaping edits can be substantial and still be patches — v1.0.1 and v1.0.2 both changed discipline behaviour and were patches, because the surface held.

A release versions the cumulative `dev` diff since the last tag, not any single PR: the highest tier reached by any change in it decides.

## Who bumps, and when

Nobody bumps in a contribution PR. Versioning is decided once per release, by the maintainer, in the release commit — a PR that edits manifest versions or adds a CHANGELOG version heading will be asked to drop it (two parallel PRs cannot both own the next number).

## Cutting a release

1. Decide the tier (above) for everything on `dev` since the last tag.
2. Bump the version in all five manifests: `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `.kimi-plugin/plugin.json`, `plugins/sdlc-skills/.codex-plugin/plugin.json`, and the root `package.json` (the npm-installable OpenCode plugin package). The gate fails if they disagree, so a half-done bump cannot ship.
3. Add the `CHANGELOG.md` entry — terse, newest-first (*Writing the changelog*, below).
4. Run the gate: `bash scripts/sh/validate-skills.sh`.
5. Commit the bump on a release branch off `dev` as `chore(release): vX.Y.Z — <one-line theme>`, and merge its PR into `dev`.
6. Open the `dev` → `main` PR and merge it as a merge commit, so the individual changes stay in history and `main` never carries a commit `dev` lacks.
7. Tag `vX.Y.Z` on `main` and create the release: title `SDLC skills vX.Y.Z`, notes carrying the narrative — the field report that drove the change, what changed, and the evidence behind it.
8. Update the installed plugin, so the release is what actually runs. The updater reads the version from its own copy of the marketplace rather than from the remote, so refresh that first and then update the plugin — on Claude Code, `claude plugin marketplace update augments-labs` followed by `claude plugin update sdlc-skills@augments-labs`, which applies on the next restart. Skip it and every local session keeps loading the previous version while the tag says otherwise.

## Writing the changelog

An entry answers two questions and stops: **what changed**, and **why someone
using this library should care**. One or two sentences. A reader who wants the
investigation behind it follows the release link, which is what that page is for.

`CHANGELOG.md` has drifted from that before: across 110 entries the median is 273
characters and the longest is 936 — most of a whole skill description spent on a
single bullet. Cut these on sight:

- **The diff, restated.** Listing the files, functions, and flags that moved
  duplicates something git already stores exactly, and more precisely.
- **The reasoning that produced the change** — what was tried, what was measured,
  what was rejected, what the counterargument was. Release-page material, all of
  it.
- **The rebuttal to an objection no changelog reader is raising.**
- **Context repeated per bullet.** Under one version heading, say it once.

Get shorter by **cutting content, never by compressing prose** — the same rule
that governs skill bodies, for the same reason, and it fails the same way when
ignored.

An entry that resists cutting to two sentences is usually two entries.

## If you are an AI agent asked to release

Follow this file exactly, and if the tier is genuinely ambiguous, ask the maintainer rather than inventing a number.
