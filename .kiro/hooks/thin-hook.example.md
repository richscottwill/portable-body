# Thin Hook Example

A hook should be a small runtime entrypoint, not the source of truth.

```json
{
  "name": "Example Weekly Review",
  "when": {"type": "userTriggered"},
  "then": {
    "type": "askAgent",
    "prompt": "Resolve <repo-root>, then read and execute <repo-root>/protocols/weekly-review.example.md. If repo root cannot be resolved, stop and ask for configuration."
  }
}
```

## Pattern

- preflight paths
- check pause/debounce state
- delegate to protocol
- write a run record
- degrade visibly on missing capability
