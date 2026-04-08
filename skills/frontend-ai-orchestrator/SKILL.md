---
name: frontend-ai-orchestrator
description: "Orchestrate end-to-end frontend delivery with a reliable core path (Superpowers + UI UX Pro Max + Playwright) plus optional quality enhancers (agent-browser, Impeccable). Delegates greenfield intake/scaffolding to a dedicated scaffold skill, then runs contract-based planning/design, implementation, regression testing, and release verification with machine-readable phase gates."
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
1. Plan Contract (Superpowers) + Design Contract (UI UX Pro Max)
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
1. Captured stack decision record, and
2. Confirmed optional libraries with the user.

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

Phase 1 ownership model (non-negotiable):
1. `superpowers/brainstorming` owns `SPEC.md` (problem, users, constraints, assumptions).
2. `superpowers/writing-plans` owns `PLAN.md` (milestones with stable IDs: `M1`, `M2`, ... and acceptance criteria IDs: `AC1`, `AC2`, ...).
3. `ui-ux-pro-max` owns `DESIGN.md` (design tokens, layout/component rules, and milestone mapping keyed by the same `M#` IDs).
4. Do not allow co-authoring of one artifact by multiple skills. One owner per artifact.
5. Run a contract-check pass after artifact generation. If mappings are missing, run targeted repair prompts (max 2 retries).

Required contract checks after phase 1:
1. Every milestone in `PLAN.md` has at least one mapped screen/component/design rule in `DESIGN.md`.
2. Every design section in `DESIGN.md` maps back to at least one `M#` milestone.
3. Acceptance criteria in `PLAN.md` are testable and reflected in either implementation tasks or QA scenarios.
4. If any check fails, phase 1 is not passed.

UI UX Pro Max compatibility inside phase 1:
1. Always pass product/industry context (for reasoning-rule matching).
2. Always pass target stack/framework context (for stack-specific guidance).
3. Request a full design-system output: pattern, style, colors, typography, key effects, anti-patterns, and pre-delivery checklist.
4. Persist design-system files by default (for example `design-system/MASTER.md` plus page overrides) and keep `DESIGN.md` as machine-checkable phase output.

## Phase 0 Delegation

For greenfield setup, delegate phase 0 to `frontend-scaffold-intake`.

Delegation rules:
1. Prefer `frontend-scaffold-intake` for all intake/scaffold decisions and command execution.
2. Require handoff payload fields from that skill before phase 1 starts.
3. If the scaffold skill is unavailable, run equivalent tool-level fallback without skipping phase 0.
4. Keep package manager default as `pnpm` unless user explicitly overrides.

## Preferred Cross-Skill Targets

Use these concrete skill names when available:

1. Intake + Scaffold phase: `frontend-scaffold-intake` (fallback: OpenCode shell/tooling + user confirmation loop)
2. Plan + Design contract phase: `brainstorming`, `writing-plans`, `ui-ux-pro-max`
3. Build phase: `executing-plans`, `systematic-debugging`, `test-driven-development` (Superpowers)
4. Exploratory QA phase: `agent-browser` (agent-browser)
5. Refine phase: `frontend-design`, `polish`, `audit` (Impeccable)
6. Regression phase: `playwright-cli` (Playwright CLI)
7. Release phase: `verification-before-completion` (Superpowers)

Skill criticality:
1. Required for baseline success: `frontend-scaffold-intake` (greenfield only), `brainstorming`, `writing-plans`, `ui-ux-pro-max`, `playwright-cli`, `verification-before-completion`
2. Optional quality enhancers: `agent-browser`, `frontend-design`, `polish`, `audit`

Fallback rule:
If a named skill is unavailable in the current environment, continue with the same phase objective using tool-level commands and equivalent process.
1. Do not skip core phases.
2. Optional phases may be marked `skipped` with an explicit reason in status JSON.

Deterministic fallback artifact format:
1. If skill output is free-form, normalize into `SPEC.md`, `PLAN.md`, and `DESIGN.md` sections before moving phases.
2. Use explicit IDs (`M#`, `AC#`, `S#` for screens, `C#` for components) so later phases can validate mappings.

Phase timeout and retry policy:
1. Default timeout per phase should be explicit (recommended: 15 minutes for plan/design, 20 minutes for build/test).
2. Contract repair retries (phase 1): max 2.
3. Regression fix-and-rerun retries (phase 5): max 3.
4. Optional enhancer retries (phases 3-4): max 1 unless user asks for deeper iteration.
5. When retries are exhausted, record `stop_reason` and continue according to gate policy.

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

Machine-readable orchestration artifacts:
1. Store per-phase status files at `.orchestrator/status/phase-<n>.json`.
2. Store latest rollup at `.orchestrator/status/run-summary.json`.
3. Do not mark phase complete until status JSON is written.

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
8. For greenfield setup, do not scaffold until stack + addon choices are confirmed.
9. Use `pnpm` as the default package manager unless explicitly overridden by the user.
10. When using Superpowers in OpenCode, prefer namespaced loading (for example `superpowers/brainstorming`) when manually invoking skills.
11. Do not claim "design approved" unless phase 1 contract checks pass.
12. Prefer measurable evaluation rubrics over subjective wording when reporting UX quality.
13. Optional enhancer phases must never silently fail; they must end as `passed`, `skipped`, `waived`, or `failed` in status JSON.
14. Core required phases must end as `passed` or explicit `waived`; otherwise overall run is `not_ready`.
