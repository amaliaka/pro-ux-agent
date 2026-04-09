# OpenCode Docker + Skills

This image extends `ghcr.io/anomalyco/opencode` and preinstalls:

- superpower skills (`obra/superpowers`)
- ui ux pro max skills (`nextlevelbuilder/ui-ux-pro-max-skill`)
- impeccable skills (`pbakaus/impeccable`)
- playwright cli skills (`microsoft/playwright-cli`)
- agent-browser skills (`vercel-labs/agent-browser`)
- root orchestration skill (`frontend-ai-orchestrator`)
- dedicated scaffold intake skill (`frontend-scaffold-intake`)

Superpowers is configured using the official OpenCode plugin method in global config (`~/.config/opencode/opencode.json`) instead of manual skill copying.
UI UX Pro Max uses the official `uipro-cli` install flow (`uipro init --ai opencode`) and is then installed into global OpenCode skills.

The image now uses a multi-stage build:
- builder stage installs and prepares all skills/config
- final stage keeps only runtime requirements and seeded skills

The final image installs one shared system Chromium (`/usr/bin/chromium`) and both Playwright + agent-browser reuse it.
`PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1` is enabled, so Playwright browser bundles are not downloaded during build.
`AGENT_BROWSER_ARGS=--no-sandbox,--disable-dev-shm-usage` is set as a Docker-safe default.
`python3` is kept in the final image because UI UX Pro Max requires it for its search script.
`pnpm` is enabled in both builder and final stages and is the default package manager for scaffolded app workflows.

## Build

```bash
docker build -t opencode-with-skills .
```

For reproducible builds, pin refs/versions (replace `main`/`latest` with specific tags or commit SHAs):

```bash
docker build -t opencode-with-skills \
  --build-arg OPENCODE_IMAGE=ghcr.io/anomalyco/opencode:latest \
  --build-arg SUPERPOWERS_REF=main \
  --build-arg UI_UX_PRO_MAX_REF=main \
  --build-arg IMPECCABLE_REF=main \
  --build-arg PLAYWRIGHT_CLI_REF=main \
  --build-arg AGENT_BROWSER_REF=main \
  --build-arg PLAYWRIGHT_CLI_VERSION=latest \
  --build-arg PLAYWRIGHT_VERSION=latest \
  --build-arg PLAYWRIGHT_BROWSER_CHANNEL=chromium \
  --build-arg AGENT_BROWSER_VERSION=latest \
  --build-arg RUN_SMOKE_CHECK=1 \
  .
```

Browser runtime is essential. The build will fail if a shared Chromium executable cannot be resolved.

If build fails, retry with verbose logs first:

```bash
docker build --no-cache --progress=plain -t opencode-with-skills .
```

Skip smoke checks for faster iterative builds:

```bash
docker build --build-arg RUN_SMOKE_CHECK=0 -t opencode-with-skills .
```

## Run (mount your own project directory)

Mount a local folder into `/workspace` in the container:

```bash
docker run --rm -it \
  --entrypoint bash \
  -v "$(pwd)/your-project:/workspace" \
  -w /workspace \
  opencode-with-skills
```

Inside the container, run OpenCode from that mounted project:

```bash
opencode
```

## Run OpenCode Web (host 0.0.0.0, port 3010)

Expose only port `3010` and run the web server on `0.0.0.0`:

```bash
docker run --rm -it \
  -p 3010:3010 \
  -v "$(pwd)/your-project:/workspace" \
  -w /workspace \
  opencode-with-skills \
  web --hostname 0.0.0.0 --port 3010 --print-logs
```

Then open: `http://localhost:3010`

If startup fails with `port is already allocated`, pick another free host port and match it in both places:

```bash
docker run --rm -it \
  -p 3110:3110 \
  -v "$(pwd)/your-project:/workspace" \
  -w /workspace \
  opencode-with-skills \
  web --hostname 0.0.0.0 --port 3110 --print-logs
```

## Persist OpenCode config and skills on host (optional)

By default, personal skills/config are in `/root/.config/opencode` in the container.
Bind-mount a host directory if you want them to persist across runs:

```bash
mkdir -p ~/.opencode-config

docker run --rm -it \
  --entrypoint bash \
  -v "$(pwd)/your-project:/workspace" \
  -v "$HOME/.opencode-config:/root/.config/opencode" \
  -w /workspace \
  opencode-with-skills
```

If this is a new/empty host config folder, seed bundled skills once:

```bash
ensure-opencode-skills
```

## Persist agent-browser state on host (optional)

`agent-browser` stores sessions and state in `~/.agent-browser` by default.
Bind-mount it if you want browser state to persist:

