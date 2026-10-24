# Acceptance tests: executable specs (eng-process v2.5, Farley four-layer model)

| Layer | Where | Rule |
|---|---|---|
| 1. Executable specs | `specs/test_*.py` | Domain language only (what, not how): no URLs, selectors, status codes. One or more per design-doc requirement, tagged `@pytest.mark.req("REQ-n")`. **Locked at CP-C** (spec-lock.json). |
| 2. DSL | `dsl.py` | Shared vocabulary. Public interface (names, parameters, docstrings) **locked at CP-C**. Assertion steps (`assert_*`, `then_*`, `expect_*`, `check_*`, `verify_*`): body changes are flagged by eng-check and must be covered by the Codex review. Private helpers (`_x`) free. |
| 3. Protocol drivers | `drivers/*.py` | One per channel (api = httpx, ui = Playwright, mcp). All system knowledge lives here. **Freely editable.** |
| 4. System under test | deployed like production | Started outside the tests; URL in `ACCEPTANCE_BASE_URL`. External systems stubbed at its boundary. |

Isolation: every spec creates its own data through the DSL (functional isolation); the DSL aliases names
(`"alice"` -> `"alice-3f9c2a"`) so a spec can run twice against the same system (temporal isolation).
Never share data between specs; never reach into the database (public interfaces only).

Run (from the repo root): `pytest tests/acceptance` (api channel) - `pytest tests/acceptance --channel=ui` (Playwright journeys,
only specs marked `@pytest.mark.channels("api", "ui")`). Needs `pip install pytest httpx` (+ `pytest-playwright`
and `playwright install chromium` for ui; `mcp` for an MCP channel).

Lock for CP-C: `python .eng/bin/eng-spec lock .`; check drift: `python .eng/bin/eng-spec status .`.
