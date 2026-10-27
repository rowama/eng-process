---
id: AGENTS
type: conventions
phase: any
status: active
owner_agent: {{AGENT}}
date: {{DATE}}
links: [PROJECT_STATE.md, docs/definition-of-done.md]
---
# Agent conventions

**Start here:** read `PROJECT_STATE.md`, then the latest handoff it links. Do not rely on chat history.
Process: eng-process kit; canonical copy at `.eng/PROCESS.md` (phases, checkpoints, skill for each phase in section 3, session convention in section 8). Run `.eng/bin/eng-check .` before and after each session.
**The kit is vendored in this repo:** skills are in `.claude/skills/eng-*/SKILL.md` (Claude Code loads them as project skills; other agents read them as files) and the scripts are in `.eng/bin/` (plain Python 3, run through the interpreter from the repo root: `python3 .eng/bin/eng-check .`; native Windows: `python .eng/bin/eng-check .` or `py .eng/bin/eng-check .`). Do not look for the kit elsewhere; if `.eng/bin` or `.claude/skills` is missing, ask the planner to run `<kit>/bin/eng-init <repo> --upgrade`.

## Working agreements
The values live in `PROJECT_STATE.md` front matter (`implementer`, `planner`, `cross_review`, `push_permission`, `board`); `.eng/PROCESS.md` section 10 says what each means. Summary:
- The **planner** agent plans, writes docs, keeps state and process. It does not write production code.
- The **implementer** (default: Claude Code on the owner's PC) codes one slice at a time. When a slice is ready, the planner sends the owner the "ready to implement" message (`.eng/bin/eng-status` prints it), then afterwards picks up the implementer's handoff and runs `eng-verify` and `.eng/bin/eng-check`.
- **Cross-model review** (Codex) is advisory, never a gate. See `.eng/PROCESS.md` section 10.
- **Push:** follow `push_permission` (default `ask`). With `standing`, after eng-verify PASS you may push to `main` without asking. **Docs-only commits always push to `main` without asking** (both modes). Tags and force-push still ask. Never merge without the owner.
- **Owner review notes** (`thoughts/shared/review-notes/`) belong to the owner. Agents never edit them until the owner says they are ready.
- **Owner-facing updates:** brief status prose (or skip), then a labeled `**Action for Rob**` numbered list (one step per line; pasteable commands in their own fence) or `No action for you.`; end with the decision he owes. Never mix his todos into a status/findings paragraph. Never use `$TOKEN`-style shell placeholders in samples — use `PASTE_…_HERE` or paste-at-prompt. See `.eng/templates/owner-update.md` (LESSONS L-007).

## Commands
- Install:  `<cmd>`
- Build:    `<cmd>`
- Test:     `<cmd>`
- Lint/typecheck: `<cmd>`
- Run locally: `<cmd>`

## Architecture map
<top-level dirs and what lives there, 5-10 lines>

## Code style / conventions
<only rules an agent cannot infer from the code>

## Rules
- Never weaken a test, timeout, or check to make it pass; never use `--no-verify`.
- Durable decisions go in `docs/decisions/` (ADR). Deferred work goes in `TODOS.md`.
- Don't touch: <paths / systems off-limits>


## Runtime facts
<!-- Short live facts agents need to run and verify this project. Put project-specific values here; keep the pattern bullets. Do not restate eng-run permission defaults (implement default is bypassPermissions in the kit). -->
- Dev server / listen port: `<port>`
- Runtime pin (e.g. Python): `<version>`
- After an MCP tool-list deploy: restart the client's MCP connections before manual verification (clients cache tool lists and will look like product bugs).

## Gotchas
