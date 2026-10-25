# Changelog (eng-process kit)

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
