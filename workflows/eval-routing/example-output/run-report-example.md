# Example Output — Eval Routing Workflow

Status: degraded-success

## Summary

A verdict record with lens scores, disagreement flags, advisory notes, and final keep/revise/revert decision.

## Completed phases

- `Artifact classification`
- `Tier selection`
- `Prompt-file creation`
- `Blind evaluator dispatch`

## Degraded or skipped

- Optional publish/dispatch phases were skipped when the example runtime lacked those capabilities.

## Next action

Review the local output. If external publishing or specialist-agent review is required, rerun the final phase on a runtime with those capabilities.
