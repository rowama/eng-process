---
name: eng-discover
description: Turn an idea or problem into an approved design doc (problem, users, success metric, narrowest wedge, testable requirements). Use for medium/large work before any scoping, research, or code.
---
# eng-discover

Session: standard Start/Finish per `.eng/PROCESS.md` section 8 (kit: `PROCESS.md`). Scripts: `.eng/bin/eng-check`, `.eng/bin/eng-status`, `.eng/bin/eng-new`.

## Inputs (files only)
- Request text / design stub `docs/design/*.md`; `docs/vision/*` if present
- `PROJECT_STATE.md`, `AGENTS.md`

## Outputs
- `docs/design/<date>-<slug>.md` (`status: in-review`)
- Optional: `docs/vision/<slug>.md` (`.eng/bin/eng-new vision`) for a long-lived feature list; `thoughts/shared/market-research/*` (`.eng/bin/eng-new market-research`) for external research. Codebase research is NOT done here.

## Steps
1. Ask Rob forcing questions one at a time: who hurts and how do we know; current workaround; what metric moves; narrowest wedge; what is out.
2. Write Problem, Users and success metric, Narrowest wedge, 2-3 Alternatives.
3. Write Requirements as testable acceptance criteria with ids (REQ-n; WHEN ... THE SYSTEM SHALL ...). This list is the baseline for eng-scope-review.
3a. **Acceptance examples (medium/large, v2.5):** for each REQ write 1-3 concrete Given/When/Then examples in the problem domain's words (what, not how: no URLs, buttons, status codes) under "Acceptance examples". Rob approves them with the design at CP-A; they become the executable specs locked at CP-C (PROCESS.md 13). Small: "n/a - small".
4. Mark every ambiguity `[NEEDS CLARIFICATION: question]`; resolve each with Rob. Do not guess.
5. One artifact: the design doc. Don't pre-draft architecture or plans. If Rob asks for one anyway, give it `status: input` and a heading note "input, not approved".
6. Don't name the implementer in the design doc; it is a PROJECT_STATE working agreement.
7. Questions for later checkpoints (e.g. auth, hosting for CP-B) may be added to `pending_approvals` now.

## Exit criteria
All sections filled; zero `[NEEDS CLARIFICATION]`; each requirement testable.

## Approval stop (Rob)
**CP-A Product**: add `CP-A: <design path> - approve problem/requirements` to pending_approvals and stop. If Rob says "back up", follow PROCESS.md section 4a.

## Finish
Standard: end with eng-handoff.
