---
id: {{ID}}
type: retro
phase: reflect
status: draft            # draft | done
owner_agent: {{AGENT}}
date: {{DATE}}
links: []
---
# Retro: {{TITLE}}

## Outcome vs goal
<shipped what; metric movement if known>

## Flow data
- Slices done / planned:
- Cycle time (first commit → merge):
- Rework (reopened slices, failed verifications, reverted commits):
- Escaped defects:

## Time per phase (rough)
| Phase | Time (h or days) | Notes |
|---|---|---|
| discover / scope | | |
| research | | |
| architecture | | |
| plan (+ plan review) | | |
| implement | | |
| verify / ship | | |

## Which step felt like waste?
<the one step (or artifact) that cost more than it returned this time, and why; "none" is a valid answer>

## Review hit-rate
- Review hit-rate: findings <N> total; accepted <a> (fixed or accepted-risk) vs rejected <r>; real bugs caught <b>; rejected-with-evidence <e>/<r>
<!-- count from thoughts/shared/verification/*review*.md since the last retro; a "real bug" = fixed finding that would have shipped a defect -->

## Predictions scored
<!-- Every ADR, consultation and retro prediction whose check date has passed: right | wrong | unclear + one-line evidence.
     Also update the Score line in the source file. -->
| Source (file) | Expected outcome | Check date | Score (right/wrong/unclear) | Evidence |
|---|---|---|---|---|

## Design adoption
<!-- From process-feedback.md 'Design adoption': adopted vs skipped kit steps this period; any redesign flag or safety escalation. -->

## Process-feedback pass
<!-- Read thoughts/shared/process-feedback.md and previous retros. List each open entry: adopt (-> change below) / reject (why) / defer. -->

## What went well
## What hurt
## Root causes

## Process changes (each becomes a concrete edit)
| Change | Target file (AGENTS.md / template / skill / DoD) | Done |
|---|---|---|

## Predictions made now (score them in a later retro)
<!-- Consultation / retro notes: one block per decision or recommendation -->
- Decision/recommendation: <...>
  - Expected outcome: <...>
  - Check date: <YYYY-MM-DD or trigger>
  - What would prove it wrong: <...>

## Kit lessons proposed (Rob approves; format in .eng/templates/kit-lesson.md)
<!-- - When <X>, do <Y>, because <Z>. (origin: <project/retro>; confirmations: 1; status: hypothesis) -->

## Learnings to keep
