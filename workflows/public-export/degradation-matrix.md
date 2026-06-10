# Degradation Matrix — Public Export Workflow

| Mode | Condition | Output |
|---|---|---|
| Full orchestration | All required + optional capabilities available | Run all phases and publish/dispatch if explicitly owned. |
| Local-only | Required local capabilities available; external connectors unavailable | Generate local report, validation output, and manual next steps. |
| Review-only | Filesystem read but no shell/connectors | Read inputs and produce a manual runbook or patch plan. |
| No-run | Cannot read repo files | Escalate to a capable runtime; do not fabricate run state. |

Missing optional capabilities are not failures. Missing required capabilities are visible degraded runs or no-runs.
