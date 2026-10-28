# Changelog (eng-process kit)

## Unreleased
### Added
- LESSONS L-010: when a change reverses a user-visible default the owner relied on, the approval ask carries a one-line Before → After example and CP-S demos it. `templates/owner-update.md`, PROCESS §9, `templates/definition-of-done.md`, eng-verify, OWNER-GUIDE.
- LESSONS L-011: a code-review runner sandbox that cannot bind loopback gives partial test coverage only — never count it for socket/integration suites; the verifier re-runs them. AGENTS template, eng-verify.
- LESSONS L-012: with two or more agents on one project, one agent owns writes to PROJECT_STATE and TODOS; others append via handoff or inbox. AGENTS template.
- LESSONS L-013: multi-component live features expose a thin end-to-end live path early (walking skeleton) so CP-S has something live to approve. `templates/plan.md`.
- L-003 extended to concurrency/timing waits: no sleep-based waits on threads/async tasks in tests (events, injected clocks, or deadline polling). `templates/definition-of-done.md`.
- Same-project reconfirm evidence appended to L-004, L-006, L-008, L-009 (Confirmations unchanged).
- LESSONS L-009: CP-S / owner manual checks list only runnable-now steps, each with a readiness predicate (or blocked + why + unblock slice); never paste the plan demo script as the current Action for Rob. eng-verify Approval stop, `templates/verification-report.md`, `templates/plan.md` Demo/Manual notes, `templates/owner-update.md`, PROCESS §9, AGENTS, OWNER-GUIDE.
- L-007 clarity addendum: Action-for-Rob defaults to detailed pasteable steps that explain jargon / adjacent systems without waiting for the owner to ask.
- L-007 first-mention addendum: first time the owner must do or understand anything new (concept, feature config, setup/admin step), explain where it lives, what it does, and the exact value/action — no assumed platform knowledge. owner-update examples; PROCESS §9, AGENTS, OWNER-GUIDE.

## 2.5.9 - 2026-10-27
### Fixed
- Remove stray negative-test line (`See PROCESS §10.`) accidentally left in `skills/eng-verify/SKILL.md` on the v2.5.8 tag. Install `@v2.5.9` (or main tip); do not use the broken v2.5.8 tag commit for upgrades.


## 2.5.8 - 2026-10-27
### Added (measurable-only plan, Rob-approved via Winston)
- PROJECT_STATE `## Latest artifacts` holds the current increment / in-play artifacts plus standing links only; optional `## Prior increments` (eng-resume does not read it). eng-check warns above 12 in-play links (`LATEST_ARTIFACTS_MAX_LINKS`). PROCESS section 8.
- Approval log size trigger: eng-check warns (and eng-status reports) when the `## Approval log` table has more than 40 rows or the section exceeds 3072 bytes. When this fires on an active project, reopen the Approval-log archive design; eng-check must then treat the archive as part of the log. **No archive is built in this release.**
- eng-resume: stale vendored kit (`.eng/VERSION` older than the kit) is surfaced once per session as an L-007 **Action for Rob** (`eng upgrade .`), skipped when `kit_upgrade: deferred` is set in PROJECT_STATE front matter or `thoughts/shared/process-feedback.md`. Never an eng-check error.
- AGENTS template: mandatory plan review is a gate for medium/large; slice/architecture cross-model reviews stay advisory.
- eng-plan / eng-implement-slice / eng-verify carry the session Start/Finish happy path inline; PROCESS stays normative for edge cases. Kit test fails on bare see-PROCESS pointer lines in those skills.
- PROCESS.md and README.md H1 carry the kit version; kit test fails when they drift from VERSION.
### Added (process, shipped on main before this tag; first tagged here)
- Risk-mitigation decision gate (LESSONS L-008): when the agent uncovers a risk and would mitigate it in design/architecture/plan, stop with **Decision needed** (risk, friction/ops cost, narrower alternative) before baking it in. `templates/owner-update.md`, PROCESS §9, AGENTS, OWNER-GUIDE, eng-discover / eng-architecture-review / eng-plan.
- Owner-facing update shape (LESSONS L-007): brief status, then labeled **Action for Rob** numbered steps (one per line; pasteable commands in their own fence) or `No action for you.`; end with the decision owed. Never use valid shell syntax as edit placeholders (`$TOKEN`); use `PASTE_…_HERE` or paste-at-prompt. Template `templates/owner-update.md`; PROCESS §9, AGENTS, OWNER-GUIDE.


