---
name: frontend-scaffold-intake
description: "Run greenfield frontend intake + scaffold safely: confirm stack/addons, choose path strategy, use temp staging for risky root merges, run stack-aware scaffold commands, and produce a handoff record for planning."
---

# Frontend Scaffold Intake

## Overview

Use this skill for greenfield app setup before planning/design.

Primary goals:
1. Capture explicit stack decisions.
2. Scaffold into a safe target path.
3. Install only approved addons.
4. Produce a clean handoff record for downstream phases.

## Execution Contract

Run this order:
1. Intake decision capture
2. Target path strategy decision
3. Scaffold command selection
4. Optional library confirmation
5. Scaffold execution
6. Conflict/merge validation when temp staging is used
7. Post-scaffold addon installation
8. Handoff summary

For each run, return:
1. Goal
2. Actions taken
3. Evidence
4. Exit criteria status
5. Handoff payload

## Intake Checklist

Confirm before scaffolding:
1. Project name
2. Framework + build tool
3. Language variant (`ts` or `js`)
4. Package manager (default: `pnpm`)
5. Optional libraries:
   - Tailwind CSS
   - Router
   - State management
   - UI component library
   - Form + validation library
   - Testing setup

## Path Strategy

When workspace is non-empty:
1. Do not scaffold directly into `.` by default.
2. If the user explicitly wants the current workspace root, scaffold into a temp directory first.
3. Run a merge/conflict check before copying staged files back into the workspace.
4. Copy staged files into the workspace root only when conflicts are absent or explicitly approved.
5. If root merge is risky or unresolved, fall back to `apps/<project-name>` or another explicit target path.
6. Use a direct subfolder target when the user wants an isolated app folder or the staged root-merge plan is not approved.

## Scaffold Command Matrix

1. Vue + Vite (`js`): `pnpm create vite@latest <app-name> --template vue`
2. Vue + Vite (`ts`): `pnpm create vite@latest <app-name> --template vue-ts`
3. React + Vite (`js`): `pnpm create vite@latest <app-name> --template react`
4. React + Vite (`ts`): `pnpm create vite@latest <app-name> --template react-ts`
5. Svelte + Vite (`js`): `pnpm create vite@latest <app-name> --template svelte`
6. Svelte + Vite (`ts`): `pnpm create vite@latest <app-name> --template svelte-ts`
7. Next.js (`interactive defaults`): `pnpm create next-app@latest <app-name> --yes`
8. Next.js (`ts` explicit): `pnpm create next-app@latest <app-name> --ts --yes`
9. Next.js (`js` explicit): `pnpm create next-app@latest <app-name> --js --yes`
10. Nuxt (`interactive/default`): `pnpm create nuxt@latest <app-name> --packageManager pnpm`
11. Astro (`interactive/default`): `pnpm create astro@latest <app-name>`
12. Angular (`interactive/default`): `pnpm dlx @angular/cli@latest new <app-name> --package-manager pnpm`
13. Laravel + starter kit (`interactive kit selection`): `laravel new <app-name>`
14. Laravel frontend deps after scaffold: `cd <app-name> && pnpm install && pnpm run build`
15. Laravel installer fallback: `composer create-project laravel/laravel <app-name>`
16. Vue feature-rich preset: `pnpm create vue@latest <app-name> -- --help` then apply selected flags
17. SvelteKit (`sv` CLI): `pnpm dlx sv create <app-name> --template minimal --types ts --no-add-ons --install pnpm`

## Stack-Aware Addon Rules

1. Next.js:
   - Ask for Tailwind/linter/biome choices.
   - Do not ask for separate router package by default.
2. Nuxt:
   - Prefer Nuxt modules (`@nuxt/ui`, `@nuxtjs/tailwindcss`, `@pinia/nuxt`).
3. Vite (React/Vue/Svelte):
   - Ask router/state/testing choices explicitly.
4. Angular:
   - Ask whether routing/SSR/strict defaults should be kept.
5. Laravel starter kits:
   - Confirm selected kit and whether to keep kit defaults.

## Addon-Aware Scaffold Construction

1. Next.js:
   - Include `--tailwind` or `--no-tailwind`.
   - Include linter choice (`--eslint`, `--biome`, or `--no-linter`).
   - Include language choice (`--ts` or `--js`).
2. Nuxt:
   - Prefer module-aware setup during/after scaffold.
3. Vue:
   - If router/pinia/testing/linting requested during scaffold, prefer `create-vue`.
4. Vite templates:
   - Keep scaffold minimal and install requested libraries after scaffold.

Default package manager policy:
1. Use `pnpm` by default.
2. Install optional libraries only after explicit user confirmation.
3. Respect user override for other package managers.

## Exit Criteria

1. Stack and template are explicitly confirmed.
2. Optional library choices are explicitly confirmed.
3. Path strategy and target path are explicit and safe.
4. If temp staging is used, merge/conflict status is explicit before files are copied into the workspace.
5. Scaffold completes, or blocker + next fix action is recorded.
6. Handoff payload is complete.

## Handoff Payload (Required)

Return these fields for orchestrators/manual flows:
1. `app_name`
2. `framework`
3. `language`
4. `package_manager`
5. `path_strategy`
6. `target_path`
7. `scaffold_command`
8. `optional_libraries_approved`
9. `optional_libraries_declined`
10. `post_scaffold_installs`
11. `merge_summary`
12. `blockers` (if any)
