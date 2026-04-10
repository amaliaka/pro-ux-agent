# Setup

This page is the quickest path to get a teammate from zero to a working OpenCode environment with the same skill bundle used in this repository.

## Prerequisites

- Docker installed locally
- access to this repository
- a local project folder you want to mount into the container

## 1. Build The Image

From the repository root:

```bash
docker build -t pro-ux-agent .
```

If you want more reproducible builds, pin the refs and versions:

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
  --build-arg AGENT_BROWSER_VERSION=latest \
  .
```

## 2. Start A Shell In The Container

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

## 3. Run A Smoke Check

This image ships with a smoke test that validates the core runtime, including Engram:

```bash
smoke-opencode-toolchain
```

It checks:

- OpenCode is available
- Engram is installed
- the Engram OpenCode plugin is present
- the OpenCode config includes the `mcp.engram` server entry
- Node, npm, and Python are present
- Playwright CLI is installed
- agent-browser is installed
- both browser tools point at the same Chromium executable

## 4. Persist Skills, Config, And Memory Across Runs

If you want your OpenCode config to survive container restarts:

```bash
mkdir -p ~/.opencode-config
mkdir -p ~/.engram

docker run -it \
  --entrypoint bash \
  -v "$(pwd)/your-project:/workspace" \
  -v "$HOME/.engram:/root/.engram" \
  -w /workspace \
  pro-ux-agent
```

If the mounted config folder is empty, seed the bundled OpenCode assets once:

```bash
ensure-opencode-skills
```

Engram stores persistent memory in `/root/.engram`, so mounting `$HOME/.engram` keeps memory across container rebuilds and restarts.

## 5. Verify Engram Inside The Container

Run this after starting a shell in the container:

```bash
engram version
engram serve >/tmp/engram.log 2>&1 &
sleep 1
curl http://127.0.0.1:7437/health
engram save "Docker setup engram test"
engram search "Docker setup engram test"
```

If you plan to use OpenCode with persisted memory, keep `/root/.config/opencode` and `/root/.engram` mounted together.

## 6. Persist agent-browser State If Needed

This is helpful when you want browser sessions or agent-browser state across runs:

```bash
mkdir -p ~/.agent-browser

docker run -it \
  --entrypoint bash \
  -v "$(pwd)/your-project:/workspace" \
  -v "$HOME/.opencode-config:/root/.config/opencode" \
  -v "$HOME/.agent-browser:/root/.agent-browser" \
  -w /workspace \
  pro-ux-agent
```

If runtime settings change, close the daemon first:

```bash
agent-browser close
```

## First-Day Recommendation

After the environment is up:

1. start with [04-using-orchestrator.md](./04-using-orchestrator.md)
2. use the orchestrator for the first task instead of invoking each skill manually
3. only switch to manual skill usage when you want tighter control over a specific phase

## Related Docs

- [02-docker-usage.md](./02-docker-usage.md)
- [05-using-individual-skills.md](./05-using-individual-skills.md)
