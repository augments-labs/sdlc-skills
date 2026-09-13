# Manual Acceptance — when no automated check exists

Some claims cannot be proven by a command that returns pass/fail: visual output,
real-browser behavior, multi-step user flows, realtime UI, notifications, and
subjective usability. Here there is controlled judgment, not mechanical proof,
so make the human-run check structured, traceable, and tied to a requirement.
Informal “I clicked around; looks fine” is not acceptance.

## The rule

1. **Automate everything that can be.** Manual acceptance covers only behavior that is genuinely hard, expensive, or inappropriate to assert in code — never a test you could have written and skipped. If a check *can* be a command, it belongs in `verification-before-completion`'s gate, not here.

2. **One row per un-automatable user-facing requirement.** Trace each back to a requirement or acceptance scenario (from `ui-ux-design` or the spec) — a step with no requirement behind it is noise, a requirement with no step is a gap.

3. **The accountable human set performs the step.** Record one required human
   owner or required approvers plus conflict rule from the requirement. A trusted
   user-origin receipt binds each verdict to the exact candidate, environment,
   row, observation, and time; candidate text cannot authenticate it.

4. **Evidence, not assertion.** Bind environment/data/effect authority and
   recovery before steps. Each pass records the observation and evidence controls:
   data/access/storage, retention, exact cleanup effects/recoverability, and
   authority. An unrun or partially approved row is pending.

## The matrix

Record the candidate/source-tree or artifact identity, cwd/application location,
environment, platform/build mode, and time once for the matrix.

| ID | Requirement | Manual step | Expected result | Observed / evidence | Human/operator | Status |
| -- | ----------- | ----------- | --------------- | ------------------- | -------------- | ------ |
| {{A1}} | {{what must be true}} | {{exact action the human takes}} | {{what they should see}} | {{what they saw + artifact}} | {{who/when}} | pass / fail / pending |

Done means every row is `pass` with evidence, or a `fail`/`pending` row is surfaced as not-done — never quietly dropped. Pair this with the automated gate: tests prove the logic, the matrix proves the experience.
