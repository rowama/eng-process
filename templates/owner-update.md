<!-- Standard owner-facing update shape (LESSONS L-007). Every project bot uses this when messaging Rob. -->
# Owner update shape

Use this shape every time you write Rob an update that might need him.

1. **Status** — brief prose, or omit if nothing new.
2. **Actions** — either a labeled block, or the exact line `No action for you.`
3. **Decision** — if he owes a checkpoint or disposition, end with one clear ask.

## Template (copy and fill)

~~~~
<one or two sentences of status, or omit>

**Action for Rob**
1. <first concrete step he does>
2. <next step — never chain several verbs in one line>
3. <…>

```bash
<optional: one pasteable command alone in its own fence>
```

**Decision needed:** <approve | defer | needs fixes | hold | CP-X …>
~~~~

## Rules
- Tag his work explicitly as **Action for Rob** (or the owner's name). Do not bury todos inside a status/findings paragraph.
- One step per numbered line. Never: "redeploy → run X → post Y → confirm → decide".
- A command he must paste gets its own fenced code block, alone.
- If he has nothing to do, write exactly: `No action for you.`
- Put the decision he owes (approve / defer / needs fixes / hold / named CP) after the actions, not mixed into status.
