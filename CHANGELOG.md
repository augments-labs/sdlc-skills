# Changelog

Notable changes to SDLC skills, newest first. Versions follow semantic versioning; the narrative for each release lives on its release page — this file is the terse, cumulative record.

## [Unreleased]

### Changed

- **`using-task-branches` is `using-git-worktrees` again, and the body now says how.** The skill walks the worktree flow step by step — detect a linked worktree or submodule, prefer a harness-native worktree tool, put the worktree under `.worktrees/` at the project root and prove it is ignored with `git check-ignore` before creating it from the proven base — and adds pressure rows for the ignore gate, the native tool, and a sandbox that blocks the path. This reverses the earlier rename: the default has been a worktree since 6.2.4, so the name should say so. Callers of `sdlc-skills:using-task-branches` must update.

## [6.3.3] — 2026-09-09

### Changed

- **The comparison surface reads as a document and shows every variant side by side.** `ui-ux-design`'s shared chrome becomes a single document column with an ink-and-orange palette, a version banner that names the open decision, a feedback strip, and a board that lays every variant out at once before any tab is chosen. The stub contract, radio-driven switching, and version markers are unchanged.

## [6.3.2] — 2026-09-09

### Changed

- **Ceremony scales with the task; approval does not.** The entry skill now says that each loaded skill's own skip conditions set how much procedure a small change needs, while a decision a skill puts to the user is owed at every size.
- **A review loop that is not converging stops.** `receiving-code-review` counts rounds on one candidate: a repeated finding class or a third round without convergence records `needs decision` and routes the dispute to its owner instead of another round.
- **Four descriptions trigger without summarising the workflow.** `viewing-artifacts`, `containing-an-incident`, `zoom-out`, and `using-sdlc-skills` lose the trailing sentence that described how they work; every trigger and skip stays.
- **Bodies defer to the files that own the rule.** `viewing-artifacts` moves its state-derivation rules to a reference, the plan skills point at their templates for the contract fields those templates define, and the TDD and YAGNI entry rule is stated once, in the router. The largest always-loaded body drops from about 2841 to 2198 tokens.

### Removed

- **The offline plan-execution contract runner.** It matched exact wording in four shipped files, so it could only catch a rephrasing; the behavioural scenario for that boundary stays.

## [6.3.1] — 2026-09-08

### Changed

- **Session start is the sole activation mechanism across adapters.** The resident router requires relevant skills before responses or actions, replacing tool and turn-end guards.
- **Subagent models are selected explicitly according to the decisions remaining.** Planning and review share the same capability tiers, avoiding accidental inheritance of the parent model where selection is supported.

## [6.3.0] — 2026-08-28

### Added

- **A turn-end guard on the done boundary.** When a session has changed code and `verifying-completion` has not run since, the turn is blocked with the reason rather than ending on an unverified completion claim. It fires on the change, not on the wording, and goes quiet once honoured; a turn that pauses to ask you something is left alone. Measured: 0 of 5 bare runs reached the done boundary having verified; 3 of 3 did with the guard active.

### Changed

- **`verifying-completion` reads what a gate asserted, not only how it exited.** A suite that goes green over assertions that could never go red is no longer citable as evidence for the code it covers — the agent says so in the claim and names repairing it as separate scope. Measured: a hollow project gate survived bounded feature work unremarked in 4 of 6 runs before, 0 of 6 after.

## [6.2.8] — 2026-08-26

### Changed

- **Routing authority now lives in the skills, not a central router.** Each skill's body binds its own preconditions, boundaries, and handoffs — claimed on evidence, never assumption — and `using-sdlc-skills` becomes the entry skill that gets the first one loaded and keeps the chain unbroken. Four missing done-boundary handoffs were added so a session's exit always names its next owner.
- **No adapter re-injects the entry skill after compaction.** Compaction carries loaded context forward on every supported harness, so re-injection was redundant cost; injection now fires only where context is actually lost — start, resume, clear.

## [6.2.7] — 2026-08-24

### Fixed

- **Codex no longer deadlocks on a missing implementation-guard receipt.** Its adapter now relies on resident routing instead of blocking structured edits with a guard whose receipt path could fail; Claude Code and Kimi Code keep their existing enforcement.
- **Selected UI directions now have a durable delivery contract.** Approved visual references carry immutable artifact and rendering identities, ownership, freshness, and conformance gates through plans, tasks, execution, and visual verification; later sessions must validate those references and gates before completion.

## [6.2.6] — 2026-08-22

### Fixed

- **Codex hooks now match the events the CLI emits:** structured edits no longer remain blocked after nested skill reads, and compaction no longer fails with invalid hook output.

## [6.2.5] — 2026-08-20

### Fixed

- **An approved plan now runs to its end without checking in between tasks.** The `executing-plans` task loop gained the return edge and exit conditions it was missing, and the router now separates re-routing from ending the turn: an approved plan and mode authorize every task in it.
- **A visual decision keeps one page, with its versions inside it.** Iterating appends a selectable version block instead of forking a `-v2.html` sibling, so earlier versions stay comparable beside the new one and the link you were first handed keeps working.

## [6.2.4] — 2026-08-19

### Changed

- **`using-task-branches` now defaults to a git worktree.** An in-place `git switch -c` / `git checkout -b` rewires the shared checkout and blocks anyone else working in it; in-place switching is reserved for a checkout dedicated to the task, and user or project preference still wins.
- **The PR template no longer asks contributors for description re-scores.** Proof for a contribution is the deterministic gate plus the smallest behavioural scenario; trigger-rate scoring stays a maintainer-run tuning tool under `tests/optimizing/`.

## [6.2.3] — 2026-08-19

### Changed

