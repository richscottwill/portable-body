# Local Analytical Store Pattern

Some workflows need structured memory that is too tabular for markdown: workflow runs, source freshness, audit rows, and weekly metrics. The portable pattern is:

1. keep schema and queries in the repo,
2. generate the local database at runtime,
3. keep binary database files out of git,
4. resolve the path through the runtime path contract.

## Public-safe demo

This folder contains a tiny fictional schema and seed set. It is safe to inspect and adapt.

Generate a local demo database if DuckDB is installed:

```bash
mkdir -p data/duckdb
duckdb data/duckdb/demo.duckdb < data/duckdb/schema.example.sql
duckdb data/duckdb/demo.duckdb < data/duckdb/seed.example.sql
duckdb data/duckdb/demo.duckdb < data/duckdb/queries/workflow-health.example.sql
```

`demo.duckdb` is ignored by git.

## Path contract

Use this shape in portable workflows:

```text
LOCAL_ANALYTICS_PATH if set, otherwise <repo-root>/data/duckdb/demo.duckdb
```

A private working system may use a different environment variable name and a richer schema. The public concept is the same: schema is portable text; live data is generated locally and never published.
