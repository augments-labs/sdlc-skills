# Test-Driven Development — Mocking

## Substitute only at a real boundary

Use a fake, stub, or mock where the test's scope meets a justified seam:
external services, database, clock, randomness, network, filesystem, or an owned
component whose contract is independently verified. Run ordinary owned logic
inside that scope for real.

**Never substitute the unit under test or its private helpers.** If every owned
collaborator is mocked, the test proves a call script rather than behavior.
Inject a genuine boundary dependency so the test can supply a small stand-in,
and cover an owned substituted boundary with a separate contract or integration
gate. Ownership alone neither justifies nor forbids the seam.

## Test the behavior, not the mock

Assert the observable result your caller would see, never that the mock was called. If removing the real component still makes the test pass, you are testing the mock.

## Keep mocks honest

- **Mirror the real shape.** A stub returning only the fields you currently read breaks silently when the code later needs a field you omitted. Match the real response.
- **Don't mock away the behavior under test.** If the test depends on a side effect, mocking the method that produces it guts the test.
- **One seam, one shape.** Structure external calls as specific functions (one per operation), so each test injects one simple stand-in instead of a branching mock factory.

## Keep production code clean

Cleanup or inspection helpers that exist only for tests belong in test utilities, never on the production type.
