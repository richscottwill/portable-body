# Example Input — Wiki Maintenance Workflow

## Trigger

Run `wiki-maintenance` against fictional demo data.

## Input surface

A fictional backlog of wiki candidates, stale pages, demand-log entries, and chat/document discoveries.

## Runtime declaration

```json
{
  "runtime": "example-runtime",
  "repo_root": "<repo-root>",
  "available_capabilities": ["filesystem_read", "filesystem_write", "agent_dispatch"]
}
```
