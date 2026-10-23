---
name: eng-architecture-review
description: Lock the system design: boundaries, contracts, data, sequence, failure modes, rollback, observability, security, and record durable decisions as ADRs. Use for large work after research is accepted and before planning.
---
# eng-architecture-review

Session: standard Start/Finish per `.eng/PROCESS.md` section 8 (kit: `PROCESS.md`). Scripts: `.eng/bin/eng-check`, `.eng/bin/eng-status`, `.eng/bin/eng-new`.

## Inputs (files only)
- Approved design doc, approved research doc (enforced by .eng/bin/eng-check for large work)
- `docs/decisions/*`; any `status: input` architecture pre-draft (treat as input, not approved)

## Outputs
- Design doc Architecture section, **or** for anything over ~1 screen a separate `docs/architecture/<date>-<slug>.md` (`.eng/bin/eng-new architecture <slug>`) linked from that section
- ADRs `docs/decisions/NNNN-<slug>.md` (`.eng/bin/eng-new adr <slug>`, id ADR-NNNN)
- Large work: cross-model review findings `thoughts/shared/verification/<date>-<slug>-review.md`

## Steps
1. Draw the component/sequence diagram (mermaid or ASCII) for new flows.
2. Define contracts first: interfaces, request/response shapes, schemas, data ownership.
3. For each error: trigger, handler, user-visible result, test. No silent failures.
4. Plan rollback, partial deploy, feature flags; observability is in scope.
5. Quick STRIDE pass for security-relevant changes.
6. **Standing question (always, for any UI):** *Can the owner judge this frontend's behaviour and code? If not, what reduces that gap?* (e.g. demo script, storybook/screenshots, simpler stack, opt-in CI checks from `.eng/templates/ci-checklist.md`). Answer it in the doc.
7. One ADR per durable choice, status `proposed`, with Expected outcome / Check date / What would prove it wrong. Use `deferred` (+ `revisit:`) for consciously postponed decisions.
8. **Cross-model review (advisory, large work):** ask Rob to run Codex on the architecture doc in Claude Code (`/codex`, i.e. `codex exec "review <path> for gaps, risks, contradictions" -o thoughts/shared/verification/<date>-<slug>-review.md`). Add the findings front matter + table above the raw output in that file, then answer each one in the doc or the findings file. Not a gate.

## Exit criteria
All checklist areas addressed or n.a. with reason; ADRs drafted; review findings answered (large).

## Approval stop (Rob)
**CP-B Architecture**: `CP-B: <design or architecture path> + <ADR paths> - approve architecture`. On approval: ADRs `accepted` (or `partially-accepted` with `## Parts`), architecture doc `approved`, one Approval log row naming every file.

## Finish
Standard: end with eng-handoff.