- **`ui-ux-design` and `viewing-artifacts` hand you the link, not just the path.** Emitted pages are now served through the governed preview and the URL arrives with the delivery — no more asking for it; the file path is the fallback when serving fails or is declined.
- **A clear task no longer stalls at the first fixable obstacle.** `interview-me` and the router now state the boundary plainly: fix it and continue to completion; only material, destructive, or external-state decisions wait for you.

## [6.2.2] — 2026-08-19

### Added

- **A governed localhost preview for the skills that emit pages.** When you ask for a link — or the environment can't open local files — `ui-ux-design` and `viewing-artifacts` now serve their surfaces on 127.0.0.1 through a bundled, key-gated, self-terminating server, instead of leaving you a file path or improvising an ad-hoc one. The file path stays the default.

### Fixed

- **Both HTML templates: a modern palette and an enforced responsiveness contract.** Zinc neutrals with a true dark mode, and the fill rules now make 360px–2560px support mandatory rather than hoped for.

## [6.2.1] — 2026-08-18

### Fixed

- **`ui-ux-design` shows visual direction by default, not by exception.** An open visual direction now gets a rendered 2–4 variant comparison surface unless a stated reason is recorded, so "what should this look like" is no longer answered with prose alone — and new house-written guidance helps the agent generate genuinely different candidate directions, not just critique them.

## [6.2.0] — 2026-08-16

### Added

- **`containing-an-incident`: stop the impact, then find out why.** When a failure is reaching users, the skill goes first to the fastest safe lever — roll back, disable, drain — so an outage is not extended by a debugging session that could have run after users were served again.

### Fixed

- **`--arm none` works on claude-code.** The adapter set no isolated config home, so `~/.claude/plugins/` loaded the operator's installed skills no matter what `--plugin-dir` pointed at. The contamination guard caught it, so no result was ever mis-scored — but the one arm that can retire a skill was unavailable on any machine with the plugin installed.

## [6.1.1] — 2026-08-16

### Added

- **`ui-ux-design` ships its comparison-surface chrome.** Step 6's visual comparisons now start from a shared template (tokens, variant switcher, decision scaffolding), so every surface behaves identically and agents author only the variants.

## [6.1.0] — 2026-08-16

### Added

- **`viewing-artifacts`: one page for the state of the trail.** Ask for the state of your SDLC work and the agent emits a single self-contained local page from `.sdlc-skills/` — attention-grouped topics, per-topic artifact spine, drift flags from real change times, task and gate rollups — derived only from real markers, showing `unknown` where approval is underivable instead of guessing.

## [6.0.4] — 2026-08-14

### Fixed

- **Approved plans now enter disciplined execution before code changes.** Execution-mode replies invoke the executor, behavior-affecting work invokes TDD and YAGNI, plan indexes expose task state, supported structured edits are guarded when the chain is skipped, and conversational decisions leave harness-native user-question actions available.

## [6.0.3] — 2026-08-12

### Added

- **A silenced gate is not a passed gate.** `verifying-completion` now stops an agent reaching green by suppressing a finding, loosening a strictness setting, or excluding a path: that changes what ran, not what is true, and the claim the gate supported is unproven.
- **Coding standards set each automated check's strictness and its warning budget.** A tool left at its permissive default admits the very code the standard means to reject, and every level costs more to raise the longer a codebase grows underneath the looser one.

## [6.0.2] — 2026-08-12

### Changed

- **Every skill description is a trigger, not a summary.** Each states the situation you are in rather than what the skill does inside, so a skill fires on the words you would actually use — and a matched description no longer invites an agent to follow the summary and skip the body.
- **Fill-in templates moved from `references/` to `assets/`**, the split the Agent Skills standard defines. Skills are still invoked by name; only direct paths to those sibling files change.
- **Skill bodies are written as sentences again.** Several had been compressed into noun stacks to fit a house line limit stricter than the standard's, which is now a target rather than a wall.

### Added

- **Three skills bundle a script** where every run had been re-deriving the same facts by hand: branch state in `finishing-a-branch`, source identity in `verifying-completion`, and conformance in `writing-skills` — whose `check-skill.sh` checks any standard skill directory, including one outside this repository.
- **A conformance record** (`docs/agent-skills-conformance.md`) stating what the Agent Skills standard requires and where this library is deliberately stricter. The gate re-measures its numbers against the tree, so the record cannot drift into a claim that merely reads as checked.

### Removed

- **The activation gate and `validate-trigger-evals.sh`.** They failed a merge on a description's trigger rate, which is a tuning measurement rather than a pass mark. Those corpora now live under `tests/optimizing/` and stay out of CI.

## [6.0.1] — 2026-08-09

### Changed

- **Every adapter injects the full `using-sdlc-skills` body at session start, not a pointer to it.** A pointer costs ~90 tokens but buys only a *request* that the agent spend a discretionary tool call loading the router — and a discretionary call gets skipped, observed on exactly the task the router governs. The body costs ~1,500 approx tokens per context epoch and leaves nothing to skip. The text is read from `skills/common/using-sdlc-skills/SKILL.md` at runtime, never copied into an adapter, so editing the skill cannot silently stop shipping it.
- **Codex hooks ship inside the plugin** (`plugins/sdlc-skills/hooks/hooks.json`, declared as `"hooks": "./hooks/hooks.json"`) and resolve the injector through `$PLUGIN_ROOT`, because hooks run with the *session* working directory. A hooks file at the repository root is outside the plugin root, so an install would never load it. Two defects surfaced by executing the adapters rather than reading them: Codex was being sent the top-level `additionalContext` envelope instead of the nested `hookSpecificOutput` one it requires, and the injector hard-coded the phase-nested skill path, which resolved in this repository and nowhere anyone installs — it now handles the flat mirror layout too.
- **Kimi declares `PostCompact` re-injection.** Documentation-based, not verified live — there is no Kimi CLI in the environment that produced it, and `docs/sdlc-skills/harness-support.md` says so.
- **`dispatching-parallel-agents` names the uncallable-dispatch failure.** The receipt gate now requires an unavailable dispatch action to be reported as NOT dispatched, naming the action attempted and what the environment needs to make it callable, so the blocker is fixable rather than mysterious. `harness-support.md` binds the action per adapter and states that availability is a property of the installed build.
- **The product is written "SDLC skills" throughout** — the acronym keeps its capitals, "skills" is an ordinary word. The repository had been carrying three spellings at once.

