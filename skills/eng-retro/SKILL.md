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
1. **Process-improvement pass (also in every advisor consultation):** read `process-feedback.md` and the previous retros. For each open entry: adopt (becomes a change below), reject (why), or defer. Mark handled entries in the log.
2. Collect flow data: slices done, cycle time, rework, escaped defects, handoffs that needed clarification, review findings by severity.
3. Went well / hurt / root causes (from files, not memory).
4. Propose at most 3 process changes, each mapped to a file edit.
5. After Rob agrees, apply the edits and tick them in the retro.

## Exit criteria
Retro written with the process-feedback pass; agreed changes applied; phase set to `discover` (next item) or project `done`.

## Approval stop (Rob)
Rob approves the proposed process changes before they are applied.

## Finish
Standard: end with eng-handoff.
