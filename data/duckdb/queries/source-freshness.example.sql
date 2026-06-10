SELECT
  source_name,
  source_type,
  last_updated,
  expected_cadence_hours
FROM ops.source_freshness
ORDER BY source_name;
