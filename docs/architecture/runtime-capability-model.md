# Runtime Capability Model

A portable operating layer treats tools as runtimes with capabilities, not as permanent homes.

## Example capability matrix

| Runtime | Shell | Git | Hooks | Agent dispatch | Filesystem | Browser | External connectors |
|---|---:|---:|---:|---:|---:|---:|---:|
| Aki-style local shell | yes | yes | different/native | yes | yes | partial | varies |
| Kiro server | yes | yes | yes | Kiro agent dispatch | yes | limited | strong, runtime-specific |
| Kiro local | yes | yes | yes | Kiro agent dispatch | yes | local | varies |
| Quick Desktop | varies | varies/no | app-specific | app-specific | local/app-scoped | yes | public app features |
| Coding agent | yes | yes | no | coding-focused | yes | limited | shell/tooling |
| General chat model | no | no | no | no | supplied files only | no | no |

## Capability-first workflow design

Each workflow should define:

- required capabilities
- optional capabilities
- degraded behavior
- output location
- local analytical store access, when a workflow needs structured/tabular memory
- human escalation path

Example:

```json
{
  "workflow": "weekly-review",
  "requires": ["filesystem_read", "filesystem_write"],
  "optional": ["agent_dispatch", "external_publish"],
  "degraded_mode": "write local review; skip external publish"
}
```

## Degraded mode is not failure

A runtime without a connector can still run file-only phases. A runtime without shell can still read protocols and produce a manual runbook. A runtime without git can still generate a patch plan.

Portability improves when missing capabilities are explicit.
