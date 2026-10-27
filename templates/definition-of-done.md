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
- [ ] Default test command (`pytest tests` or the project equivalent) collects and runs unit + acceptance with zero silent collection skips (no quietly skipped modules).
- [ ] Time- or rate-based behaviour uses an injected/frozen clock in tests from slice 1 (kit LESSONS L-003).
- [ ] Executable specs (medium/large, when acceptance is enabled): every REQ in the approved design has a spec
      (`eng-spec trace`), all specs pass on every planned channel, and locked specs / the DSL interface were not
      changed without Rob's re-approval (`eng-spec status` clean; assertion-step changes covered by the code review).
- [ ] Error paths handled; no silent failures.
- [ ] Docs touched by the change are updated (README, AGENTS.md commands, API docs).
- [ ] CHANGELOG entry under Unreleased; VERSION bumped at ship if the project uses one.
- [ ] Durable decisions recorded as ADRs; deferrals recorded in TODOS.md.
- [ ] Verification report written with verdict PASS.
- [ ] PROJECT_STATE.md updated and a handoff written.
<!-- Project-specific additions below -->
