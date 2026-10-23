---
id: DOD
type: definition-of-done
phase: any
status: active
owner_agent: {{AGENT}}
date: {{DATE}}
links: []
---
# Definition of Done

A slice/increment is Done only when every applicable item holds, proven by commands re-run in the verifying session (a report is a claim until re-executed):

- [ ] All plan success criteria for the slice are checked: automated (re-run, exit 0) and manual (confirmed by Rob).
- [ ] New behavior has tests; a bug fix has a regression test that failed before the fix.
- [ ] No test, timeout, lint rule, or check was weakened, skipped, or suppressed without Rob's named approval.
- [ ] Build, lint/typecheck, and the full test suite pass.
- [ ] Error paths handled; no silent failures.
- [ ] Docs touched by the change are updated (README, AGENTS.md commands, API docs).
- [ ] CHANGELOG entry under Unreleased; VERSION bumped at ship if the project uses one.
- [ ] Durable decisions recorded as ADRs; deferrals recorded in TODOS.md.
- [ ] Verification report written with verdict PASS.
- [ ] PROJECT_STATE.md updated and a handoff written.
<!-- Project-specific additions below -->
