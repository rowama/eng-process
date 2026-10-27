# eng-process kit (v2.5.9, see [CHANGELOG.md](CHANGELOG.md))

A project-agnostic, file-based engineering process for one human approver (Rob) and several interchangeable AI agents. Every step is a skill with file inputs, file outputs, exit criteria, and an approval stop; all state lives in the repo so any agent can resume cold.

## Index
| Path | What |
|---|---|
| [PROCESS.md](PROCESS.md) | Canonical process: triage + readiness check, 9 phases (the only skill-routing table), checkpoints, back-up path, WIP, DoD, session convention, working agreements, brownfield migration |
| [templates/](templates/) | Artifact templates with machine-checkable front matter (`id, type, phase, status, owner_agent, date, links`) |
| [skills/](skills/) | `eng-*/SKILL.md`, one per repeatable step |
| [bin/](bin/) | `eng-init`, `eng-check`, `eng-status`, `eng-new` (python3 stdlib only; shared `englib.py`) |
| [tests/run-tests.sh](tests/run-tests.sh) | Smoke tests on throwaway repos in /tmp |
| [SOURCES.md](SOURCES.md) | What was adopted from where |
| [CHANGELOG.md](CHANGELOG.md), [VERSION](VERSION) | Kit changes (v1 -> v2) and current version |

## Install (the `eng` command)
Python 3.9+, stdlib only, no dependencies. Install once per machine:
```bash
pipx install git+https://github.com/rowama/eng-process        # or: uv tool install git+https://github.com/rowama/eng-process
pipx upgrade eng-process                                        # or: uv tool upgrade eng-process
pipx install git+https://github.com/rowama/eng-process@v2.5.9  # pin a release tag
```
Then, from a repo root:
```bash
eng init .            # scaffold + vendor the kit (same as bin/eng-init)
eng upgrade .         # re-vendor kit files after `pipx upgrade` (same as eng-init --upgrade); v2.5.5: auto-commits kit paths only (not pushed), `--no-commit` to skip
eng check | eng status | eng new <type> <slug> | eng run <role> ... | eng spec <init|lock|status|trace> | eng version
```
`eng <cmd> --help` shows each command's options; the repo defaults to `.`. The repo never needs the package: `eng init` copies standalone scripts into `.eng/bin/`, so `python3 .eng/bin/eng-check .` keeps working for any agent, with or without `eng` installed.
- **Windows (native):** install Python from python.org or `winget install Python.Python.3.12`, then `py -m pip install --user pipx && py -m pipx ensurepath` (reopen the terminal). `eng` works in PowerShell, cmd and Git Bash. Vendored scripts: `py .eng/bin/eng-check .`. Git for Windows is required (eng-init calls `git`).
- **WSL:** install inside WSL (`sudo apt install pipx && pipx ensurepath`); a Windows-side install is a separate copy. Keep repos on the WSL filesystem (`~/src`), not `/mnt/c`, for speed and file modes.
- **macOS:** `brew install pipx && pipx ensurepath` (or `brew install uv`).
- **Linux:** `sudo apt install pipx` / `dnf install pipx`, or `uv`. Avoid `sudo pip install` (PEP 668).
- From a checkout without installing: `python3 -m pip install -e .` or call `bin/eng-init` etc. directly.

## Adopt in a repo
```bash
# with the package: eng init /path/to/repo ...   (or from a kit checkout: export PATH=<kit>/bin:$PATH)
eng-init /path/to/repo --agent <agent-name> [--triage medium] [--brownfield]   # never overwrites
# fill AGENTS.md Commands + Architecture map and PROJECT_STATE working agreements, then:
eng-check /path/to/repo                        # must exit 0
git -C /path/to/repo add -A && git -C /path/to/repo commit -m "Adopt eng-process"
```
Skills travel with each repo: `eng-init` vendors them into `<repo>/.claude/skills/` and the scripts into `<repo>/.eng/bin/` (PROCESS.md 10a). Upgrade an existing repo with `bin/eng-init <repo> --upgrade`. The planner box also keeps copies in its own skill dir.

