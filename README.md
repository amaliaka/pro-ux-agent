# pro-ux-agent

`pro-ux-agent` is a Dockerized OpenCode environment for frontend delivery. It packages OpenCode together with a curated skill stack, browser tooling, persistent memory support, and custom orchestration skills so teammates can start from the same working setup instead of recreating local environments by hand.

The repository is designed for teams that want a repeatable workflow for planning, scaffolding, building, reviewing, and validating frontend work with AI assistance.

## Highlights

- One containerized environment for OpenCode, browser tooling, memory, and frontend workflow skills
- Faster teammate onboarding with a reproducible Docker-first setup
- Shared Chromium runtime for both Playwright CLI and agent-browser
- Repo-owned orchestration skills for safer scaffolding and more consistent execution
- Built-in smoke checks for validating the environment after build

## Features

- Dockerized OpenCode runtime based on `ghcr.io/anomalyco/opencode`
- Preinstalled AI skill stack for planning, design, implementation, and refinement
- Engram integration with seeded OpenCode plugin and MCP configuration
- `pnpm` enabled as the default package manager for scaffolded workflows
- Multi-stage image build to keep the final runtime leaner
- Optional persistence for OpenCode config, Engram memory, and agent-browser state
- Support for interactive CLI use and OpenCode web mode

## Project Introduction

This project extends `ghcr.io/anomalyco/opencode` and preinstalls the tools and skills used by this workflow:

- Engram persistent memory for OpenCode
- Superpowers skills
- UI UX Pro Max skills
- Impeccable skills
- Playwright CLI skills
- agent-browser skills
- `frontend-ai-orchestrator`
- `frontend-scaffold-intake`

It also standardizes a few important runtime choices:

- Multi-stage Docker build for a smaller final image
- One shared Chromium runtime for Playwright and agent-browser
- `pnpm` enabled in both builder and final stages
- Engram plugin and MCP configuration seeded into OpenCode config
- Docker-safe browser defaults for container usage

## Why This Repo Exists

- Reduce setup drift across teammates and machines
- Provide a predictable entry point for frontend tasks
- Bundle planning, design, implementation, and browser validation tools together
- Preserve workflow rules through repo-owned custom skills instead of relying only on upstream defaults

## Installation

### Prerequisites

- Docker installed locally
- A local project directory to mount into `/workspace`

### Build The Image

```bash
docker build -t pro-ux-agent .
```

For more reproducible builds, pin refs and versions instead of using `main` or `latest`:

```bash
docker build -t pro-ux-agent \
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

If you need a verbose rebuild:

```bash
docker build --no-cache --progress=plain -t pro-ux-agent .
```

If you want a faster iterative build and are okay skipping smoke checks:

```bash
docker build --build-arg RUN_SMOKE_CHECK=0 -t pro-ux-agent .
```

Browser runtime is required. The build will fail if a shared Chromium executable cannot be resolved.

## Optional OMO Variant

If you want to experiment with `oh-my-openagent` without making the default image heavier or more opinionated, this repository now includes a separate optional variant in [Dockerfile.omo](./Dockerfile.omo).

This is intended for advanced users who want to try:

- multi-model sub-agent delegation
- background-agent workflows
- extra harness features such as built-in MCPs, hooks, and richer agent controls

Build the optional glibc-based variant directly:

```bash
docker build -f Dockerfile.omo -t pro-ux-agent-omo \
  --build-arg OMO_CLAUDE=no \
  --build-arg OMO_OPENAI=no \
  --build-arg OMO_GEMINI=no \
  --build-arg OMO_COPILOT=no \
  .
```

Run it like the standard image:

```bash
docker run -it \
  --entrypoint bash \
  -v "$(pwd)/your-project:/workspace" \
  -w /workspace \
  pro-ux-agent-omo
```

Notes:

- Keep `pro-ux-agent` as the recommended default image.
- Treat `pro-ux-agent-omo` as experimental until the team is happy with its cost, complexity, and reliability tradeoffs.
- Upstream still documents the installer package as `oh-my-opencode` even though the repo is now named `oh-my-openagent`.
- `Dockerfile.omo` is intentionally glibc-based and separate from the main Alpine image because `oh-my-openagent` depends on GNU libc Linux binaries.
- The current OMO CLI uses `--openai`, not `--chatgpt`, for OpenAI/ChatGPT subscription setup.
- The OMO install runs during image build with the provided subscription flags, and provider authentication still happens at runtime.
- Auth and provider setup still happen at runtime after the image is built.

## Quick Start

### Start An Interactive Shell

```bash
docker run -it \
  --entrypoint bash \
  -v "$(pwd)/your-project:/workspace" \
  -w /workspace \
  pro-ux-agent
