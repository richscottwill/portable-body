# Failure Modes — Weekly Business Review / Projection Workflow

| Failure | Detection | Recovery |
|---|---|---|
| pause_or_lock | Pause flag or fresh lock exists | Exit cleanly with a no-op status and write/retain no partial output. |
| missing_required_capability | Runtime lacks a required capability | Produce a manual runbook or degraded report; do not pretend the workflow completed. |
| optional_connector_unavailable | Optional connector is missing or unauthenticated | Skip that phase, include a visible degraded-mode section, continue with local outputs. |
| schema_or_input_mismatch | Input file/table does not match expected shape | Stop before mutation; write validation errors and examples of expected shape. |
| partial_unit_failure | One unit/market/page/source fails while others succeed | Isolate the failed unit; complete the rest; report the skipped unit explicitly. |
| publish_failure | External publication fails after local output succeeds | Keep local output as source of truth; write a publish retry manifest. |

## Circuit breaker pattern

If the same failure repeats three times for the same workflow/source, stop retrying inline. Write the failure to the workflow log, surface the blocker, and require a human or a more capable runtime to clear it.

## Per-unit isolation

When the workflow processes multiple units (markets, pages, sources, artifacts, people, or tasks), isolate failures per unit. A single bad unit should not erase valid output from all other units unless the failed unit is a shared dependency.
