---
name: eng-ship
description: Prepare a verified change for release: changelog, version, PR, CI, review-notes rotation. Use only after a PASS verification report with CP-D approved.
---
# eng-ship

Session: standard Start/Finish per `.eng/PROCESS.md` section 8 (kit: `PROCESS.md`). Scripts: `.eng/bin/eng-check`, `.eng/bin/eng-status`, `.eng/bin/eng-new`.

## Inputs (files only)
- Verification report (`status: pass`), `CHANGELOG.md`, `VERSION` if present, `AGENTS.md`

## Outputs
- Finalized CHANGELOG entry, bumped `VERSION` (if used), pushed branch, PR (`gh pr create`)
- Rotated owner review notes (if any)

## Steps
1. `.eng/bin/eng-check .`; confirm verification `pass` and no pending approvals.
2. Sync with the base branch; re-run the full test suite.
3. Finalize the CHANGELOG entry (user-facing summary first; `.eng/bin/eng-check` rejects `<...>` placeholders and empty bullets); bump VERSION per project convention.
4. Docs audit: README/AGENTS.md/API docs match changed behavior.
5. Push (per `push_permission`; default ask Rob first) and open a PR linking the plan, verification report, review findings and ADRs. Wait for CI; fix only by root cause.
6. Never merge or deploy yourself unless Rob explicitly asked for that specific action.
7. **Notes rotation:** if `thoughts/shared/review-notes/<owner>-review-notes.md` has notes beyond the template header, `git mv` it to `<cycle-id>-<owner>-review-notes.md` (cycle id = release version or plan id) and recreate the empty scratch file from `.eng/templates/review-notes.md`.

## Exit criteria
PR open, CI green, CHANGELOG/VERSION updated, notes rotated.

## Approval stop (Rob)
**CP-P**: `CP-P: <PR url> - review/merge/deploy`. After merge, set phase `reflect`.

## Finish
Standard: end with eng-handoff.
