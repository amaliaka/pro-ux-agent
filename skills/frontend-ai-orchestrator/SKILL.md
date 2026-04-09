---
name: frontend-ai-orchestrator
description: "Orchestrate end-to-end frontend delivery with a reliable core path (Superpowers + Playwright), routed design authority selection, and optional quality enhancers (agent-browser, Impeccable). Delegates greenfield intake/scaffolding to a dedicated scaffold skill, then runs contract-based planning/design, implementation, regression testing, and release verification with machine-readable phase gates."
---

# Frontend AI Orchestrator

## Overview

Run this skill as the top-level controller for frontend work. Keep output phase-based, produce explicit gates, and route work to the right specialized skill at each phase.

Reliability model:
1. Core path must succeed even when optional skills are unavailable.
2. Optional phases can improve UX quality but cannot block baseline delivery by default.
3. Every phase must write a machine-readable status artifact for orchestration control.

## Execution Contract

Follow this strict order unless the user explicitly requests a shortcut:

0. Intake + Scaffold via `frontend-scaffold-intake` (for greenfield app requests)
1. Plan Contract (Superpowers) + Design Contract / Alignment (best-fit design authority)
2. Implement with OpenCode using milestone delivery
3. Explore browser behavior with agent-browser (optional enhancer phase)
4. Refine UI/UX with Impeccable (optional enhancer phase, usually triggered by phase 3 or poor phase 5 signals)
5. Lock regression coverage with Playwright CLI (core required phase)
6. Final verification with Superpowers

Core required phases:
1. Phase 0 (when greenfield), phase 1, phase 2, phase 5, phase 6

Optional enhancer phases:
1. Phase 3 (agent-browser)
2. Phase 4 (impeccable)

Optional phase skip policy:
1. If optional skill is unavailable, mark phase as `skipped` with reason `skill_unavailable`.
2. If optional phase times out, mark as `skipped` with reason `timeout`.
3. Continue to next core phase unless user explicitly requires optional phase success.

Hard gate between phase 1 and phase 2:
Do not start Build until Plan + Design contracts have either:
1. Passed the contract gate, or
2. Been explicitly waived by the user.

Hard gate for greenfield app setup:
Do not start Plan + Design contracts until Intake + Scaffold has:
1. Captured explicit stack decision record,
2. Confirmed optional libraries with the user,
3. Recorded safe path strategy, scaffold location, and scaffold command, and
4. Produced a complete handoff payload with `app_name`, `framework`, `language`, `package_manager`, `path_strategy`, `target_path`, `scaffold_command`, `optional_libraries_approved`, `optional_libraries_declined`, `post_scaffold_installs`, `merge_summary`, and `blockers`.

Blocker policy for greenfield handoff:
1. If scaffold blockers are still open, phase 0 is not passed.
2. Do not start phase 1 until blockers are resolved or explicitly waived by the user.

Waiver format:
The user must explicitly state they want to skip a gated phase. If no explicit waiver is present, continue through the default flow.

For each phase, return:

1. Goal
2. Actions taken
3. Evidence
4. Exit criteria status
5. Next phase handoff

Use [references/workflow.md](references/workflow.md) for phase details and exit criteria.
Write machine-readable status using [references/phase-status-schema.md](references/phase-status-schema.md).

Artifact location policy:
1. Canonical shared directory for phase-1 contract artifacts is `.orchestrator/contracts/`.
2. Write `.orchestrator/contracts/SPEC.md`, `.orchestrator/contracts/PLAN.md`, and `.orchestrator/contracts/DESIGN.md` unless the user explicitly requests a different shared location.
3. Record these full paths in phase status `artifacts`.

Phase 1 ownership model (non-negotiable):
1. `superpowers/brainstorming` owns `.orchestrator/contracts/SPEC.md` (problem, users, constraints, assumptions).
2. `superpowers/writing-plans` owns `.orchestrator/contracts/PLAN.md` (milestones with stable IDs: `M1`, `M2`, ... and acceptance criteria IDs: `AC1`, `AC2`, ...).
3. `.orchestrator/contracts/DESIGN.md` must have exactly one primary design authority. Choose from:
   - `ui-ux-pro-max` for open-ended direction and cross-domain design reasoning
   - `design-system` for token/component/system architecture
   - `ui-styling` for implementation-ready styling against an existing design/template
   - orchestrator normalization when the user supplies an authoritative design/template and no new design system should be invented
4. `brand` is an optional upstream input pass when identity, voice, or visual brand rules are still unsettled.
5. Do not allow co-authoring of one artifact by multiple skills. One owner per artifact.
6. Run a contract-check pass after artifact generation. If mappings are missing, run targeted repair prompts (max 2 retries).

