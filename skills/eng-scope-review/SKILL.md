---
name: eng-scope-review
description: Decide scope for an approved design: expand, selective expand, hold, or reduce relative to the approved requirements list, and record cuts. Use after CP-A and before research, or when scope is in question mid-project.
---
# eng-scope-review

Session: standard Start/Finish per `.eng/PROCESS.md` section 8 (kit: `PROCESS.md`). Scripts: `.eng/bin/eng-check`, `.eng/bin/eng-status`, `.eng/bin/eng-new`.

## Inputs (files only)
- Approved `docs/design/*.md` (its Requirements list as approved at CP-A is the **baseline**)
- `TODOS.md`, existing `docs/decisions/*`

## Outputs
- Design doc Scope decision section (names the baseline)
- `TODOS.md` entries for every cut; ADR (`.eng/bin/eng-new adr <slug>`) for any durable scope decision

## Steps
1. State the baseline: the approved REQ ids. Every mode is relative to it: expand = add REQs; selective = add named REQs only; hold = baseline exactly; reduce = drop named REQs.
2. Challenge each requirement: needed for the wedge? cheaper version?
3. Propose one mode with a one-paragraph rationale; list In and Out by REQ id.
4. Within the blast radius, prefer the complete version when it costs little more; flag anything outside it.
5. Move every Out item to TODOS.md with source link. ADR only for decisions someone might re-litigate.

## Exit criteria
Baseline named; mode chosen; In/Out lists explicit; cuts in TODOS.md.

## Approval stop (Rob)
Rob approves the scope (recorded as part of CP-A in the Approval log); stop until recorded.

## Finish
Standard: end with eng-handoff.
