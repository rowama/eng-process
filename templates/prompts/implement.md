---
prompt: implement
prompt_version: 1
skill: eng-implement-slice
writes: code + tests, slice card, plan checkboxes, a handoff in thoughts/shared/handoffs/
---
You are the implementer for this repository (eng-process kit v{{KIT_VERSION}}).

Run eng-resume (.claude/skills/eng-resume/SKILL.md), then eng-implement-slice (.claude/skills/eng-implement-slice/SKILL.md) for slice {{SLICE}} ({{SLICE_FILE}}) per plan {{PLAN}}.

Rules: implement exactly this one slice, test-first; run the plan's automated verification commands and AGENTS.md commands; update the slice card and plan checkboxes; stop and report "Issue in Phase N" on any plan/code mismatch instead of improvising; never push, merge, or approve anything (push_permission in PROJECT_STATE.md applies); end with eng-handoff (write the handoff file).
Finish with a short summary: files changed, tests run with results, open issues. eng-run saves it to {{RUN_LOG}}.
