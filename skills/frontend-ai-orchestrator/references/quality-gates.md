# Quality Gates

## Phase Gates

Phase status requirement (all phases):
1. Write status JSON for each phase to `.orchestrator/status/phase-<n>.json`
2. Use schema in `references/phase-status-schema.md`
3. Allowed status values: `passed`, `failed`, `skipped`, `waived`, `blocked`

### Intake + Scaffold gate
1. Stack decisions confirmed (framework, language, package manager, app name; default manager is pnpm unless overridden)
2. Path strategy is explicit (`workspace_root_via_temp`, `subfolder`, or other approved target strategy)
3. Scaffold command chosen from stack matrix and recorded
4. Optional libraries explicitly approved or declined
5. Optional-library-aware scaffold flags/modules are captured
6. Stack-aware addon defaults are acknowledged (for example Next router built-in, Nuxt module-first)
7. Non-empty workspace path strategy is respected or explicitly overridden by user
8. If workspace-root placement is requested in a non-empty workspace, temp staging and merge/conflict review are completed before copy-back
9. Scaffold completed or blocker captured with next action
10. Scaffold handoff payload is complete with `app_name`, `framework`, `language`, `package_manager`, `path_strategy`, `target_path`, `scaffold_command`, `optional_libraries_approved`, `optional_libraries_declined`, `post_scaffold_installs`, `merge_summary`, and `blockers`
11. Phase 1 does not begin while unresolved scaffold blockers remain unless explicitly waived by the user
12. Phase status JSON written

### Plan Contract + Design Contract / Alignment gate
1. Spec clarified and explicitly approved
2. `.orchestrator/contracts/SPEC.md`, `.orchestrator/contracts/PLAN.md`, and `.orchestrator/contracts/DESIGN.md` artifacts exist
3. Milestones defined with stable IDs (`M#`)
4. Acceptance criteria measurable (with explicit IDs, for example `AC#`)
5. Risks and assumptions listed
6. Selected design mode is documented
7. Tokens are documented when created or explicitly inherited from an existing design authority
8. Direction selected, defaulted, or preserved from the existing design source
9. Accessibility concerns addressed
10. Design rules mapped to milestones
11. Existing template/design constraints are captured when provided
12. Industry + stack-specific guidance is explicitly captured when a UI UX Pro Max family skill is used
13. Anti-patterns and pre-delivery checklist are documented when new design decisions are created
14. Contract check passes: every milestone has design mapping and every major design section maps to milestones
15. Phase status JSON written

### Build gate
1. Plan Contract + Design Contract gate passed or explicitly waived by the user
2. Milestone implemented
3. Verification evidence captured
4. No blocking defects left hidden
5. Phase status JSON written

### Exploratory QA gate
1. Critical scenarios executed
2. Browser issues reproducible
3. Evidence captured
4. Dedicated exploratory session/profile/account used
5. Visual/UX scorecard captured (at minimum: hierarchy, spacing, contrast, consistency, responsiveness, feedback states)
6. Phase status JSON written

Optional handling for Exploratory QA:
1. If `agent-browser` is unavailable, phase may be `skipped` with reason `skill_unavailable`
2. If execution times out, phase may be `skipped` with reason `timeout`
3. `skipped` exploratory QA does not fail baseline delivery by default

### Refine gate
1. High-priority UX issues addressed
2. Interaction states consistent
3. Copy and feedback clarity improved
4. Changes tie back to exploratory QA findings
5. Exploratory re-check done when UI-affecting changes were made
6. Phase status JSON written

Optional handling for Refine:
1. If no meaningful UX issues are found, phase may be `skipped` with reason `no_findings`
2. If refine skills are unavailable, phase may be `skipped` with reason `skill_unavailable`
3. `skipped` refine does not fail baseline delivery by default

### Regression gate
1. Critical test suite passes
2. New regressions encoded into tests
3. Flaky areas documented
4. Regression tests run with isolated/clean state
5. Phase status JSON written

### Release gate
1. Coverage summary complete
2. Remaining risks explicit
3. Go/no-go recommendation stated
4. Rollup run summary written

Core vs optional pass policy:
1. Core phases (`0` when greenfield, `1`, `2`, `5`, `6`) must be `passed` or explicit `waived`
2. Optional phases (`3`, `4`) may be `passed`, `skipped`, or `waived`
3. Any core phase `failed` or `blocked` means overall run status is `not_ready`

## Delivery Checklist

1. Requirements coverage confirmed
2. Scaffold + addon choices documented (for greenfield work)
3. Visual/UX polish reviewed
4. Accessibility concerns acknowledged
5. Critical browser flows tested
6. Deterministic regression tests run
7. Known limitations documented
8. Browser-state isolation between QA and regression confirmed
9. Rollback or hotfix path stated
10. Auto-fix loop count and stopping reason recorded when autonomous mode is used
11. Run summary JSON captures per-phase status and final recommendation