```

Inside the container:

```bash
opencode
```

### Run OpenCode Web

```bash
docker run -it \
  -p 3010:3010 \
  -v "$(pwd)/your-project:/workspace" \
  -w /workspace \
  pro-ux-agent \
  web --hostname 0.0.0.0 --port 3010 --print-logs
```

Open `http://localhost:3010`.

If port `3010` is already in use:

```bash
docker run -it \
  -p 3110:3110 \
  -v "$(pwd)/your-project:/workspace" \
  -w /workspace \
  pro-ux-agent \
  web --hostname 0.0.0.0 --port 3110 --print-logs
```

## Persistence

By default, OpenCode config, Engram memory, and agent-browser state live inside the container filesystem. Bind-mount host directories if you want them to survive rebuilds and restarts.

### Persist OpenCode Config

```bash
mkdir -p ~/.opencode-config

docker run -it \
  --entrypoint bash \
  -v "$(pwd)/your-project:/workspace" \
  -v "$HOME/.opencode-config:/root/.config/opencode" \
  -w /workspace \
  pro-ux-agent
```

If the mounted config directory is empty, seed the bundled assets once:

```bash
ensure-opencode-skills
```

### Persist Engram Memory

```bash
mkdir -p ~/.engram

docker run -it \
  --entrypoint bash \
  -v "$(pwd)/your-project:/workspace" \
  -v "$HOME/.engram:/root/.engram" \
  -w /workspace \
  pro-ux-agent
```

### Persist agent-browser State

```bash
mkdir -p ~/.agent-browser

docker run -it \
  --entrypoint bash \
  -v "$(pwd)/your-project:/workspace" \
  -v "$HOME/.agent-browser:/root/.agent-browser" \
  -w /workspace \
  pro-ux-agent
```

If browser runtime settings change, restart the daemon:

```bash
agent-browser close
```

## Verification

Run the built-in smoke test to validate the runtime, shared browser setup, and Engram wiring:

```bash
smoke-opencode-toolchain
```

For a direct Engram sanity check inside the container:

```bash
engram version
engram serve >/tmp/engram.log 2>&1 &
sleep 1
curl http://127.0.0.1:7437/health
engram save "Docker container engram test memory"
engram search "Docker container engram test"
```

## Workflow Overview

The preferred entry point for frontend work is `frontend-ai-orchestrator`. For greenfield apps, it delegates the intake and scaffolding phase to `frontend-scaffold-intake` before moving into planning, design, implementation, and verification.

At a high level, the workflow favors:

- Confirming stack and scaffold choices before generating app code
- Using `pnpm` by default unless the user explicitly requests another package manager
- Preserving existing design systems when a project already has an authoritative UI direction
- Combining exploratory browser checks, refinement, and deterministic validation before completion

For the full workflow details and examples, use the docs linked below.

## Documentation

- [docs/README.md (Document Map)](./docs/README.md#document-map)
- [docs/01-setup.md](./docs/01-setup.md)
- [docs/02-docker-usage.md](./docs/02-docker-usage.md)
- [docs/03-scenarios-and-flows.md](./docs/03-scenarios-and-flows.md)
- [docs/04-using-orchestrator.md](./docs/04-using-orchestrator.md)
- [docs/05-using-individual-skills.md](./docs/05-using-individual-skills.md)
- [docs/06-custom-skills-and-rationale.md](./docs/06-custom-skills-and-rationale.md)
- [docs/07-omo-variant.md](./docs/07-omo-variant.md)

## Skill References

- [frontend-ai-playbook.md](./frontend-ai-playbook.md)
- [skills/frontend-ai-orchestrator/SKILL.md](./skills/frontend-ai-orchestrator/SKILL.md)
- [skills/frontend-scaffold-intake/SKILL.md](./skills/frontend-scaffold-intake/SKILL.md)
