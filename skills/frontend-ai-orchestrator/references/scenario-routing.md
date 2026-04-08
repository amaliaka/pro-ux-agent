# Scenario Routing

Use this table to decide which phase starts first.

Core rule:
1. Always complete core phases (`1`, `2`, `5`, `6`; plus `0` for greenfield).
2. Use phases `3` and `4` as optional enhancers unless user explicitly requires them.

| Scenario | Start phase | Next phase |
|---|---|---|
| New app / greenfield project | Intake + Scaffold | Plan + Design Contracts |
| Brand-new feature in existing app | Plan + Design Contracts | Build |
| Existing feature enhancement | Plan + Design Contracts | Build |
| Visual polish request | Refine | Regression Automation |
| Accessibility quality concerns | Refine | Regression Automation |
| Browser-only bug | Exploratory QA | Regression Automation |
| Flaky test or repeated regressions | Regression Automation | Release Verification |
| Pre-release confidence check | Release Verification | (stop) |

## Tie-break Rules

1. If scope is unclear in an existing app, run Plan + Design Contracts first.
2. If the task includes creating a new app, run Intake + Scaffold (`frontend-scaffold-intake`) before Plan + Design Contracts.
3. After Intake + Scaffold, run the combined Plan + Design contract phase before Build by default.
4. Skip the combined phase only when the user explicitly waives it.
5. Intake + Scaffold requires explicit optional-library confirmation before command execution.
6. If issue is not reproducible in tests, run Exploratory QA first.
7. If bug is reproducible manually, encode it in Regression Automation immediately.
8. Use separate sessions/profiles/accounts for Exploratory QA and Regression Automation.
9. If exploratory QA finds meaningful UI issues, run Refine before Regression Automation.
10. If exploratory QA is skipped due to unavailable skill/timeout, continue with Regression Automation and record skip reason in phase status JSON.
