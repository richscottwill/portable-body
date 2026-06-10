# Hook Contract Table — Sanitized Example

This mirrors the private working layer's hook contract table without exposing real workflows.

| Hook | Contract source | Purpose | State | Side effects | Degraded mode |
|---|---|---|---|---|---|
| `.kiro/hooks/portable-eod.example.md` | `context/protocols/workflow-state.md` | End-of-day summary pattern | `context/active/workflow-runs/` | Local markdown only | Skip unavailable integrations |
| `.kiro/hooks/weekly-review.example.md` | `context/protocols/decision-agent.md` | Weekly learning loop pattern | `context/intake/` | Local markdown only | Counts-only review |
| `.kiro/hooks/thin-hook.example.md` | Any protocol | Thin delegator pattern | Protocol-defined | Protocol-defined | Protocol-defined |

Use this table as a map, not as executable truth. The hook + protocol are authoritative.
