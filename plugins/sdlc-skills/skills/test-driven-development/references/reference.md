# Test-Driven Development — Reference

How to keep a test on the public interface. (The discipline—when and why to
test first—is in `../SKILL.md`.)

## Test behavior, not implementation

Assert what the unit does through its public interface. If a behavior can't be
reached through the public surface, that's a design signal, not a reason to
test internals.

## Don't let the test deform the domain

Making code testable should *improve* the design, not corrupt it. Two ways a test can deform the thing it tests:

- **Parameter pollution** — widening a domain signature with infrastructure (`createOrder(order, clock, idGenerator, random)`) purely so a test can pin those down. Injecting genuine collaborators is good design; but a clock or an id generator is ambient infrastructure — hide it behind the seam (a provider the unit holds, a wrapper you substitute in the test) rather than threading it through the public domain API.
- **Helper leakage** — promoting an internal (`isAmountValid`, `normalizeName`) to the public surface only so a unit test can reach it. If it has no standalone domain meaning and no production caller, asserting on it directly is testing an implementation detail. Exercise it through the public behavior, or extract it into its *own* unit with a real interface — don't expose it in place.

Same signal as a hard-to-write test: if the only reason a parameter or method is public is the test, the seam is in the wrong place. Move the seam, don't widen the API.

## Refactor targets

When you extract private helpers in REFACTOR, keep the tests on the public
interface — don't let them couple to the new internals.
