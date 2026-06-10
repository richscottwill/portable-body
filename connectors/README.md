# Connector Interfaces

Portable Body treats tools as replaceable connectors. The reference implementation names common tools directly because they are widely available: Asana/Jira/Linear for tasks, Outlook/Google Calendar for email and calendar, Slack/Teams/Discord for chat, SharePoint/Google Drive/Notion/Confluence for documents, Excel/xlsx for spreadsheet ingestion, and DuckDB/SQLite for local analytics.

A private implementation chooses one connector per interface and records the runtime capability requirements in `context/config/runtime-capabilities.example.json`.
