---
name: eng-implement-slice
description: Implement exactly one slice of an approved plan, test-first, then hand off for independent review and verification. Use when PROJECT_STATE shows an approved plan and a todo slice, or a small triaged task. Normally run by the implementer (Claude Code on the owner's PC) from the "ready to implement" prompt.
---
# eng-implement-slice

Session: standard Start/Finish per `.eng/PROCESS.md` section 8 (kit: `PROCESS.md`). Scripts: `.eng/bin/eng-check`, `.eng/bin/eng-status`, `.eng/bin/eng-new`.

## Who runs this
The PROJECT_STATE `implementer` (default Claude Code on Rob's PC). If you are the planner, don't code: check readiness (plan approved, slice is `active_slice` with `status: todo`, `pending_approvals` empty, `.eng/bin/eng-check` OK) then start the run: `python3 .eng/bin/eng-run implement <plan> <slice-id>` (or `eng run implement ...`). Rob's CP-C / slice-ready approval covers starting it unless he said otherwise; with no standing note in PROJECT_STATE, one-line "start implement?" is enough. Tell Rob once, as FYI, with the "ready to implement" message `.eng/bin/eng-status` prints. Don't default to paste-and-stop: the paste prompt ("Run eng-resume, then eng-implement-slice for <slice> per <plan>") is the fallback when eng-run/Claude CLI is unavailable or Rob wants to drive Claude interactively. Stop only for real decisions: CP-S, push when `push_permission: ask` (docs-only commits push without asking), eng-check failures, locked-spec issues, open critical/high plan-review findings, blockers.

## Inputs (files only)
- Approved plan (read fully); the slice card; files named in that phase's Changes Required

## Outputs
- Code and tests; plan checkboxes for this phase; slice card Progress log, `status: review`
- `CHANGELOG.md` Unreleased entry when user-visible: `.eng/bin/eng-new changelog <slug> --section Added --summary "<user-facing sentence>"` (no placeholders)
- Responses to the independent review findings file

## Steps
1. `.eng/bin/eng-check .` must pass. Set slice `in-progress`, PROJECT_STATE `active_slice`.
2. Write a failing test for the slice behavior; then the smallest change that passes.
2a. **Executable specs (v2.5):** before step 2, run the slice card's `specs:` (`pytest <node>`) and confirm they fail for the right reason. Make them pass by changing code, drivers, or private DSL helpers. **Never edit** locked specs (`tests/acceptance/specs/`) or the DSL public interface (names, parameters, docstrings): if one looks wrong, stop and report "Issue in Phase N: spec <node> - <why>". A change to a DSL assertion step body must be named in the handoff so the code review covers it. `eng-check` and `eng-run implement` flag these edits for Rob (warnings, not failures).
3. If the code doesn't match the plan: stop and report "Issue in Phase N: expected X, found Y" in slice Blockers. Don't improvise.
4. Run the phase's Automated Verification; fix until it passes. Never weaken a test/gate.
5. Bug: no fix without root cause; after 3 failed attempts stop and hand off.
6. Keep the diff ~100-200 lines; commit naming the slice id. Push only per `push_permission` (default: ask Rob first; docs-only commits push without asking).
7. (Medium/large: the plan review is a gate; .eng/bin/eng-check refuses `in-progress` until it is linked and clean, or Rob's waiver row is logged for a grandfathered plan.) **Slice-diff review (advisory)** unless the change is small or docs-only: run Codex on the slice diff (Claude Code: gstack `/codex`, i.e. `codex review --base <base> > thoughts/shared/verification/<date>-<slice-slug>-review.md`, so the output lands in the repo, not just the terminal; or simply `python3 .eng/bin/eng-run code-review <slice-id>`, which writes the findings file and a run log; needs `npm install -g @openai/codex` and `codex login`). Always for auth, tenancy or security. Add the findings front matter + table above Codex's raw output in that file (template `review-findings.md`); fix or answer each (commit refs in the Response column), set it `addressed`.
8. Headless: Rob (or Chet/Dave on Rob's PC, with his approval) may start this skill with `python3 .eng/bin/eng-run implement <plan> <slice-id>`; the run log lands in `thoughts/shared/runs/`. The starter owns the completion signal: **stay attached** until exit (default), then read the run log + latest handoff / PROJECT_STATE and continue (eng-verify / request CP-S) or surface the blocker. Fire-and-forget only with a non-empty `[hooks] implement_on_complete` or `on_complete` plus a timeout routine (M 2h / L 4h) on the `.running.md` PID marker (PROCESS.md section 10; L-006). Empty hooks = do not detach.
9. Compact progress into the slice card and plan checkboxes as you go; end with eng-handoff so the planner can pick up.

## Exit criteria
Automated criteria pass (exit codes in Progress log); review findings answered or skip reason noted; slice `review`; one slice only.

## Approval stop (Rob)
None here. The planner runs eng-verify, then requests **CP-S Slice**: `CP-S: <slice path> - manual verification` with the Manual Verification steps. Don't start the next slice.

## Finish
Standard: end with eng-handoff.
