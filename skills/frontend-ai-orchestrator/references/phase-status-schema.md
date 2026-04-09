# Phase Status Schema

Use this schema for `.orchestrator/status/phase-<n>.json` and `run-summary.json`.

## Required Fields

1. `run_id` (string): stable ID for the end-to-end run
2. `phase` (number): phase index (`0`..`6`)
3. `phase_name` (string)
4. `criticality` (string): `core` or `optional`
5. `status` (string): `passed`, `failed`, `skipped`, `waived`, or `blocked`
6. `gate_passed` (boolean)
7. `failed_checks` (array of strings)
8. `artifacts` (array of strings): output file paths. Use canonical run artifact paths (for example `.orchestrator/contracts/SPEC.md`, `.orchestrator/contracts/PLAN.md`, `.orchestrator/contracts/DESIGN.md` unless the workflow explicitly chose a different shared location)
9. `evidence` (array of strings): logs, screenshots, test reports
10. `next_action` (object):
    - `type` (`continue`, `repair`, `retry`, `stop`, `handoff`)
    - `target_phase` (number or `null`)
    - `reason` (string)
11. `loop` (object):
    - `iteration` (number)
    - `max_iterations` (number)
    - `stop_reason` (string or `null`)
12. `timing` (object):
    - `started_at` (ISO-8601 string)
    - `ended_at` (ISO-8601 string)
    - `duration_ms` (number)
    - `timeout_ms` (number)
13. `notes` (array of strings)

## Example: Passed Core Phase

```json
{
  "run_id": "todo-webapp-20260408-113045",
  "phase": 1,
  "phase_name": "Plan Contract + Design Contract",
  "criticality": "core",
  "status": "passed",
  "gate_passed": true,
  "failed_checks": [],
  "artifacts": [
    ".orchestrator/contracts/SPEC.md",
    ".orchestrator/contracts/PLAN.md",
    ".orchestrator/contracts/DESIGN.md"
  ],
  "evidence": [
    "logs/phase-1-contract-check.log"
  ],
  "next_action": {
    "type": "continue",
    "target_phase": 2,
    "reason": "Contract checks passed"
  },
  "loop": {
    "iteration": 1,
    "max_iterations": 2,
    "stop_reason": null
  },
  "timing": {
    "started_at": "2026-04-08T11:30:45Z",
    "ended_at": "2026-04-08T11:35:20Z",
    "duration_ms": 275000,
    "timeout_ms": 900000
  },
  "notes": [
    "All milestones mapped to design rules"
  ]
}
```

## Example: Skipped Optional Phase

```json
{
  "run_id": "todo-webapp-20260408-113045",
  "phase": 3,
  "phase_name": "Exploratory QA",
  "criticality": "optional",
  "status": "skipped",
  "gate_passed": false,
  "failed_checks": [
    "agent_browser_not_available"
  ],
  "artifacts": [],
  "evidence": [
    "logs/phase-3-skill-availability.log"
  ],
  "next_action": {
    "type": "continue",
    "target_phase": 5,
    "reason": "Optional phase skipped by policy"
  },
  "loop": {
    "iteration": 1,
    "max_iterations": 1,
    "stop_reason": "skill_unavailable"
  },
  "timing": {
    "started_at": "2026-04-08T11:40:00Z",
    "ended_at": "2026-04-08T11:40:03Z",
    "duration_ms": 3000,
    "timeout_ms": 300000
  },
  "notes": [
    "Proceeding with deterministic regression baseline"
  ]
}
```

## Run Summary Shape

`run-summary.json` should contain:
1. `run_id`
2. `overall_status` (`ready` or `not_ready`)
3. `phase_statuses` (array of per-phase file paths)
4. `core_phase_results` (object keyed by phase number)
5. `optional_phase_results` (object keyed by phase number)
6. `release_recommendation` (`go` or `no-go`)
7. `top_risks` (array of strings)
8. `supervisor_update` (short human-readable summary)
