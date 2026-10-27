---
name: eng-project-init
description: Scaffold the eng-process kit into a repository, greenfield or brownfield (migrating pre-kit docs, ADRs and decisions). Use when starting a new project or adopting the process in an existing repo that has no PROJECT_STATE.md.
---
# eng-project-init

Session: starts fresh with only the repo's top-level listing, README and build files (no context from other projects). Finish per `.eng/PROCESS.md` section 8. Scripts: `eng-init`, `.eng/bin/eng-check`, `.eng/bin/eng-status`.

## Inputs (files only)
- Target repo path; triage size if already known
- Existing repo on an older kit: `<kit>/bin/eng-init <repo> --upgrade`, then update the stale sections it lists by hand and commit.
- Kit source: wherever the planner keeps it (`<kit>/bin/eng-init`). After init everything is vendored in the repo: `.eng/bin/`, `.eng/templates/`, `.eng/PROCESS.md`, `.eng/VERSION`, `.claude/skills/eng-*/SKILL.md`

## Outputs
- Everything `eng-init` scaffolds (PROCESS.md section 1), including `OWNER-GUIDE.md`, `thoughts/shared/process-feedback.md`, the owner's scratch file under `thoughts/shared/review-notes/`, and the owner inbox `thoughts/shared/inbox.md` (v2.5.6, see eng-inbox)
- Brownfield: migrated docs, ADRs renamed to `NNNN-slug.md`, back-filled Approval log

## Steps
1. Greenfield: `<kit>/bin/eng-init <repo> --agent <you> [--triage <size>]`. Brownfield: add `--brownfield` and follow PROCESS.md section 11 (`git mv` in a dedicated commit, map each doc to a kit type and loc (eng-init prints a suggested destination per doc; confirm each)ation, ADR renumbering and cross-reference rewrite, back-fill the Approval log with Checkpoint `pre-kit`, delete nothing without Rob's OK). `--force` only with Rob's consent.
2. Fill AGENTS.md Commands and Architecture map from commands you actually ran; leave `<cmd>` where unknown and list them as Blockers.
3. Fill the PROJECT_STATE working-agreement fields (defaults per PROCESS.md section 10; ask Rob about `push_permission` and `board`).
3a. (v2.5, optional) Executable specs are opt-in per project: `python3 .eng/bin/eng-spec init .` copies the four-layer scaffold to `tests/acceptance/` and sets `acceptance: executable-specs`. Existing projects are grandfathered until they opt in (PROCESS.md 13).
4. Set Goal and Next action. **Respect a known triage:** if `triage` is unset, Next action = "Run eng-triage". If it is set (or the project claims a later phase), Next action = "Run eng-triage readiness check, then <skill for the phase>". Never overwrite a known triage.
5. `.eng/bin/eng-check <repo>` must pass; `.eng/bin/eng-status <repo>` readiness line reviewed.

## Exit criteria
Kit files present; .eng/bin/eng-check passes; AGENTS.md commands verified or listed as blockers; brownfield docs migrated with history kept.

## Approval stop (Rob)
Ask Rob to confirm the Goal if inferred, and the back-filled Approval log rows (brownfield).

## Finish
Standard: end with eng-handoff.
