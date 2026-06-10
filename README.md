# Portable Body — Sanitized Agent-Bridge Shape

This repository is a public, sanitized example of a portable AI operating system. It intentionally mirrors the **directory shape and naming conventions** of a private working layer while replacing private content with fictional templates and architecture notes.

The thesis is simple: **AI tools change faster than operating systems should.** A durable operating layer should survive movement across Aki, Kiro, Quick Desktop, coding agents, general chat models, and whatever comes next.

## Why the structure looks like this

The private working layer uses a repo-root contract: every runtime resolves a `<repo-root>` and then reads stable paths such as `context/body/`, `context/protocols/`, `.kiro/hooks/`, `.kiro/agents/`, and `tools/`. This public repo keeps that shape so someone can understand the system without seeing private work data.

## Map

| Private working-layer concept | Public sanitized path | What to inspect |
|---|---|---|
| Workspace bootstrap | `AGENTS.md` | How a fresh AI session or teammate orients itself |
| Body-system navigation | `context/body/body.md` | Which organ to load for which task |
| Operating organs | `context/body/*.md` | Templates for principles, memory, current work, tasks, observation |
| Workflow contracts | `context/protocols/*.md` | Portable protocols that hooks/agents execute |
| Hook envelopes | `.kiro/hooks/*.example.md` | Thin delegator pattern without private automation |
| Agent definitions | `.kiro/agents/generic-team/*.md` | Generic team-agent instruction pattern |
| Runtime config | `context/config/runtime-capabilities.example.json` | Capability/degraded-mode model |
| Active contract surfaces | `context/active/hook-contract-table.md` | How workflows are indexed without loading every hook |
| Architecture docs | `docs/architecture/` | Six-layer model, boundary contract, runtime portability, tool landscape |
| Examples | `docs/examples/` | Sanitized session flow and audit examples |
| Export tooling docs | `tools/portable-body-export/` | How the public layer is generated safely |

## What this demonstrates

- A **body-system memory model**: small markdown organs that let an AI recover identity, priorities, context, operating rules, and active work.
- A **protocol layer**: reusable operating contracts that agents can execute across tools and runtimes.
- A **thin-hook pattern**: hooks stay small and delegate durable behavior to markdown protocols.
- A **runtime portability contract**: workflows resolve `<repo-root>` and runtime capabilities instead of hardcoding one machine or one AI app.
- A **tool-landscape model**: Aki, Kiro, Quick Desktop, coding agents, and general chat models are treated as runtimes with different capabilities, not as the source of truth.
- A **sanitized showcase boundary**: public examples are generated from templates, not mirrored from the private working repo.

## What this intentionally does not contain

- Real company, customer, project, organization structure, private workplace data, or performance data.
- Real Slack/Asana/SharePoint IDs.
- Real meeting notes, relationship notes, strategy docs, dashboards, or databases.
- Credentials, MCP config, or operational secrets.
- The private working repo history.

## Start here

1. Read `AGENTS.md`.
2. Read `context/body/body.md`.
3. Read `docs/START-HERE.md`.
4. Read `docs/architecture/tool-landscape.md`.
5. Read `docs/architecture/showcase-map.md`.
6. Inspect `context/protocols/path-standardization.md` and `context/protocols/workflow-state.md`.
7. Inspect `.kiro/hooks/thin-hook.example.md`.

## Design principle

The goal is not to publish someone's life or company context. The goal is to publish a **repeatable structure** that another person can adapt safely.
