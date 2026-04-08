# Workflow

## Phases

Core baseline path:
1. Phase 0 (greenfield only)
2. Phase 1
3. Phase 2
4. Phase 5
5. Phase 6

Optional enhancer path:
1. Phase 3 and phase 4 are quality enhancers, not baseline blockers unless user explicitly requires them.

### Phase 0: Intake + Scaffold (`frontend-scaffold-intake`)

Goal: capture stack decisions and scaffold starter app correctly before planning.
Preferred skill: `frontend-scaffold-intake`
Fallback: OpenCode shell commands with explicit user confirmation for options.

Deliverables:
1. Stack decision record (framework, language, package manager, app name; default package manager is pnpm unless overridden)
2. Target directory decision (`apps/<app-name>` when workspace is non-empty unless explicitly overridden)
3. Scaffold command selection (from stack command matrix)
4. Optional-library-aware command/flag decisions
5. Optional library decision list (approved/declined)
6. Stack-aware addon defaults decision notes
7. Scaffold execution summary
8. Scaffold handoff payload (app name, stack, target path, command used, addon decisions, blockers)

Exit criteria:
1. Stack and template are explicitly confirmed.
2. Optional library choices are explicitly confirmed.
3. Scaffold target path is explicit and safe for current workspace state.
4. Starter app scaffold exists and installs successfully with the chosen package manager (or failure is reported with next fix action).
5. `.orchestrator/status/phase-0.json` written.

### Phase 1: Plan Contract + Design Contract (Superpowers + UI UX Pro Max)

Goal: produce a machine-checkable delivery contract before implementation.
Preferred skills: `brainstorming`, `writing-plans`, `ui-ux-pro-max`

Sequence:
1. Superpowers brainstorming/spec approval -> `SPEC.md`
2. Superpowers writing-plans output -> `PLAN.md`
3. UI UX Pro Max design-system finalization and milestone mapping -> `DESIGN.md`
4. Contract check and targeted repair loop (max 2 retries)

Deliverables:
1. `SPEC.md` with approved scope + assumptions
2. `PLAN.md` with milestone IDs (`M1`, `M2`, ...) and acceptance criteria IDs (`AC1`, `AC2`, ...)
3. `DESIGN.md` with token system, style rules, anti-patterns, and mappings keyed by `M#`
4. Risk list and definition of done
5. Verification strategy

Exit criteria:
1. Scope and assumptions are explicit.
2. Acceptance criteria are testable.
3. Risks have mitigation notes.
4. Spec is approved before plan/build handoff.
5. Token choices are documented.
6. Visual direction is approved or defaulted explicitly.
7. Accessibility implications are called out.
8. Every `PLAN.md` milestone has a mapping in `DESIGN.md`.
9. Every major `DESIGN.md` section maps back to at least one milestone.
10. Contract check passed (or explicit user waiver).
11. `.orchestrator/status/phase-1.json` written.

### Phase 2: Build (OpenCode + Superpowers discipline)

Goal: implement milestone by milestone.
Precondition: Phase 1 Plan + Design contract exit criteria passed, or explicit user waiver.
Preferred skills: `executing-plans`, `systematic-debugging`, `test-driven-development`

Deliverables:
1. Incremental code changes
2. Verification notes per milestone
3. Open issues list

Exit criteria:
1. Milestone acceptance criteria are satisfied.
2. No unresolved blocking errors.
3. Major assumptions are documented.
4. `.orchestrator/status/phase-2.json` written.

### Phase 3: Exploratory QA (agent-browser, optional)

Goal: validate real browser behavior and edge-case flows.
Preferred skill: `agent-browser`

Run conditions:
1. `agent-browser` available, or user explicitly requests exploratory QA.
2. If unavailable or timeout, mark `skipped` and continue to phase 5.

Deliverables:
1. Scenario execution logs
2. Reproduction steps for issues
3. Browser-state notes (session/auth/state)
4. Isolation record (session/profile/account used for exploratory runs)
5. Screenshot evidence set for key flows

Exit criteria:
1. Critical user journeys run in browser.
2. Reproducible issues captured with commands.
3. Browser-only regressions identified.
4. Exploratory session/profile is isolated from regression test profile.
5. `.orchestrator/status/phase-3.json` written.

### Phase 4: Refine (Impeccable, optional)

Goal: improve quality of hierarchy, usability, and polish using phase 3 evidence.
Preferred skills: `frontend-design`, `polish`, `audit`

Run conditions:
1. Trigger when phase 3 or phase 5 identifies meaningful UX issues.
2. Skip by default when no meaningful UX issues are found.
3. If skill unavailable, mark `skipped` and continue to phase 5 or phase 6.

Deliverables:
1. Prioritized UX findings
2. Patch-level improvement plan
3. Accessibility and readability checks
4. Confirmed before/after notes tied to phase 3 findings

Exit criteria:
1. High-severity UX issues are fixed or tracked.
2. Visual and interaction consistency improved.
3. Copy and feedback states are coherent.
4. If changes were applied, one exploratory re-check is completed before phase 5.
5. `.orchestrator/status/phase-4.json` written.

### Phase 5: Regression Automation (Playwright CLI)

Goal: convert critical behavior into deterministic tests.
Preferred skill: `playwright-cli`

Deliverables:
1. Updated test coverage for critical journeys
2. Test run outcomes
3. Flakiness notes and mitigations
4. Test-state isolation notes (clean state or dedicated regression account/profile)

Exit criteria:
1. Critical-path tests pass.
2. New regressions are covered.
3. Remaining gaps are explicit.
4. Regression tests do not depend on exploratory browser state.
5. `.orchestrator/status/phase-5.json` written.

### Phase 6: Release Verification (Superpowers)

Goal: verify readiness and residual risk.
Preferred skill: `verification-before-completion`

Deliverables:
1. Requirements coverage summary
2. Test + UX quality summary
3. Known limitations and rollback notes

Exit criteria:
1. Required gates passed or explicitly waived.
2. Open risks are documented with impact.
3. Final status is clear: ready or not ready.
4. `.orchestrator/status/phase-6.json` and `.orchestrator/status/run-summary.json` written.
