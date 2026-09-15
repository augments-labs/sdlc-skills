# Branch finishing state machine

Bind the state, ownership and authority relevant to the selected action.
Materialization, publication and integration require current verification and
review; keep-as-is, discard and PR-only close/reopen use their own identity and
authority gates below. This is a procedure to read, not a file to copy into the
candidate.

Before asking for a mutating choice, issue an immutable transition descriptor
with a stable transition ID; exact candidate, base, and current remote/PR state;
one action; exact targets and payload (commit set, remote/ref, title/body, merge
method, cleanup or discard inventory); expected pre/post effects; idempotency or
retry rule; recovery; and exact approver set/conflict rule/trusted receipt
source. Its digest excludes its own identity slot and all later
attempts/outcomes. The complete receipt set binds that digest. Any field or
bound input change creates a successor descriptor and needs new approval. Keep
descriptors and mutable transition records outside the candidate or return them
directly; a repository record is a new candidate to verify and review.

Give every mutation attempt a stable ID in an append-only external ledger.
After timeout, lost response, cancellation, or another unknown outcome, do not
retry: reconcile repository, remote, PR, workspace, worker/descendant, and effect
state first. Remain `cancellation-requested` until quiescent; quarantine partial
and late results. A linked retry is allowed only when the observed state proves
it cannot duplicate or conflict with the first attempt. Otherwise preserve the
actual state and report the ambiguous blocker.

Resolve policy and action contracts from the trusted base/project/user boundary.
Run hooks and gates only through their authorized effect contracts; a hook,
template, or remote message cannot grant secret, network, tool, mutation, or
publication access.

## States

| State | Required evidence | Allowed next states |
| --- | --- | --- |
| `candidate` | exact source identity; green gates and applicable review before materialization/publication/integration; exact owned inventory and recoverability before discard | `materialized-kept`, `published branch`, `integration candidate`, `published for review`, `kept`, or fresh-inventory `discard-pending` |
| `materialized-kept` | exact reviewed digest materialized by the authorized commit set; no publication/integration/cleanup | after refresh/new choice: `published branch`, `integration candidate`, `published for review`, `kept`, or `discard-pending` |
| `published branch` | exact reviewed commit set pushed without rewriting shared history; no PR/integration/cleanup | after refresh/new choice: `published branch`, `published for review`, `integration candidate`, `kept`, or `discard-pending` |
| `integration candidate` | exact base + candidate combined in owned temporary state | `integrated`, `blocked-preserved`, or fresh-inventory `discard-pending` before base advance |
| `published for review` | pushed branch and one correctly targeted PR | refreshed `published for review` after exact update/reopen, `remote integration candidate`, `closed-preserved`, `kept for feedback`, or fresh-inventory `discard-pending` |
| `remote integration candidate` | exact PR head/base, policy gates, and pre-merge integrated result green | `integrated`, `blocked-preserved` |
| `integrated` | target contains candidate; required integrated gates/review green | `kept` or, after a separate direct cleanup choice, `owned cleanup` |
| `integrated-regression` | target already contains candidate but a required post-integration gate failed or is inconclusive; source and raw evidence retained | containment/debugging/recovery under project authority; no cleanup or release |
| `outcome-unknown` | stable attempt/descriptor and raw timeout/lost-response evidence; observed repository/remote/PR/workspace/effect state is not reconciled | cancellation/reconciliation until quiescent, then classify the actual state or `blocked-preserved`; no blind retry or new mutation |
| `blocked-preserved` | raw failure/conflict evidence and all source state retained | investigation; corrected candidate re-enters `candidate`, or exact task-owned unintegrated inventory may enter `discard-pending` |
| `discard-pending` | exact inventory and token requested | `discarded` only on exact token |
| `kept` | exact branch/HEAD/workspace/remote/PR state reported with no mutation | terminal for this invocation; later work refreshes and re-enters `candidate` |
| `kept for feedback` | exact open PR, branch, and workspace retained | feedback routes through review; later merge or update starts a refreshed transition |
| `closed-preserved` | exact unmerged PR closed; local/remote source branch and workspace retained | `kept` or, after refresh and direct choice, `published for review` by reopen |
| `owned cleanup` | confirmed integration, exact owned resources, and separate direct cleanup choice | `cleaned` after post-action verification |
| `cleaned` | target still contains integrated result; named owned resources are absent and adjacent resources remain | terminal |
| `discarded` | exact confirmed inventory removed; actual removals and recoverability reported | terminal |

