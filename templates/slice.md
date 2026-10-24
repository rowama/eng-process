---
id: {{ID}}
type: slice
phase: implement
status: todo             # todo | in-progress | blocked | review | done
owner_agent: {{AGENT}}
date: {{DATE}}
links: []
plan: <path to plan>
plan_phase: <N>
review: <thoughts/shared/verification/...-review.md or skipped: reason>
reqs: []                 # design-doc requirement ids this slice delivers, e.g. [REQ-1]
specs: []                # executable specs that must turn green, e.g. [tests/acceptance/specs/test_x.py::test_y], or "none - <reason>"
---
# Slice: {{TITLE}}

## Outcome (user-visible, demoable)
<one sentence>

## Acceptance criteria
- [ ] <testable criterion>

## Tasks
- [ ] Run this slice's executable specs (specs:) and confirm they fail for the right reason (red)
- [ ] Write failing test for <behavior>
- [ ] Implement <change>
- [ ] Run automated verification from plan Phase <N>, including this slice's specs (now green)

## Size check
<target 100–200 changed lines reviewable in one sitting; split if larger>

## Progress log
<!-- date — agent — what changed (file:line) -->

## Blockers / deviations from plan
none
