# Example Input — Eval Routing Workflow

## Trigger

Run `eval-routing` against fictional demo data.

## Input surface

A fictional artifact diff and eval-routing config selecting smoke/standard/full tier.

## Runtime declaration

```json
{
  "runtime": "example-runtime",
  "repo_root": "<repo-root>",
  "available_capabilities": ["filesystem_read", "filesystem_write", "agent_dispatch"]
}
```