### Added

- **`tests/run-session-start.sh`** — an offline CI gate on what every adapter actually injects: valid JSON in each harness's envelope, the canonical router body present verbatim with frontmatter stripped, escaping that survives the quotes and tables inside it, the echoed event name, and both skill-tree layouts. It executes the Codex plugin's own hook command from an unrelated working directory rather than grepping for it.

### Removed

- **The turn-end Stop nudge, on every adapter.** It re-routed whenever a turn's wording matched a completion word — a cadence, not a boundary — re-spending its full text in a long session, and buying each repetition with an extra model turn because it blocked turn-end. Routing that has to survive a long session belongs in the resident surface, re-applied only where the harness reports context was actually lost.
- **The pre-edit implementation guard.** It denied a session's first `Write`/`Edit` until `test-driven-development` and `yagni` had fired, and existed to catch the skipped pointer above. With the router resident, the pair led the first code edit unaided in **2 of 3** measured runs of the new `tests/scenarios/behavioral/implementation-entry-routing.sh`. That margin does not buy a hook that denies edits — and it was never the boundary it read as, since a shell heredoc writes code without passing through any Write/Edit tool. A partial gate that reads as a total one is worse than a stated limit.

## [6.0.0] — 2026-08-07

### Changed

- **The library is now SDLC skills, and the repository lives at `augments-labs/sdlc-skills`.** Breaking for everyone who installs or invokes it: the plugin is `sdlc-skills`, the Claude marketplace key is `augments-labs` (`/plugin install sdlc-skills@augments-labs`), and every skill is addressed as `sdlc-skills:<name>`. The name lived in three places at once — org, repository, plugin — and only one of them said what the library is.
- **The router skill is `using-sdlc-skills`** (was `using-augments`). Its trigger, body, and routing behaviour are unchanged; only the address moved. No skill `description` contains the old name, so no trigger changed.
- **Artifacts are written to `.sdlc-skills/`** (was `.augments/`), and receipt tokens carry the `SDLC_SKILLS_` prefix. A project with existing artifacts keeps them where they are; the directory is not migrated for you.
- **Documentation and mirror paths moved** — `docs/sdlc-skills/`, `plugins/sdlc-skills/`. Direct links to files under the old paths, including the images, no longer resolve.
- **The brand marks are a lifecycle ring**, replacing the letter-A monogram in both the plugin icon and `docs/images/`.

## [5.1.1] — 2026-08-03

### Fixed

- **`yagni` now fires when code is about to be deleted as unused.** Its body already carried the guard — never delete by confidence, prove absence across static, runtime, reflection, configuration, generated, and external-consumer paths — but the trigger named only implementation being written, so the discipline was unreachable at the moment it was needed. Observed: RED 1, GREEN 2.
- **`visual-ui-verification` now fires at an ordinary UI done-claim.** The trigger did not match everyday interface vocabulary, so a finished page presented as ready to ship reached completion checking and stopped there. It now names page, screen, and view, the done and ready-to-ship boundary, and the local-impression anti-pattern. Observed: RED 1, GREEN 2.
- **`spec-it` and `interview-me` name where their artifacts go.** Both produced a normative artifact while leaving its location to per-run inference, unlike every other artifact-producing skill; the spec location was already asserted by the behavioural scenario but never stated by the skill. The alignment brief also preserves other approved sections so it cannot overwrite an approved goal, scope, or feasibility section.
- **`finishing-a-branch` no longer contradicts its own trigger.** Its precondition demanded a readiness verdict for any source materialization, which swept in the commit-and-keep option on the explicit mid-development keep path the trigger exempts from readiness. Now scoped to final candidate materialization.
- **The assurance catalogue has a visual and interface correctness category.** `visual-ui-verification` directs an agent to become a `verification-strategy` matrix row, but the catalogue it selects from offered no such category.

## [5.1.0] — 2026-08-03

### Added

- **`visual-ui-verification` skill (testing)** — drives an integrated GUI or TUI across accepted states and conditions, retains candidate-bound raw and rendered frames, calibrates inspection with a known-bad frame, and returns defects and an evidence-backed verdict for verification and release gates.

### Changed

- **Local checkpoint authority is explicit.** Authorized repository edits include gated local task-branch commits unless higher-priority policy withholds them; checkpoints remain distinct from completion, review, push, publication, integration, discard, and cleanup.

## [5.0.0] — 2026-08-01

### Added

- **`migration-strategy` skill (design)** — governs wide rewrites and migrations through an approved preservation contract: translation rules, representative trial slices, partition ownership, convergence measures, abort conditions, cutover, rollback, and source-change reconciliation.
- **`complexity-audit` skill (maintenance)** — performs a read-only, evidence-bound audit of existing accidental complexity and hands accepted structural findings to `refactor-architecture` instead of mutating the audited target.
- **Dedicated YAGNI challenge boundaries** — a pre-edit challenger for material enduring surface, an exact-candidate reviewer, and an existing-code auditor, each owned by the lifecycle skill that activates it.

### Changed