No transition is inferred from another. Opening a PR is not integration;
integration is not release; a source-tree green is not integrated green.
Terminal means only that this invocation stops; a later request starts with a
fresh state/authority check rather than borrowing the old transition choice.
Only an unintegrated, exactly inventoried, task-owned state may enter
`discard-pending`. Integrated, shared, host-owned, or ownership-uncertain state
cannot; preserve it and report the blocker.

## Materialize a reviewed working tree

Use this only after a direct transition choice requires commits. Freeze the
reviewed working-tree inventory and digest, then stage exactly those paths
path-by-path. Inspect the staged inventory and tree identity; an unrelated,
missing, ignored, generated, or newly changed path stops materialization.

Run hooks and commit-bound gates in preflight only under the descriptor's effect
contract. Any hook/formatter content change creates a new candidate and voids
the old direct transition choice. If no commit exists, rebind, reverify,
re-review, and obtain a new exact-candidate choice before committing. If the
hook already created a commit, preserve it without amend/reset,
bind/reverify/re-review it, and obtain a new choice before any further history,
remote, PR, or integration mutation. Rejection never permits bypass.

Create only the commit set included in the direct transition choice—never amend,
squash, rebase, or mix cleanup implicitly. The created commit set holds the
reviewed state only when a rerun of `scripts/branch-state.sh` reports
`dirty.clean: true` and either `dirty.digest` equals the reviewed digest or
`head.sha` equals the reviewed revision. Otherwise preserve the working tree
and stop.

## Integrate locally

1. Reconfirm the base revision has not moved.
2. Construct the combined result in a temporary branch/workspace owned by this
   transition, using the project's integration policy.
3. Preserve conflict evidence; never discard source changes to make the combine
   succeed.
4. Run the integrated result's required gates and read raw output. Bind evidence
   to its exact revision/artifact and audit required test/platform/build cells.
5. When risk requires integrated review, present this exact result to
   `requesting-code-review` before advancing the base.
6. If any gate/review blocks, keep candidate, temporary integration state,
   original workspace, and branch. Report `blocked-preserved`.
7. Only while the base remains the recorded revision, advance it using the
   approved project method. Verify the target now names/contains the gated
   integrated result.

## Commit exact candidate and keep

Materialize the reviewed working tree through the procedure above, including
its `dirty.clean: true` check, and confirm that no created commit adds an
unrelated path. Do not push, open a PR, advance a base, or clean anything.
Report the exact branch, commits, and workspace as
`materialized-kept`. A later transition refreshes candidate/base/remote state
and requires its own direct choice; the commit choice grants nothing else.

## Push and open a PR

1. Materialize the complete reviewed source tree through the procedure above;
   prove the commit set contains no unrelated or missing files.
2. Check upstream/remote branch collision and contribution instructions.
3. Push without rewriting shared history. A rejection or moved remote is new
   state to investigate, not permission to force-push.
4. Create exactly one PR against the proven base using the filled template and
   truthful evidence. Report its identity.
5. Preserve the local branch/workspace and runtime notes for review feedback.
   Cleanup waits for confirmed integration and a later valid cleanup transition.

## Push branch without a PR

