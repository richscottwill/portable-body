# Eval Routing Workflow

This workflow pack is a public, vendor-neutral reference implementation of a hook-managed workflow pattern from the private operating layer. It is intentionally detailed enough to recreate on another machine while using fictional inputs and replaceable connector interfaces.

## Purpose

Route artifacts through independent evaluators and reader lenses before accepting, revising, or reverting changes.

## Connector interfaces

- `agent-dispatch`
- `filesystem`

## Phase map

| # | Phase |
|---|---|
| 1 | Artifact classification |
| 2 | Tier selection |
| 3 | Prompt-file creation |
| 4 | Blind evaluator dispatch |
| 5 | Score aggregation |
| 6 | Disagreement handling |
| 7 | KEEP/REVISE/REVERT verdict |

## Design rationale

Independent blind evals prevent the authoring agent from grading its own work; advisory adversarial review catches valid dissent without hard-blocking everything.

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
