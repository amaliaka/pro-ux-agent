# Optional OMO Variant

This page documents the optional `oh-my-openagent` variant for this repository.

It exists for one reason: some teams may want to experiment with richer agent orchestration and cheaper sub-agent routing without making the default `pro-ux-agent` image heavier or more complex for everyone else.

## Recommendation

- Default path: `pro-ux-agent`
- Optional experimental path: `pro-ux-agent-omo`

Keep the default image as the team standard unless the optional variant proves its value in real usage.

## Why The Variant Is Separate

`oh-my-openagent` adds another opinionated harness layer on top of OpenCode. That can be useful, but it also increases:

- image size
- configuration surface area
- overlap with the repo's existing frontend orchestrator
- cognitive load for teammates who only need the standard frontend workflow

Separating it keeps the core project simple while still allowing experimentation.

## What The Variant Is Good For

- trying multi-model sub-agent delegation
- routing simple subtasks to cheaper or faster models
- experimenting with background-agent workflows
- evaluating built-in MCPs, hooks, and extra harness features before wider adoption

## What It Is Not For

- replacing the default image immediately
- becoming mandatory for the team before it is evaluated
- mixing advanced harness behavior into the default workflow without explicit buy-in

## Build

Build the optional glibc-based variant:

```bash
docker build -f Dockerfile.omo -t pro-ux-agent-omo \
  --build-arg OMO_CLAUDE=no \
  --build-arg OMO_OPENAI=no \
  --build-arg OMO_GEMINI=no \
  --build-arg OMO_COPILOT=no \
  .
```

The OMO installer runs during the image build using the supplied subscription flags.

Then run the container:

```bash
docker run --rm -it \
  --entrypoint bash \
  -v "$(pwd)/your-project:/workspace" \
  -w /workspace \
  pro-ux-agent-omo
```

Supported build-arg values:

- `OMO_CLAUDE=no|yes|max20`
- `OMO_OPENAI=no|yes`
- `OMO_GEMINI=no|yes`
- `OMO_COPILOT=no|yes`

The installer package name remains `oh-my-opencode` in upstream installation docs even after the repository rename to `oh-my-openagent`.
The current CLI uses `--openai` as the flag name for OpenAI/ChatGPT access.

## Runtime Notes

- Provider authentication still needs to be completed at runtime.
- The OMO image is intentionally glibc-based and separate from the main Alpine image.
- The existing `ensure-opencode-skills` seed flow preserves extra top-level OpenCode config files, including OMO-related user config files seeded during build.
- The repo's custom frontend orchestrator still exists; `omo` is an additional layer, not a replacement.

## Current Compatibility Limitation

The default `pro-ux-agent` image uses Alpine Linux with musl libc.

`oh-my-openagent` is blocked in that Alpine image because one of its dependencies, `@ast-grep/cli`, only publishes GNU libc Linux binaries and no musl variants. That is why `Dockerfile.omo` uses a separate Debian/glibc base instead of extending the main image.

Practical result:

- the main image stays lean and stable
- the OMO image remains opt-in and experimental
- the two images can evolve independently without forcing OMO complexity onto the default workflow

## Suggested Evaluation Criteria

Measure the optional variant against the default image on real tasks:

- total token or provider cost
- task completion time
- rework caused by weak sub-agent outputs
- teammate onboarding friction
- debugging difficulty when something goes wrong

If the variant lowers cost without making the workflow harder to trust, keep iterating. If it mostly adds confusion, keep it opt-in only.
