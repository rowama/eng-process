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

### L-007: When messaging the owner with work he must do, separate brief status prose from a labeled Action-for-Rob numbered list (one step per line; pasteable commands in their own fence; never use valid shell syntax like `$TOKEN` as an edit placeholder — use `PASTE_…_HERE` or "paste at the prompt"), default to detailed steps that name the exact command and what it does versus adjacent systems/jargon without waiting for the owner to ask for clarity, and end with the decision he owes, because mixed status/findings/todo paragraphs hide what he is supposed to do, shell-valid placeholders get expanded if he pastes them, and underspecified steps force him to chase clarity.
- Origin: anonymised project, 2026-10-27
- Confirmations: 1
- Status: hypothesis
- Approved by Rob: 2026-10-27
- Evidence: anonymised project, 2026-10-27, owner could not sort action items out of mixed status/review paragraphs; confirmed the labeled Action-for-Rob numbered-list shape works for multi-step work. Same day: Action-for-Rob sample used `$TOKEN`-style placeholder; shell expanded it on paste — prefer `PASTE_BOT_TOKEN_HERE` or paste-at-prompt. 2026-10-28 clarity addendum: owner had to push for exact CLI and jargon explained (what a project command does vs the adjacent product); that detail level is now the default.

### L-008: When the agent uncovers a risk and would mitigate it in design, architecture, or plan, stop with an explicit Decision needed that names the risk, the friction/ops cost, and a narrower alternative, because baking mitigation in as ordinary scope hides a cost the owner did not choose.
- Origin: anonymised project, 2026-10-27
- Confirmations: 1
- Status: hypothesis
- Approved by Rob: 2026-10-27
- Evidence: anonymised project, 2026-10-27, blast-radius mitigation landed in architecture without a clear cost ask; owner later rejected the friction (extra step per bot per channel).

### L-009: When asking the owner for CP-S (or any manual verification), only list steps that are runnable against the deployed/runtime-now path, each with a verified readiness predicate (entry point started, env present, dependency live); if a step is blocked, say blocked + why + which slice unblocks it — never paste the plan's full demo script or later-slice criteria as the current Action for Rob, because unverified demo steps burn owner time on paths that cannot succeed yet.
- Origin: anonymised project, 2026-10-28
- Confirmations: 1
- Status: hypothesis
- Approved by Rob: 2026-10-28
- Evidence: anonymised project, 2026-10-28 — CP-S Action listed full live e2e from the slice demo while the feature path was not started in the app entrypoint; owner stood up infra and failed; checklist narrowed only after the failure.
