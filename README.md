# Portable Body — A Public Reference Implementation for a Portable AI Operating Layer

Portable Body is a sanitized, public reference implementation of a private AI operating system. It mirrors the working system's **shape, operating patterns, and workflow logic** without publishing private company, customer, project, people, metrics, credentials, or IDs.

The thesis is simple: **AI tools change faster than operating systems should.** The durable layer should be repo-native: markdown memory, protocols, hooks, agents, connector contracts, local analytics, workflow state, and export boundaries that can move across Aki, Kiro, Quick Desktop, coding agents, general chat models, and whatever comes next.

This is more than a showcase. The goal is that someone outside the original environment can use this repo to recreate their own private working layer with their own tools, data, agents, and workflows.

## The system map

Start with the visual map in `docs/system-map.md`, then use `docs/recreate-agent-bridge-system.md` and `docs/replication-checklist.md` to recreate the system on another machine.


| Layer | What it does | Where to look |
|---|---|---|
| 1. Bootstrap | Tells a fresh AI/runtime how to orient in the repo | `AGENTS.md`, `docs/START-HERE.md` |
| 2. Body / memory | Portable context surfaces: principles, current state, memory, tasks, observation | `context/body/` |
| 3. Protocols | Durable workflow contracts, failure rules, evaluation rules, and decision rules | `context/protocols/` |
| 4. Hooks / triggers | Thin runtime entrypoints that delegate to protocols | `.kiro/hooks/`, `docs/catalog/hooks.md` |
| 5. Agents / teams | Role-scoped workers and review lenses | `.kiro/agents/`, `docs/catalog/agents.md` |
| 6. Connectors | Tool interfaces for tasks, chat, calendar, docs, spreadsheets, analytics, and publishing | `connectors/` |
| 7. Local analytics | Text-defined schema/query layer; generated database files stay local | `data/duckdb/` |
| 8. Workflow packs | End-to-end reusable operating workflows | `workflows/` |
| 9. Public/private boundary | How to publish patterns without leaking private state | `context/protocols/public-showcase-layer.md`, `SANITIZE.md` |

## What we were able to build

This repo captures the reusable parts of a larger private system:

- **A repo-root operating contract**: every runtime resolves `<repo-root>` and avoids machine-specific paths.
- **A body-system memory model**: markdown organs split durable context into navigable, reviewable surfaces.
- **A protocol layer**: recurring judgment becomes explicit reusable operating contracts.
- **Thin hook orchestration**: hooks stay small; durable logic lives in markdown protocols.
- **Workflow-state discipline**: workflows record status, phases, runtime, degraded mode, and audit outputs.
- **Connector interfaces**: Asana/Jira-style tasks, Outlook/Google-style email/calendar, Slack/Teams-style chat, SharePoint/Drive-style document stores, Excel/xlsx ingestion, DuckDB/SQLite local analytics, and publishing surfaces are modeled as replaceable connectors.
- **A local analytics pattern**: schema, seed data, and queries live in git; generated `.duckdb` files stay local and ignored.
- **Workflow packs** for morning brief, end-of-day, weekly business review/projections/callouts, wiki maintenance, eval routing, compression/curriculum, and public export.
- **Agent team patterns**: researcher/writer/reviewer roles, wiki-team process, eval-team concepts, and compression/curation agents.
- **Evaluation before mutation**: changes can be scored, reviewed, kept, or reverted instead of blindly accepted.
- **A public export boundary**: templates and generated catalogs let the architecture be shared without exposing private operating data.

## The problems this system is working through

This project exists because several problems show up once AI work becomes daily infrastructure rather than one-off prompting:

