---
id: OWNER-GUIDE
type: owner-guide
phase: any
status: active
owner_agent: {{AGENT}}
date: {{DATE}}
links: [PROJECT_STATE.md]
---
# Owner guide (plain language)

You are the only approver. Agents propose; you decide. Everything official is written in the repo.

## Your loop
1. Open `PROJECT_STATE.md` (or ask for `.eng/bin/eng-status`). Look at **Next action** and **pending approvals**.
2. Read the artifact named in a pending approval. Jot thoughts in your scratch file `thoughts/shared/review-notes/{{OWNER}}-review-notes.md`. Agents won't touch it until you say "notes ready".
   Random ideas go in `thoughts/shared/inbox.md`: edit it yourself or start a message with `note:`, `n:`, `idea:`, `feature:`, `future feature:`, `ff:`, `capture:`, or `cap:` and the agent just appends it. Say "process incoming" (or "check idea log" / "process notes") to go through it together: each item gets moved, acted on, or deferred, then the old inbox is archived under `thoughts/shared/inbox/` and a fresh one starts with the deferred items.
3. Approve or reject in chat. The agent records it in the Approval log, the document's status, and an ADR if the decision is durable, then commits.
4. When a slice is ready, the planner sends you a short "ready to implement" message with a line to paste into your coding agent.
5. After coding, an independent review (Codex) may add findings. They are advice. You decide at the slice and Done checkpoints. Reviews are always saved as files in `thoughts/shared/verification/`.
6. Headless steps on your PC: `python3 .eng/bin/eng-run plan-review <plan>`, `implement <plan> <slice-id>`, `code-review <slice-id>`. Add `--dry-run` to preview. The planner starts plan-review (after the plan is drafted), implement (after CP-C), and code-review (when the slice is ready to verify) by default and tells you as FYI — you are not the default runner. Say yes only for ad-hoc runs outside those paths, or if you want to drive one yourself.

## How agents will message you
Updates that need you use a fixed shape so your actions are easy to spot:
1. Short status (or none).
2. A labeled **Action for Rob** list — one step per line; a command to paste sits alone in a code block. Placeholders in those commands are obvious non-shell tokens like `PASTE_BOT_TOKEN_HERE` (never `$TOKEN`, which a shell would expand). If you have nothing to do, you will see `No action for you.`
3. The decision they need from you, when any (approve / defer / needs fixes / hold / a named checkpoint).

They should never bury your todos inside a mixed status/findings paragraph.
If they uncovered a risk and want to mitigate it in the design, they must cost the friction and ask you before baking it in (absorb / accept risk / defer / narrower) — not treat a soft yes as approval of that cost.

## When something looks wrong
Say "back up to discover" (or to any phase). That's normal, not a failure. The agent revises the documents and writes down why.

## Glossary
- **PROJECT_STATE**: the one-page status file every agent reads first: phase, next step, blockers, approvals.
- **Triage**: sizing a request as small, medium or large, which decides how many steps it needs.
- **Checkpoint (CP-A, CP-R, CP-B, CP-C, CP-S, CP-D, CP-P)**: a point where work stops until you approve: product, research, architecture, plan, each slice, done, and merge/deploy.
- **Success metric**: the observable number or behavior that tells us the change worked.
- **ADR (Architecture Decision Record)**: a short numbered note of one durable decision and why, in `docs/decisions/`.
- **Slice**: one small, end-to-end, demoable piece of work (about 100-200 changed lines).
- **DoD (Definition of Done)**: the checklist every slice must pass (`docs/definition-of-done.md`).
- **Runtime facts** (in `AGENTS.md`): short live values agents need (port, runtime pin, MCP restart after tool-list deploys). Project-specific numbers stay in that project's AGENTS; the section pattern comes from the kit.
- **Push permission** (`push_permission` in PROJECT_STATE): `ask` (default) or `standing`. With standing, after eng-verify PASS agents may push to `main` without asking. **Docs-only commits always push without asking.** Tags and force-push still need you.

## Headless implement permissions
`eng run implement` runs Claude headless, so it needs a non-interactive permission mode. The kit default for implement is `--permission-mode bypassPermissions`; `acceptEdits` is not enough because it does not auto-approve eng-check or pytest. Reviews stay read-only. Override in `.eng/runners.toml` (`[runners.claude] implement_args`).

After a headless run, the agent that started it must **stay attached** until it exits (default), or be woken by a non-empty `on_complete` hook. Then it must pick up: it reads the run log and latest handoff and moves on to verify / CP-S or tells you the blocker. You should not have to paste the handoff filename. To wake a planner that is not attached, set `[hooks] implement_on_complete` in `.eng/runners.toml` (opt-in, empty by default; e.g. curl a Grok Bot routine webhook). It runs on success and failure and never changes eng-run's exit code. Since v2.5.4 the general `on_complete` wakes the starter after any role (plan-review, code-review too; role keys like `code_review_on_complete` override it), and a backup timeout (45m / 2h / 4h for S / M / L) checks the `thoughts/shared/runs/*.running.md` PID marker: still running = you may get a soft ping; finished = the bot resumes; died with nothing written = the bot retries a known fix once, else hands it to Ulrik with the run log, marker, what was tried and which machine.

Kit upgrades: `eng upgrade .` re-vendors the kit and (v2.5.5+) commits only the kit files as `chore: eng-process kit upgrade to vX.Y.Z` (never pushed; your own edits and `.eng/runners.toml` are left alone). Add `--no-commit` to review first. If an upgrade creates `thoughts/shared/inbox.md` (v2.5.6+), commit it once yourself: the auto-commit skips project files.
