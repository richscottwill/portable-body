# Path Standardization Protocol

## Contract

1. `AGENT_BRIDGE_ROOT` or an equivalent runtime variable is the canonical repo-root override.
2. Prose uses `<repo-root>/...` notation.
3. Scripts resolve concrete paths before executing.
4. Temporary workflow files use repo-local scratch unless an explicit temp env var is set.
5. Local analytical stores resolve through an environment override when set; otherwise use a repo-local generated path such as `<repo-root>/data/duckdb/demo.duckdb`.
6. Generated `.duckdb`, WAL, cache, and scratch files stay out of git.
7. Never hardcode a personal home directory in portable instructions.

## Runtime examples

| Runtime | How it should resolve paths |
|---|---|
| Aki / local agent shell | Read `AGENT_BRIDGE_ROOT` or infer from current repo checkout. |
| Kiro server/local | Resolve hook cwd to repo root before reading protocols. |
| Claude Code / Codex / coding agents | Use the workspace root passed by the coding agent. |
| Quick Desktop / generic chat | Use manual `<repo-root>` substitution or produce a runbook when filesystem is unavailable. |

## Shell example

```bash
export AGENT_BRIDGE_ROOT="${AGENT_BRIDGE_ROOT:-$(pwd)}"
REPO_ROOT="$AGENT_BRIDGE_ROOT"
OUTPUT="$REPO_ROOT/context/active/example-output.md"
```

## Python example

```python
from pathlib import Path
import os
repo_root = Path(os.environ.get("AGENT_BRIDGE_ROOT", ".")).resolve()
analytics_path = Path(os.environ.get("LOCAL_ANALYTICS_PATH", repo_root / "data/duckdb/demo.duckdb"))
```