## 2.5.7 - 2026-10-27
### Changed
- Wake pair harden: **stay attached** to eng-run until exit is the default. Fire-and-forget only when a non-empty `[hooks] on_complete` / `<role>_on_complete` is set (plus a timeout routine). eng-run prints a WARNING when no hook will fire; eng-check warns when `[hooks]` is missing/empty. PROCESS section 10, eng-plan / eng-implement-slice / eng-verify, OWNER-GUIDE, runners.toml comments, LESSONS L-006.
### Added (process, from Unreleased)
- `push_permission: standing` = after eng-verify PASS, push `main` without asking; tags/force-push still ask.
- Docs-only commits always push to `main` without asking (L-004).
- Planner starts mandatory `eng-run plan-review` after the plan is drafted (FYI; L-005).
- DoD template: default test collection with zero silent skips; frozen clocks from slice 1 (L-003).
- AGENTS **Runtime facts** section pattern.
- LESSONS L-004, L-005, L-006 (hypotheses).

## 2.5.6 - 2026-10-26
### Added
- Owner incoming-thoughts inbox `thoughts/shared/inbox.md` (template `templates/inbox.md`, `## Open` / `## Deferred`). Capture prefixes `note:` `n:` `idea:` `feature:` `future feature:` `ff:` `capture:` `cap:` mean append only. "process incoming" / "check idea log" / "process notes" walks each item with the owner (classify, clarify, move/act, or defer), then archives to `thoughts/shared/inbox/YYYY-MM-DD-HHMM-inbox.md` with per-item status and restarts the live inbox with deferred items (deferral date).
- New skill `eng-inbox`. PROCESS.md (layout + owner workflow), OWNER-GUIDE, eng-project-init, eng-resume (mentions non-empty inbox, never processes), eng-handoff pointer.
- eng-init creates the inbox; `--upgrade` creates it when missing or blank and never overwrites existing content. eng-check skips the inbox and its archive (no front matter).
### Migration
- `eng upgrade .` creates `thoughts/shared/inbox.md` if missing (not auto-committed: it is a project file; commit it yourself).

## 2.5.5 - 2026-10-26
### Added
- `eng upgrade .` / `eng-init --upgrade` now makes a kit-only git commit (`chore: eng-process kit upgrade to vX.Y.Z`) staging only `.eng/bin/`, `.eng/templates/`, `.eng/prompts/`, `.eng/PROCESS.md`, `.eng/VERSION`, `.claude/skills/eng-*`, plus `.gitignore` when its eng-process defaults block changed. Never stages `.eng/runners.toml` or project files (OWNER-GUIDE.md, AGENTS.md boilerplate refreshes stay uncommitted). Never pushes. Uses the repo's git identity.
- Prints `Committed kit upgrade to vX.Y.Z as <sha> (kit paths only; not pushed).` or `Kit files updated to vX.Y.Z; left uncommitted: <reason>` (not a git repo, merge/rebase/cherry-pick/revert in progress, nothing to commit, `--no-commit`). Exit code stays 0.
- `--no-commit` escape hatch (`eng upgrade . --no-commit`).

