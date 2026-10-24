---
id: {{ID}}
type: adr
phase: {{PHASE}}
status: proposed         # proposed | accepted | partially-accepted | deferred | rejected | deprecated | superseded
owner_agent: {{AGENT}}
date: {{DATE}}
links: []
superseded_by: none
revisit: none
---
# {{ID}}: Acceptance tests as executable specifications (four-layer model)

<!-- v2.5 starter ADR for large work (eng-architecture-review). Create with `eng-new adr "Acceptance tests"`
     and paste this body; edit the channels and the SUT deployment to fit the project. -->

## Status
proposed

## Context
The design doc's requirements (REQ-n) and plain-language acceptance examples say what the system must do. We need
automated evidence of that, written in the problem domain's language, that survives UI and API changes and that
coding agents cannot quietly weaken to make their work pass.

## Decision
We will write acceptance tests as executable specifications in four layers (Dave Farley):
1. Specs in `tests/acceptance/specs/`, domain language only, tagged `@pytest.mark.req("REQ-n")`.
2. A DSL (`tests/acceptance/dsl.py`) shared by all specs; aliasing gives each spec its own data.
3. Protocol drivers per channel: `api` (httpx) for every spec; `ui` (Playwright) for <one> web journey; <mcp if agent-facing>.
4. The system under test deployed like production, started outside the tests; external systems stubbed at its boundary.
Specs and the DSL public interface are locked at CP-C (`eng-spec lock`, hash in the Approval log). DSL assertion-step
changes must be covered by the code review. Drivers are freely editable.

## Consequences
- Positive: specs read as requirements; one driver change absorbs a UI/API change; agents cannot redefine "done".
- Negative: a DSL and drivers to maintain; a deployable SUT is needed for the suite.
- Neutral: changing a spec after CP-C needs Rob's re-approval.

## Prediction (scored in a later eng-retro)
- Expected outcome: no shipped REQ without a passing spec; UI/API changes touch drivers, not specs.
- Check date: <after the increment ships>
- What would prove it wrong: specs rewritten in most slices, or specs that mostly mirror the implementation.
- Score: unscored
