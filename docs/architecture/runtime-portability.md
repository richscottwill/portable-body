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


## Tool planning lens

When evaluating a new tool, ask:

1. Can it read the repo structure?
2. Can it resolve `<repo-root>`?
3. Does it have shell/git/filesystem access?
4. Does it support hooks or only interactive runs?
5. Can it dispatch subagents or only run one model?
6. Which connectors are available?
7. What is the safe degraded mode?

This lets the operating layer absorb tool churn without rewriting every workflow.
