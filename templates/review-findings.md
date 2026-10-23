---
id: {{ID}}
type: review-findings
phase: {{PHASE}}
status: open             # open | addressed | closed
owner_agent: {{AGENT}}
date: {{DATE}}
links: []
review_kind: {{KIND}}    # plan (MANDATORY gate for medium/large) | slice (advisory) | architecture (advisory)
subject: <plan + slice cards, slice card, or architecture doc reviewed>
diff: <base>...<head commit, or n.a. for document reviews>
reviewer: codex
command: <exact command run from the repo root, e.g. codex exec "..." -o <this file>; output always goes to this file>
---
# Independent review: {{TITLE}}
<!-- Plan reviews gate implementation (medium/large): .eng/bin/eng-check fails while any critical/high row is open or
     lacks a valid disposition. Slice and architecture reviews are advisory.
     Severity: critical | high | medium | low.
     Disposition: open | fixed (where/commit) | accepted-risk (ONLY with Rob's approval: name it, e.g. "Rob 2026-10-23") | rejected (reason + EVIDENCE required: a file:line such as src/auth.py:42, or a test reference such as
     tests/test_auth.py::test_expired_token; eng-check warns when a rejected row cites neither). -->

## Findings
| # | Severity | Location | Finding | Disposition | Reason / approval |
|---|---|---|---|---|---|

## Reviewer raw output
<paste the numbered list Codex printed; link the full log if long>
