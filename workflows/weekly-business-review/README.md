# Weekly Business Review / Projection Workflow

This workflow pack is a public, vendor-neutral reference implementation of a hook-managed workflow pattern from the private operating layer. It is intentionally detailed enough to recreate on another machine while using fictional inputs and replaceable connector interfaces.

## Purpose

Turn a spreadsheet or warehouse refresh into validated projections, narrative callouts, dashboard artifacts, and a publish-ready report.

## Connector interfaces

- `spreadsheet-ingestion`
- `local-analytics`
- `document-store`
- `publishing`
- `agent-dispatch (optional reviewer/writer agents)`

## Phase map

| # | Phase |
|---|---|
| 1 | Preflight gates |
| 2 | Spreadsheet ingest |
| 3 | Local analytics load |
| 4 | Forecast/projection refresh |
| 5 | Prior forecast scoring |
| 6 | Narrative callout drafting |
| 7 | Dashboard artifact refresh |
| 8 | Publish or degraded report |

## Design rationale

This workflow preserves the single-owner refit/tool pattern and per-unit failure isolation: one failing market/product/segment should not erase all usable output.

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
