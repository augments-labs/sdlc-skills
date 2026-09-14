# Testing a Skill

Format checks prove shape. Behavior proof asks whether the skill changes the
agent's action at the exact failure surface, and if you never watched an agent
fail without the skill, you do not know it prevents the right failure. An
explanation, quotation, or claim of compliance is written by the same generator
under test and is not a verdict.

## What is worth proving

A live run costs money and time, so spend it where behavior can go wrong:

- **Prove** a skill that holds a discipline under pressure, gates a transition,
  bounds authority, or must fire on one opening and stay silent on a neighbouring
  one — anything an agent has an incentive to rationalize past.
- **Skip** a skill with no rule to violate: a lookup reference, a syntax or API
  guide, a format the agent either emits or does not. Nothing there can collapse
  under pressure, so the run measures the model rather than the skill.

Naming the class and skipping is a finding. Running a pressure scenario against a
skill that has no pressure surface is ceremony, and it buys a green that means
nothing.

## Start from a real failure

Record the smallest realistic counterexample and its evidence strength:

- **observed** — the wrong action happened in a real session;
- **contract gap** — required state or stop is absent or contradicted in the
  current text; or
- **candidate** — an adversarial path worth deciding, not a fabricated failure.

Candidates may enter an audit without live proof. Once you edit behavior, run the
smallest applicable before/after probe. If the control does not exhibit the
claimed failure, narrow the measured claim or stop that probe; do not tune the
prompt to force RED. Keep reported failures and contract contradictions visible.
A passing sample does not disprove them or establish that a skill is unnecessary.

## Match proof to the failure

| Failure | Required observable |
| --- | --- |
| Wrong skill fires or stays silent | Structured activation on natural positive and negative openings |
| Wrong artifact or side effect | Load, execute, or inspect the result; an assertion exit code is the verdict |
| Discipline collapses under pressure | No-guidance control and edited-skill run on the same pressured task |
| Stateful boundary is crossed | Forbidden mutation stays absent and the pending state remains visible |

Use the library's evals lab first. Extend a runner only after the smallest
controlled probe cannot observe the behavior. A transcript may explain
a failure, but it cannot replace an artifact, side-effect, or structured-event
assertion when one exists.

## RED, GREEN, then challenge

1. **RED:** preserve the exact opening, fixture, base skill version, wrong
   observable, command, and output.
2. **GREEN:** change only the contract under test and rerun the same probe. Read
   the real assertion result.
3. **Challenge:** add only pressure relevant to the discipline—time, sunk cost,
   authority, ambiguity—or a negative opening relevant to activation. Do not
   broaden the task until you no longer know what caused the result.

Fresh context prevents the edited session from teaching the control. Keep fixture,
permissions, tools, and environment equal across arms; otherwise the comparison
does not isolate the skill.

Freeze and record the evaluator identity outside the candidate before either
arm; the candidate cannot modify its judge. Calibrate the evaluator by applying
one deliberate wrong observable and watching the assertion fail, then restore
it. Any evaluator or fixture mutation outside the predeclared arm difference
invalidates the pair instead of producing GREEN.

## Cost and honest reporting

Before any live harness run, confirm the authorized service, data boundary, and
budget. Use synthetic/public fixtures; never send repository secrets, private
code, credentials, or personal data merely to prove a skill.

Start with one targeted pair. Repeat in proportion to risk and nondeterminism;
load-bearing routing or authorization needs more evidence than a lookup reference.
Do not build or run a full skill-by-harness matrix merely for coverage, and do not
add scenarios to unchanged skills.

Report commands, base/edited arms, environments, run counts, and every pass,
failure, timeout, refusal, or inconclusive result. A single green run is weak
evidence. An unavailable live runner means “shape validated; behavior unproven,”
never “works.”

## Throwaway probes

When unsure whether a section changes behavior, write three pressure prompts that
would tempt an agent to break its rule. Run each once with the section and once
without, report every result in the change's review, and commit nothing.

## Gotchas

- A green on a large tier does not transfer to a small one: a smaller model
  drops steps a larger one keeps. Prove on the smallest tier the library
  supports.
