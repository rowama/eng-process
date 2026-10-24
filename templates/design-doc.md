---
id: {{ID}}
type: design
phase: discover
status: draft            # input (pre-draft from an earlier phase) | draft | in-review | approved | superseded
owner_agent: {{AGENT}}
date: {{DATE}}
links: []
# implementer is a PROJECT_STATE working agreement; never name it here
---
# Design: {{TITLE}}

## Problem
<who hurts, how, evidence. Facts, not solutions.>

## Users and success metric
<primary user; observable metric that tells us it worked>

## Narrowest wedge
<smallest version that delivers the value>

## Requirements (acceptance criteria)
<!-- EARS-style or Given/When/Then; each must be testable. -->
- [ ] REQ-1: WHEN <trigger> THE SYSTEM SHALL <response>

## Acceptance examples
<!-- v2.5. Medium/large work: 1-3 concrete examples per requirement in plain language, Given/When/Then, in the
     problem domain's words (what, never how: no URLs, buttons, status codes). Rob approves these at CP-A.
     They become the executable specs (tests/acceptance/specs/, tagged @pytest.mark.req("REQ-n")) locked at CP-C.
     Small work: leave "n/a - small". -->
- REQ-1 / example 1: GIVEN <context> WHEN <action> THEN <observable outcome>

## Constraints and assumptions
- [NEEDS CLARIFICATION: <question>]   <!-- must be resolved before CP-A approval -->

## Alternatives considered
| Option | Pros | Cons |
|---|---|---|

## Scope decision (filled by eng-scope-review)
Baseline: the Requirements list above as approved at CP-A (REQ ids).
Mode (relative to that baseline): <expand | selective | hold | reduce>
- In:
- Out (also recorded in TODOS.md):

## Architecture (filled by eng-architecture-review)
<!-- Fill here for medium work. Large work may use a separate docs/architecture/ doc (.eng/bin/eng-new architecture <slug>); then put only a link and 3-line summary here. -->
<components and boundaries, contracts/interfaces, data ownership and schemas, sequence diagram (mermaid or ASCII), failure modes and error handling, rollback and feature flags, observability, security (STRIDE quick pass)>

## Open questions