- **Correctness-first contracts across the full skill surface.** Routing is authority-first and phase-sensitive; proposed artifacts, decisions, attempts, evidence, reviews, integration, and release verdicts carry explicit identities and cannot silently satisfy one another.
- **High-risk transformations now have first-class assurance.** `verification-strategy` owns project and initiative assurance matrices; TDD gains a preservation cycle; plans gain partitioned work queues; code review gains equivalence and adversarial roles; completion, branch finishing, and release readiness distinguish source green, reviewed, integrated, and releasable states.
- **Testing guidance is proportional to what deterministic gates and nondeterministic harness probes can actually prove.** Shared scenarios remain lean, live results retain failures and inconclusive outcomes, and temporary probes are removed after they expose and close the targeted gap.

### Removed

- **Per-prompt implementation reminder.** Lifecycle routing and existing implementation gates replace the retired reminder hook and `implementation-remind.sh`.

## [4.3.0] — 2026-07-29

### Added

- **`verification-strategy` skill (testing)** — designs the project's verification battery once per project, and again whenever the proof of correctness comes into question: acceptance behaviour tests against observable behaviour, a falsifiability audit with a closing mutation check, metric floors that fail the build (never targets), and CI wiring. Strict boundary: test mechanics stay with `test-driven-development`, honest claims with `verifying-completion`, per-feature gates with `writing-plans`' Evaluators. Activation 5/5 across all three harnesses; behavioural pair on Kimi — GREEN builds acceptance tests, a mutation floor, and a CI workflow (suite goes red when behaviour is gutted); RED fails the floor assertion as designed.

### Changed

- **`coding-standards` description narrowed to its conventions lane** — vocabulary, naming, patterns, never-do's — explicitly excluding proof-of-correctness, which is `verification-strategy`'s territory. The trigger overlap only became visible once the new skill existed. Own-scenario regression 3/3 across harnesses.

## [4.2.2] — 2026-07-27

### Fixed

- **`data-model` no longer disqualifies itself on stateless domains.** The trigger read "the data a system stores / skip when no persistent state", so a realistic stateless-but-domain-rich opening (a workflow engine holding no state) never routed to the skill — measured 0/2, landing on `interview-me`. The description now fires on concepts a system stores *or merely computes over* (3/3 post-fix, storage opening 2/2, 7/7 neighbors unaffected); the body gains a state-transitions step and makes the storage step conditional. (The initially reported Kimi 0/3 miss was a measurement artifact of an expiring auth session — corrected same day: 5/5 after re-login, all three harnesses green.)

### Added

- **`data-model` behavioural scenario** — asserts the shared design document names the concepts, models the lifecycle in words the opening never uses (an echo of the prompt fails it), and states invariants; the activation scenario now carries the opening that actually failed pre-fix.

## [4.2.1] — 2026-07-26

### Fixed

- **`writing-plans` body back under the CI token budget.** The `references/` pointer prefixes from the sibling uniformization pushed it to 1603/1600 approx-tokens and failed the token-budget step on main; three surgical trims (no behaviour change) bring it to 1587.

## [4.2.0] — 2026-07-26

### Added

- **Implementation-time enforcement.** A PreToolUse guard (`scripts/sh/implementation-guard.sh`) denies a session's first code edit until `test-driven-development` and `yagni` have fired — transcript-based on Claude Code, ledger-based on Kimi (whose hook payloads carry no transcript). Codex ships a per-prompt reminder instead: no project-level hook event fires in headless `codex exec` (measured), and the codex arm of the `yagni` behavioural scenario carries the pair rule as an `AGENTS.md` — the one channel Codex always reads. Fail-open everywhere; 25-case offline suite in `tests/run-implementation-guard.sh`.
- **On-demand references for eight thin skills** — ADR and coding-standards templates, security-audit checklists, release-gate details, handoff and post-mortem templates, dispatch-brief examples, and a data-model worked example.
- **`yagni` behavioural scenario** with assertions a description-recall test cannot make: an injected probe suite for correctness, naming/idiom/why-comment greps for craft, and a dependency/file-count cap for scope.
- **Craft discipline in `yagni`** — minimal ≠ unreadable: match the file, name for the domain, comment the why, simple over clever; the SessionStart nudge now names the TDD+yagni pair.

### Changed

- **All skill siblings live under `references/`** — one convention; pointer lines, cross-references, and `writing-skills` updated.
- **Hook scripts moved to `scripts/sh/`** (hook configs stay in `hooks/`); the nudge text is inline in `session-start.sh`.
- **`harness-support.md`:** the implementation boundary is now enforced in core — a deliberate, evidence-driven change to the former nudge-only policy, with the hook-honesty rules preserved.

## [4.1.3] — 2026-07-26

### Added

- **`spec-it` reference forms.** A requirement's acceptance criterion now takes the cheapest form that makes it checkable — a failing test, a mockup page, a reference implementation plus deltas, or a rubric — with prose as the fallback rather than the starting point. New sibling `reference-forms.md`; `spec-review.md` gains a sixth check that every referenced artifact resolves and runs.
- **Behavioural tests.** `tests/run-behavioral.sh` runs a two-arm comparison (RED loads the skills from a `git worktree` at `--base`, GREEN from the working tree) and the scenario's own assertions return the verdict as an exit code. Scenarios for `spec-it`, `test-driven-development` and `debugging`, each using a check a description-recall test cannot make: remove the subject and the test must go red.

### Changed

