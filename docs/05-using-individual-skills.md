# Using Individual Skills

This page is for cases where you do not want the full orchestrator flow and prefer to call the specialist skills more directly.

The inventory below was checked against the upstream source repositories on April 9, 2026.

## Quick Recommendation

If the team asks which skill is the single most useful entry point for frontend work in this repository, the answer is:

- `frontend-ai-orchestrator` for end-to-end delivery

If the team asks which specialist skill family is the most useful for frontend quality specifically, the answer is:

- UI UX Pro Max

If the team asks which skill is most important before release, the answer is:

- `playwright-cli`

## Important Packaging Note

The upstream sources do not all package capabilities the same way:

- Superpowers is a multi-skill library.
- UI UX Pro Max is a multi-skill family.
- agent-browser is a multi-skill family.
- Playwright CLI is a single skill.
- For this repository, Impeccable should be documented from its OpenCode skill directory only.

That means the most accurate way to document this repository is:

- list UI UX Pro Max and agent-browser by their upstream skill folders
- list Playwright CLI as one skill
- list Impeccable by its actual installable OpenCode skill directories

There is also an environment-compatibility wrinkle:

- plain OpenCode and OMO-enabled OpenCode may not expose every upstream skill under the exact same slash-command name
- plugin-backed skills can be installed and still be surfaced differently from local directory skills
- for that reason, the orchestrator should rely on contract outputs and phase behavior more than one exact command label

## Inventory Summary

| Source | Inventory type | Count |
|---|---|---|
| Local custom skills | Skills | 2 |
| Superpowers | Skills | 14 |
| UI UX Pro Max | Skills | 7 |
| Playwright CLI | Skills | 1 |
| agent-browser | Skills | 6 |
| Impeccable | OpenCode skills | 21 |

Total documented skills from all sources used here: `51`

## Local Custom Skills

These are the manually created skills that make this repository workflow-specific rather than just a loose bundle of upstream tools.

| Skill | What it is used for | Best time to use | FE value |
|---|---|---|---|
| `frontend-ai-orchestrator` | Routes the whole workflow and applies phase gates | Default entry point for most frontend work | Highest overall leverage |
| `frontend-scaffold-intake` | Safe greenfield intake and scaffold | Before planning a new app | High for greenfield |

## Superpowers Skill Library

Superpowers is the process backbone in this setup.

| Skill | Category | What it is used for |
|---|---|---|
| `brainstorming` | Collaboration | Refine rough ideas, scope, assumptions, and tradeoffs |
| `dispatching-parallel-agents` | Collaboration | Coordinate concurrent agent work |
| `executing-plans` | Collaboration | Implement from a plan in controlled batches |
| `finishing-a-development-branch` | Collaboration | Close out a branch with merge or PR decisions |
| `receiving-code-review` | Collaboration | Process review feedback constructively and systematically |
| `requesting-code-review` | Collaboration | Review work against plan and quality expectations |
| `subagent-driven-development` | Collaboration | Execute planned work with staged review loops |
| `systematic-debugging` | Debugging | Run a root-cause-oriented debugging process |
| `test-driven-development` | Testing | Enforce red-green-refactor behavior |
| `using-git-worktrees` | Collaboration | Create isolated workspaces and verify a clean baseline |
| `using-superpowers` | Meta | Learn how to operate the Superpowers system |
| `verification-before-completion` | Debugging | Force evidence before claiming success |
| `writing-plans` | Collaboration | Break work into explicit milestones and verification steps |
| `writing-skills` | Meta | Create or improve skills using Superpowers conventions |

## UI UX Pro Max Skill Family

UI UX Pro Max is not just one skill. The upstream skill directory currently exposes 7 skills:

| Skill | What it is used for |
|---|---|
| `banner-design` | Banner and hero asset design across social, ads, web, and print |
| `brand` | Brand voice, visual identity, messaging, asset management, and consistency |
| `design-system` | Token architecture, component specs, CSS variables, and systematic design |
| `design` | Unified design workflow for brand, tokens, UI, logo, CIP, slides, banners, social photos, and icons |
| `slides` | Strategic HTML presentations with layout patterns and Chart.js |
| `ui-styling` | shadcn/ui, Tailwind CSS, accessible UI composition, theming, and responsive styling |
| `ui-ux-pro-max` | General design intelligence across product types, styles, palettes, typography, UX rules, and stacks |

Most useful UI UX Pro Max skills for frontend work in this repo:

1. `ui-ux-pro-max`
2. `design-system`
3. `ui-styling`
4. `brand`

How to think about them in the orchestrator:

1. `ui-ux-pro-max` is the default when product direction and visual choices are still open.
2. `design-system` is the best fit when tokens, components, CSS variables, and reusable rules need to be formalized.
3. `ui-styling` is the best fit when the design already exists and the hard part is translating it into implementation details.
4. `brand` is useful when voice or identity is still underdefined, but it is usually an input pass rather than the main phase-1 owner.
5. `design`, `banner-design`, and `slides` are more situational and are not strong defaults for the orchestrator.

