# Wiki Maintenance Workflow

This workflow pack is a public, vendor-neutral reference implementation of a hook-managed workflow pattern from the private operating layer. It is intentionally detailed enough to recreate on another machine while using fictional inputs and replaceable connector interfaces.

## Purpose

Maintain a knowledge base with multi-agent research, writing, critique, publication checks, demand logging, and broad-sweep discovery.

## Connector interfaces

- `document-store`
- `chat`
- `local-analytics`
- `agent-dispatch`
- `publishing`

## Phase map

| # | Phase |
|---|---|
| 1 | Preflight and lock |
| 2 | Broad sweep |
| 3 | Researcher pass |
| 4 | Writer pass |
| 5 | Critic/eval pass |
| 6 | Revision pass |
| 7 | Librarian/publication pass |
| 8 | Concierge demand report |
| 9 | Maintenance digest |

## Design rationale

A staged editorial pipeline catches gaps that a single agent misses; publication checks prevent invisible knowledge articles.

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
