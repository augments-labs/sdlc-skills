# Assurance challenger prompt template

Fill Inputs and append the fenced prompt to the filled broad code-reviewer
prompt. The reviewer fills Output; its receipt replaces the broad receipt.

````markdown
Challenge assurance as a distinct axis: generic code quality review cannot
establish that a gate can fail or protects its named promotion.

## Inputs

- Candidate: {{read-only descriptor with full exact candidate and review-input identities, matching the broad prompt}}
- Assurance matrix and catalogue dispositions: {{paths and exact normative matrix version}}
- Evidence: {{raw green, controlled-red, restoration-green, and execution-inventory locations; summaries are claims}}
- Protected promotion: {{promotion and external invocation owner}}

## Challenge

1. Trace every material risk to a gate, threshold, environment, cadence,
   evidence owner, protected promotion, and failure response. Unmapped risks,
   planned commands presented as evidence, and unsupported omissions block.
2. Confirm the matrix and catalogue dispositions existed before gate code.
   Concurrent or retrospective authoring fails this transition.
3. In a reviewer-owned copy, or from retained raw results, replay representative
   behavior divergence and oracle hollowing. A historical mutation alone does
   not protect later test/control edits; verify the continuing cadence.
4. For a tiny fixed inventory whose execution-loss risk is decided by one
   path/count floor in the existing project command, require that floor and
   prove removing its sole protected test/layer turns the command red. Otherwise,
   name the execution-loss risk that floor cannot decide, complete `yagni`'s
   pre-edit challenge, then require exact multisets of required, recursively
   discovered, and eligible runtime receipts. Select the smallest attacks that
   decide the gate's real mechanisms: empty/removed control data, valid
   invocation rewiring, skip/focus/todo forms, case/cell deletion, addition,
   duplication, hollowing, narrowing, non-execution, forged receipts, and
   resource ceilings. Each applicable attack independently turns the protected
   command red and restores green; record why others are inapplicable.
   Challenge an inner controller from its independently owned parent only when
   that controller exists. When the real launcher can hang or spawn descendants,
   force a representative synchronous hang with an escaped child/process group
   and prove the whole tree is gone; do not build a process tree merely to test
   its cleanup.
5. Distinguish what the project command runs from who protects its invocation.
   A mutable command cannot prove that it was not validly rewired around its
   controller or replaced wholesale with forged output. Whole-plane replacement
   challenges the external control-change boundary, not the plane's own output.
   Without external CI/branch/promotion enforcement, the claimed protected
   promotion is `planned` or `blocked`; do not demand recursive self-attestation
   or call that promotion protected.
6. Verify the candidate stayed read-only during challenge and that reports and
   decisions remain outside its identity. Any accepted fix creates a new
   candidate whose immutable lineage names the predecessor, fresh completion
   evidence, a fresh review invocation, and focused re-review. Reject lifecycle
   edits to the predecessor as counterfeit supersession.

## Output

Add this coverage table to the reviewer-owned report. Record every challenged
risk and attack, including unrun and inconclusive cells. Findings name the
violated matrix cell and shortest repair.

| Risk/matrix cell and attack | Command or artifact | Raw result location | Result or limitation |
| --- | --- | --- | --- |
| {{cell and attack}} | {{what you inspected or ran}} | {{evidence location}} | {{result, unrun, or inconclusive}} |

`clear` requires every applicable cell and claimed promotion to be accounted
for; an unrun cell is `inconclusive`. Missing either assurance member means
generic breadth review only. A path, label, combined prose identity, shortened
digest, or mismatched matrix version is invalid.

End the returned response with exactly one unfenced valid JSON line, copying
identities byte-for-byte:
SDLC_SKILLS_REVIEW_RESULT={"candidate":"{{exact result identity}}","context":"{{exact review-input identity}}","verdict":"{{ready | not_ready | ready_after_fixes}}","report":"{{location or returned directly}}","assurance":"{{clear | findings | inconclusive}}","assurance_version":"{{exact normative matrix version}}"}
````