## Playwright CLI

Playwright CLI remains a single specialist skill in this setup.

| Skill | What it is used for |
|---|---|
| `playwright-cli` | Deterministic browser automation, snapshots, tracing, test generation, storage state work, and debugging |

Why it matters:

- it is the most trustworthy release gate in the stack
- it converts flaky manual findings into repeatable checks

## agent-browser Skill Family

agent-browser is also not just one skill. The upstream `skills/` directory currently exposes 6 skills:

| Skill | What it is used for |
|---|---|
| `agent-browser` | General browser automation for websites and web apps |
| `agentcore` | Run agent-browser on AWS Bedrock AgentCore cloud browsers |
| `dogfood` | Systematic exploratory QA with screenshots, repro videos, and structured reports |
| `electron` | Automate Electron desktop apps via CDP |
| `slack` | Interact with Slack workspaces using browser automation |
| `vercel-sandbox` | Run agent-browser inside Vercel Sandbox microVMs |

Most relevant agent-browser skills for this repo's frontend workflow:

1. `agent-browser`
2. `dogfood`
3. `electron`

## Impeccable OpenCode Skills

For this repository, the only Impeccable view that matters is the upstream OpenCode directory:

- <https://github.com/pbakaus/impeccable/tree/main/.opencode/skills>

The upstream `.opencode/skills` directory currently exposes 21 skills:

| Skill | Focus |
|---|---|
| `adapt` | Adapt designs for different devices or contexts |
| `animate` | Add purposeful motion |
| `arrange` | Improve layout, spacing, and visual rhythm |
| `audit` | Technical quality checks |
| `bolder` | Make flat designs more expressive |
| `clarify` | Improve unclear UX copy |
| `colorize` | Introduce strategic color |
| `critique` | UX design review |
| `delight` | Add moments of joy or surprise |
| `distill` | Strip the design to its essence |
| `extract` | Pull patterns into reusable components |
| `frontend-design` | Base frontend design skill foundation |
| `harden` | Improve robustness, edge cases, and i18n/error handling |
| `normalize` | Align implementation with design-system standards |
| `onboard` | Improve onboarding-flow design |
| `optimize` | Performance improvements |
| `overdrive` | Add technically ambitious effects |
| `polish` | Final pass before shipping |
| `quieter` | Tone down overly loud design |
| `teach-impeccable` | Setup and design-context teaching |
| `typeset` | Improve typography choices and hierarchy |

Most useful Impeccable skills for frontend work in this repo:

1. `audit`
2. `polish`
3. `critique`
4. `arrange`
5. `typeset`

## Practical Manual Sequences

### Sequence A: Manual Feature Workflow

1. `superpowers/brainstorming` or the closest planning/spec workflow exposed in your environment
2. `superpowers/writing-plans` or the closest plan-authoring workflow exposed in your environment
3. `ui-ux-pro-max`, `design-system`, or `ui-styling`
4. implement with OpenCode
5. `playwright-cli`
6. `superpowers/verification-before-completion` or an equivalent evidence-first verification pass

### Sequence B: Manual Browser Bug Workflow

1. `agent-browser` or `dogfood`
2. implement fix
3. `playwright-cli`
4. `superpowers/verification-before-completion`

### Sequence C: Manual Design Polish Workflow

1. `ui-ux-pro-max`, `design-system`, or `ui-styling`
2. implement design corrections
3. `audit`
4. `polish`
5. `playwright-cli`

## Most Useful Skills For FE Development

If the team wants a shorter shortlist:

1. `frontend-ai-orchestrator` for end-to-end flow control
2. `ui-ux-pro-max` for broad design intelligence
3. `design-system` for token and system thinking
4. `ui-styling` for implementation-ready UI guidance
5. `playwright-cli` for trustworthy release checks
6. `agent-browser` for exploratory QA and screenshots
7. `dogfood` for structured browser-based product review
8. `audit` and `polish` for final design-quality passes
9. `superpowers/verification-before-completion` or an equivalent evidence-first verification pass for honest final checks

## Practical Guidance

1. Use individual skills when you want direct phase-level control.
2. Use the orchestrator when you want the system to route the phases for you.
3. Add references when calling UI UX Pro Max or Impeccable. This noticeably reduces generic AI output.
4. Use `dogfood` or `agent-browser` when you need screenshots, repro evidence, or exploratory QA.
5. Use `playwright-cli` when you need repeatable proof.

## Upstream Sources

- <https://github.com/obra/superpowers/tree/main/skills>
- <https://github.com/nextlevelbuilder/ui-ux-pro-max-skill/tree/main/.claude/skills>
- <https://github.com/pbakaus/impeccable/tree/main/.opencode/skills>
- <https://github.com/microsoft/playwright-cli/tree/main/skills/playwright-cli>
- <https://github.com/vercel-labs/agent-browser/tree/main/skills>
