---
name: viewing-artifacts
description: "Shows the state of the artifact trail — briefs, specs, designs, plans, execution — at a glance instead of file by file. Use when the user asks where the project stands, what needs attention, whether the plan is still in sync with the spec, to see the state of specs and plans, or to visualize the trail. Skip when one artifact must be read, written, or edited."
---

# Viewing Artifacts

One self-contained page answers "what is the state of my SDLC work, and what
needs attention?" from the `.sdlc-skills/` artifact trail. Every value on it
is derived from a real marker; where no marker exists the page says unknown.
A confident guess is fabrication — the failure this skill exists to prevent.
The page carries state, not documents.

## When to use

- The user asks for the state, progress, or drift of their SDLC work — what needs attention, how far each initiative is, what changed after a downstream artifact consumed it — or asks to see the trail as a page.
- **Skip** when a specific artifact must be read, created, or edited: that is the owning skill's work, and this skill never mutates the trail.
- **Skip** when there is no trail and nobody asked for its state — an unprompted empty page helps nobody.

## Available scripts

- **`scripts/start-server.sh`** and **`scripts/stop-server.sh`** — start and
  stop the governed localhost preview (per-session key, owner watchdog, idle
  timeout). They wrap `scripts/serve.py`; never run another server.

## Step 1: Read the trail

1. Resolve the project root: the main checkout, even from a linked task
   worktree, because the trail and its plan mirrors live there. When the
   common git directory is not a checkout's `.git` (a submodule, a separate
   git directory, a bare repository's worktree), the root is the current
   checkout's top.

   ```bash
   if common="$(git rev-parse --git-common-dir 2>/dev/null)" && common="$(cd "$common" && pwd -P)"; then
     case "$common:$(unset GIT_DIR GIT_WORK_TREE; git -C "${common%/.git}" rev-parse --is-bare-repository 2>/dev/null)" in
       */.git:false) root="${common%/.git}" ;;
       *) root="$(git rev-parse --show-toplevel 2>/dev/null)" || root="$PWD" ;;
     esac
   else
     root="$PWD"
   fi
   ```

   Read `$root/.sdlc-skills/`: `briefs/`, `specs/`, `designs/`, `plans/`,
   `verification/`, `audits/`, `post-mortems/`. Absent folder → unreached
   phase.
2. No `.sdlc-skills/` → render the template's empty state naming what
   produces artifacts. An artifact at a user-set path → read it where its
   recorded pointer names it: a pointer field, a ledger row's `Location`, or a
   plan's bound inputs. A recorded path that cannot be read → that artifact's
   values unknown, and Step 3.3 names the cause class. Never search the
   filesystem for look-alikes.
3. Read `references/state-derivation.md` before deriving a value. Derive
   every value by its rules: slug allowlist, phase artifacts, approval
   sources, drift, attention grouping.
4. Match each section's approved version and location to its decision
   ledger (append-only, outside the artifact); preserve its own decision
   vocabulary. Take task progress from the plan's
   ledger rows, never the index checkboxes; only the state `done` counts
   complete. Compare consumed identities for drift; timestamps alone
   indicate possible staleness, never prove freshness. No value → unknown.

## Step 2: Render

1. Open `assets/page-template.html` before filling anything. Follow its
   top-of-file and region comments: region order, repeats, omissions,
   allowed values. Fill every region it marks.
2. Entity-encode every artifact-derived value before inserting: `&` first,
   then `<`, `>`, `"`. Derived values go in as text, except two attribute
   values the template needs: a topic anchor `href`, `#topic-` plus an
   allowlisted slug; and an open-file `href` or visual `src`, the path of a
   file read in Step 1, relative to `views/index.html` and starting with `../`.
   Never write a URL or a scheme into `href` or `src`.
3. Before writing, `git check-ignore -q` the view path. Not ignored, and this
   checkout holds a candidate a verification or review is bound to → ask
   whether to write it there and stop until the user answers: the write is
   content, and it moves that candidate's digest. A status question is not
   consent to that.
4. Write exactly one file: `$root/.sdlc-skills/views/index.html`, never one
   inside a linked task worktree. Create `views/` if missing. No external
   URLs, no JavaScript, no scratch or backup files. Regeneration recomputes
   from the trail and rewrites in place; never merge a previous render.

## Step 3: Deliver

1. Deliver the file path and offer to serve the page, root `.sdlc-skills/`,
   entry `views/index.html`. Start it from `$root`, only after the user
   accepts:

   ```bash
   bash scripts/start-server.sh --root .sdlc-skills --entry views/index.html
   ```

2. Hand over the printed URL. Serving fails or declined → the file path
   stands. `needs python3` → say so, name the platform's install route,
   deliver the file path. Install a runtime only on explicit request.
3. Reply in one short message: path or URL, as-of UTC, every place the page
   says unknown or omitted a block, whether drift came from file mtimes, and
   the cause class of any ledger pointer that could not be honored.
4. No longer needed → `bash scripts/stop-server.sh {{pid}}`, with the `pid`
   from the startup record.

## Gotchas

- Run without `--root`, `bash scripts/start-server.sh` exits 1 with
  `needs --root DIR`, and the file-path fallback in Step 3.2 hides that no
  preview started.
- A status request is not consent to a background listener: a preview started
  unasked opens a local port the user never agreed to.
- From a linked task worktree, the `.sdlc-skills/` beside the worktree's files
  is absent or an older committed copy: reading it shows a false empty trail,
  and a view written there changes the candidate digest that a pending
  verification or review is bound to.
- In a checkout that is itself the candidate, a view written under a trail the
  project does not ignore still changes that checkout's digest.
