---
name: eng-research
description: Document how the relevant code works today, with file:line references and no recommendations (codebase research; external/market research is a separate market-research artifact). Use after scope is approved and before architecture or planning, or whenever an agent needs to understand existing code.
---
# eng-research

Session: standard Start/Finish per `.eng/PROCESS.md` section 8 (kit: `PROCESS.md`). Scripts: `.eng/bin/eng-check`, `.eng/bin/eng-status`, `.eng/bin/eng-new`.

## Inputs (files only)
- Approved `docs/design/*.md` (requirements -> research questions); `.eng/bin/eng-check` fails if it isn't approved
- `AGENTS.md` architecture map

## Outputs
- `thoughts/shared/research/<date>-<slug>.md` (codebase only). External/market/methods research goes to `thoughts/shared/market-research/` via `.eng/bin/eng-new market-research`, where recommendations are allowed.

## Steps
1. Write the exact research question(s) first.
2. Spawn parallel sub-tasks to locate files, analyze components, find patterns; each returns paths + file:line notes.
3. Read the key files yourself, fully.
4. Write findings: what exists, where, how data flows. **Only document; no critique, no proposals.**
5. Fill git_commit/branch so staleness is detectable. For external sources, add the provenance block (source, pinned commit or read date, verified/unverified; PROCESS.md 12).

## Exit criteria
Every question answered or listed open; every claim has a file:line; no recommendations.

## Approval stop (Rob)
**CP-R Research** (Large; optional Medium): `CP-R: <path> - read and accept research`. If rejected, mark `discarded` and redo in a fresh session.

## Finish
Standard: end with eng-handoff.
