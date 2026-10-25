<!-- Standard ready-to-implement message. Filled by .eng/bin/eng-status. The planner STARTS the run with the eng-run line, then shows Rob this message as FYI (not a paste ask). -->
Slice ready for {{IMPLEMENTER}} - starting implement run.
Repo: {{REPO}}
Plan: {{PLAN}}
Slice: {{SLICE_ID}} ({{SLICE}})
Push: {{PUSH}} (ask = ask before each push)
Start (from repo root):
  python3 .eng/bin/eng-run implement {{PLAN}} {{SLICE_ID}}
  (or: eng run implement {{PLAN}} {{SLICE_ID}} with the global CLI)
Fallback (interactive Claude) - paste into {{IMPLEMENTER}}:
  Run eng-resume, then eng-implement-slice for {{SLICE_ID}} per {{PLAN}}. Finish with eng-handoff.
