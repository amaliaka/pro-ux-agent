# Prompt Templates

## Shared Requirement (All Phases)

```text
After each phase, write `.orchestrator/status/phase-<n>.json` using `references/phase-status-schema.md`.
Include:
1) status (`passed|failed|skipped|waived|blocked`)
2) gate_passed (true/false)
3) failed_checks (if any)
4) next_action
5) artifacts and evidence paths
```

## 0) Intake + Scaffold Template

```text
Delegate phase 0 to `frontend-scaffold-intake`.
Pass user context:
1) app name
2) framework + build tool
3) language (js/ts)
4) package manager (default: pnpm)
5) optional library preferences
6) path preference (current workspace root vs isolated app folder)

Require output from delegated skill:
1) stack decisions
2) path strategy decision
3) scaffold command used
4) addon decisions
5) scaffold/install evidence
6) handoff payload fields:
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
7) explicit blocker status and next action if scaffold is incomplete
8) if non-empty workspace root placement is requested, use temp staging first and report merge/conflict results before copying files back

If scaffold skill is unavailable, run equivalent fallback without skipping phase 0.
Normalize fallback output into the same handoff payload keys before continuing.

Return:
1) confirmed stack decisions
2) scaffold command used
3) addon decisions (approved/declined)
4) scaffold/install evidence
5) exact handoff payload object
6) whether blockers prevent phase 1 start
7) handoff into Plan + Design Contracts phase
8) phase status JSON path
```

## 1) Plan Contract + Design Contract Template

```text
Use combined Superpowers + selected design-authority workflow for this frontend task.
Preferred skills: brainstorming, writing-plans, then choose from ui-ux-pro-max, design-system, or ui-styling. Use brand only when identity/voice is unresolved.
Task: <feature/request>
Constraints: <stack/timeline/requirements>
Product/Industry: <product-type or domain>
Target stack: <react|next|vue|nuxt|svelte|astro|angular|laravel|swiftui|jetpack-compose|react-native|flutter|html-tailwind|shadcn>
Existing design authority: <figma/template/design system/screenshots/component library or none>
Write phase-1 contract artifacts to:
- `.orchestrator/contracts/SPEC.md`
- `.orchestrator/contracts/PLAN.md`
- `.orchestrator/contracts/DESIGN.md`

Run sequence:
1) superpowers brainstorming -> output `.orchestrator/contracts/SPEC.md`
2) superpowers writing-plans -> output `.orchestrator/contracts/PLAN.md` (milestone IDs M1..Mn, acceptance IDs AC1..ACn)
3) choose design mode:
   - net_new_direction -> ui-ux-pro-max
   - design_system -> design-system
   - implementation_styling -> ui-styling
   - design_alignment -> preserve the existing design/template and write `.orchestrator/contracts/DESIGN.md` from it
   - optional brand input if identity rules are missing
4) if the user already has an authoritative design/template, do not invent a new visual system by default. Write `.orchestrator/contracts/DESIGN.md` as an alignment contract with:
   - design sources
   - immutable constraints
   - reusable components/templates
   - allowed deviations
   - milestone mappings
5) otherwise, generate `.orchestrator/contracts/DESIGN.md` using the selected UI UX Pro Max family skill
6) contract-check pass:
   - every M# in `.orchestrator/contracts/PLAN.md` has a mapping in `.orchestrator/contracts/DESIGN.md`
   - every major design section maps to at least one M#
   - acceptance criteria are measurable and represented in implementation or QA strategy
   - `.orchestrator/contracts/DESIGN.md` states the selected design mode or existing design authority
7) if contract-check fails, run targeted repair prompt for missing mappings only (max 2 retries)

Return:
1) `.orchestrator/contracts/SPEC.md` summary
2) `.orchestrator/contracts/PLAN.md` summary
3) `.orchestrator/contracts/DESIGN.md` summary
4) selected design mode and why it was chosen
5) contract-check result (pass/fail + missing items if fail)
6) technical and UX risks
7) verification strategy
8) next-phase handoff to Build (or explicit user waiver reason)
9) phase status JSON path
```

## 2) Build Template

```text
Implement the next milestone from the approved plan.
Preferred skills: executing-plans, systematic-debugging, test-driven-development.
Precondition: Plan + Design contract gate passed, or user explicitly waived this gate.
Use superpowers execution discipline:
- small, verifiable steps
- progress checklist
- assumptions and risks logged

Output:
1) what changed
2) what is verified
3) what remains
4) phase status JSON path
```

## 3) Exploratory QA Template

```text
Use agent-browser for exploratory QA on <url>.
Preferred skill: agent-browser.
Use a dedicated exploratory session/profile/account and document it.
If `agent-browser` is unavailable or execution times out, mark phase as `skipped` and continue to phase 5.
Scenarios:
1) happy path
2) invalid input paths
3) empty/error states

Return:
1) steps executed
2) observed behavior
3) reproducible bugs
4) command snippets used
5) exploratory session/profile/account identifier
6) screenshot evidence list
7) UX scorecard (hierarchy, spacing, contrast, consistency, responsiveness, feedback states; score 1-5 each)
8) phase status JSON path
```

## 4) Refinement Template

```text
Run an impeccable-style UI/UX refinement pass on:
Preferred skills: frontend-design, polish, audit.
- <page/route/component list>

If no meaningful UX issues exist, mark phase `skipped` with reason `no_findings`.

Input evidence:
1) phase 3 screenshots
2) phase 3 reproducible issues
3) phase 3 UX scorecard

Focus on:
1) hierarchy and readability
2) spacing rhythm and visual balance
3) contrast and accessibility
4) interaction feedback states
5) clarity of copy

Return prioritized issues, concrete patch recommendations, and a re-check checklist for phase 3.
Also return phase status JSON path.
```

## 5) Regression Template

```text
Use playwright-cli to verify:
Preferred skill: playwright-cli.
Use a clean or dedicated regression session/account (do not reuse exploratory state).
1) auth/login path
2) main conversion path
3) settings/profile path

If the project uses project-local Playwright and Chromium is missing or the executable cannot be found:
1) run `pnpm exec playwright install chromium` from the project workspace
2) rerun the regression command
3) record the repair command and rerun result
4) prefer this over first pointing Playwright at `/usr/bin/chromium`

For each failure:
1) fix
2) add or update automated coverage
3) rerun until stable
4) report regression session/account used

Loop budget:
- max 3 fix-and-rerun loops unless user asks for deeper iteration.

Return:
1) test outcomes and failures fixed
2) updated coverage list
3) remaining gaps
4) phase status JSON path
```

## 6) Release Verification Template

```text
Use superpowers verification-before-completion workflow.
Preferred skill: verification-before-completion.

Report:
1) requirement coverage
2) UX quality baseline
3) test results summary
4) known limitations
5) release recommendation (go/no-go)
6) phase status JSON path
7) run summary path (`.orchestrator/status/run-summary.json`)
8) supervisor update (5 lines max: what shipped, quality signal, remaining risk, blocker/none, next step)
```
