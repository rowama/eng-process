---
name: eng-inbox
description: Owner incoming-thoughts inbox (thoughts/shared/inbox.md). Use when the owner's message starts with note:, n:, idea:, feature:, future feature:, ff:, capture:, or cap: (append it), or says "process incoming", "check idea log", "process notes", or similar (process and rotate the inbox).
---
# eng-inbox

Owner capture bin for random thoughts and feature ideas. Same posture as review-notes: agents never triage or act on it unless asked.

## Inputs
- `thoughts/shared/inbox.md` (create from `.eng/templates/inbox.md` if missing)

## Outputs
- Capture: one appended bullet under `## Open`
- Process: archive `thoughts/shared/inbox/YYYY-MM-DD-HHMM-inbox.md`, fresh live inbox holding only deferred items, items moved to their homes

## Capture (append only)
Trigger: the message starts (case-insensitive, leading whitespace ok) with `note:` `n:` `idea:` `feature:` `future feature:` `ff:` `capture:` `cap:`.
1. Append `- [<tag>] YYYY-MM-DD: <text verbatim>` under `## Open` (tag = note, idea, feature, future-feature, capture).
2. Commit (`chore: inbox capture`). Reply with one line. Do not classify, discuss, or act on it.

## Process
Trigger: "process incoming", "check idea log", "process notes", or similar.
1. Read the whole live inbox (Open and Deferred).
2. For each item, in order: classify it (feature, principle/convention, research task, bug, design note, ADR candidate, process feedback, question, drop). Ask clarifying questions one at a time. Recommend a home or an action; the owner decides. Any answer can be **defer**.
3. Settle it: move it to its home (TODOS.md, the project feature list, docs/design, an ADR via eng-triage, `thoughts/shared/process-feedback.md`), do the small action on the spot with the owner, or mark it deferred or dropped. Record what you did.
4. Only when **every** item is actioned, moved, dropped, or deferred:
   - `mkdir -p thoughts/shared/inbox` and `git mv thoughts/shared/inbox.md thoughts/shared/inbox/YYYY-MM-DD-HHMM-inbox.md`; annotate each item in the archive with `-> <status>: <action / destination>`.
   - Recreate `thoughts/shared/inbox.md` from `.eng/templates/inbox.md` with every deferred item under `## Deferred` as `- [deferred YYYY-MM-DD] <text>` (keep earlier deferral dates too).
   - Commit (`chore: process inbox`).
5. If the session stops partway, leave the live inbox in place, mark settled items `-> done: ...` inline, and note it in the handoff. Rotate later.
