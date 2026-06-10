-- Public-safe fictional seed data.

INSERT OR REPLACE INTO ops.workflow_runs VALUES
  ('run-001', 'weekly-review', 'aki-local', '2026-01-05 09:00:00', '2026-01-05 09:02:00', 'completed', NULL),
  ('run-002', 'content-refresh', 'quick-desktop-local', '2026-01-06 10:00:00', '2026-01-06 10:01:00', 'degraded', 'external_publish unavailable'),
  ('run-003', 'repo-sync', 'kiro-server', '2026-01-07 08:00:00', '2026-01-07 08:01:30', 'completed', NULL);

INSERT OR REPLACE INTO ops.source_freshness VALUES
  ('notes', 'markdown', '2026-01-07 08:00:00', 24),
  ('tasks', 'connector', '2026-01-06 18:00:00', 12),
  ('weekly_metrics', 'local_table', '2026-01-05 12:00:00', 168);