## 2.5.4 - 2026-10-26
### Added
- Autonomous-run harness for every `eng-run` role: right after the runner starts, eng-run writes a PID marker `thoughts/shared/runs/<stem>.running.md` (`status: running`, `pid`, `eng_run_pid`, `role`, `slice`, `target`, `started`, `run_log`; valid front matter so eng-check passes mid-run) and deletes it once the finished run log is written. Finished run logs record `pid` and `eng_run_pid`. No marker when the runner fails to start; `--dry-run` prints the marker path and writes nothing.
- Hook env adds `ENG_PID` (runner child) and `ENG_ENG_RUN_PID`.
### Changed
- `[hooks]` now resolve for every role: `<role>_on_complete` (`implement_on_complete`, `plan_review_on_complete`, `code_review_on_complete`) wins, else general `on_complete`, else none. `implement_on_complete` alone still fires only for implement. Hook-failure warning names the role.
- (process) Wake pair for every autonomous eng-run role: callback hook + effort-based timeout (S/M/L 45m/2h/4h). Timeout classifies via the PID marker: alive = soft ping / one-band extend; dead + run log or handoff = missed callback, resume; dead + nothing = one retry for known project fixes, else hand platform/env/silent-subprocess failures to Ulrik (what failed, exact symptom + paths, tried, machine). PROCESS.md section 10, README, OWNER-GUIDE, eng-implement-slice, eng-plan, eng-verify, runners.toml template aligned.
### Migration
- `eng upgrade .` refreshes `.eng/bin/eng-run` and skills. `runners.toml` is project-owned: an existing `on_complete` now also fires after plan-review and code-review; set role keys if you want implement-only. Markers are deleted on finish; a leftover one means a run died.

## 2.5.3 - 2026-10-26
### Changed (process)
- Planner owns the `eng-run implement` completion signal: whoever starts it stays on the run (or resumes when it exits), reads the new run log + latest handoff / PROJECT_STATE, then continues (eng-verify / CP-S) or surfaces the blocker to Rob. No fire-and-forget. PROCESS.md section 10, eng-implement-slice, eng-plan, README, OWNER-GUIDE aligned.
### Added
- Optional `[hooks] implement_on_complete` (alias `on_complete`) in `.eng/runners.toml`: shell command run from the repo root after every implement exit (ok and failed), after the run log is written. Env: `ENG_ROLE ENG_EXIT_CODE ENG_STATUS ENG_RUN_LOG ENG_REPO ENG_PLAN ENG_SLICE ENG_HANDOFF`. `--dry-run` prints it without running. Hook failure warns (stderr + run log) and never changes eng-run's exit code. Empty by default; no network defaults.
### Migration
- `eng upgrade .` refreshes `.eng/bin/eng-run` and skills. `runners.toml` is project-owned and not overwritten: add a `[hooks]` table yourself if wanted.

## 2.5.2 - 2026-10-26
### Changed
- `eng-run implement` with the built-in claude runner now defaults to `--permission-mode bypassPermissions` (was `acceptEdits`). Headless runs cannot answer prompts and acceptEdits does not auto-approve pytest / `python3 .eng/bin/*`, so implement stalled at eng-check. Reviews stay read-only via `--allowedTools`; codex defaults unchanged.
- `templates/runners.toml`, OWNER-GUIDE, eng-run help document the default and how to override back to acceptEdits or tighten.
### Migration
- `eng upgrade .` to refresh vendored `.eng/bin/eng-run`. `runners.toml` is project-owned and not overwritten; an explicit `implement_args` there still wins.

## 2.5.1 - 2026-10-25
### Changed (process)
- Implement handoff defaults to eng-run: once a slice is ready the planner starts `python3 .eng/bin/eng-run implement <plan> <slice-id>` and tells Rob as FYI; CP-C / slice-ready approval covers starting it unless Rob said otherwise. The paste prompt is now the "Fallback (interactive Claude)".
- `templates/ready-to-implement.md` leads with the eng-run command; `eng-status` banner reads "ready to implement (start with eng-run; show Rob as FYI)".
- PROCESS.md section 10, eng-implement-slice, eng-plan, README aligned. Planners still stop for CP-S, push when `push_permission: ask`, eng-check failures, locked-spec issues, open critical/high plan-review findings, blockers.
### Migration
- `eng-init --upgrade` to refresh vendored templates/skills. No `eng spec` changes.

