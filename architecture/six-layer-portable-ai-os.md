# Six-Layer Portable AI Workspace Pattern

This is a sanitized architecture pattern for an AI-assisted operating system.

## Layers

1. **Identity and principles** — durable preferences, constraints, and operating philosophy.
2. **Current state** — what matters now, kept short and frequently refreshed.
3. **Working memory** — relationship/context notes that are private in real deployments and templated here.
4. **Protocols** — repeatable markdown contracts for workflows.
5. **Hooks and agents** — thin runtime envelopes that call protocols and specialist roles.
6. **Audit and learning loops** — decision logs, failure logs, reviews, and portability checks.

## Portability rule

Shared artifacts should refer to the repository as `<repo-root>`. Executable code should resolve that through `AGENT_BRIDGE_ROOT` or a runtime resolver. Do not bake in one machine's home directory.

## Boundary rule

The private working layer can contain real context. The showcase layer must contain only templates, fictional examples, and architecture descriptions.