- **`test-driven-development`:** RED must run through the project's *own* command, and a broken project command must be fixed or named — a test the project's gate cannot execute is not a gate.
- **`spec-it`:** three step-6 loopholes closed, each found by running it — an open contract is not an exemption; a criterion that cannot go red is not a criterion; confirm it runs through the project's own command.
- **`tests/` rebuilt around one runner per test kind.** Scenarios were byte-identical across three harness copies (93 files → 44) and `run-behavioral.sh` was ~60% duplicated in each. Now one dispatcher per kind taking `--harness`, with `tests/harnesses/<name>.sh` holding only what differs per CLI. The deterministic gate moved to `scripts/sh/`.
- **Activation runner no longer truncates skill chains.** It killed the run at the first non-router skill, so a correct chain (`using-sdlc-skills → using-task-branches → test-driven-development → yagni`) was cut short and scored as a miss.

### Removed

- **`governance/`** — the adoptable deterministic-gate templates, with their references.
- **Dated evidence records.** `CLAUDE.md`, `CONTRIBUTING.md` and the PR template now ask for a re-run and the real numbers instead of a committed record.

## [4.1.2] — 2026-07-21

### Changed

- **Selftest fixtures inlined.** The three activation-detector selftests now write their fixture streams from inline heredocs to a temp dir per run; the committed `fixtures/*.jsonl` dirs are gone, leaving zero `.jsonl`/`.log` files under `tests/`. Identical content, identical checks, all three selftests pass.

## [4.1.1] — 2026-07-21

### Fixed

- **Duplicate hooks load in Claude Code.** `.claude-plugin/plugin.json` named `hooks/hooks.json` in a `hooks` key while the harness auto-loads that file, so every session logged `Hook load failed: Duplicate hooks file detected`. The key is dropped; a live probe confirms the SessionStart nudge still routes.
- **`writing-plans` body back under the CI token cap** after the trigger rewrite pushed it to 1610 (now 1598).

### Changed

- **`yagni` now chains from `test-driven-development` at the implementation moment.** TDD's GREEN step invokes it, and `using-sdlc-skills` names the pair — the router line is the load-bearing anchor (live A/B on both harnesses; the body sentence alone did not fire). `yagni`'s trigger rewritten: build MORE than asked vs deliver LESS than asked, no more, no less.
- **Five triggers de-vagued**, rewritten from their own bodies' vocabulary: `release-readiness` (names its real gate signals), `writing-plans` ("alignment brief" → a brief from `interview-me`/`spec-it`), `refactor-architecture` (concrete friction symptoms), `spec-it` and `feasibility-check` (Skip clauses added). Re-measured 10/10 on both harnesses.
- **Checkpoint commits.** `using-task-branches` and `verifying-completion` now tell an agent to bank verified work on the task branch as it goes — uncommitted work is one power cut from gone.

### Added

- **v4.1.0 live-verification debt closed on Claude Code** (account newly available): working-tree activation probes, the owed `ui-ux-design` probe, a RED/GREEN re-run of the 2026-07-19 `debugging` additions, and honest records under `tests/harness/claude-code/`.
- **Kimi Code scenario tree completed** (1 → 31 openings) with a live per-phase sweep record (8/8 activated, CLI 0.28.1); committed run artifacts purged and ignored.

## [4.1.0] — 2026-07-19

### Added

- **Kimi Code CLI adapter.** `.kimi-plugin/plugin.json` exposes the canonical skills directly (no mirror), loads `using-sdlc-skills` at session start, binds skill language to the harness's real tools, and re-nudges at the done boundary via a manifest-declared Stop hook. Live activation and Stop-hook proofs recorded under `tests/harness/kimi-code/`; the session-start nudge does not survive mid-session compaction (recorded gap).
- **Stop-nudge policy shared across harnesses.** `hooks/stop-nudge-detect.sh` holds the single done-boundary detector; Claude/Codex and Kimi wrappers only adapt payload and block format.
- **Token budget enforced in CI.** `token-budget.sh --max 1600` gates the always-loaded surface.

### Changed

- **Field-report skill improvements.** `finishing-a-branch` checks repo PR templates first; `writing-plans` writes plan files incrementally; `requesting-code-review` returns actionable findings with blocking/advisory dispositions and files the full report; `executing-plans` stops fix loops after three failed attempts; `debugging` greps the literal error string first and requires intermittent-bug tests to replay the observed failure.

## [4.0.0] — 2026-07-15

### Changed

- **`ui-ux` is now `ui-ux-design`.** The renamed invocation address reflects a broader interface-design workflow and is a breaking surface change for callers of `sdlc-skills:ui-ux`.
- **UI/UX design starts from project evidence.** Existing routes, components, tokens, content, previews, responsive conventions, accessibility rules, and tests constrain flows and directions before any new setup is proposed.

### Added

- **Portable visual decisions.** Progressive guides cover intentional design quality, 2–4 controlled alternatives, safe visualization fallbacks without a bundled server, and explicit human decision records. Codex activation and project-evidence behavior are recorded; live Claude activation remains unverified until account access is available.

## [3.0.0] — 2026-07-07

### Changed

- **`using-git-worktrees` is now `using-task-branches`.** The skill surface now reflects the actual workflow: start repo edits on a meaningful task branch or harness workspace, and use a worktree only when user/project preference or runtime isolation calls for one. This is a breaking invocation-address change for callers of `sdlc-skills:using-git-worktrees`.
- **Repo-edit routing starts with branch/status discipline.** `using-sdlc-skills` now routes edit, fix, refactor, and plan-execution requests through `using-task-branches` before repo exploration or implementation, with activation evidence recorded for Claude Code and Codex.

### Added

- **Branch-start activation fixtures.** The Claude Code and Codex activation harnesses can run scenarios inside a disposable git repo on `main`; Codex can also install the current checkout into a temporary authenticated `CODEX_HOME` for live working-tree probes.

## [2.3.0] — 2026-07-06

### Added

