-- Public-safe demo schema for a local analytical store.
-- This file is intentionally tiny and fictional.

CREATE SCHEMA IF NOT EXISTS ops;

CREATE TABLE IF NOT EXISTS ops.workflow_runs (
  run_id VARCHAR PRIMARY KEY,
  workflow VARCHAR NOT NULL,
  runtime VARCHAR NOT NULL,
  started_at TIMESTAMP NOT NULL,
  completed_at TIMESTAMP,
  status VARCHAR NOT NULL,
  degraded_reason VARCHAR
);

CREATE TABLE IF NOT EXISTS ops.source_freshness (
  source_name VARCHAR PRIMARY KEY,
  source_type VARCHAR NOT NULL,
  last_updated TIMESTAMP NOT NULL,
  expected_cadence_hours INTEGER NOT NULL
);

CREATE VIEW IF NOT EXISTS ops.workflow_health AS
SELECT
  workflow,
  COUNT(*) AS runs,
  SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) AS completed_runs,
  SUM(CASE WHEN status = 'degraded' THEN 1 ELSE 0 END) AS degraded_runs,
  MAX(completed_at) AS last_completed_at
FROM ops.workflow_runs
GROUP BY workflow;
