# Sanitization Rules

This repo is public. Treat every export as hostile until scanned.

## Strip / replace

- Employer, customer, vendor, and internal project names → fictional placeholders.
- Real people names, aliases, org charts, levels, locations, and relationship notes → fictional roles or remove.
- Real task IDs, Slack/channel IDs, calendar IDs, document URLs, and private paths → `[id]`, `[url]`, or `<repo-root>`.
- Real metrics, financials, performance numbers, private career and reward details → fictional examples or remove.
- Meeting notes, private strategy, and private operational history → remove or rewrite as fictional examples.
- Credentials, tokens, private keys, local absolute paths, and internal binaries → remove entirely.

## Keep

These terms are public-safe when used generically or with fictional examples:

- Asana, Jira, Linear, GitHub Issues, and other task systems.
- Outlook, Google Calendar, and other email/calendar systems.
- Slack, Teams, Discord, and other chat systems.
- SharePoint, Google Drive, Notion, Confluence, and other document stores.
- Excel/xlsx ingestion, dashboards, WBR-style reviews, forecasts, projections, callouts, and performance analysis.
- DuckDB, SQLite, local analytical stores, MCP/connectors, hooks, agents, evals, and runtime adapters.
- Architecture patterns, file layout patterns, protocol shapes, quality gates, degraded modes, and design rationale.

## Required checks before publish

```bash
python3 tools/portable-body-export/scan_public_export.py <export-dir>
```

A passing scan is necessary but not sufficient. Human review is still required, especially for newly imported workflow text.
