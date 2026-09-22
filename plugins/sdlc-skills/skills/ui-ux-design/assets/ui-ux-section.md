# UI/UX section template

Copy this section into the design document, replacing every `{{placeholder}}`.
Preserve the sections already approved around it; this one is immutable once its
identity is issued. Every flow, state, visual reference, decision, and
acceptance check gets a stable ID, and a successor never recycles one.

```markdown
## UI/UX design

**Status:** {{draft | proposed; decision state stays external}}
**Identity:** recorded in the ledger row, never here: this section's identity
under the Identity rule of the artifact layout reference (`using-sdlc-skills`)
**Predecessor:** {{prior normative identity, or none; a proposal only links it}}
**Approval rule:** {{one accountable decision owner, or the required approvers
plus the conflict resolver and the rule that decides}}
**External decision ledger:** {{location; pending / changes requested / approved /
rejected / cancelled / superseded by approved normative identity, with trusted
evidence bound to this exact version}}
**Stable ID delta:** {{every flow, state, visual-reference variant, decision,
and check ID as added / changed / removed / preserved; a removal needs owning
approval}}

### Context

**Audience and situation:** {{who uses this, and what is going on for them}}
**Requirements this serves:** {{the approved requirement or brief identities}}
**Existing system evidence:** {{routes, screens, components, tokens, type,
content patterns, preview tooling, responsive and accessibility conventions, and
tests you actually read — with paths}}
**Deliberate constraints vs inconsistencies:** {{which existing patterns are
intentional and binding, and which this work may correct}}

### Frame

**Primary job:** {{the single thing this interface is for}}
**Primary affordance:** {{the one control or gesture that does it}}
**Success looks like:** {{observable outcome}}
**Failure looks like:** {{observable outcome}}

### Flows

| ID | Journey | Given | When | Then |
| --- | --- | --- | --- | --- |
| {{F-001}} | {{name}} | {{entry condition}} | {{what the user does}} | {{completion, escape, or recovery}} |

Every flow needs an entry, a completion, an escape, and a recovery path.

### State matrix

| ID | Screen or region | State | What the user sees | What they can do next |
| --- | --- | --- | --- | --- |
| {{S-001}} | {{screen}} | {{empty / loading / partial / validation / error / offline / no-permission}} | {{content and affordances}} | {{the way out}} |

### Hierarchy and content

| Screen | Primary | Secondary | Contextual | Deferred |
| --- | --- | --- | --- | --- |
| {{screen}} | {{what wins the eye}} | {{}} | {{}} | {{what is one level down}} |

Use realistic content and the user's vocabulary. An action name stays identical
through its control, its confirmation, and its errors.

### Visual direction

{{Layout, type, color, spacing, shape, imagery, and motion as one
product-specific system — what it is, and what in the product it comes from.}}

Where variants were compared: {{what was held constant, what differed, which won,
and on what grounds — or, when no comparison ran, the stated reason none was owed}}

#### Selected visual references

| Reference ID | Decision ID | Medium | Approved design artifact version | Artifact locator | Artifact version | Content digest | Selection ID | Rendering-input identity | Freshness evaluator | Normative conditions | Distinguishing invariants |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| {{VR-001}} | {{D-001}} | {{local HTML / project or native preview / screenshot / wireframe}} | {{this design's identity}} | {{stable path, route, or artifact ID}} | {{immutable version, revision, or capture ID}} | {{digest of selected bytes or artifact}} | {{stable variant, state, frame, or region ID}} | {{immutable chrome, assets, fixture, environment, and capture-set identity}} | {{exact check producing one of `pass`, `mismatch`, `unavailable`, or `error`}} | {{states, viewports, themes, fixtures, or capture set}} | {{observable traits that distinguish this selection from rejected directions}} |

Use one keyed row per independently selected decision, or state `not
applicable` with the recorded reason no comparison was owed.

### Conditions

| Condition family | Behavior, or skip record |
| --- | --- |
| Responsive breakpoints | {{what changes, or: skip ID, rationale and evidence, owner, expiry or revisit date, compensating evaluator, and who approved}} |
| Input methods | |
| Keyboard and focus | |
| Semantic structure | |
| Contrast | |
| Reduced motion | |
| Content extremes | |
| Localization pressure | |

### Evidence

| Claim | Kind | Source |
| --- | --- | --- |
| {{what is asserted}} | {{observed project fact / user research / usability observation / accessibility or policy constraint / stakeholder preference / inference}} | {{where it came from}} |

A preference can select a direction. It can never stand in for proof that users
can complete the flow.

### Decisions and deviations

| ID | Decision | Rationale | Deviates from the existing system? |
| --- | --- | --- | --- |
| {{D-001}} | {{what was decided}} | {{why}} | {{no, or what it departs from and why}} |

### Acceptance checks

| ID | Check | Who or what runs it |
| --- | --- | --- |
| {{A-001}} | {{observable pass/fail condition}} | {{human check for subjective criteria; never self-approved}} |

### Open risks

| Risk | Future evaluator | Owner |
| --- | --- | --- |
| {{unresolved usability or accessibility risk}} | {{what would settle it}} | {{who owns it}} |

Never present a named future evaluator as though it had already run.
```
