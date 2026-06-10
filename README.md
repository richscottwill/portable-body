# Portable Body — Sanitized AI Operating System Showcase

This repository is a public, sanitized example of a portable AI operating system. It shows the architecture patterns without exposing the private working system, real workplace data, or personal context.

## What this demonstrates

- A **body-system memory model**: small markdown organs that let an AI recover identity, priorities, context, operating rules, and active work.
- A **protocol layer**: reusable operating contracts that agents can execute across tools and runtimes.
- A **thin-hook pattern**: hooks stay small and delegate durable behavior to markdown protocols.
- A **runtime portability contract**: workflows resolve `<repo-root>` and runtime capabilities instead of hardcoding one machine.
- A **sanitized showcase boundary**: public examples are generated from templates, not mirrored from the private working repo.

## What this intentionally does not contain

- Real company, customer, project, organization structure, private workplace data, or performance data.
- Real Slack/Asana/SharePoint IDs.
- Real meeting notes, relationship notes, strategy docs, dashboards, or databases.
- Credentials, MCP config, or operational secrets.
- The private working repo history.

## Three-layer model

| Layer | Purpose | Visibility |
|---|---|---|
| Private working layer | Real hooks, protocols, data, docs, and active work | Private only |
| Public showcase layer | Sanitized architecture and reusable patterns | Safe to share |
| Durability/DR layer | Private backups/snapshots for recovery | Private only |

See `architecture/layer-boundary-contract.md` for the full boundary.

## Start here

1. Read `architecture/six-layer-portable-ai-os.md`.
2. Read `architecture/showcase-map.md` for a guided tour.
3. Inspect the body templates under `body/`.
4. Inspect protocol examples under `protocols/`.
5. Inspect hook examples under `hooks/`.

## Design principle

The goal is not to publish someone's life or company context. The goal is to publish a **repeatable structure** that another person can adapt safely.
