# Workflow State Template

Portable workflows should write structured run records.

```json
{
  "workflow": "example",
  "run_id": "...",
  "phase_results": {},
  "runtime": "...",
  "started_at": "...",
  "completed_at": "...",
  "status": "completed|failed|skipped",
  "repo_root": "...",
  "commit": "..."
}
```