Required contract checks after phase 1:
1. Every milestone in `.orchestrator/contracts/PLAN.md` has at least one mapped screen/component/design rule in `.orchestrator/contracts/DESIGN.md`.
2. Every design section in `.orchestrator/contracts/DESIGN.md` maps back to at least one `M#` milestone.
3. Acceptance criteria in `.orchestrator/contracts/PLAN.md` are testable and reflected in either implementation tasks or QA scenarios.
4. `.orchestrator/contracts/DESIGN.md` states the selected design mode or cites the existing design authority being preserved.
5. If any check fails, phase 1 is not passed.

Phase 1 design routing (non-negotiable):
1. If visual direction is open-ended or product/style choices are still ambiguous, use `ui-ux-pro-max`.
2. If the main need is tokens, component rules, CSS variables, or system architecture, use `design-system`.
3. If the user already has a specific design system, template, screenshots, or component library and mainly needs implementation-ready guidance, use `ui-styling`.
4. If identity, voice, or visual brand rules are still open, use `brand` as an input pass before selecting a single `.orchestrator/contracts/DESIGN.md` owner.
5. If the user supplies an authoritative existing design/template and explicitly wants it preserved, default to `design_alignment` mode. In that mode, `.orchestrator/contracts/DESIGN.md` must capture the design sources, immutable constraints, reusable components/templates, allowed deviations, and milestone mapping.
6. Do not generate a new visual system when the user explicitly wants to preserve an existing template/design system unless they ask for changes.
7. Always pass product/industry context and target stack/framework context when using a UI UX Pro Max family skill.
8. Persist design-system files by default when new design decisions are created (for example `design-system/MASTER.md` plus page overrides), and keep `.orchestrator/contracts/DESIGN.md` as machine-checkable phase output.

## Phase 0 Delegation

For greenfield setup, delegate phase 0 to `frontend-scaffold-intake`.

Delegation rules:
1. Prefer `frontend-scaffold-intake` for all intake/scaffold decisions and command execution.
2. Require these handoff payload fields before phase 1 starts: `app_name`, `framework`, `language`, `package_manager`, `path_strategy`, `target_path`, `scaffold_command`, `optional_libraries_approved`, `optional_libraries_declined`, `post_scaffold_installs`, `merge_summary`, `blockers`.
3. If the scaffold skill is unavailable, run equivalent tool-level fallback without skipping phase 0.
4. Keep package manager default as `pnpm` unless user explicitly overrides.
5. If fallback is used, normalize the output into the same handoff payload keys before moving to phase 1.

## Preferred Cross-Skill Targets

Use these concrete skill names when available:

1. Intake + Scaffold phase: `frontend-scaffold-intake` (fallback: OpenCode shell/tooling + user confirmation loop)
2. Plan + Design contract phase: `brainstorming`, `writing-plans`, then choose `ui-ux-pro-max`, `design-system`, or `ui-styling`; use `brand` when identity/voice is unresolved
3. Build phase: `executing-plans`, `systematic-debugging`, `test-driven-development` (Superpowers)
4. Exploratory QA phase: `agent-browser` (agent-browser)
5. Refine phase: `frontend-design`, `polish`, `audit` (Impeccable)
6. Regression phase: `playwright-cli` (Playwright CLI)
7. Release phase: `verification-before-completion` (Superpowers)

Skill criticality:
1. Required for baseline success: `frontend-scaffold-intake` (greenfield only), `brainstorming`, `writing-plans`, `playwright-cli`, `verification-before-completion`
2. Required phase-1 design authority: one selected design mode backed by `ui-ux-pro-max`, `design-system`, `ui-styling`, or authoritative existing-design alignment written into `.orchestrator/contracts/DESIGN.md`
3. Optional phase-1 input skill: `brand`
4. Optional quality enhancers: `agent-browser`, `frontend-design`, `polish`, `audit`

Fallback rule:
If a named skill is unavailable in the current environment, continue with the same phase objective using tool-level commands and equivalent process.
1. Do not skip core phases.
2. Optional phases may be marked `skipped` with an explicit reason in status JSON.

Deterministic fallback artifact format:
1. If skill output is free-form, normalize into `.orchestrator/contracts/SPEC.md`, `.orchestrator/contracts/PLAN.md`, and `.orchestrator/contracts/DESIGN.md` before moving phases.
2. Use explicit IDs (`M#`, `AC#`, `S#` for screens, `C#` for components) so later phases can validate mappings.

