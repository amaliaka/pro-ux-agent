# Using The Orchestrator

The preferred top-level skill in this repository is `frontend-ai-orchestrator`.

Its job is not to replace the specialist skills. Its job is to route them in the correct order, apply team rules, and keep the workflow from skipping critical phases.

## What The Orchestrator Solves

Without an orchestrator, a frontend workflow usually depends on the user remembering:

- when to scaffold
- when to plan before coding
- when to switch from design generation to implementation
- when to use exploratory QA versus deterministic regression
- when a task is actually ready to call complete

`frontend-ai-orchestrator` packages those decisions into one repeatable flow.

## Core Phase Model

| Phase | Purpose | Main skills |
|---|---|---|
| 0 | Intake and scaffold for greenfield apps | `frontend-scaffold-intake` |
| 1 | Plan contract and design contract/alignment | `brainstorming`, `writing-plans`, plus `ui-ux-pro-max`, `design-system`, or `ui-styling` depending on design mode |
| 2 | Build milestone by milestone | OpenCode plus Superpowers execution skills |
| 3 | Exploratory browser QA | `agent-browser` |
| 4 | UI/UX refinement | Impeccable commands such as `audit` and `polish` |
| 5 | Deterministic regression | `playwright-cli` |
| 6 | Final verification and release signal | `verification-before-completion` |

Core required phases:

- 0 for greenfield only
- 1
- 2
- 5
- 6

Optional enhancer phases:

- 3
- 4

## What Happens Automatically

When you start with the orchestrator:

- greenfield work is routed to `frontend-scaffold-intake` first
- plan and design are gated before build
- existing templates or design systems are preserved through a design-alignment contract instead of forcing net-new design generation
- optional QA and refinement are handled as enhancer phases instead of blocking baseline delivery
- regression and final verification stay mandatory unless you explicitly waive them
- if project-local Playwright is missing Chromium during regression, the orchestrator should repair it with `pnpm exec playwright install chromium` before falling back to browser-path overrides
- phase-1 contract artifacts are written to `.orchestrator/contracts/` and status artifacts are written to `.orchestrator/status/`
- machine-readable status artifacts are written under `.orchestrator/status/`

## Important Clarification

Yes, the orchestrator helps you use the skill stack without manually naming every underlying skill each time.

That said, prompt quality still matters. If the first prompt is vague, the orchestrator will still need to ask more questions. If the first prompt already includes stack, style, scope, and references, the workflow becomes much faster.

## Phase 1 Design Modes

The orchestrator should not treat every design task the same.

- Use `ui-ux-pro-max` when the visual direction is still open-ended.
- Use `design-system` when the main need is tokens, components, and reusable rules.
- Use `ui-styling` when a design/template already exists and implementation guidance is the main need.
- Use `brand` only when identity or voice is still unsettled.
- If the user already has an authoritative design or template, phase 1 should produce `.orchestrator/contracts/DESIGN.md` as an alignment artifact and may skip a UI UX Pro Max family call.

## Recommended Prompt Pattern

For a new app:

```text
Use frontend-ai-orchestrator for a new frontend project.
Stack: Next.js + TypeScript
Package manager: pnpm
Path preference: current workspace root
Style: modern B2B SaaS, clean but not generic
Need: dashboard, auth, settings
Optional libraries I want: Tailwind, shadcn/ui, React Hook Form, Zod, Playwright
References: <links or screenshots>
```

For a new feature in an existing app:

```text
Use frontend-ai-orchestrator for a new feature in the existing app.
Feature: improve onboarding flow for first-time users
Constraints: keep current design system, mobile-first, must preserve analytics events
Existing design authority: <figma/template/design system>
References: <links or screenshots>
```

For a browser bug:

```text
Use frontend-ai-orchestrator starting from browser QA / regression flow.
Problem: the modal closes unexpectedly after validation error on Safari-width viewports
App URL: <url>
Need screenshots, reproduction steps, fix, and Playwright coverage
```

## Why It Is Good For Teams

- fewer skipped steps
- less prompt repetition
- more consistent artifacts across contributors
- easier handoff because phase outputs are explicit
- clearer go or no-go status at the end

## Best Practices

1. Put stack, design direction, and constraints in the first prompt.
2. If you already have a design system or template, say that explicitly so phase 1 uses alignment mode instead of generating a new style direction.
3. Use the orchestrator by default for greenfield or multi-phase work.
4. Switch to individual skills only when you want phase-level control.
5. Keep tasks well-scoped. Fewer, well-batched tasks can reduce repeated review loops, but the right size still depends on team preference and risk tolerance.

## Orchestration Artifacts

The custom orchestrator writes machine-readable state:

- `.orchestrator/status/phase-0.json`
- `.orchestrator/status/phase-1.json`
- `.orchestrator/status/phase-2.json`
- `.orchestrator/status/phase-3.json`
- `.orchestrator/status/phase-4.json`
- `.orchestrator/status/phase-5.json`
- `.orchestrator/status/phase-6.json`
- `.orchestrator/status/run-summary.json`

These are useful when you want:

- a shared progress model
- automation around phase status
- easy review of what passed, skipped, failed, or was waived

## When Not To Use It

You can skip the orchestrator when:

- you only want one specialist skill for a narrow task
- you are experimenting with a very custom workflow
- you already know exactly which phase you want to run manually

## Related Docs

- [03-scenarios-and-flows.md](./03-scenarios-and-flows.md)
- [05-using-individual-skills.md](./05-using-individual-skills.md)
- [06-custom-skills-and-rationale.md](./06-custom-skills-and-rationale.md)