## How agents use it
1. **Every session starts with `eng-resume`**: read `PROJECT_STATE.md`, then the latest handoff, nothing else. `eng-status .` gives the one-screen view.
2. Run the one skill named in *Next action*. New work starts at `eng-triage`.
3. Create artifacts only with `eng-new <type> <slug>` (types: design architecture vision adr research market-research brief plan slice handoff review verification retro changelog).
4. At a checkpoint, add the item to front-matter `pending_approvals` (the only copy) and stop. Rob approves in chat; the agent records it (Approval log + status + ADR if durable) and commits.
5. Code is written by the `implementer` (default Claude Code on Rob's PC). The planner starts the slice with `.eng/bin/eng-run implement <plan> <slice-id>` (paste prompt from `eng-status` is the interactive fallback), then owns the completion signal: it stays on the run (or is woken by the opt-in `[hooks] implement_on_complete` hook in `.eng/runners.toml`) and picks up from the run log + latest handoff, so Rob never pastes the handoff filename. v2.5.4: the same wake pair (callback hook via role key or general `on_complete`, plus an effort-based timeout S/M/L 45m/2h/4h) covers plan-review and code-review; eng-run writes a `<stem>.running.md` PID marker while running so a timeout can tell still-running from missed-callback from died-silently (platform failures go to Ulrik; PROCESS.md section 10). Codex cross-model review is advisory (PROCESS.md section 10); `.eng/bin/eng-run` runs the implementer and reviewers headless and files their output.
6. **Every session ends with `eng-handoff`** and a passing `eng-check .`. It also works as a pre-commit or CI gate (`eng-check . || exit 1`).

Flow: `triage → discover (CP-A) → scope → research (CP-R) → architecture (CP-B) → plan (CP-C) → implement-slice ×N (CP-S each) → verify (CP-D) → ship (CP-P) → retro`. Small tasks: triage → implement-slice → verify → ship. Back up to an earlier phase any time (PROCESS.md 4a).

## Script reference
- `eng-init <repo_dir> [--agent N] [--force]`: scaffold docs/, thoughts/shared/*, .eng/, and the root files.
- `eng-check <repo_dir> [--quiet] [--strict]`: exit 1 with `ERROR <file>: <msg>` lines on: missing files/dirs; missing or invalid front matter; unfilled `{{tokens}}`; duplicate ids; ADR filename/id mismatch; partially-accepted ADR without `## Parts`; unresolved links; plans missing sections; malformed `pending_approvals` items or missing paths; body/front-matter pending drift; earlier-phase checkpoint still pending; missing phase prerequisites for the triage size (every phase from research on); Approval log vs. status mismatch (both ways); WIP > 1; changelog placeholders/empty bullets. Full list: `eng-check --help`.
- `eng-status <repo_dir>`: phase, triage, working agreements, slice, approvals, readiness, next action, blockers, latest artifacts, slice board, check result, and the ready-to-implement message when applicable.
- `eng-new <type> <slug> [--repo D] [--title T] [--agent N] [--phase P]`: create from template; ADRs numbered `NNNN`; handoffs `YYYY-MM-DD_HH-MM-SS_slug.md`; `changelog` inserts a complete entry under `## [Unreleased]` (`--summary`, `--section`).
- `eng-run <role> ...` (v2.3): run an agent non-interactively from the repo root: `plan-review <plan>`, `implement <plan> <slice-id>`, `code-review <slice-id | --base REF>`. Runner per role from `.eng/runners.toml` (project-owned; defaults implement=claude, reviews=codex), override with `ENG_RUNNER_<ROLE>` or `--runner`. Adapters: `claude`, `codex`, generic `command`. Every run writes `thoughts/shared/runs/<date>-<role>-<target>.md`; reviews also write a review-findings file in `thoughts/shared/verification/` (never terminal-only). Refuses self-review unless `--allow-self-review`; `--dry-run` prints the exact command. Bots start it when the process covers the role (plan-review / implement / code-review) and tell Rob as FYI; ask only for ad-hoc runs.
- v2.4 learning loop (PROCESS.md §12): ADR/retro predictions scored in eng-retro, evidence required to reject a finding, research provenance headers (SOURCES.md), kit lessons (`LESSONS.md`, `templates/kit-lesson.md`), design-adoption tracking in process feedback, opt-in CI checklist (`templates/ci-checklist.md`). New eng-check warnings (warn-only until v2.5.0): rejected-no-evidence, draft-before-design, design-changed-after-approval.
Set `ENG_AGENT` to avoid repeating `--agent`.
- `eng-spec <init|lock|status|trace>` (v2.5): opt-in executable specs (Dave Farley's four-layer ATDD: specs, DSL, protocol drivers, system under test). `init` copies the scaffold to `tests/acceptance/`; `lock` writes `tests/acceptance/spec-lock.json` and prints the CP-C `approved speclock sha256:` row; `status` diffs against the lock; `trace` prints the REQ -> spec table for the verification report. See PROCESS.md section 13.

## Test
```bash
tests/run-tests.sh                             # from the repo root; plus tests/smoke-install.sh
# expect: ALL TESTS PASSED (137 checks)
# manual equivalent:
export PATH="$PWD/bin:$PATH"
rm -rf /tmp/engdemo && mkdir /tmp/engdemo && git -C /tmp/engdemo init -q
eng-init /tmp/engdemo && eng-check /tmp/engdemo; echo $?          # 0
eng-new plan demo --repo /tmp/engdemo && eng-status /tmp/engdemo
sed -i 's/^phase: discover/phase: implement/; s/^triage: .*/triage: medium/' /tmp/engdemo/PROJECT_STATE.md
eng-check /tmp/engdemo; echo $?                                    # 1: missing prerequisites
```
