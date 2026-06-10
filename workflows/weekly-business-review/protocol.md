# Weekly Business Review / Projection Workflow — Protocol

Workflow id: `weekly-business-review`

## Purpose

Turn a spreadsheet or warehouse refresh into validated projections, narrative callouts, dashboard artifacts, and a publish-ready report.

## Required capabilities

- `filesystem_read`
- `filesystem_write`
- `shell`
- `python_3_10`
- `local_analytics`
- `spreadsheet_ingest`

## Optional capabilities

- `agent_dispatch`
- `document_store_publish`
- `dashboard_publish`

## Protocol

### Phase 0 — Preflight gates (cheapest first)

1. **Pause flag.** If `<repo-root>/context/active/weekly-business-review-paused.flag` exists, exit with a visible paused message and do not start connector work.
2. **Concurrency lock.** If `<repo-root>/context/active/weekly-business-review.lock` is fresh, exit as already running. If stale, overwrite and continue.
3. **Capability check.** Compare the workflow's required/optional capabilities against `context/config/runtime-capabilities.example.json` or the runtime's equivalent registry.
4. **Input availability check.** Verify required input files, source freshness, and schema compatibility before mutation.

Order matters: pause is a cheap local file check; lock prevents double execution; capability checks prevent unsupported tool calls; input checks stop silent stale-data runs. Reversing this order wastes expensive connector calls and makes paused or unsupported runs noisy.


### Phase sequence

| # | Phase | Gate |
|---|---|---|
| 1 | Preflight gates | Stop or degrade visibly if this phase cannot prove its output. |
| 2 | Spreadsheet ingest | Stop or degrade visibly if this phase cannot prove its output. |
| 3 | Local analytics load | Stop or degrade visibly if this phase cannot prove its output. |
| 4 | Forecast/projection refresh | Stop or degrade visibly if this phase cannot prove its output. |
| 5 | Prior forecast scoring | Stop or degrade visibly if this phase cannot prove its output. |
| 6 | Narrative callout drafting | Stop or degrade visibly if this phase cannot prove its output. |
| 7 | Dashboard artifact refresh | Stop or degrade visibly if this phase cannot prove its output. |
| 8 | Publish or degraded report | Stop or degrade visibly if this phase cannot prove its output. |

### Verification gates

- Each phase writes a phase result into the run record before the next phase starts.
- Any connector read must record source name, freshness, and row/item count when applicable.
- Any generated artifact must be written locally before optional publication.
- Any external write must have an idempotency key or retry manifest.
- The final report must include completed phases, skipped phases, degraded capabilities, and next action.

### State ownership

- `context/active/<workflow>-run.json` is the current run record.
- `context/active/<workflow>-lock` is the concurrency lock.
- `context/active/<workflow>-failures.jsonl` is the append-only failure log.
- `context/intake/` or workflow-specific output directories hold human-readable reports.

### Approval boundary

This public template defaults to drafts and proposals. If your private implementation can send messages, close tasks, publish dashboards, or update external docs, add an explicit approval or ownership guardrail before those writes.

### Completion contract

A completed run is not simply "no exception." It must produce a report that states what was done, what was skipped, what was degraded, and what can be safely consumed by the next workflow.
