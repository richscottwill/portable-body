# Karpathy Compression / Curriculum Workflow

This workflow pack is a public, vendor-neutral reference implementation of a hook-managed workflow pattern from the private operating layer. It is intentionally detailed enough to recreate on another machine while using fictional inputs and replaceable connector interfaces.

## Purpose

Evolve body/protocol files through controlled compression or refactor experiments that must pass structural checks and blind evals.

## Connector interfaces

- `agent-dispatch`
- `filesystem`
- `local-analytics optional`

## Phase map

| # | Phase |
|---|---|
| 1 | Candidate selection |
| 2 | Experiment prompt |
| 3 | Structural validity check |
| 4 | Blind eval route |
| 5 | Score comparison |
| 6 | Keep/revert |
| 7 | Learning log and cooldown |

## Design rationale

Randomized target selection avoids only optimizing obvious sections; structural validity gates prevent prose-quality evals from accepting broken config or hooks.

## Files in this pack

| File | Use |
|---|---|
| `protocol.md` | Step-by-step execution contract. |
| `capabilities.json` | Machine-readable capability requirements. |
| `runtime-capabilities.md` | Human-readable capability and platform notes. |
| `degradation-matrix.md` | What each runtime should produce when capabilities are missing. |
| `state-schema.example.json` | Run record and state-file examples. |
| `failure-modes.md` | Known failures and recovery branches. |
| `example-input/trigger-example.md` | Fictional trigger/input surface. |
| `example-output/run-report-example.md` | Fictional successful/degraded output. |

## Public/private boundary

This pack keeps workflow mechanics, ordering rationale, connector categories, and failure handling. It omits real people, organizations, private projects, IDs, URLs, credentials, and live metrics.
