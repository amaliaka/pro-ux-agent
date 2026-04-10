# Docker Usage

This page covers the day-to-day Docker patterns for this repository after the image has already been built.

## Why Docker Is The Default Here

This repository intentionally runs OpenCode and the skill stack inside a container because the workflow depends on more than just one CLI:

- OpenCode plus several skill bundles
- Engram persistent memory for OpenCode
- Playwright CLI
- agent-browser
- a shared Chromium runtime
- Python for UI UX Pro Max helper scripts
- seeded OpenCode config and skills

Containerizing the stack keeps those dependencies consistent for the whole team.

## Daily Shell Usage

Run the container against a local project folder:

```bash
docker run --rm -it \
  --entrypoint bash \
  -v "$(pwd)/your-project:/workspace" \
  -w /workspace \
  opencode-with-skills
```

Then run:

```bash
opencode
```

## Run OpenCode Web

```bash
docker run --rm -it \
  -p 3010:3010 \
  -v "$(pwd)/your-project:/workspace" \
  -w /workspace \
  opencode-with-skills \
  web --hostname 0.0.0.0 --port 3010 --print-logs
```

Open:

```text
http://localhost:3010
```

If `3010` is already used, change both host and container port:

```bash
docker run --rm -it \
  -p 3110:3110 \
  -v "$(pwd)/your-project:/workspace" \
  -w /workspace \
  opencode-with-skills \
  web --hostname 0.0.0.0 --port 3110 --print-logs
```

## Rebuild Patterns

Verbose rebuild:

```bash
docker build --no-cache --progress=plain -t opencode-with-skills .
```

Faster iterative rebuild without smoke checks:

```bash
docker build --build-arg RUN_SMOKE_CHECK=0 -t opencode-with-skills .
```

## Host Persistence Patterns

Persist OpenCode config:

```bash
-v "$HOME/.opencode-config:/root/.config/opencode"
```

Persist agent-browser state:

```bash
-v "$HOME/.agent-browser:/root/.agent-browser"
```

Persist Engram memory:

```bash
-v "$HOME/.engram:/root/.engram"
```

Combined example:

```bash
docker run --rm -it \
  --entrypoint bash \
  -v "$(pwd)/your-project:/workspace" \
  -v "$HOME/.engram:/root/.engram" \
  -v "$HOME/.agent-browser:/root/.agent-browser" \
  -w /workspace \
  opencode-with-skills
```

## Useful Container Commands

Seed bundled skills into an empty mounted config:

```bash
ensure-opencode-skills
```

Validate runtime:

```bash
smoke-opencode-toolchain
```

Test Engram directly:

```bash
engram version
engram serve >/tmp/engram.log 2>&1 &
sleep 1
curl http://127.0.0.1:7437/health
engram save "Docker usage engram test"
engram search "Docker usage engram test"
```

Reset agent-browser daemon after changing browser settings:

```bash
agent-browser close
```

## Practical Team Notes

- The image uses one shared system Chromium for both Playwright CLI and agent-browser.
- Engram data lives in `/root/.engram`, so mount that path if you want memory to persist.
- `PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1` avoids duplicated Playwright browser bundles in the image.
- `pnpm` is enabled by default, which matches the scaffold behavior in the custom skills.
- The image seeds OpenCode skills, plugins, and config so new containers do not need to reinstall the whole stack every time.

## Related Docs

- [01-setup.md](./01-setup.md)
- [06-custom-skills-and-rationale.md](./06-custom-skills-and-rationale.md)