## 2.5.0 - 2026-10-23
### Added
- Executable specifications (Dave Farley's ATDD four-layer model; PROCESS.md section 13; opt-in per project). Design-side specs (design doc, architecture, ADRs) say what and how to build; executable specs are their test-side expression and point back with `@pytest.mark.req("REQ-n")`.
- `bin/eng-spec` / `eng spec`: `init` (copies the scaffold `templates/acceptance/` to `tests/acceptance/`, sets `acceptance: executable-specs`), `lock` (writes `tests/acceptance/spec-lock.json`: spec file hashes, DSL public interface, DSL assertion-step bodies; prints the CP-C row `approved speclock sha256:<hex>`), `status`, `trace` (REQ -> spec table).
- Scaffold: `conftest.py` (`--channel api|ui|mcp`, `driver`/`app` fixtures, `req` and `channels` markers), `dsl.py` (aliasing for isolation), drivers `api.py` (httpx), `ui.py` (Playwright), `mcp.py` (MCP SDK), example spec, README.
- Templates: design doc "Acceptance examples" (Given/When/Then, approved at CP-A); slice `reqs:`/`specs:` and a "run specs, confirm red" task; plan Testing Strategy acceptance line (channels, speclock); DoD item; verification report "Executable specs" table; `adr-acceptance-tests.md`.
- Prompts (prompt_version 2): implement must not edit locked specs or the DSL interface; plan-review checks REQ coverage, domain language and channels; code-review runs `eng-spec status` and names changed assertion steps.
- `eng-run implement` snapshots specs and the DSL around the run: on change it prints a WARNING and records an OWNER REVIEW entry in the run log (exit code unchanged).
- eng-check (warn-only until v2.6.0, `--strict` makes them errors; only when opted in and triage is not small): `speclock-not-approved`, `spec-changed-without-approval`, `dsl-interface-changed`, `dsl-assertion-changed`, `slice-without-spec`, `spec-unknown-node`, `req-without-spec`.
- Skills: discover (acceptance examples), architecture-review (channels ADR, large), plan (write and lock specs), implement-slice (red first, never edit locked files), verify (re-run, trace), ship, triage (depth by size), project-init (opt-in).
- eng-init vendors `templates/acceptance/` to `.eng/templates/acceptance/`.
### Changed (behaviour)
- As announced in 2.4.0, `rejected-no-evidence`, `draft-before-design` and `design-changed-after-approval` are now errors. `draft-before-design` also skips triage `unset` (size unknown before triage).
### Migration
- `eng-init --upgrade`; nothing changes until a project runs `eng-spec init .`. Approved designs without Acceptance examples are grandfathered; write their examples straight into specs at the next CP-C.

## 2.4.0 - 2026-10-23
### Added
- Predictions: ADR template gets Expected outcome / Check date / What would prove it wrong / Score; retro template records predictions made in consultations and scores past ones right/wrong/unclear (eng-retro step 2).
- Review evidence: rejecting a finding requires evidence (file:line or a test reference) in Reason. Retro gets a review hit-rate line (accepted vs rejected, real bugs caught).
- Research provenance convention (SOURCES.md, PROCESS.md §12): per-file `<!-- provenance -->` header (source, commit or date, verified/unverified), pinned src commits, staleness diff when a consultation relies on research, web snapshot only for decision-driving claims at re-derivation. eng-research step 5.
- Frontend legibility: architecture template/skill standing question "Can the owner judge this frontend's behaviour and code? If not, what reduces that gap?"; plan template Demo script section; opt-in size-dependent `templates/ci-checklist.md` (lint, typecheck, axe, bundle budget, Lighthouse), not enforced.
- Kit lessons: `templates/kit-lesson.md` ("when X, do Y, because Z", origin, confirmation count, status hypothesis until confirmed by a second project, Rob approves) and `LESSONS.md`; eng-retro proposes lessons.
- Retro: "Which step felt like waste?" and rough time per phase.
- Process feedback: Design adoption table (adopted/skipped + reason; informed owner skip not counted; two non-safety skips -> redesign flag; any safety-gate skip (personal data, mandatory plan review) -> escalate to Rob).
- eng-check warnings (warn-only until v2.5.0, `--strict` makes them errors): `rejected-no-evidence`; `draft-before-design` (plan/slice drafts while no design doc is CP-A approved; not for small triage); `design-changed-after-approval` (design doc changed after its latest CP-A row: `sha256:<prefix>` in the decision cell is compared with the file, otherwise git commit dates after the approval date; not during Discover).
### Changed (behaviour)
- `stray-approval` (warn-only in 2.3.x) is now an error.

## 2.3.2 - 2026-10-23
### Fixed
- eng-run: absolute plan paths are resolved through symlinks before making them repo-relative (macOS /var -> /private/var).
- Tests run on real Windows (Git Bash): mixed D:/ paths for native Python, .exe/.cmd fake agents, python on PATH for the `env -i` test; macOS CI uses GNU sed/grep; smoke test passes pipx the real interpreter path.

## 2.3.1 - 2026-10-23
### Added
- Installable package `eng-process` (pyproject, hatchling; Python >=3.9, stdlib only) with console script `eng`: `init`, `upgrade`, `check`, `status`, `new`, `run`, `version`. Skills, templates, prompts and scripts ship as package data; `eng init` vendors exactly as `bin/eng-init`. Install: `pipx install git+https://github.com/rowama/eng-process` (or `uv tool install`).
- GitHub Actions CI: ubuntu/windows/macos x Python 3.9/3.12, kit tests + pipx install smoke test (`tests/smoke-install.sh`).
- LICENSE (MIT), .gitignore, .gitattributes (LF).
### Changed (behaviour)
- eng-run codex defaults are conservative: implement runs `codex exec --sandbox workspace-write` (was `--full-auto`); plan-review runs `codex exec --sandbox read-only`. Opt in to more autonomy per project in `.eng/runners.toml`: `[runners.codex] implement_args = ["--approve-for-me"]` (or `["--full-auto"]` on older CLIs).
- code-review via codex now calls `codex review --base <base>` (current CLI; no `-o`, the review is captured from stdout into the findings file). `review_prompt = true` sends the prompt template instead of `--base` (the CLI rejects both together).
- Claude defaults unchanged: implement `--permission-mode acceptEdits`, reviews read-only `--allowedTools`. All overridable via `<role>_args`.
- Toml fallback test runs on Python < 3.11 (no tomllib).

## 2.3.0 - 2026-10-23
### Added
- `bin/eng-run` (vendored to `.eng/bin/`): headless `plan-review <plan>`, `implement <plan> <slice-id>`, `code-review <slice-id | --base REF>` with `claude`, `codex` and generic `command` adapters; runner per role from project-owned `.eng/runners.toml` (`ENG_RUNNER_<ROLE>`, `--runner`); prompt templates `templates/prompts/<role>.md` -> `.eng/prompts/`. Every run writes `thoughts/shared/runs/` (new `run-log` type); reviews write a review-findings file to `thoughts/shared/verification/` and fill an empty `plan_review:`. Self-review guard (`--allow-self-review`), `--dry-run`. Windows: `.cmd` shims get the prompt on stdin. TOML via `tomllib` (3.11+) or a minimal stdlib fallback.
- `eng-check --strict`.
### Changed
- Stray-approval check ignores ~~struck~~ text and history/done/archive/changelog sections, and is warn-only until v2.4.0 (Dave, Farmer).
- `--upgrade` stale-section report: section name plus a short diff.
- `.gitignore` block: only missing lines are added; duplicate blocks removed.
- `--upgrade` prints (does not run) `git rm -r --cached` for tracked files now ignored.
- Docs/skills (PROCESS 10, README, OWNER-GUIDE, eng-plan, eng-implement-slice, eng-verify) mention eng-run; Chet/Dave may run it on Rob's PC with approval.
- Tests: 137 checks.

## 2.2.1 - 2026-10-23
### Fixed
- Windows (native Python): paths are normalized to POSIX form wherever compared or printed (`englib.posix`/`rel`; front-matter values, links, pending items and Approval log paths), so backslash paths no longer cause false "unlogged" errors. Tested by simulation on Linux only (ntpath relpath, backslash sep, backslash paths in files).
- eng-status: latest artifact (e.g. handoff) chosen by front-matter date, then mtime, not filename; the Codex command uses a "from the repo root" hint and repo-relative paths, never an absolute `cd`.
- `__pycache__`/`.pyc` are never vendored.
### Added
- Grandfather route for plans approved before the mandatory plan review: retroactive review before the next slice, or a Rob-approved waiver row in the Approval log; eng-check's error names both.
- eng-check: flags approvals written outside the Approval log table.
- `--upgrade`: refreshes unchanged kit boilerplate sections in project files, lists owner-edited stale sections (never overwrites); adds empty `plan_review:` to plans lacking it.
- eng-init/--upgrade: managed `.gitignore` defaults block, appended without clobbering existing lines.
- Docs call scripts through the interpreter (`python .eng/bin/eng-check .` / `py` on Windows).
- Tests: 92 checks.

## 2.2.0 - 2026-10-23
### Changed
- The kit travels with each repo: eng-init vendors skills into `.claude/skills/<name>/SKILL.md` (Claude Code project skills), scripts into `.eng/bin/`, plus `.eng/templates/`, `.eng/PROCESS.md`, `.eng/VERSION` (LF, executable). Lesson: an implementer on another machine (WSL) found no skills or eng-check and ran the process by hand.
- Skills, templates and PROCESS.md call scripts by repo-relative path (`.eng/bin/eng-check .`); no kit-source paths.
- AGENTS.md / CLAUDE.md templates say where the skills and scripts live.
### Added
- `<kit>/bin/eng-init <repo> --upgrade`: re-vendors kit-owned files only, never project files.
- eng-check: fails when `.eng/bin` or `.claude/skills/eng-*` is missing; warns when `.eng/VERSION` is older than the running kit (or `$ENG_KIT/VERSION`).
- PROCESS.md 10a: vendoring, upgrade, optional global install to `~/.claude/skills`.
- Tests: vendoring, frontmatter, no kit paths, vendored scripts run with no kit access (clean env, kit dir renamed), version warning, upgrade leaves project files alone (78 checks).

## 2.1.0 - 2026-10-23
### Changed
- Codex plan review is now MANDATORY for medium/large work, after plan + slice cards and before CP-C (small exempt; slice-diff and architecture reviews stay advisory). eng-plan step 8-9, PROCESS.md sections 3 and 10.
- Findings template: severity critical/high/medium/low; disposition fixed / accepted-risk (Rob's approval recorded) / rejected (reason); `review_kind`.
- Unified wording: `input` = pre-draft from an earlier phase, `draft` = in its own phase (PROCESS.md, templates, eng-discover).
### Added
- `eng-new plan-review <slug>` -> `thoughts/shared/verification/<date>-<slug>-plan-review.md`; plan front matter `plan_review:`.
- eng-check: medium/large fails when a slice is in-progress or phase is implement+ without a linked plan review, or with an open critical/high finding, an unapproved accepted-risk or a reason-less rejection.
- eng-check: pseudo-approval statuses (e.g. `approved-for-review`) are errors.
- eng-status: prints the ready-to-paste `codex exec` command with real paths while a plan awaits CP-C.
- eng-init --brownfield: suggested destination and type for every pre-existing doc.
- Every Codex command (plan review, slice-diff review, architecture review; skills, PROCESS.md, eng-status) writes straight to its review file in the repo with `-o`/`--output-last-message <path>` (`codex exec review --base <base> -o ...` for diffs); the findings front matter/table is added above the raw output.
### Fixed
- eng-check no longer crashes on docs without an `id` (clean "missing 'id'" error).

## [2.0.0] - 2026-10-21
From the kit's first real adoption friction log and the owner's working agreements. v1 repos: re-run `eng-init` (adds new dirs/files, never overwrites), add the working-agreement fields to PROJECT_STATE front matter, delete the "Pending approvals" body list, then fix whatever `eng-check` reports (most likely ADR filenames/ids and Approval log rows; see PROCESS.md section 11).

### Added
- Artifact types: `architecture` (docs/architecture/), `vision` (docs/vision/), `market-research` (thoughts/shared/market-research/), `project-brief` (thoughts/shared/briefs/, `eng-new brief`), `review-findings` (`eng-new review`, in thoughts/shared/verification/), `process-feedback` (thoughts/shared/process-feedback.md), `owner-guide`.
- Templates: architecture, vision, market-research, project-brief, review-findings, process-feedback, review-notes (owner scratch), ready-to-implement message, OWNER-GUIDE (with glossary).
- eng-init scaffolds OWNER-GUIDE.md, process-feedback.md, `thoughts/shared/review-notes/<owner>-review-notes.md`, new dirs, `.eng/VERSION`; options `--owner`, `--triage`, `--brownfield`.
- Status `input` (pre-draft, not approved) for design-like docs, research and plans. ADR statuses `partially-accepted` (needs `## Parts`), `deferred` (`revisit:`), `rejected`.
- PROJECT_STATE working-agreement fields: `implementer`, `planner`, `cross_review`, `push_permission`, `board`; "Back-ups to an earlier phase" section.
- PROCESS.md: readiness table (section 2), one-phase-one-artifact rule and pre-draft labeling, blameless back-up path (4a), owner review workflow and notes rotation, session convention (8), working agreements, implementer hand-off loop, Codex cross-model review, Windows notes (10), brownfield migration (11).
- eng-check: phase prerequisites for every phase from research on; earlier-checkpoint-pending error (later checkpoints may be pending early); pending item format and path existence; body/front-matter pending drift; ADR filename <-> id; Parts for partially-accepted; Approval log <-> status consistency both ways; CHANGELOG placeholders and empty bullets; triage value; warning for missing working agreements.
- eng-status: working agreements, readiness with earliest incomplete phase, rendered pending list, ready-to-implement message.
- eng-triage readiness check; eng-retro process-feedback pass (also each advisor consultation); cross-model review steps in eng-implement-slice, eng-verify, eng-architecture-review, eng-plan; notes rotation in eng-ship and eng-handoff; brownfield mode in eng-project-init.
- Verification report "Cross-model review (advisory)" section; slice `review:` field.
- Tests: 28 -> 59 checks.

### Changed
- Front-matter parser: commas inside quoted inline-list items are kept; quoted scalars keep `#`; UTF-8 BOM tolerated.
- Front matter `pending_approvals` is the single source of truth; PROJECT_STATE body only references it.
- Skill routing lives only in PROCESS.md section 3. AGENTS.md template references it, and `.eng/PROCESS.md` is marked as a pinned read-only copy.
- Skills reference the shared session convention instead of repeating Start/Finish; eng-handoff/eng-resume no longer tell you to run themselves.
- eng-init's Next line and eng-project-init respect an already-known triage.
- `eng-new changelog` writes a complete entry (`--summary`, `--section`) with no placeholders.
- eng-scope-review modes are relative to a named baseline (the approved requirements list).
- Script output is ASCII only and stdout is forced to UTF-8 (fixes mojibake on Windows consoles). Files are written UTF-8 without BOM, LF.

## [1.0.0] - 2026-10-19
- Initial kit: PROCESS.md, 13 skills, templates, eng-init/check/status/new, smoke tests.
