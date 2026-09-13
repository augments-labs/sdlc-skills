# The Generator and the Gate

*The design philosophy behind sdlc-skills: how to do real engineering on a non-deterministic substrate.*

Every skill in this library is shaped by one problem: a language model is a powerful generator, but it is not a reliable engineer — and software engineering does not tolerate unverified correctness. This document explains how SDLC skills resolves that, and why the skills look the way they do.

## What real engineering guarantees

Engineering tolerates uncertainty, but only when it is **quantified and bounded** — a tolerance, a budget, an error bar. What it never tolerates is **unverified correctness**. A bridge may carry a safety factor; it may not be "probably standing".

So the non-negotiable is not that the process is certain. It is that **an
executable correctness verdict is established by an executable check, not by
the builder's confidence.** A product preference or authority decision is a
different claim: bind it to an explicit decision or controlled rubric rather
than pretending a machine proved it.

## The two non-determinisms of a language model

A model is non-deterministic in two distinct places, and they are not equal.

- **In generation** — the same request yields different code each time. This is harmless. There are many correct implementations; the path need not be deterministic.
- **In its verdict** — it will report "this works", "tests pass", "done", confidently, when it is not true. This is fatal, because it is exactly the thing engineering forbids: an unverified correctness claim presented as fact.

And the verdict problem cannot be fixed by instruction. Telling a model "you must verify" only raises a probability; it can never reach certainty, because the substrate is probabilistic. Forcing compliance with ever-heavier instructions builds reliability on sand — the rule holds most of the time and fails silently the rest.

## The reconciliation: the generator and the gate

You do not make the model reliable. You make the **verdict** external to it.
Mechanically decidable claims use executable gates the model cannot talk into
passing. Judgment and authority use explicit revision-bound decisions or
controlled rubrics that block progression without pretending to be mechanical
proof.

This is how all engineering produces reliable results from unreliable parts — not by trusting the worker, but by gating the output: inspection, tolerances, tests. The reliability lives in the gate, not the generator.

Stated as a rule:

> **A skill shifts the probability of good generation. An external gate decides
> whether the result may advance—executable for correctness claims, explicitly
> human-owned where judgment or authority is irreducible.**

You need both. But the reliability comes from the gate. Effort spent forcing compliance is spent on the part that can never be guaranteed; effort spent on the gate is spent on the part that can.

## Every skill is a generator wrapped in an external gate

This is the thread that runs through the whole library. None of these skills
asks you to trust the model's word. Code claims require observed executable
results; plans and designs require exact-version approval or a named rubric.
The latter reliably controls progression but does not certify correctness beyond
the evidence and authority it records.

| Skill | The generator | The gate (where truth lives) |
| ----- | ------------- | ---------------------------- |
| `test-driven-development` | the model writing code | the test passing — watched to fail first |
| `verification-before-completion` | the model claiming "done" | running the check and reading the output |
| `writing-plans` / `executing-plans` | the model doing a task | the per-task Evaluator and the plan Acceptance |
| `debugging` | the model's hypothesis | the reproduction loop |
| planning and design skills | the model proposing intent or structure | exact-version review, rubric, and direct accountable decision |

## Instruction and gate are different tools

A tempting mistake is to make the model's *verdict* reliable by injecting more instructions — an enforcer that says "you must, before everything, confirm it works". That tries to settle by instruction the one thing only a check can settle: probabilistic, fragile, and tied to one tool.

The engineering-correct enforcement of an executable verdict is the opposite—a
deterministic gate on the **artifact**. A version-control or CI step that runs
the tests and refuses the bad output does not care how confident the model was,
does not vanish for another worker, and is portable because it lives in the
project rather than one tool's session. Prefer a gate on the output over an
instruction about the verdict.

This does not make instruction worthless — it makes it the *wrong tool for the
verdict* and the *right tool for getting the generator to the gate*.

Nothing deterministic checks whether the model reaches for the applicable skill
at the right moment, or runs the check it is tempted under pressure to skip (see
the next section). There a firm instruction is the strongest lever available, and
this library uses it in two places on purpose. The routing stance is
non-negotiable by default, because a soft, optional nudge is walked past. And a
discipline skill raises its voice — a hard stop, a red-flag list, a
rationalization table naming the excuse and its rebuttal — where an agent would
otherwise talk itself past its own gate. In a discipline skill that emphasis is
the mechanism, not a lapse.

What emphasis cannot do is settle anything. Nothing becomes true here by being
said forcefully, so it belongs in bodies, where the temptation is, and stays out
of descriptions. A description is a trigger: it fires on the plain vocabulary of
the situation, and shouting at it neither makes a trigger match nor earns back
the characters it spends.

The discipline is to keep the two honest and separate — **a firm floor where you
have only process; a deterministic gate where you have proof; and never the
language of one dressed on the other.**

## Where there is proof, and where there is only process

Be honest about the limit. Some disciplines can be gated deterministically—a
test, check, or reproduction returns pass or fail. Judgmental work cannot:
“consider the architecture” has no command that proves the design wise. Its
artifact can still be held at a controlled review and explicit approval
boundary, while compliance with the reasoning procedure remains probabilistic.
Call that what it is; a blocking decision is not a correctness proof.

Nor does a decision record authenticate itself. A status or `Approval:` field
is process history unless the current user-role answer or a trusted project or
harness receipt binds the accountable actor's origin, exact artifact version,
and authorized transition. Without that evidence, the decision stays pending.

Real engineering is precise about where it has proof and where it has only process. A skill that dressed "you should brainstorm" in the same absolute language as "the tests pass" would be lying — the very hollow verification it warns against.

## Alongside intelligence, not in its way

Skills and model intelligence are complements, not rivals. As models grow more capable, the *generation* half of the problem genuinely shrinks: a stronger model needs less guidance about how to write the code, and a skill that micromanages a capable generator subtracts value. That is why every skill carries a complexity gate — a stated "skip this when…" — and why the library is a toolbox rather than a pipeline: where the model's judgment is strong, the skill defers to it.

What does not shrink with capability is the verdict problem. However intelligent
the generator becomes, it remains probabilistic and cannot certify its own
output—“I am confident” is neither a check result nor accountable approval. The
division of labor is stable: the model brings intelligence; the project brings
executable checks and human decision owners. A skill that gets in a capable
model's way is a bug, and a result that advances without its required gate is
the failure the gate exists to stop.

## What this means for the library

This is why `using-sdlc-skills` carries a firm entry stance *and* refuses to overclaim. Its first job is to install the mental model that makes every other skill cohere:

> You are a generator. Executable claims need executable gates; judgment and
> authority need explicit accountable decisions. Truth comes from their
> evidence, never from your confidence. “Done” means the required gate accepted
> the exact state, not that you believe it is done.

Its second job is to get the first skill invoked and keep the chain unbroken — firmly, because a skipped skill is the failure the library exists to prevent, and a gentle suggestion is walked past. Routing between skills lives in the skills themselves: each body's preconditions, skips, and handoffs carry the work to its next owner, stated once, where the work actually is. But routing is process, not proof: it carries no deterministic verdict, so its firmness is persuasion, honestly labeled, never a claim to be a gate. The reliability of SDLC skills does not live in that firmness. It lives in the gates the skills define — and, where you want enforcement, in deterministic checks wired into git and CI, where enforcement is real and portable.
