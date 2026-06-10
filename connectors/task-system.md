# Task System Connector Interface

Examples: Asana, Jira, Linear, GitHub Issues.

## Responsibilities

- Read assigned/open tasks.
- Read comments and activity history.
- Create proposed tasks only through approval gates.
- Update status/priority fields when a workflow owns that action.
- Preserve an audit row for every write.

## Portable contract

```json
{
  "capability": "task_system",
  "required_for": ["morning-backend", "meeting-to-task", "end-of-day"],
  "degraded_mode": "surface proposed task changes in markdown instead of writing"
}
```

## Safety rule

Read operations can run unattended. Writes require a workflow-owned guardrail or human approval gate.
