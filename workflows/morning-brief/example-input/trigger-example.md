# Example Input — Morning Brief Workflow

## Trigger

Run `morning-brief` against fictional demo data.

## Input surface

A morning trigger with optional source freshness records and fictional calendar/task/chat snapshots.

## Runtime declaration

```json
{
  "runtime": "example-runtime",
  "repo_root": "<repo-root>",
  "available_capabilities": ["filesystem_read", "filesystem_write", "local_analytics", "task_system"]
}
```
