# Six-Layer Portable AI OS

A portable AI operating system separates context, rules, workflows, tools, and publishing boundaries.

| Layer | Purpose | Example in this repo |
|---|---|---|
| 1. Identity / voice | Stable operating principles and writing style | `body/soul.template.md` |
| 2. Memory / context | Current state, relationships, active work | `body/memory.template.md`, `body/current.template.md` |
| 3. Protocols | Reusable execution rules | `protocols/*.template.md` |
| 4. Hooks / triggers | Thin entrypoints that invoke protocols | `hooks/*.example.md` |
| 5. Agents / roles | Specialized workers with scoped instructions | `agents/*.md` |
| 6. Boundary / publishing | What can leave the private layer | `architecture/layer-boundary-contract.md` |

## Why markdown?

Markdown is diffable, portable across AI tools, and legible to humans. Machines can still parse frontmatter, headings, tables, and fenced examples.

## Why thin hooks?

Hooks are runtime-specific. Protocols are portable. Keep hooks short and push durable logic into protocol files.

## Why `<repo-root>`?

Hardcoded machine paths break when moving between local desktop, server, and alternate AI runtimes. Public examples use `<repo-root>` and environment variables instead.
