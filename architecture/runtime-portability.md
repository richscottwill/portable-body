# Runtime Portability Pattern

Portable workflows should assume they may run in different environments.

## Contract

- Use `<repo-root>` in prose.
- Use `AGENT_BRIDGE_ROOT` or an equivalent repo-root override in executable scripts.
- Put temporary workflow files under repo-local scratch or an explicit temp env var.
- Detect capabilities before using them.
- Degrade visibly when a runtime lacks a tool.

## Example

```bash
export AGENT_BRIDGE_ROOT="${AGENT_BRIDGE_ROOT:-$(python3 tools/scripts/path_resolver.py root)}"
REPO_ROOT="$AGENT_BRIDGE_ROOT"
SCRATCH_DIR="${PORTABLE_TMP:-$REPO_ROOT/context/active/scratch}"
```

## Capability examples

| Capability | Degrade behavior |
|---|---|
| Shell unavailable | produce instructions / monitoring-only report |
| Git unavailable | skip sync and log manual action |
| External publish unavailable | write local artifact and mark unpublished |
| Agent dispatch unavailable | run orchestrator-only stages |
