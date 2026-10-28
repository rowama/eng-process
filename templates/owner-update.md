<!-- Standard owner-facing update shape (LESSONS L-007, L-009). Every project bot uses this when messaging Rob. -->
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
- **Never use valid shell syntax as an edit placeholder** in instructions or sample commands (e.g. `$TOKEN`, `${BOT_TOKEN}`, `$1`). Shells expand those if he pastes. Use an obvious non-runnable token like `PASTE_BOT_TOKEN_HERE`, or tell him to paste the value at the prompt / when asked. Wrong: `export TOKEN=$BOT_TOKEN`. Right: `export TOKEN=PASTE_BOT_TOKEN_HERE` or "paste the bot token when the prompt asks".
- If he has nothing to do, write exactly: `No action for you.`
- Put the decision he owes (approve / defer / needs fixes / hold / named CP) after the actions, not mixed into status.


## Manual / CP-S steps (LESSONS L-009)
- Only ask the owner to run steps that work **against the runtime that is live now** (entrypoint started, required env present, dependency deployed).
- Each Action-for-Rob manual step must state readiness in one short clause (`ready: <how you verified>`) or be listed as blocked: `Blocked: <why>; unblocks in <slice or phase>` — never as a current step.
- Never paste the plan's full Demo script or later-slice criteria as today's Action for Rob. The demo script is aspirational end-state; CP-S uses the currently-runnable subset only.

## Default detail (LESSONS L-007 clarity)
- Default to detailed, pasteable instructions. Name the exact command or click path.
- After each command, one line on what success looks like.
- The first time you use project jargon or a project CLI, say what it does versus the adjacent product/system (e.g. what `set-bot` does vs the chat product). Do not wait for the owner to ask for clarity.
- The first time the owner must **do or understand** something new — a concept, feature config, setup step, admin step, env var, mount, scale setting, flag, secret, or similar — explain it with no assumed platform knowledge: **where it lives** (which product, UI path, file, or CLI — e.g. Coolify → this service → Environment, not the Dockerfile), **what it does**, and the **exact value or action** (or `PASTE_…_HERE`). Do not assume he already knows that product or path.
- Wrong: “attach `/data`, set `MMB_STORE_KEY`, replicas, `LIVE_BOTS_ENABLED`.”
- Right (illustrative — same shape for any new setup/admin step):
  1. In Coolify → this service → Environment (**not** the Dockerfile): set `MMB_STORE_KEY=PASTE_STORE_KEY_HERE` — encrypts the store.
  2. In Coolify → this service → Persistent storage: mount host `/data` → container `/data`.
  3. In Coolify → this service → Scaling: set replicas to `1` (Coolify UI scaling, not a Dockerfile change).
  4. In Coolify → this service → Environment: set `LIVE_BOTS_ENABLED=true` — turns on live bot listeners.

## Default reversal (LESSONS L-010)
- When a change reverses a user-visible default the owner relies on, put a one-line **Before → After** example in the approval ask (e.g. `Before: X happens by default → After: X only when you opt in`) and demo it at CP-S. Rule-style prose alone gets approved without the reversal being noticed.

## Risk you uncovered (mitigation cost)

When **you** uncovered a risk and your design, architecture, or plan would mitigate it, do not bake the mitigation in as a normal feature. Before it lands:

1. Name it as a risk you uncovered (not product scope).
2. Cost it honestly — money if any, and especially **friction / ops burden** (extra steps per bot, per channel, per deploy, complexity).
3. Offer at least one narrower alternative (accept the risk, smaller mitigation, defer, waive).
4. Stop with L-007 shape and an explicit decision — soft acknowledgment is not approval of the cost.

~~~~
I uncovered <risk>. Mitigating it in the design would mean <concrete friction/cost>.

**Action for Rob**
1. Choose one: absorb this mitigation | accept the risk | defer | use <narrower option>

**Decision needed:** approve mitigation cost vs accept/defer
~~~~

