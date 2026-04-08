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

Require output from delegated skill:
1) stack decisions
2) scaffold command used
3) addon decisions
4) scaffold/install evidence
5) handoff payload fields

If scaffold skill is unavailable, run equivalent fallback without skipping phase 0.

Return:
1) confirmed stack decisions
2) scaffold command used
3) addon decisions (approved/declined)
4) scaffold/install evidence
5) handoff into Plan + Design Contracts phase
6) phase status JSON path
```

## 1) Plan Contract + Design Contract Template

```text
Use combined superpowers + ui-ux-pro-max workflow for this frontend task.
Preferred skills: brainstorming, writing-plans, ui-ux-pro-max.
Task: <feature/request>
Constraints: <stack/timeline/requirements>
Product/Industry: <product-type or domain>
Target stack: <react|next|vue|nuxt|svelte|astro|angular|laravel|swiftui|jetpack-compose|react-native|flutter|html-tailwind|shadcn>

Run sequence:
1) superpowers brainstorming -> output SPEC.md
2) superpowers writing-plans -> output PLAN.md (milestone IDs M1..Mn, acceptance IDs AC1..ACn)
3) ui-ux-pro-max design-system pass -> output DESIGN.md (tokens, style rules, mapping keyed by M#)
4) contract-check pass:
   - every M# in PLAN.md has a mapping in DESIGN.md
   - every major design section maps to at least one M#
   - acceptance criteria are measurable and represented in implementation or QA strategy
5) if contract-check fails, run targeted repair prompt for missing mappings only (max 2 retries)

Return:
1) SPEC.md summary
2) PLAN.md summary
3) DESIGN.md summary
4) contract-check result (pass/fail + missing items if fail)
5) technical and UX risks
6) verification strategy
7) next-phase handoff to Build (or explicit user waiver reason)
8) phase status JSON path
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
