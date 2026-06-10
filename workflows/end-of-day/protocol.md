# End-of-Day Workflow — Protocol

Workflow id: `end-of-day`

## Purpose

Close the workday by reconciling tasks, meetings, decisions, follow-ups, knowledge updates, and tomorrow carry-forward state.

## Required capabilities

- `filesystem_read`
- `filesystem_write`
- `task_system_read`
- `local_analytics`

## Optional capabilities

- `email_calendar`
- `chat`
- `document_store_publish`
- `agent_dispatch`

## Protocol

### Phase 0 — Preflight gates (cheapest first)

1. **Pause flag.** If `<repo-root>/context/active/end-of-day-paused.flag` exists, exit with a visible paused message and do not start connector work.
2. **Concurrency lock.** If `<repo-root>/context/active/end-of-day.lock` is fresh, exit as already running. If stale, overwrite and continue.
3. **Capability check.** Compare the workflow's required/optional capabilities against `context/config/runtime-capabilities.example.json` or the runtime's equivalent registry.
4. **Input availability check.** Verify required input files, source freshness, and schema compatibility before mutation.

Order matters: pause is a cheap local file check; lock prevents double execution; capability checks prevent unsupported tool calls; input checks stop silent stale-data runs. Reversing this order wastes expensive connector calls and makes paused or unsupported runs noisy.


### Phase sequence

| # | Phase | Gate |
|---|---|---|
| 1 | Doctor/preflight | Stop or degrade visibly if this phase cannot prove its output. |
| 2 | Task delta sync | Stop or degrade visibly if this phase cannot prove its output. |
| 3 | Meeting/action-item extraction | Stop or degrade visibly if this phase cannot prove its output. |
| 4 | Decision and follow-up queue | Stop or degrade visibly if this phase cannot prove its output. |
| 5 | Knowledge/state refresh | Stop or degrade visibly if this phase cannot prove its output. |
| 6 | Compression/eval handoff | Stop or degrade visibly if this phase cannot prove its output. |
| 7 | Frontend summary | Stop or degrade visibly if this phase cannot prove its output. |

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