- **Codex plugin adapter.** New `plugins/sdlc-skills/.codex-plugin/` manifest, local `.agents/plugins/marketplace.json`, generated flat skill mirror, and `scripts/sync-codex-plugin-skills.sh` make the same 30 canonical skills installable in Codex without forking skill content. The structural gate now validates the Codex mirror and manifest versions.
- **Codex CLI harness evidence.** New `tests/harness/codex-cli/` covers install smoke, activation fixture selftests, 30 real activation scenarios, Stop-hook wrapper tests, and Codex-specific behavioral records for the discipline skills.

### Changed

- **Hooks are shared at the root `hooks/` layer.** The Claude Code hook manifest now points to `hooks/hooks.json`, while Codex project-hook config mirrors `hooks/hooks-codex.json`; both use the shared `hooks/context.md` and `hooks/stop-nudge.sh` where their event models allow it.
- **Docs no longer frame SDLC skills as Claude-only.** Harness-support docs, README status, and activation notes now describe Claude Code and Codex as exercised adapters, with Codex hook limitations stated explicitly.

## [2.2.0] — 2026-07-01

### Added

- **Done-boundary `Stop` re-nudge.** New `hooks/claude-code/stop-nudge.sh`, wired as a `Stop` hook, closes the long-standing "the verify/review skills don't fire after a long task" gap: SDLC skills routes once at SessionStart, but the done boundary arrives at turn-end with nothing to re-route. When a turn wraps up claiming the work is done, the hook re-routes **once** to `using-sdlc-skills` → `verifying-completion` (and, at a feature boundary, `requesting-code-review` / `finishing-a-branch`). It is a *routing* re-nudge, not a gate: it blocks no action, certifies no verdict, fires at most once (`stop_hook_active` guard), reads only the Stop payload, and fails open. Disable by removing the `Stop` entry from `hooks/claude-code/hooks.json`. Proof: offline `tests/harness/claude-code/test-stop-nudge.sh` + `2026-07-01-stop-nudge-done-boundary.md`.
- **Review-depth ladder in `requesting-code-review`.** Shallow / Standard / Deep tiers keyed to a change's risk and blast radius (not wall-clock), with an adversarial refute-pass at the Deep tier.
- **Plan-as-contract in `writing-plans`.** Per-task Consumes/Produces interface blocks, an index-level Constraints block, reviewer-gate task sizing, and an Execution Handoff (inline vs subagent-driven) at the present-and-pause.

### Changed

- **Leaner skill triggers (~620 always-loaded tokens).** 26 skill `description`s drop the embedded what-it-does summary that buried the trigger — which, per `writing-skills` doctrine, made the model follow the summary and skip the body; the `Use when…` trigger, the `Skip…` clause, and genuine this-vs-that disambiguation stay. Re-measured on the harness; the four ALWAYS discipline triggers were left untouched (trimming `yagni` measurably dropped its activation, so it was reverted). Record: `2026-07-01-description-token-efficiency.md`.
- **Explicit gap handoffs between adjacent skills** — `verifying-completion` → `requesting-code-review`, `spec-it` → design, `finishing-a-branch` → `release-readiness`, and others — so a chain does not stall half-done.
- **`executing-plans` de-serialized.** Three execution modes (inline / sequential offload / parallel fan-out), user-posture honoring, and per-task gate cadence clarified (sequential default; independent tasks fan out).
- **`yagni` relocated** `skills/implementation/` → `skills/common/` as a cross-cutting discipline — the invocation address `sdlc-skills:yagni` is unchanged — plus a consent-based never-work-on-`main` guard in `using-git-worktrees`, and a slimmer `using-sdlc-skills` router.

## [2.1.1] — 2026-06-26

### Changed

- **Routing-first delivery: a thin pointer to the `using-sdlc-skills` router.** The SessionStart bootstrap (`hooks/claude-code/context.md`) slims to a one-line pointer that re-fires on compaction; the routing discipline it used to carry — red-flags, the rationalization table, a deterministic-engineer mental-model graph — moves into the `using-sdlc-skills` body, removing the duplication between them. The philosophy is reconciled, not softened: a firm floor where there is only process, a deterministic gate where there is proof, never one dressed as the other (`docs/sdlc-skills/philosophy.md`).
- **The dispatch skills activate at the right moment.** `dispatching-parallel-agents`' trigger moves from a burden-of-proof description ("provably independent… quick enough inline") to a positive, observable one; the independence check stays in the body. `subagent-dispatch.md` drops the "optional" framing, points to the shared dispatch packet instead of duplicating it, and resolves a paste-vs-path contradiction.
- **The `.sdlc-skills/` output location is mandatory.** Across the nine writing skills the artifact path stops being an optional "default" and becomes the standard location, overridable only by the user, with one canonical phrasing; the five design skills write sections of one shared dated design doc. A validator assertion keeps it from drifting back.
- **The activation runners are routing-first aware.** Both harness runners judge the whole `using-sdlc-skills → X` chain (route-then-fire) instead of the first Skill call, with an offline fixture + selftest for the chain.

### Removed

- **The Codex adapter.** `.codex-plugin/` and the Codex references in the docs are removed — SDLC skills is Claude-Code-only for now; a real Codex harness returns when it is exercised and proven. (Past release history in this file is unchanged.)

## [2.1.0] — 2026-06-24

### Added

- **`governance/` — deterministic gate templates.** Adoptable CI / branch-protection / pre-commit templates that make the production-critical skills non-skippable at the commit/PR/CI boundary, where persuasion can't — branch-protection (CI-green + review + conversation-resolution, bulletproof), `tests-accompany-code`, `release-readiness`, `trust-boundary-flag` (heuristics, honestly labelled). Each maps to the skill it enforces; dogfooded on SDLC skills itself.

### Changed

