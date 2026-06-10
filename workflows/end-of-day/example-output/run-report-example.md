# Example Output — End-of-Day Workflow

Status: degraded-success

## Summary

A closeout summary, follow-up queue, knowledge updates, workflow-state record, and a visible degraded-mode banner if sources were unavailable.

## Completed phases

- `Doctor/preflight`
- `Task delta sync`
- `Meeting/action-item extraction`
- `Decision and follow-up queue`

## Degraded or skipped

- Optional publish/dispatch phases were skipped when the example runtime lacked those capabilities.

## Next action

Review the local output. If external publishing or specialist-agent review is required, rerun the final phase on a runtime with those capabilities.
