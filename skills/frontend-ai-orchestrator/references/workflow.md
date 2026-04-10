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
2. Path strategy decision (`workspace_root_via_temp`, `subfolder`, or another explicit target strategy)
3. Target directory decision (`apps/<app-name>` or explicit alternative when relevant)
4. Scaffold command selection (from stack command matrix)
5. Optional-library-aware command/flag decisions
6. Optional library decision list (approved/declined)
7. Stack-aware addon defaults decision notes
8. Scaffold execution summary
9. Merge/conflict summary when temp staging is used
10. Scaffold handoff payload with exact keys:
   - `app_name`
   - `framework`
   - `language`
   - `package_manager`
   - `path_strategy`
   - `target_path`
   - `scaffold_command`
   - `optional_libraries_approved`
   - `optional_libraries_declined`
   - `post_scaffold_installs`
   - `merge_summary`
   - `blockers`

Exit criteria:
1. Stack and template are explicitly confirmed.
2. Optional library choices are explicitly confirmed.
3. Path strategy and scaffold target path are explicit and safe for current workspace state.
4. If current-workspace-root placement is requested in a non-empty workspace, temp staging plus conflict review is completed before files are copied back.
5. Starter app scaffold exists and installs successfully with the chosen package manager, or the phase is marked `failed`/`blocked` with explicit blocker details and next action.
6. The scaffold handoff payload is complete and machine-checkable.
7. Do not hand off to phase 1 while unresolved scaffold blockers remain unless the user explicitly waives the blocker.
8. `.orchestrator/status/phase-0.json` written.

### Phase 1: Plan Contract + Design Contract / Alignment (Superpowers + selected design authority)

Goal: produce a machine-checkable delivery contract before implementation.
Preferred skills: `brainstorming`, `writing-plans`, then choose `ui-ux-pro-max`, `design-system`, or `ui-styling`; use `brand` as optional input when identity is unresolved.
Artifact directory: `.orchestrator/contracts/`

Sequence:
1. `brainstorming` -> `.orchestrator/contracts/SPEC.md`
2. `writing-plans` -> `.orchestrator/contracts/PLAN.md`
3. Choose design mode:
   - `net_new_direction` -> `ui-ux-pro-max`
   - `design_system` -> `design-system`
   - `implementation_styling` -> `ui-styling`
   - `design_alignment` -> normalize an existing authoritative design/template into `.orchestrator/contracts/DESIGN.md`
   - optional `brand` input pass when identity is still open
4. Produce `.orchestrator/contracts/DESIGN.md`
5. Contract check and targeted repair loop (max 2 retries)

Deliverables:
1. `.orchestrator/contracts/SPEC.md` with approved scope + assumptions
2. `.orchestrator/contracts/PLAN.md` with milestone IDs (`M1`, `M2`, ...) and acceptance criteria IDs (`AC1`, `AC2`, ...)
3. `.orchestrator/contracts/DESIGN.md` with either generated design rules or preserved design-alignment constraints, always mapped by `M#`
4. Risk list and definition of done
5. Verification strategy

Exit criteria:
1. Scope and assumptions are explicit.
2. Acceptance criteria are testable.
3. Risks have mitigation notes.
4. Spec is approved before plan/build handoff.
5. Selected design mode is explicit.
6. Token choices are documented when new tokens are created or existing tokens are referenced.
7. Visual direction is approved, defaulted explicitly, or marked as preserved from the existing design authority.
8. Accessibility implications are called out.
9. Every `.orchestrator/contracts/PLAN.md` milestone has a mapping in `.orchestrator/contracts/DESIGN.md`.
10. Every major `.orchestrator/contracts/DESIGN.md` section maps back to at least one milestone.
11. Existing template/design constraints are captured when provided.
12. Contract check passed (or explicit user waiver).
13. `.orchestrator/status/phase-1.json` written.

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

Run conditions:
1. If the project uses project-local Playwright and Chromium is missing, run `pnpm exec playwright install chromium` in the project workspace before the regression run.
2. Prefer this project-scale install step over switching Playwright to `/usr/bin/chromium` for pnpm-based app workflows.

Deliverables:
1. Updated test coverage for critical journeys
2. Test run outcomes
3. Flakiness notes and mitigations
4. Test-state isolation notes (clean state or dedicated regression account/profile)
5. Browser-install evidence when a missing-browser repair was needed

Exit criteria:
1. Critical-path tests pass.
2. New regressions are covered.
3. Remaining gaps are explicit.
4. Regression tests do not depend on exploratory browser state.
5. If a missing-browser error occurred in a project-local Playwright setup, the repair command and rerun outcome are recorded.
6. `.orchestrator/status/phase-5.json` written.

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