- **Routing is firm and non-negotiable; the per-turn floor is gone.** The field test of v2.0's gentle/per-turn approach failed — the model skipped the loaded skill under momentum. The SessionStart bootstrap is rewritten firm (skip-rationalizations named, no easy-out); the `UserPromptSubmit` per-turn floor is removed (re-asserting a line every turn didn't stop the skip and cost tokens per turn); the four discipline descriptions return to firm `ALWAYS invoke`. Persuasion is the firm-but-leaky floor; the gates are the wall. Honest limit recorded: the execution-momentum regime that failed isn't reproducible in the headless harness — which is precisely why the gates exist.

## [2.0.0] — 2026-06-24

### Changed

- **Activation moves from coercion to structure; Claude-Code-first.** The firing pressure v1.0.7 put in descriptions (`ALWAYS invoke…`) was a workaround for a SessionStart nudge that decays over a long session. v2.0 carries it structurally: a slim procedural SessionStart bootstrap **plus a per-turn `UserPromptSubmit` floor** so the routing check can't decay mid-session (`docs/sdlc-skills/activation.md`). The four discipline descriptions drop `ALWAYS` → plain "Use when…"; re-measured on a real `claude -p` sweep of all 30 skills (28/30 fired first try, effectively 30/30 on fair scenarios), activation holds without the coercion.
- **Tests flip from harness-agnostic proxies to real per-harness runs.** The proxies measured a ceiling, not the floor, so an ignored skill shipped green. The real `claude -p` harness (`tests/harness/claude-code/`; `--working-tree`, an offline `selftest`, `--verbose`, `--max-turns`) is now the activation layer; `behavioral/` discipline-pressure tests move under it. Identity rewritten to **portable skills + per-harness real tests** (Codex frozen; its manifest-sync relaxed to a note while `.claude-plugin` stays strict).

### Added

- **`yagni`** — build only what's needed and make it work, guarding both over-engineering and its opposite, laziness dressed as simplicity (stubs, TODOs, the smallest diff in the wrong place). Ships with a `references/` folder; `using-sdlc-skills` gains a phase-chaining cue.

### Removed

- **`caveman`** (terse-output mode) — the skill-surface change that makes this a major release.
- **The harness-agnostic proxy test layer** (`tests/triggering/`, `tests/invocation/`, `triggering-harness.sh`, `invocation-harness.sh`, `coverage.sh`) and the growing per-adapter record file — superseded by the real per-harness runs.

## [1.0.7] — 2026-06-21

### Changed

- **The four discipline triggers fire by default, not on invitation.** `debugging`, `test-driven-development`, `verifying-completion`, and `receiving-code-review` were rewritten from gentle "Use when…" descriptions to imperative "ALWAYS invoke…" ones. The driver was real use: gentle descriptions under-fire because the SessionStart nudge decays over a long session while the always-loaded catalogue does not — so the firing pressure belongs in the descriptions, the one surface that stays salient. Only the descriptions changed (discipline bodies untouched, so no behavioural re-prove owed); triggering re-measured at positive **3/3** each. The cost is real and **accepted**: the firm framing over-fires on trivial cases its own exception exempts (firm `debugging` routed a one-line error **3/3** vs a gentle baseline of **2/3 NONE**) — firing over ceremony-avoidance, recorded honestly in `tests/triggering/`.

### Added

- **An invocation proxy and a real-CLI activation layer.** `tests/invocation/` + `invocation-harness.sh` measure the *decision to invoke* — the step the triggering proxy presumes — with the shipped nudge on/off and "proceed" offered as a co-equal outcome (its over-measurement is noted in the records). `tests/harness/claude-code/` drives the real `claude -p` headless against the installed plugin and detects a structured `Skill` tool_use (`run-activation.sh` single-shot, `run-flow.sh` multi-turn resumed); scenarios live by filename under `scenarios/` mirroring `skills/` (phase folders plus `common/`). Records the first observed native activations for the Claude Code adapter, including the planning wing firing `define-goals → feasibility-check → scope-it` across one resumed session.

## [1.0.6] — 2026-06-18

### Changed

- **The proactive-use nudge states one action: invoke.** The Claude Code SessionStart nudge (`hooks/claude-code/context.md`) drops the v1.0.5 "say which … `Using sdlc-skills:<name>`" announcement — it conflated *invoke* with *announce*, and only the announcement was fakeable (a field session named a skill, served the request another way, and never called `Skill`). The single action is now the invocation itself, whose tool call is the unfakeable trace. Also reworded "before you touch the code" → "before you start", which presupposed a pre-implementation phase and mis-framed maintenance work. Re-tested old-vs-new by transcript grep for a real `Skill` call: no activation regression, feature→`spec-it` 3/3 and maintenance→`debugging` 3/3 under the new wording, and 3/3 `debugging` against the real 172k-LoC `mobile-client`; the native-SessionStart confirmation is recorded as owed post-install. `tests/triggering/session-nudge.md`.

### Added

- **Triggering-record coverage is gated.** `tests/coverage.sh` checks that every skill has a `tests/triggering/<name>.md` record (and warns when one shows no skip scenario); the existence half is now enforced by `validate-skills.sh` — the check that would have caught a skill shipping with no record. The 12 skills that lacked a record are backfilled (routing measured 3/3 unanimous per skill, fire + skip). `tests/token-budget.sh` reports the approximate context cost (chars/4) of the always-loaded surface — every `SKILL.md` plus the nudge — making "earn every line" a measurable number.

### Fixed