Phase timeout and retry policy:
1. Default timeout per phase should be explicit (recommended: 15 minutes for plan/design, 20 minutes for build/test).
2. Contract repair retries (phase 1): max 2.
3. Regression fix-and-rerun retries (phase 5): max 3.
4. Optional enhancer retries (phases 3-4): max 1 unless user asks for deeper iteration.
5. When retries are exhausted, record `stop_reason` and continue according to gate policy.

Project-scale Playwright fallback policy:
1. When phase 5 uses a project-local Playwright install and the browser is missing or the executable cannot be found, run `pnpm exec playwright install chromium` from the project workspace before retrying tests.
2. Treat this as the default repair step for pnpm-based projects instead of first rewriting Playwright to use `/usr/bin/chromium`.
3. Record the browser install command and rerun result in phase-5 evidence.

## Workflow Routing

Choose the first phase based on task type:

1. New app setup: start at phase 0
2. New feature in existing app: start at phase 1
3. Visual polish request: start at phase 4
4. Browser-only bug: start at phase 3
5. Regression or flaky behavior: start at phase 5
6. Release-readiness request: start at phase 6

When starting at phase 0, default next phase is phase 1.
When starting at phase 1, default next phase is phase 2 (Build) only after contract gate pass or explicit waiver.

Use [references/scenario-routing.md](references/scenario-routing.md) when the task is ambiguous.

## Prompting Pattern

When executing a phase, use the matching prompt template from
[references/prompt-templates.md](references/prompt-templates.md).

Never proceed to the next phase without summarizing:

1. What changed
2. What remains risky
3. Whether the phase gate passed

Self-evaluation loop (phases 3-5):
1. Run exploratory browser QA first (phase 3) and collect screenshots + behavior notes.
2. If phase 3 is skipped/unavailable, continue with phase 5 and use deterministic test evidence as baseline UX signal.
3. If issues are found, run refine pass (phase 4) with patch-level fixes.
4. Re-run exploratory QA once after refine when phase 3 is available.
5. Convert confirmed failures into deterministic regression tests (phase 5).
6. Limit auto-fix loops to 3 total iterations unless user requests deeper iteration.

Docker/browser execution guidance:
1. Prefer production-like run (`pnpm build` + `pnpm preview --host 0.0.0.0`) for evaluations.
2. Use fixed viewport(s), locale, timezone, and seeded data when possible.
3. Keep exploratory and regression browser state isolated.
4. For project-scoped Playwright runs, if Chromium is missing, install it inside the project with `pnpm exec playwright install chromium` before introducing browser-path overrides.

Machine-readable orchestration artifacts:
1. Store phase-1 contract artifacts at `.orchestrator/contracts/SPEC.md`, `.orchestrator/contracts/PLAN.md`, and `.orchestrator/contracts/DESIGN.md` by default.
2. Store per-phase status files at `.orchestrator/status/phase-<n>.json`.
3. Store latest rollup at `.orchestrator/status/run-summary.json`.
4. Do not mark phase complete until status JSON is written.

## Quality Gates

Apply gates at two levels:

1. Phase gate: each phase has required outputs and checks
2. Delivery gate: merge/release readiness checks before completion

Use [references/quality-gates.md](references/quality-gates.md) for complete checklists.

## Non-Negotiable Rules

1. Prefer small, reversible iterations over large rewrites.
2. Encode discovered bugs into deterministic tests when possible.
3. Keep design decisions explicit (tokens, spacing, typography, motion).
4. Call out uncertainty and assumptions immediately.
5. Isolate browser state between exploratory QA and regression testing (separate sessions/profiles/accounts).
6. Do not mark completion until all required gates are addressed or explicitly waived by the user.
7. Do not move from Plan + Design contracts to Build without a contract gate pass or explicit user waiver.
8. For greenfield setup, do not scaffold until stack + addon choices are confirmed and the path strategy/target path are explicit.
9. Use `pnpm` as the default package manager unless explicitly overridden by the user.
10. When using Superpowers in OpenCode, prefer namespaced loading (for example `superpowers/brainstorming`) when manually invoking skills.
11. Do not claim "design approved" unless phase 1 contract checks pass.
12. Prefer measurable evaluation rubrics over subjective wording when reporting UX quality.
13. Optional enhancer phases must never silently fail; they must end as `passed`, `skipped`, `waived`, or `failed` in status JSON.
14. Core required phases must end as `passed` or explicit `waived`; otherwise overall run is `not_ready`.
15. Do not claim greenfield intake is complete unless the phase 0 handoff payload is complete and blocker status is explicit.
16. If the user already has an authoritative design/template, preserve it by default and use phase 1 to document alignment instead of inventing a new visual system.
