# Example Input — End-of-Day Workflow

## Trigger

Run `end-of-day` against fictional demo data.

## Input surface

A day-end trigger plus fictional task completions, meeting notes, and chat decisions.

## Runtime declaration

```json
{
  "runtime": "example-runtime",
  "repo_root": "<repo-root>",
  "available_capabilities": ["filesystem_read", "filesystem_write", "task_system_read", "local_analytics", "email_calendar"]
}
```
