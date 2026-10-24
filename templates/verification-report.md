---
id: {{ID}}
type: verification
phase: verify
status: draft            # draft | pass | fail
owner_agent: {{AGENT}}
date: {{DATE}}
links: []
plan: <path to plan>
git_commit: {{COMMIT}}
---
# Verification: {{TITLE}}

## Implementation status
- [x]/[ ] Phase N: <name> — <complete | partial | missing>

## Automated verification (re-executed in this session; paste exit codes)
| Command | Exit | Notes |
|---|---|---|

## Executable specs (v2.5; paste `eng-spec trace` and fill results from the re-run; "n/a - small" otherwise)
| REQ | design doc | specs | result |
|---|---|---|---|

Spec lock: <`eng-spec status` output: clean | changes + Rob's re-approval row>

## Code review findings
<matches plan? deviations, edge cases, error handling, security, weakened tests/timeouts/suppressions (name each)>

## Cross-model review (advisory)
<!-- Summarize thoughts/shared/verification/*-review.md: reviewer, command, findings count by severity, each high finding's resolution. "skipped: small/docs-only" is valid. Advisory: never by itself a FAIL, but an unresolved high finding must be named in the Verdict. -->
- Findings file: <path or skipped: reason>

## Manual verification required (for Rob)
- [ ] <step>

## Definition of Done
<each item from docs/definition-of-done.md: pass / fail / n.a.>

## Verdict
<PASS | FAIL — reasons; follow-ups added to TODOS.md>
