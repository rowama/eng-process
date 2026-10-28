---
name: eng-verify
description: Independently verify the implementation against the plan and the Definition of Done by re-running every check, and fold in the advisory cross-model review. Use after the implementer's handoff and review fixes, for each slice before CP-S and for the increment before shipping.
---
# eng-verify

Session: standard. **Start:** read only `PROJECT_STATE.md`, the latest handoff it links, and this skill's Inputs; run `.eng/bin/eng-check .` and stop and report if it fails for a reason this skill must not fix; stop if `pending_approvals` holds a checkpoint this skill needs. **Finish:** run eng-handoff (updates PROJECT_STATE phase / active_slice / pending_approvals / owner_agent / date / Next action / Blockers / Latest artifacts, writes the handoff, eng-check must pass, commits docs). Edge cases: `.eng/PROCESS.md` section 8. Scripts: `.eng/bin/eng-check`, `.eng/bin/eng-status`, `.eng/bin/eng-new`.

## Inputs (files only)
- Plan, slice cards, `docs/definition-of-done.md`, the implementer's latest handoff
- Review findings `thoughts/shared/verification/*-review.md` for the slice(s)
- `git diff <base>...HEAD`

## Outputs
- `thoughts/shared/verification/<date>-<slug>.md` (includes a **Cross-model review** section)
- Follow-ups in `TODOS.md`

## Steps
1. Run as the planner (or another agent), not the implementer. Pick up the implementer's handoff.
2. Re-execute every Automated Verification command and the full test/lint/build; record command + exit code.
3. Review the diff against the plan: deviations, missed items, edge/error paths, security; name every weakened test, timeout, skip, or suppression.
3a. **Executable specs (v2.5, when acceptance is enabled):** re-run the whole acceptance suite on every planned channel (`pytest tests/acceptance`, plus `--channel=ui` for large work), paste `python3 .eng/bin/eng-spec trace .` into the report's Executable specs table with results, and `eng-spec status .`. Any REQ without a passing spec, or a locked spec / DSL interface change without Rob's new CP-C speclock row, is a FAIL item; a changed DSL assertion step must be covered by the code review findings.
4. **Cross-model review:** medium/large: confirm the mandatory plan review is linked and clean (.eng/bin/eng-check). Slice diffs: confirm the Codex findings file exists for this diff (required for auth/tenancy/security slices; "skipped: small/docs-only" otherwise allowed). If missing and needed, ask Rob to run it before CP-S (`python3 .eng/bin/eng-run code-review <slice-id>`; Chet/Dave may run it on Rob's PC with his approval). eng-run refuses to let the implementer review its own slice; a `--allow-self-review` run must be named in the report. Whoever starts a headless code-review **stays attached** until exit (default), or uses a non-empty `code_review_on_complete` / `on_complete` plus an S 45m timeout on the `.running.md` PID marker (PROCESS.md section 10; L-006). Summarize it in the report section: reviewer, command, counts by severity, the resolution of each high finding. Advisory: never a FAIL by itself, but name any unresolved high finding in the Verdict.
5. Walk the DoD item by item: pass / fail / n.a.
6. Verdict PASS only if all criteria and DoD items pass; otherwise FAIL with the slice to reopen. Run `.eng/bin/eng-check .`.

## Exit criteria
Report complete with re-executed evidence, review summary and verdict.

## Approval stop (Rob)
Per slice: **CP-S** `CP-S: <slice path> - manual verification`. Increment: **CP-D** `CP-D: <report path> - approve done` with the Manual Verification checklist.

Before the CP-S (or CP-D) **Action for Rob** (LESSONS L-009): filter Manual verification to steps that are runnable against the deployed/runtime-now path. For each step, record `ready: <predicate you verified>` (entrypoint started, env present, dependency live) or move it under **Blocked / deferred** with `blocked: <why> → unblocks in <slice>`. Never paste the plan's full Demo script or later-slice criteria as the current Action for Rob. Default L-007 clarity: exact commands, success look, jargon explained once; on first mention of anything new, where it lives + what it does + exact value/action.

## Finish
Standard: end with eng-handoff.
