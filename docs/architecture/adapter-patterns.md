# Adapter Patterns

Adapters keep workflows from depending on one AI app or one machine layout.

## Path adapter

Use `<repo-root>` in prose and a repo-root env var in scripts.

```bash
REPO_ROOT="${PORTABLE_ROOT:-$(python tools/path_resolver.py root)}"
```

## Runtime capability adapter

Before a workflow starts, check capabilities.

```text
require: filesystem_read, filesystem_write
optional: git, shell, agent_dispatch, external_publish
```

## Agent dispatch adapter

Do not hardcode one agent CLI. Write prompts to files and invoke the runtime-supported dispatch backend.

```text
run-agent --agent reviewer --prompt-file context/active/prompt.md --output-file context/active/review.md
```

## Connector adapter

Treat external systems as optional connectors. A missing connector should produce a visible degraded artifact, not a silent skip.

## Public export adapter

Never mirror a private working repo into a public showcase repo. Export from an allowlist and scan the result.
