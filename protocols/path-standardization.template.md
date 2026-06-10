# Path Standardization Template

## Contract

1. `AGENT_BRIDGE_ROOT` or equivalent is the canonical repo-root override.
2. Prose uses `<repo-root>/...` notation.
3. Scripts resolve the concrete path before executing.
4. Temporary workflow files use repo-local scratch unless an explicit temp env var is set.
5. Never hardcode a personal home directory in portable instructions.

## Example

```bash
export AGENT_BRIDGE_ROOT="${AGENT_BRIDGE_ROOT:-$(python3 tools/scripts/path_resolver.py root)}"
REPO_ROOT="$AGENT_BRIDGE_ROOT"
OUTPUT="$REPO_ROOT/context/active/example-output.md"
```
