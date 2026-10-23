# Sources: what was adopted, from where
Fetched or read 2026-10-19. Local clones are under `/workspace/research/src`.

| Source | Adopted | Not adopted / why |
|---|---|---|
| HumanLayer `.claude/commands` (research_codebase, create_plan, implement_plan, validate_plan, iterate_plan, create_handoff, resume_handoff), https://github.com/humanlayer/humanlayer/tree/main/.claude/commands | Research is documentation only, with file:line refs and parallel sub-tasks. Plan template sections (Overview, Current State, Desired End State, Key Discoveries, **What We're NOT Doing**, phases with **Automated vs Manual Verification**, Testing Strategy, References). Stop on mismatch ("Issue in Phase N") and pause after each phase for manual checks. Verification report follows validate_plan. Handoff sections and filename `YYYY-MM-DD_HH-MM-SS_desc.md` follow create_handoff. Resume reads the handoff fully, then verifies the recent changes. | `humanlayer thoughts sync`, ticket/Linear coupling, TodoWrite-specific steps, model pins |
| HumanLayer thoughts system, https://github.com/humanlayer/humanlayer/blob/main/hlyr/THOUGHTS.md | `thoughts/shared/{research,plans,handoffs}` layout (extended with slices/verification/retros) | Separate thoughts repo, per-user dirs, symlinks/`searchable/` hard links, and the pre-commit hook that keeps thoughts out of the code repo. Here thoughts are committed in-repo so state passes between agents through git |
| Horthy / HumanLayer: Advanced Context Engineering, "Why Software Factories Fail", https://github.com/humanlayer/advanced-context-engineering-for-coding-agents (ace-fca.md, wsff.md) | Research→Plan→Implement, frequent intentional compaction into files, ~40% context guideline (presented as a guideline, not a threshold), small/medium/large triage, vertical slices (tracer bullets), human review at research and plan, 100–200-line review units, "too many bad PRs" leading to WIP limits | Lights-off / autonomous "ralph" loops |
| 12-Factor Agents, https://github.com/humanlayer/12-factor-agents | Own your context window; contact humans as a step (approval checkpoints); small focused agents | Framework-level factors (tool schemas, etc.) |
| gstack, https://github.com/garrytan/gstack (v1.91.146.0) | Think→Plan→Build→Review→Test→Ship→Reflect chain where each skill writes the file the next one reads. office-hours forcing questions → eng-discover. plan-ceo-review scope modes → eng-scope-review. plan-eng-review prime directives (no silent failures, diagrams, rollback/flags, observability in scope, deferrals in TODOS.md) → eng-architecture-review. ETHOS Honest Work: no weakened gates, no self-certification, "a report is a claim until re-executed" → DoD and eng-verify. User Sovereignty → Rob decides. investigate's "no fix without root cause, stop after 3 failures". ship order (sync base, tests, VERSION, CHANGELOG, docs audit, PR). CLAUDE.md skill routing table → AGENTS.md. TODOS.md format. SKILL.md frontmatter with a "Use when…" description | `~/.gstack` decisions.jsonl (replaced by in-repo ADRs so state stays in the repo), /learn store (replaced by retro → AGENTS.md edits), browser/QA tooling, autoplan auto-decisions, 4-part version scheme |
| GitHub Spec Kit, https://github.com/github/spec-kit (README, spec-driven.md) | `[NEEDS CLARIFICATION: …]` markers that must be resolved before approval. Spec → plan → tasks progression. The constitution idea is mapped to AGENTS.md + DoD | Separate constitution file and `/speckit-*` commands. Command names were observed as `/speckit-constitution`, `-specify`, `-plan`, `-tasks`, `-implement` (plus newer `-assess`, `-bug`, `-converge`); this changes between versions |
| AWS Kiro specs, https://kiro.dev/docs/specs/ | requirements → design → tasks, three phases. EARS-style acceptance criteria ("WHEN … THE SYSTEM SHALL …") in the design template. Bugfix specs (current/expected/unchanged behavior) noted | Kiro IDE task execution |
| Michael Nygard, "Documenting Architecture Decisions" (2011), https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions; https://adr.github.io/ | ADR template: Title, Context, Decision ("We will…"), Status (proposed/accepted/deprecated/superseded), Consequences. Numbered and append-only | MADR's extra fields (kept minimal) |
| Anthropic, Claude Code best practices, https://www.anthropic.com/engineering/claude-code-best-practices (now redirects to https://code.claude.com/docs/en/best-practices) | Explore → plan → code. Give the agent a way to verify its work. Short CLAUDE.md ("Would removing this cause mistakes?"), `@path` import (CLAUDE.md → @AGENTS.md). `/clear` between tasks becomes one phase per session. Sub-agents for investigation. Reset after being corrected twice | Product-specific settings and hooks |
| Anthropic, Effective context engineering for AI agents, https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents | "smallest possible set of high-signal tokens". Compaction, structured note-taking, and sub-agent architectures become handoffs, PROJECT_STATE, and search sub-tasks | — |
| Agile/Scrum/Kanban/INVEST (see /workspace/research/agile.md) | Definition of Done, controlling WIP (pull only with capacity), retro → concrete changes, INVEST-small slices, flow metrics in the retro | Sprints and ceremonies (optional cadence) |

## Unverified / caveats
- The ~40% context figure is Horthy's rule of thumb and varies by model. Agents have no context meter, so the PROCESS.md proxies (>~15 files read, >~30 tool calls, corrected twice) are this kit's own heuristics and are not sourced.
- Spec Kit and gstack change quickly. Command names and versions are as observed on 2026-10-19.
- Kiro: only the specs overview page was read. The EARS notation is inferred from Kiro's "structured notation" wording and general EARS practice, not quoted.
- The Claude Code best-practices content was read at its redirect target, which is a docs page rather than the original engineering post.
- The HumanLayer repo README says much of its code is deprecated. The `.claude/commands` files were used as reference prompts, not as maintained products.

## Research provenance convention (v2.4)
Every research file (kit research in `/workspace/research/*.md`, project research in `thoughts/shared/research/`) starts with a provenance block:

```
<!-- provenance
- source: <url or repo> | commit: <pinned sha> or date: <YYYY-MM-DD read> | verified | unverified
-->
```
- **Pin** cloned source repos (`/workspace/research/src/*`) to a commit; the pins are listed in `/workspace/research/README.md` and in each file's header.
- **Staleness diff** before a consultation or decision relies on the research: `git -C src/<repo> fetch && git -C src/<repo> log --oneline <pin>..origin/HEAD -- <paths>`; for web sources, re-read. Note the result in the consultation notes.
- **Snapshot** a web source (save a dated copy) only when a decision-driving claim rests on it, at re-derivation time.
- `verified` = the author checked the claim against the pinned source; `unverified` = summary from memory, secondary source, or not re-checked.

## v2 additions
- Friction found in the kit's first real adoption (generalized; no project content kept) and the owner's standing working agreements: implementer/planner split, advisory cross-model review, optional board, process-feedback pass. See CHANGELOG.md.
- OpenAI Codex CLI (`codex review`, `codex exec`; `npm install -g @openai/codex`, `codex login`) as invoked by gstack's `/codex` skill. Not re-verified against the current Codex docs on this date. Check the flags if the CLI changes.