1. **Tool churn** — Aki, Kiro, Quick Desktop, coding agents, chat models, and future tools have different capabilities. The operating layer should survive them.
2. **Context sprawl** — memory, tasks, relationship context, strategy, logs, and workflows become too large for one prompt or one app.
3. **Runtime coupling** — hardcoded home paths, temp directories, shell assumptions, connector availability, and app-specific hooks break portability.
4. **Invisible workflow failures** — a hook that fails silently can be worse than no automation. Workflows need status, failure logs, and degraded modes.
5. **Unsafe publication boundaries** — the private working layer contains real data; public examples must preserve structure and reasoning without copying private content.
6. **Data/prose mismatch** — some memory belongs in markdown; some belongs in a local analytical store; the system needs both.
7. **Quality control** — generated work needs reviewers, claim validation, eval routing, and keep/revert gates.
8. **Recoverability** — a fresh runtime should be able to reconstruct the operating model from files, not hidden app state.

## Replicate it on another machine

This repo is designed to be opened by Codex, Claude Code, Antigravity 2, Aki, Kiro, Quick Desktop, or a general coding agent on a fresh machine. The replication path is:

1. Read `AGENTS.md` so the AI runtime understands the workspace contract.
2. Read `docs/system-map.md` for the visual architecture.
3. Read `docs/recreate-agent-bridge-system.md` to create a private production instance from this public reference.
4. Use `docs/replication-checklist.md` to verify the new machine/runtime can read, edit, run, degrade, and publish safely.
5. Fill `context/body/`, `context/config/`, `connectors/`, `data/duckdb/`, and `workflows/` with your own private data and tool choices.

The thing to replicate is not merely this public repo. It is the **operating pattern used by the private working layer**: repo-root paths, body memory, protocols, hooks, agents, connector interfaces, local analytics, workflow state, audits, and public/private export boundaries.

## Where the most interesting workflows live

| Workflow | What it demonstrates | Public path |
|---|---|---|
| Morning brief | multi-source ingest, degraded mode, task/calendar/chat connectors | `workflows/morning-brief/` |
| End-of-day | daily reconciliation, meeting/task routing, status outputs | `workflows/end-of-day/` |
| Weekly business review | Excel/xlsx ingest, forecast refresh, projection scoring, callout writing, dashboard refresh | `workflows/weekly-business-review/` |
| Wiki maintenance | researcher → writer → critic → librarian → concierge pattern | `workflows/wiki-maintenance/` |
| Eval routing | independent evaluators, review lenses, keep/revert decisions | `workflows/eval-routing/` |
| Compression/curriculum | context-size management via experiment loops and evaluations | `workflows/karpathy-compression/` |
| Public export | how private operating logic becomes a sanitized public reference | `workflows/public-export/` |

## How to read this repo

Fast path:

1. `AGENTS.md` — bootstrap contract.
2. `docs/START-HERE.md` — tour through the repo.
3. `docs/system-map.md` — visual map of runtimes, repo layer, connectors, workflows, analytics, and public/private boundary.
4. `docs/recreate-agent-bridge-system.md` — detailed guide for reproducing the private working-layer pattern on another machine.
5. `docs/replication-checklist.md` — validation checklist for Codex, Claude Code, Antigravity 2, Aki, Kiro, Quick Desktop, or another runtime.
6. `docs/architecture/tool-landscape.md` — why this must be portable across tools.
7. `context/body/body.md` — navigation map for the body system.
8. `context/protocols/path-standardization.md` — the path portability contract.
9. `workflows/weekly-business-review/README.md` — example of a data + narrative workflow.
10. `workflows/karpathy-compression/README.md` — example of eval-driven context evolution.
11. `connectors/README.md` — how tool integrations are abstracted.

Deeper path:

- `docs/catalog/hooks.md` — hook/workflow inventory.
- `docs/catalog/protocols.md` — protocol inventory.
- `docs/catalog/agents.md` — agent/team inventory.
- `data/duckdb/README.md` — local analytics pattern.
- `context/active/hook-contract-table.md` — how active workflows are indexed.

## What this intentionally does not contain

- Real company, customer, project, organization structure, private workplace data, or real performance data.
- Real Slack/Asana/SharePoint IDs, document URLs, calendar IDs, or task IDs.
- Real meeting notes, relationship notes, career material, internal strategy, credentials, or operational secrets.
- The private working repo history.

The goal is not to publish someone's private assistant state. The goal is to publish a **repeatable operating structure** that another person or team can adapt safely.
