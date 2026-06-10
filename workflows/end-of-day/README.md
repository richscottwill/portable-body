# End-of-Day Workflow

This workflow pack is a public, vendor-neutral reference implementation of a hook-managed workflow pattern from the private operating layer. It is intentionally detailed enough to recreate on another machine while using fictional inputs and replaceable connector interfaces.

## Purpose

Close the workday by reconciling tasks, meetings, decisions, follow-ups, knowledge updates, and tomorrow carry-forward state.

## Connector interfaces

- `task-system`
- `email-calendar`
- `chat`
- `document-store`
- `local-analytics`
- `agent-dispatch`

## Phase map

| # | Phase |
|---|---|
| 1 | Doctor/preflight |
| 2 | Task delta sync |
| 3 | Meeting/action-item extraction |
| 4 | Decision and follow-up queue |
| 5 | Knowledge/state refresh |
| 6 | Compression/eval handoff |
| 7 | Frontend summary |

## Design rationale

The backend/frontend split prevents heavy sync work from blocking the human-facing summary and lets missing connectors degrade visibly rather than silently skipping closeout.

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
