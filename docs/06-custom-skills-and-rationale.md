# Custom Skills And Rationale

This repository does not only install upstream skills. It also adds two manual custom skills that make the workflow more usable for a real frontend team.

## Custom Skill 1: `frontend-ai-orchestrator`

Purpose:

- act as the top-level controller for frontend delivery
- standardize the phase order
- make core steps hard to skip accidentally
- reduce prompt repetition
- generate machine-readable status artifacts

Main benefit:

Instead of manually remembering when to call planning, design, exploratory QA, regression, and release verification, the team can start from one entry point and let the workflow route itself.

Why it was needed:

- upstream skills are specialists, not an opinionated team workflow
- different contributors can otherwise skip different phases
- greenfield and existing-app work need different entry logic
- the team wanted consistent artifacts such as `.orchestrator/contracts/SPEC.md`, `.orchestrator/contracts/PLAN.md`, `.orchestrator/contracts/DESIGN.md`, and `.orchestrator/status/*.json`

## Custom Skill 2: `frontend-scaffold-intake`

Purpose:

- handle greenfield intake safely before planning
- confirm stack, language, package manager, and optional libraries
- choose a safe scaffold target path
- run scaffold commands using repo conventions
- produce a clean handoff payload for the orchestrator

Main benefit:

It prevents messy project bootstrapping. The workflow does not jump into planning or implementation until the stack decision and scaffold path are explicit.

Why it was needed:

- starter commands differ a lot by framework
- addon choices change the right scaffold path
- new apps should not be scaffolded into `.` by default
- this repo prefers `pnpm`, uses `apps/<project-name>` as the safe isolated default, and uses temp staging plus copy-back when root placement in a non-empty workspace is explicitly requested

## Why These Two Skills Work Well Together

`frontend-scaffold-intake` solves the beginning of the workflow.

`frontend-ai-orchestrator` solves the rest of the delivery lifecycle.

Together they turn a loose collection of specialist skills into a team process.

## Why Use OpenCode For This Stack

OpenCode is the harness that ties the workflow together:

- it is the execution environment the team actually uses
- it can coordinate the installed skill set
- it works well as the main coding driver while specialist skills contribute where they are strongest

## Why Dockerize OpenCode Instead Of Installing Everything Locally

Short version:

- more reproducible
- easier onboarding
- less local machine drift
- easier to pin or swap versions
- safer isolation for browser tooling and global skill config

Repository-specific benefits:

- one shared Chromium binary is reused by both Playwright CLI and agent-browser
- the image seeds OpenCode config and skills so new environments start from the same baseline
- Python is present for UI UX Pro Max helper scripts
- `pnpm` is already enabled, which matches the scaffold workflow
- the smoke check validates the whole toolchain before teammates start using it

## Brief Team Pitch

If you need a short explanation for teammates:

1. The upstream skills are excellent specialists.
2. The manual custom skills turn them into one repeatable frontend delivery system.
3. Docker makes that system consistent and easy to reproduce across machines.

## Related Docs

- [04-using-orchestrator.md](./04-using-orchestrator.md)
- [05-using-individual-skills.md](./05-using-individual-skills.md)
