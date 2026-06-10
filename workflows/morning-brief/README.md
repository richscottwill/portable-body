# Morning Brief Workflow

This workflow pack is a public, vendor-neutral reference implementation of a hook-managed workflow pattern from the private operating layer. It is intentionally detailed enough to recreate on another machine while using fictional inputs and replaceable connector interfaces.

## Purpose

Prepare a morning operating picture from tasks, calendar, chat, email, local analytics, and saved state without sending anything automatically.

## Connector interfaces

- `task-system`
- `email-calendar`
- `chat`
- `local-analytics`
- `dashboard/publishing optional`

## Phase map

| # | Phase |
|---|---|
| 1 | Backend health checks |
| 2 | Parallel source ingestion |
| 3 | Orchestrator-owned exceptions |
| 4 | State file generation |
| 5 | Brief drafting |
| 6 | Approval queues |
| 7 | Draft-only outbound suggestions |

## Design rationale

Parallel ingestion improves freshness, but connector fan-out failures require orchestrator-owned exceptions and visible partial status.

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
