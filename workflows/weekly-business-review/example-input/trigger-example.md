# Example Input — Weekly Business Review / Projection Workflow

## Trigger

Run `weekly-business-review` against fictional demo data.

## Input surface

A fictional weekly_metrics.xlsx drop containing rows for MarketA/MarketB/MarketC with spend, traffic, conversions, and target columns.

## Runtime declaration

```json
{
  "runtime": "example-runtime",
  "repo_root": "<repo-root>",
  "available_capabilities": ["filesystem_read", "filesystem_write", "shell", "python_3_10", "local_analytics", "spreadsheet_ingest", "agent_dispatch"]
}
```
