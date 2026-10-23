# Opt-in CI checklist (frontend), size-dependent
<!-- Not enforced by eng-check. Pick per project in the plan's Testing Strategy (or an ADR) and record the
     choice. Start small; add a row when its cost is lower than the defects it would catch. -->

| Check | Small (prototype / 1 page) | Medium (real users) | Large (product / many routes) | Typical tool |
|---|---|---|---|---|
| Lint | yes | yes | yes | eslint / ruff |
| Typecheck | if TS | yes | yes | `tsc --noEmit`, mypy/pyright |
| Accessibility (axe) | optional | key pages | all routes in CI | @axe-core/playwright, axe-core CLI |
| Bundle budget | no | warn at a set size | fail over budget | size-limit, bundlesize, vite build report |
| Lighthouse | no | optional, manual | CI on key routes with budgets | lighthouse-ci |

How to adopt:
1. Choose the column by triage size; note exceptions with a reason.
2. Add the commands to the plan's **Automated Verification** so eng-verify re-executes them.
3. Owner legibility: prefer checks whose output Rob can read (a failing axe rule names the element; a budget names the bytes).
