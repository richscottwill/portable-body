# Tool Landscape — Why the Operating Layer Is Portable

AI tooling is changing quickly. New desktop apps, coding agents, model-hosted assistants, local shells, browser agents, and MCP-style connector systems appear faster than any single workflow can be rewritten.

This repo demonstrates a design response: keep the durable operating system in plain files and protocols, then let each tool act as a runtime.

## Core thesis

Tools change. The operating layer should survive.

The stable layer is:

- repo structure
- markdown protocols
- small context files
- explicit path contracts
- capability detection
- adapter scripts
- export/sanitization boundaries

The unstable layer is:

- which app runs the workflow
- which model is available
- whether shell/git/browser access exists
- which connectors are installed
- whether hooks or scheduled jobs are supported

## Runtime classes

| Runtime class | What it is good for | Portability caution |
|---|---|---|
| Aki-style local agent shell | orchestration, local files, tool use, teammate agents | may not share Kiro hook semantics |
| Kiro server / devspace | hooks, persistent automation, server-side tools | paths and credentials can be environment-specific |
| Kiro local | local hook and agent development | may differ from server paths/capabilities |
| Quick Desktop | public desktop app and user-facing local workflows | shell/git/connectors may be limited or app-specific |
| Coding agents | implementation, refactors, tests | usually not the owner of memory/routine semantics |
| General chat models | reasoning, review, bootstrap tests | no durable filesystem unless given files explicitly |
| MCP / connector layer | access to external systems | connectors differ by runtime and permission scope |

## Design implication

A workflow should not say:

```text
Run this exact command from this exact home directory in this exact app.
```

It should say:

```text
Resolve <repo-root>. Check runtime capabilities. Use adapters for app-specific actions. Degrade visibly when a capability is missing.
```

## Public vs private

This public repo names runtime classes and patterns. It does not include private workplace connectors, internal project names, IDs, dashboards, or data.

Public-safe content:

- Aki as a local orchestration/runtime example.
- Kiro as a hook/runtime example.
- Quick Desktop as a public desktop runtime category.
- MCP/connectors as a generic capability class.
- Coding agents as implementation runtimes.

Private content that does not belong here:

- real connector configs
- real IDs
- real internal systems
- project names
- performance data
- relationship notes
