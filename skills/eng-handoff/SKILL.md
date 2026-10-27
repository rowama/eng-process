---
name: eng-handoff
description: Compact the current session into a handoff file so another agent can continue cold. Use at the end of every session, before context gets large, and whenever stopping for approval.
---
# eng-handoff

This skill is the standard session Finish (`.eng/PROCESS.md` section 8). It is not for project briefs: use `.eng/bin/eng-new brief` for orienting a new implementer.

## Inputs (files only)
- Your own session work; `PROJECT_STATE.md`; `git status`, `git log -5`

## Outputs
- `thoughts/shared/handoffs/YYYY-MM-DD_HH-MM-SS_<slug>.md` (`.eng/bin/eng-new handoff <slug>`)
- Updated `PROJECT_STATE.md`

## Steps
1. `.eng/bin/eng-new handoff <slug> --agent <you>`.
2. Fill: Task(s) with status and plan phase; 2-3 Critical References; Recent changes as `file:line`; Learnings; exhaustive Artifacts; Approvals; Action Items starting with the next skill (`next_skill:`).
3. Record approvals Rob gave in chat this session: Approval log row, artifact status, ADR if durable; remove from `pending_approvals` (front matter only).
4. Update PROJECT_STATE (phase, active slice, Next action, Blockers, pending approvals, Latest handoff link, owner_agent, date).
5. **Notes rotation:** if a slice became `done` this session and the owner's review-notes file has notes, `git mv` it to `<slice-id>-<owner>-review-notes.md` and recreate the empty scratch file from `.eng/templates/review-notes.md`.
6. If an inbox process (eng-inbox) stopped partway, say so in Action Items; never rotate `thoughts/shared/inbox.md` here.
7. If you hit process friction, append it to `thoughts/shared/process-feedback.md` now, in-session (the retro pass reads that log, not handoffs).
8. Commit docs; `.eng/bin/eng-check .` passes.

## Exit criteria
A cold agent could continue using PROJECT_STATE + this file alone.

## Approval stop (Rob)
None; it records approvals requested by other skills. When you message Rob about a stop or next step, use `.eng/templates/owner-update.md` (LESSONS L-007): status, then **Action for Rob** / `No action for you.`, then the decision owed.
