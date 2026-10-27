# Kit lessons

Format: `.eng/templates/kit-lesson.md` (kit: `templates/kit-lesson.md`). Each lesson is
**when X, do Y, because Z**, with origin, confirmation count and status. A lesson stays a
*hypothesis* until a second project confirms it, then becomes *confirmed*. Only lessons Rob
approved are listed here; eng-retro proposes them in the retro's "Kit lessons proposed" section.

## Confirmed

## Hypotheses

### L-001: When a headless implementer run starts, preflight that gate commands (eng-check, test runner) actually run under the configured permission mode before taking the slice, because a mis-set implement_args / acceptEdits override still burns a full run.
- Origin: anonymised project v0.2.0 retro, 2026-10-26
- Confirmations: 1
- Status: hypothesis
- Approved by Rob: 2026-10-26
- Evidence: anonymised project, 2026-10-26, a permission-mode override blocked gate commands and a full implementer run was wasted.

### L-002: When a project ships trunk-based (main + tag), CP-P may name the tag/commit instead of a PR URL, because eng-ship/PROCESS still shape CP-P as PR merge and force improvisation on trunk+tag projects.
- Origin: anonymised project v0.2.0 retro, 2026-10-26
- Confirmations: 1
- Status: hypothesis
- Approved by Rob: 2026-10-26
- Evidence: anonymised project, 2026-10-26, CP-P had to be improvised for a main + tag release.

### L-003: When code has time- or rate-based behaviour, inject the clock in tests from slice 1, because wall-clock tests flake intermittently and are found late.
- Origin: anonymised project v0.2.0 retro, 2026-10-26
- Confirmations: 1
- Status: hypothesis
- Approved by Rob: 2026-10-26
- Evidence: anonymised project, 2026-10-26, wall-clock-dependent tests flaked intermittently and were found late.

### L-004: When a commit is documentation-only, push it to main without asking, because waiting for push OK on prose stalls the process loop for no code risk.
- Origin: anonymised project / kit docs cycle, 2026-10-26
- Confirmations: 1
- Status: hypothesis
- Approved by Rob: 2026-10-26
- Evidence: anonymised project / kit, 2026-10-26, docs-only process commits sat waiting for push OK after the change was already approved.

### L-005: When a mandatory plan review is due, the planner starts eng-run plan-review on the owner's PC without asking, because handing the owner the command blocks the loop for a non-decision.
- Origin: anonymised project, 2026-10-27
- Confirmations: 1
- Status: hypothesis
- Approved by Rob: 2026-10-27
- Evidence: anonymised project, 2026-10-27, planner offered paste/widget instead of starting plan-review; owner expected it to run automatically.

### L-006: When starting eng-run, stay attached until exit unless a non-empty on_complete hook is configured, because empty hooks plus fire-and-forget silently miss completion.
- Origin: anonymised project, 2026-10-27
- Confirmations: 1
- Status: hypothesis
- Approved by Rob: 2026-10-27
- Evidence: anonymised project, 2026-10-27, plan-review finished with exit 0 and no wake; runners.toml had no [hooks]; starter had ended the turn.
