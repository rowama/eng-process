---
id: {{ID}}
type: adr
phase: {{PHASE}}
status: proposed         # proposed | accepted | partially-accepted | deferred | rejected | deprecated | superseded
owner_agent: {{AGENT}}
date: {{DATE}}
links: []
superseded_by: none
revisit: none            # for deferred: the trigger or date to revisit
---
# {{ID}}: {{TITLE}}

## Status
proposed

## Context
<forces at play, in tension; value-neutral facts>

## Decision
We will <full sentences, active voice>.

## Parts
<!-- Required when status is partially-accepted; optional otherwise. One line per part:
     - P1 <part> - accepted (YYYY-MM-DD)
     - P2 <part> - proposed | deferred (revisit: <trigger>) -->

## Consequences
<resulting context: positive, negative, neutral>

## Prediction (scored in a later eng-retro)
- Expected outcome: <what we expect to observe if this decision is right; measurable where possible>
- Check date: <YYYY-MM-DD or trigger, e.g. "after slice 3 ships">
- What would prove it wrong: <the observation that would make us revisit>
- Score: unscored    <!-- eng-retro sets: right | wrong | unclear (YYYY-MM-DD, one-line evidence) -->
