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
5. If `thoughts/shared/inbox.md` has items under `## Open` or `## Deferred`, mention the count to Rob ("N inbox items; say process incoming to go through them"). Do not process them unless asked (eng-inbox).
6. **Stale kit:** if step 1 printed `vendored kit vX is older than kit vY`, ask Rob once per session, unless deferred (`kit_upgrade: deferred` in PROJECT_STATE front matter, or a `kit_upgrade: deferred` line in `thoughts/shared/process-feedback.md`; then say nothing). Use the L-007 shape: one status line, then

   **Action for Rob**
   1. Reply "upgrade" to have the planner run the upgrade, or "defer" to record `kit_upgrade: deferred` in PROJECT_STATE.
   2. Or run it yourself in the repo root:
   ```
   eng upgrade .
   ```
   Decision owed: upgrade the vendored kit now, or defer. Never an eng-check error; do not block the Next action on it.
7. State: phase, next skill, discrepancies. Then run that skill in this session only if context is still small.

## Exit criteria
Agent can state the phase, next skill, and blockers from files alone; discrepancies recorded.

## Approval stop (Rob)
Stops if needed approvals are pending or the handoff contradicts the repo.
