---
name: eng-resume
description: Cold-start any agent on a project. Use at the beginning of every session, before any other eng-* skill, or when taking over work from another agent.
---
# eng-resume

This skill is the standard session Start (`.eng/PROCESS.md` section 8). It ends by running the Next action's skill or eng-handoff; it doesn't call itself.

## Inputs (files only)
- `PROJECT_STATE.md`; the latest handoff it links; only that handoff's Critical References

## Outputs
- No new artifact; updates `PROJECT_STATE.md` (`owner_agent`, `date`) and Blockers if discrepancies are found

## Steps
1. Run `.eng/bin/eng-status .` and `.eng/bin/eng-check .`. Note the `readiness:` line and the working agreements (are you the planner or the implementer?).
2. Read PROJECT_STATE fully, then the latest handoff fully. Read its Critical References directly.
3. Verify the handoff's Recent changes exist (`git log`, `git status`, open the cited file:line).
4. If a pending approval is one the next skill needs, or readiness is NOT READY: report to Rob and stop (suggest eng-triage readiness check).
5. State: phase, next skill, discrepancies. Then run that skill in this session only if context is still small.

## Exit criteria
Agent can state the phase, next skill, and blockers from files alone; discrepancies recorded.

## Approval stop (Rob)
Stops if needed approvals are pending or the handoff contradicts the repo.