- **Dispatch and review packets stop parking bulk in the costliest context.** `dispatching-parallel-agents` now passes bulky context (a diff, a spec, a log) as a file path the agent reads rather than pasted text, and names the tier explicitly (omitted, an agent inherits the session's costliest). `requesting-code-review` hands the reviewer the diff *range* to expand itself (not a pasted diff) and a review tier chosen to match the diff's risk. Watched before/after in `tests/behavioral/`: the file-handoff line moved behaviour 2/2 vs. inline paste; the review-tier rewording moved agents 0/2 → 3/3 from deferring to the session tier to choosing one by risk.

## [1.0.5] — 2026-06-14

### Changed

- **The proactive-use nudge makes invoking a skill the visible first act.** The Claude Code SessionStart nudge (`hooks/claude-code/context.md`) was reworded from a passive "check whether a skill fits … and invoke it" — which an agent can satisfy silently and skip — to "before you touch the code, invoke the skill that fits, and say which as you do it (`Using sdlc-skills:<name> to <purpose>`)", with the no-skill escape now *spoken* rather than silent. The collaboration stance is unchanged: no coercion ("must / no choice"), no whole-skill injection, still ~800 tokens. Driven by a field session where the nudge reached context yet no skill was invoked; old-vs-new measured in `tests/triggering/session-nudge.md` — the announcement is adopted reliably (7/7, including 3/3 under the verbatim competing output-style injections that drowned the nudge in the field), with no activation regression and a live re-test recorded as owed.

## [1.0.4] — 2026-06-14

### Fixed

- **The proactive-use nudge reaches more sessions, more reliably.** The Claude Code SessionStart matcher gained `resume`, so the nudge fires on resumed sessions (`--continue`/`--resume`/`/resume`), not just fresh starts; and the hook now wraps `context.md` in the harness's JSON context envelope via `hooks/claude-code/session-start.sh` instead of relying on raw stdout being read as context. Delivery only — the nudge text is byte-identical, so activation is unchanged; recorded in `tests/triggering/session-nudge.md`.

## [1.0.3] — 2026-06-11

### Added

- **Versioning policy** (`RELEASING.md`): semver mapped to the skill surface, who bumps and when, and the release checklist; the gate now fails a half-done version bump across the three manifests.
- **ADRs carry a status lifecycle.** `architecture-decisions` marks each record proposed / in force / superseded, so a later session can't read an unbuilt plan as the current architecture.
- **Harness-collision checks in the gate**: shipped text is linted for harness scanner trigger-words, and a skill name that shadows a common built-in slash command is rejected.
- **Compaction-survival requirement for adapters** (`docs/sdlc-skills/harness-support.md`): the proactive-use nudge must outlive context compaction; mechanisms ranked, session-start-only declared a gap.
- **Record-staleness rule** (`tests/README.md`): a model-generation change makes existing verdicts the previous generation's data; every dated entry names the harness and tier it was measured from.

### Fixed

- **Reviewer subagents are read-only.** All five `requesting-code-review` dispatch prompts now forbid mutating the shared checkout — no edits, branch switches, or checkouts during a review; a comparison needing one is reported, not performed.

## [1.0.2] — 2026-06-10

### Fixed

- **Code review now reaches the "done" boundary.** A field failure showed work being reported complete with every gate green but the diff unreviewed. `requesting-code-review`'s trigger is now event-conditioned (fires at the done boundary — complete/commit/merge/PR — not only when you already want fresh eyes), and `verifying-completion` hands off to independent review once its gate passes instead of ending the chain at "verified". Proven old-vs-new in `tests/triggering/requesting-code-review.md` (the skill's first activation record) and `tests/behavioral/verifying-completion.md` (0/2 → 3/3 on the handoff; flaky-green hard-stop unregressed).
- **Docs: deterministic boundary interrupts stay project-local.** New `harness-support.md` section on why blocking commit/merge hooks belong in your own project config, not in SDLC skills core.

## [1.0.1] — 2026-06-10

### Fixed

- **The plan→execution seam now pauses for the user.** `writing-plans` ends by presenting the plan index for the user's go, and `executing-plans` confirms the user has seen the plan before starting — pause-by-default, with explicit escapes ("plan it and build it, don't stop" or an explicitly requested unattended run). A pre-plan "go ahead" no longer counts as approval of the unseen plan, and a non-interactive session means presenting the plan at turn end, not skipping the pause. Driven by a captured field failure; proven RED → loopholes closed → GREEN in `tests/behavioral/writing-plans.md`.

## [1.0.0] — 2026-06-09

First public release.

### Added

- **30 skills across all seven SDLC phases** — planning, analysis, design, implementation, testing, deployment, maintenance — plus the cross-cutting `common/` toolbox (orientation, skill-authoring, interviewing, prototyping, zoom-out, handoff, worktrees, parallel dispatch, terse output). Full index in the README.
- **The deterministic gate** (`tests/validate-skills.sh`): frontmatter shape, line budgets, no external references or vendor model names, skills-array sync across every harness manifest, and internal doc paths resolve — enforced by CI on every push and PR.
- **Dated evidence records** under `tests/`: `triggering/` (does a description route the right opening), `behavioral/` (does a discipline hold under pressure), `harness/` (does an adapter actually load and activate) — each entry stating the environment it was measured from, including honest nulls and stated gaps.
- **Harness adapters**: a Claude Code plugin with a session-start nudge (firm, not coercive), and a Codex manifest (provisional — not yet exercised in a live session).
- **The philosophy** (`docs/sdlc-skills/philosophy.md`): every skill is a non-deterministic generator wrapped in a deterministic gate — truth comes from the gate, never from confidence — and skills work alongside model intelligence, never impeding it.
- **Contributor surface**: `CLAUDE.md` (shared via `AGENTS.md` and `GEMINI.md` symlinks), `CONTRIBUTING.md`, a PR template with authoring-environment disclosure, and a Code of Conduct.
