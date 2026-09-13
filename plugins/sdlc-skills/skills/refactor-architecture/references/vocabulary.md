# Module Design Vocabulary

Shared terms for `refactor-architecture` (and `system-architecture`), so the same concept is never two words.

- **Module** — a unit that hides a body of work behind an interface. Judged by what it *hides*, not its size.
- **Interface** — everything a caller must know to use the module: signatures, types, names, and the obligations and failure modes implied. Narrower is better.
- **Depth** — the ratio of hidden complexity to interface surface. A *deep* module does a lot behind a little; a *shallow* one's interface is nearly as large as its implementation (a pass-through, a thin wrapper). **Depth is a property of the interface, not the implementation** — adding code doesn't deepen a module; hiding more behind the *same* interface does.
- **Seam** — a place where an implementation or external boundary can change
  without spreading its impedance and failure policy into callers. Justified by
  repeated behavior with a stable owner and measured change friction, or by one
  real volatile/external boundary with measured translation, isolation, or
  recovery needs. Implementation count alone and hypothetical future variation
  neither require nor justify one.
- **Adapter** — the thin translation layer at a seam that converts the outside world's shape to yours and back. It owns the impedance mismatch so the core doesn't.
- **Leverage** — friction removed per unit of churn. Refactor where leverage is highest, not where the code is ugliest.

## The deletion test

To tell a deep module from a shallow one: imagine deleting it and inlining its work into every caller. If that **spreads** complexity the module was holding, it earns its depth — keep it. If the complexity merely **relocates** unchanged, the module is shallow — collapse it.
