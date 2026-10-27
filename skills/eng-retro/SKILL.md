---
name: eng-retro
description: Reflect on a shipped increment (or a week, or an advisor consultation) and turn lessons and process feedback into concrete edits to conventions, templates, skills, or the DoD. Use after ship, on a regular cadence, or whenever an advisor is consulted about the project.
---
# eng-retro

Session: standard Start/Finish per `.eng/PROCESS.md` section 8 (kit: `PROCESS.md`). Scripts: `.eng/bin/eng-check`, `.eng/bin/eng-status`, `.eng/bin/eng-new`.

## Inputs (files only)
- Plans, slice cards, verification and review-findings reports, handoffs since last retro; `git log`; `TODOS.md`
- `thoughts/shared/process-feedback.md` and previous `thoughts/shared/retros/*`

## Outputs
- `thoughts/shared/retros/<date>-<slug>.md`
- Edits to `AGENTS.md`, `docs/definition-of-done.md`, `.eng/templates/*` as agreed; kit-level suggestions collected for the kit maintainer (never project details)

## Steps
1. **Process-improvement pass (also in every advisor consultation):** read `process-feedback.md` and the previous retros. For each open entry: adopt (becomes a change below), reject (why), or defer. Mark handled entries in the log. Friction only mentioned in handoffs is not seen here, so agents must log it in `process-feedback.md` in-session.
2. **Score past predictions:** for every ADR, consultation note and previous retro entry with *Expected outcome / Check date / What would prove it wrong* whose check date has passed, score it **right / wrong / unclear** with one line of evidence (retro table + the entry's `Score:` line). Record new predictions for recommendations made now.
3. **Review hit-rate:** from `thoughts/shared/verification/*review*.md` since the last retro: findings total, accepted (fixed / accepted-risk) vs rejected, real bugs caught, rejected rows with evidence (file:line or test).
4. **Design adoption:** read the *Design adoption* section of `process-feedback.md`. Informed-owner skips are not counted. Two counted non-safety skips of the same step -> write a **redesign flag** for that step. Any safety-gate skip (personal data, mandatory plan review, CP approvals) -> escalate to Rob now, don't wait for the retro to finish.
5. **Waste and time:** answer "which step felt like waste?" and fill rough time per phase.
6. **Kit lessons:** propose lessons as "When X, do Y, because Z" (`.eng/templates/kit-lesson.md`) with origin, confirmations and status `hypothesis`. A lesson already in the kit's `LESSONS.md` that this project confirms gets +1 confirmation; at 2 projects it becomes `confirmed`. Rob approves every kit lesson change; no project details.
7. Collect flow data: slices done, cycle time, rework, escaped defects, handoffs that needed clarification, review findings by severity.
8. Went well / hurt / root causes (from files, not memory).
9. Propose at most 3 process changes, each mapped to a file edit.
10. After Rob agrees, apply the edits and tick them in the retro.

## Exit criteria
Retro written with the process-feedback pass, predictions scored, review hit-rate, waste/time and design-adoption sections filled; agreed changes applied; phase set to `discover` (next item) or project `done`.

## Approval stop (Rob)
Rob approves the proposed process changes and every kit lesson before they are applied.

## Finish
Standard: end with eng-handoff.
