# Path Standardization Template

Use `<repo-root>` in shared documentation. Use `AGENT_BRIDGE_ROOT` in executable workflows.

## Contract

1. If `AGENT_BRIDGE_ROOT` is set, use it.
2. Otherwise discover the repo root from the current working directory.
3. Never assume a fixed home directory.
4. Runtime-specific capability checks should fail cleanly.
