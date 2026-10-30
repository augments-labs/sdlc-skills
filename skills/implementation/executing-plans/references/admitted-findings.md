# Admitted Findings (`Out-of-task findings: fix when admitted`)

Read this when the plan index's `Out-of-task findings` field says `fix when admitted`.

1. Admit only an observed failure: wrong output, a crash, a shipped statement
   that is false, or a test that passes on broken code. Write the admitted
   finding a task file shaped like the plan's own under `{{plan-dir}}/added/`,
   unlisted in the index so the plan's identity holds, and append an `admitted`
   row that repeats the finding row's where-text and names that file.
2. The approved field authorizes an added task inside its budget, and nothing
   else. Its `Evaluator` reproduces the observed failure and is red before the
   fix; its `Depends on` names every listed task that owns a file it edits; it
   passes the plan-contract check (Step 3). A finding whose fix would change a
   listed task's contract or `Evaluator` is not admitted: it waits for Step 5.4.
3. Run an added task through Step 4 before Step 5. It has no index row to
   mirror: its state lives in the execution ledger only, and Step 5.1 runs its
   evaluator with the listed tasks'.
4. A finding raised while building or reviewing an added task, or by the Step
   5.2 review outside every task's contract, waits for Step 5.4. It never
   becomes another task.
5. When the added tasks reach the field's budget, admit nothing more; the rest
   wait for Step 5.4. If no budget is recorded, the budget is a quarter of the
   listed tasks, rounded up.
