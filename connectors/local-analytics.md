# Local Analytics Connector Interface

Examples: DuckDB, SQLite, local Parquet/CSV cache.

## Responsibilities

- Store workflow runs, source freshness, metrics, forecasts, and audit rows.
- Support read-only queries from agents.
- Route writes through a controlled helper or workflow-owned writer.
- Keep generated database files out of public git.

## Portable contract

Schema and queries are committed as text. Binary database files are generated locally.
