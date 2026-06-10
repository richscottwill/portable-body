# Workflow State Protocol

Purpose: make recurring workflows observable, resumable, debuggable, and safe to degrade.

## Run record schema

```json
{
  "workflow": "example-workflow",
  "run_id": "2026-01-01T00:00:00Z-example",
  "phase_results": [],
  "runtime": "example-runtime",
  "started_at": "2026-01-01T00:00:00Z",
  "completed_at": null,
  "status": "running",
  "skip_reason": null,
  "repo_root": "<repo-root>",
  "commit": "<sha>",
  "capabilities": {
    "missing_required": [],
    "missing_optional": []
  },
  "outputs": [],
  "next_action": null
}
```

## Status values

| Status | Meaning |
|---|---|
| `running` | Lock acquired and phases are in progress. |
| `ok` | All required phases completed. |
| `degraded` | Required output exists, but one or more optional capabilities/phases were skipped. |
| `skipped` | Preflight intentionally stopped the run. |
| `failed` | Required phase failed; downstream workflows must not consume output as fresh. |

## Lock rules

1. Check pause flag before lock.
2. Acquire lock before connector calls.
3. Treat fresh lock as already-running.
4. Treat stale lock as recoverable only if its timestamp exceeds the workflow's documented maximum runtime.
5. Remove or mark lock on clean completion; preserve failure evidence on abort.

## Phase result shape

```json
{
  "phase": "ingest",
  "status": "ok|skipped|failed|degraded",
  "started_at": "2026-01-01T00:00:00Z",
  "completed_at": "2026-01-01T00:01:00Z",
  "evidence": "<repo-root>/context/active/artifact.json",
  "notes": "what a downstream workflow needs to know"
}
```

## Rules

- Write state before external side effects.
- Mark skipped runs explicitly.
- Preserve partial failures instead of pretending success.
- Include enough evidence for another runtime to resume or produce a manual runbook.
