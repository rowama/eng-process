<!-- Standard message the planner sends the owner when a slice is ready. Filled by .eng/bin/eng-status. -->
Slice ready for {{IMPLEMENTER}}.
Repo: {{REPO}}
Plan: {{PLAN}}
Slice: {{SLICE_ID}} ({{SLICE}})
Push: {{PUSH}} (ask = ask before each push)
Paste into {{IMPLEMENTER}}:
  Run eng-resume, then eng-implement-slice for {{SLICE_ID}} per {{PLAN}}. Finish with eng-handoff.