Materialize the reviewed source through the procedure above, verify remote
branch ownership/collision/upstream state, and push without rewriting shared
history. Verify the remote tip equals the exact pushed commit set. Do not open a
PR, integrate, or clean resources. Report local and remote branch identities as
`published branch`. A later source push, PR creation, or integration refreshes
candidate/base/remote state and consumes a new exact choice.

## Update an existing PR

1. Refresh open/closed/merged state, exact head/base/source branch, permissions,
   remote tip, policy, and current title/body. A non-open or moved PR stops.
2. For a source update, materialize the verified/reviewed exact candidate, require
   an owned fast-forwardable source branch, push without rewrite, and verify the
   same PR now names the exact commit set.
3. For a description update, present the exact truthful title/body and mutate
   only those fields after the direct choice.
4. Do not infer retarget, history rewrite, close/reopen, branch deletion,
   integration, or cleanup. Each is absent or a distinct transition.
5. Preserve branch/workspace and report refreshed PR/head/base identities as
   `published for review`.

## Close or reopen a PR without changing source

1. Refresh exact open/closed/merged state, head/base/source branch, permissions,
   policy, and retained local/remote resources.
2. Bind the direct choice to that PR and state. Close only an open unmerged PR;
   reopen only a closed unmerged PR when policy permits. A merged PR routes to
   integrated-result verification instead.
3. Preserve every source ref and workspace. Do not push, retarget, rewrite,
   delete a branch, integrate, discard, or clean.
4. Verify the resulting PR state and unchanged head/base/source identities.
   Report `closed-preserved` after close or `published for review` after reopen.

## Merge an existing PR

1. Refresh the PR's open/merged state, exact head and base revisions,
   mergeability, required CI, approvals, unresolved findings/conversations, and
   repository merge policy. Never substitute a cached status.
2. Confirm its head is the reviewed candidate. If source, base, requirements,
   or required evidence changed, reverify and re-review the affected candidate.
3. Construct the exact combined result in an owned temporary workspace using
   the proposed merge method. Run its required gates and any required
   integrated-result review before changing the remote base.
4. Reconfirm PR head, base, policy gates, and direct merge choice immediately
   before invoking the repository's normal merge action. Do not bypass policy,
   use administrator override, or force a stale result through.
5. Verify the PR is merged, the target contains the expected gated tree/result,
   and required post-merge CI ran on the resulting target revision. A
   post-merge failure is an integrated regression to contain or recover under
   project policy; record `integrated-regression`, retain source/evidence, and
   do not report success, release, or clean.
6. Retain branch/workspace state until both integration and the separate owned
   cleanup transition are confirmed.

## Keep

Make no integration, publication, history, or cleanup mutation. Report the exact
branch/HEAD and workspace path so work remains findable.

## Owned cleanup

Reconfirm integration and resource ownership. Before removing a worktree, rerun
`scripts/branch-state.sh --full` inside it. A non-zero exit, or a non-empty
`dirty.ignored` the cleanup choice does not name, preserves the worktree; report
it. Capture paths before changing directory; remove an owned worktree from
outside it, then use safe branch deletion. Do not prune, force-delete, remove
remotes, or clean adjacent workspaces unless each action and target was
explicitly authorized.

Detached, host-owned, shared, or ownership-uncertain workspaces are reported to
their owner and left intact.

## Confirmed discard

The confirmation token must exactly match the displayed candidate inventory.
The inventory includes the ignored listing (`dirty.ignored`), which no recovery
restores; a listed ignored directory is confirmed whole. A removal git refuses
without `--force` stops the discard; report it.
Re-resolve state immediately before deletion; any delta invalidates the token
and requires a new inventory. Include every open/closed PR, exact head/base,
remote ref, and whether the requested discard closes it. An unlisted, merged,
shared, or ownership-uncertain PR and the source it needs remain untouched.
Close an exact task-owned unmerged PR only when that action is in the confirmed
inventory; then remove only the listed task-owned remote/local resources in a
safe order. Report each close/removal and whether recovery remains possible.
