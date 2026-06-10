# Workflow State Template

Purpose: make recurring workflows observable and resumable.

## Run record

```json
{
  "workflow": "example-workflow",
  "run_id": "2026-01-01T00:00:00Z-example",
  "phase_results": {},
  "runtime": "local",
  "started_at": "2026-01-01T00:00:00Z",
  "completed_at": null,
  "status": "running",
  "skip_reason": null,
  "repo_root": "<repo-root>",
  "commit": "<sha>"
}
```

## Rules

- Write state before external side effects.
- Mark skipped runs explicitly.
- Preserve partial failures instead of pretending success.
