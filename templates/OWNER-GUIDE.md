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
3. Approve or reject in chat. The agent records it in the Approval log, the document's status, and an ADR if the decision is durable, then commits.
4. When a slice is ready, the planner sends you a short "ready to implement" message with a line to paste into your coding agent.
5. After coding, an independent review (Codex) may add findings. They are advice. You decide at the slice and Done checkpoints. Reviews are always saved as files in `thoughts/shared/verification/`.
6. To have an agent run one step for you: `python3 .eng/bin/eng-run code-review <slice-id>` (or `plan-review <plan>`, `implement <plan> <slice-id>`). Add `--dry-run` to see the command first. A bot (Chet, Dave) may run this on your PC only after you say yes.

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

## Headless implement permissions
`eng run implement` runs Claude headless, so it needs a non-interactive permission mode. The kit default for implement is `--permission-mode bypassPermissions`; `acceptEdits` is not enough because it does not auto-approve eng-check or pytest. Reviews stay read-only. Override in `.eng/runners.toml` (`[runners.claude] implement_args`).

After a headless implement, the agent that started it (or an `on_complete` wake) must pick up: it reads the run log and latest handoff and moves on to verify / CP-S or tells you the blocker. You should not have to paste the handoff filename. To wake a planner that is not attached, set `[hooks] implement_on_complete` in `.eng/runners.toml` (opt-in, empty by default; e.g. curl a Grok Bot routine webhook). It runs on success and failure and never changes eng-run's exit code.
