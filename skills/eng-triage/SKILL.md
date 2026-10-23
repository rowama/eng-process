---
name: eng-triage
description: Classify a request as small, medium, or large and choose the phases it needs, or run the readiness check when a project claims to be at a later phase. Use when a new request, bug, or idea arrives, when research shows the work is bigger than assumed, or when adopting/resuming a project that says it is already past discovery.
---
# eng-triage

Session: standard Start/Finish per `.eng/PROCESS.md` section 8 (kit: `PROCESS.md`). Scripts: `.eng/bin/eng-check`, `.eng/bin/eng-status`, `.eng/bin/eng-new`.

## Inputs (files only)
- The request text (save it to the design doc or slice card)
- `PROJECT_STATE.md`, `AGENTS.md`, `PROCESS.md` section 2

## Outputs
- `PROJECT_STATE.md` `triage:`, `phase`, Next action, Blockers
- Small: a slice card (`.eng/bin/eng-new slice <slug>`). Medium/Large: a design doc stub (`.eng/bin/eng-new design <slug>`)

## Steps
1. If `triage` is already set and still fits, keep it (go to step 5). Otherwise apply the PROCESS.md section 2 table: files touched, new interfaces, data changes, reversibility, risk area (security, money, data loss).
2. Do at most a quick locate (sub-task) to count affected areas; no deep research.
3. Pick size; when unsure, size up. Write the 3-line rationale in the stub artifact.
4. Small: fill the slice card (change, test, acceptance criterion); set phase `implement`. Medium/Large: set phase `discover`.
5. **Readiness check** (always when the project claims a later phase, e.g. "already discussing slice 1"): run `.eng/bin/eng-status .` and read its `readiness:` lines (they implement the PROCESS.md section 2 readiness table). For each earlier phase on this size's path, confirm the artifact exists **and** its approval is in the Approval log with a matching status. If anything is missing: set `phase` to the earliest incomplete phase, list exactly what's missing under Blockers (artifact, checkpoint, who acts), and add a "Back-ups to an earlier phase" line (PROCESS.md section 4a). Pre-kit decisions may be back-filled (section 11) only with Rob's confirmation.
6. `.eng/bin/eng-check .` passes.

## Exit criteria
Size recorded with rationale; phase matches the evidence; missing items listed; next skill named.

## Approval stop (Rob)
Ask Rob to confirm the size when it is Large, or Small touching a risk area, and to confirm any phase reset.

## Finish
Standard: end with eng-handoff.