```bash
mkdir -p ~/.agent-browser

docker run --rm -it \
  --entrypoint bash \
  -v "$(pwd)/your-project:/workspace" \
  -v "$HOME/.opencode-config:/root/.config/opencode" \
  -v "$HOME/.agent-browser:/root/.agent-browser" \
  -w /workspace \
  opencode-with-skills
```

If you change browser executable env vars or update runtime settings, close any running daemon first:

```bash
agent-browser close
```

This avoids an upstream issue where a running daemon may ignore a newly set `AGENT_BROWSER_EXECUTABLE_PATH`.

## Re-seed skills manually (optional)

```bash
ensure-opencode-skills
```

## Smoke check (optional)

Validate the toolchain and shared-browser wiring:

```bash
smoke-opencode-toolchain
```

## Documentation

For the team-facing documentation set, see:

- [docs/README.md](/Users/amaliaka/Work/Devops/pro-ux-agent/docs/README.md)
- [docs/01-setup.md](/Users/amaliaka/Work/Devops/pro-ux-agent/docs/01-setup.md)
- [docs/02-docker-usage.md](/Users/amaliaka/Work/Devops/pro-ux-agent/docs/02-docker-usage.md)
- [docs/03-scenarios-and-flows.md](/Users/amaliaka/Work/Devops/pro-ux-agent/docs/03-scenarios-and-flows.md)
- [docs/04-using-orchestrator.md](/Users/amaliaka/Work/Devops/pro-ux-agent/docs/04-using-orchestrator.md)
- [docs/05-using-individual-skills.md](/Users/amaliaka/Work/Devops/pro-ux-agent/docs/05-using-individual-skills.md)
- [docs/06-custom-skills-and-rationale.md](/Users/amaliaka/Work/Devops/pro-ux-agent/docs/06-custom-skills-and-rationale.md)

## Skill Usage Guide

For scenarios, prompt examples, and an end-to-end workflow that uses all installed tools/skills together, see:

- [frontend-ai-playbook.md](/Users/amaliaka/Work/Devops/pro-ux-agent/frontend-ai-playbook.md)

Root skill source in this repo:

- [skills/frontend-ai-orchestrator/SKILL.md](/Users/amaliaka/Work/Devops/pro-ux-agent/skills/frontend-ai-orchestrator/SKILL.md)
- [skills/frontend-scaffold-intake/SKILL.md](/Users/amaliaka/Work/Devops/pro-ux-agent/skills/frontend-scaffold-intake/SKILL.md)

### Orchestrator Behavior (important)

`frontend-ai-orchestrator` now includes a required `Intake + Scaffold` phase for greenfield apps, delegated to `frontend-scaffold-intake`:

1. Confirms stack first (framework, language, package manager, app name)
2. Asks for optional libraries (Tailwind, router, state, UI library, forms, testing)
3. Scaffolds with the matching starter command
4. Uses `pnpm` as default package manager unless user explicitly requests another one
5. In non-empty repositories, defaults scaffold path to `apps/<project-name>` unless root placement is explicitly requested
6. If root placement is explicitly requested in a non-empty repository, scaffolds in a temp directory first and copies back only after merge/conflict review
7. Applies optional-library choices in scaffold flags/modules when supported by the stack

Example mapping:

- Vue + Vite (`js`): `pnpm create vite@latest my-vue-app --template vue`
- Vue + Vite (`ts`): `pnpm create vite@latest my-vue-app --template vue-ts`
- Vue with built-in feature flags: `pnpm create vue@latest my-vue-app -- --help` (then choose `--typescript`, `--router`, `--pinia`, etc.)
- Next.js: `pnpm create next-app@latest my-app --yes`
- Nuxt: `pnpm create nuxt@latest my-app --packageManager pnpm`
- Astro: `pnpm create astro@latest my-app`
- Angular: `pnpm dlx @angular/cli@latest new my-app --package-manager pnpm`
- SvelteKit: `pnpm dlx sv create my-app --template minimal --types ts --no-add-ons --install pnpm`
- Laravel starter kit: `laravel new my-app`

This happens before `Plan + Design -> Build` unless you explicitly waive phases.

Behavior alignment note:

1. Superpowers flow is treated as spec-first (`brainstorming`) then plan (`writing-plans`) before build.
2. Phase 1 design routing now chooses between `ui-ux-pro-max`, `design-system`, `ui-styling`, or existing-design alignment depending on what the user already has.
3. If the user already has an authoritative design/template, the orchestrator should preserve it and write `.orchestrator/contracts/DESIGN.md` as an alignment contract instead of inventing a new design system.
4. UI UX Pro Max family input should include explicit product/industry + target stack so its reasoning engine and stack-specific guidance are applied.
