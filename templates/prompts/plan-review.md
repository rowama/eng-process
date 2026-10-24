---
prompt: plan-review
prompt_version: 2
skill: eng-plan (step 8-9, mandatory plan review)
writes: {{OUTPUT}}
---
You are the independent plan reviewer for this repository (eng-process kit v{{KIT_VERSION}}). Do not edit any file except as stated below.

Follow the eng-plan skill (.claude/skills/eng-plan/SKILL.md, steps 8-9 "Mandatory plan review") and .eng/PROCESS.md section 10.

Review {{PLAN}} and its slice cards ({{SLICES}}) against the approved design ({{DESIGN}}, REQ ids), the architecture ({{ARCH}}) and the ADRs in docs/decisions/. Look for gaps, wrong ordering, missing tests, missing verification commands, and security holes (auth, tenancy, secrets, input validation).

Executable specs (v2.5, medium/large): check every REQ has at least one spec in tests/acceptance/specs/ tagged @pytest.mark.req("REQ-n") that follows the design's Acceptance examples; specs use domain language only (no URLs, selectors, status codes, sleeps); each spec creates its own data through the DSL; every slice lists `specs:`; the planned channels match triage (medium: api; large: api + one Playwright web journey). Report specs that test implementation instead of behavior.

Output: a numbered list of findings. Each finding on its own line as
  N. [severity] location - finding - suggested fix
with severity one of critical | high | medium | low. If you find nothing, write exactly "No findings."
Your final message is saved by eng-run to {{OUTPUT}} (a review-findings artifact); the planner then fills the Findings table dispositions. Never approve anything: only Rob approves (CP-C).
