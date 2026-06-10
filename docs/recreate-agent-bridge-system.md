# Recreate the Agent-Bridge-Style System on Another Machine

This guide is for someone opening this repo with Codex, Claude Code, Antigravity 2, Aki, Kiro, or another coding/agent runtime. It explains how to recreate a private operating layer like the production `agent-bridge` system using your own tools and data.

This repo is the public reference implementation. Your private instance should be a separate repo that follows the same shape.

## Target outcome

After setup, your private repo should have:

- a bootstrap file that tells AI runtimes how to operate,
- body files for durable context and memory,
- protocols for repeated workflows,
- hooks or equivalent trigger envelopes,
- specialist agent definitions,
- connector interfaces for your tools,
- a local analytical store for tabular memory,
- workflow packs for your recurring operations,
- state/log surfaces for observability,
- tests/audits to catch portability regressions,
- a public/private boundary for sanitized sharing.

## Step 1 — Clone and open with your runtime

```bash
git clone https://github.com/richscottwill/portable-body.git my-operating-layer
cd my-operating-layer
```

Open the folder in one of these tools:

- **Claude Code / Codex / Antigravity 2:** use it as a coding workspace. Ask it to read `AGENTS.md`, `docs/START-HERE.md`, and this file before editing.
- **Aki-style local agent shell:** set the workspace to this repo and use shell/file tools to modify it.
- **Kiro server/local:** install or mirror `.kiro/hooks/` and `.kiro/agents/` according to your Kiro setup.
- **Quick Desktop or another desktop app:** use the repo as the local filesystem context; workflows that need shell/git/connectors should degrade to runbooks if the app cannot execute them.

## Step 2 — Create your private production repo

Do not put real data directly into this public reference repo. Create a private repo:

```bash
cp -R my-operating-layer my-agent-bridge
cd my-agent-bridge
git remote remove origin
# create your private remote, then add it here
```

Rename the project if needed, but keep the shape:

```text
AGENTS.md
.kiro/hooks/
.kiro/agents/
context/body/
context/protocols/
context/active/
context/intake/
context/config/
connectors/
data/duckdb/
workflows/
docs/catalog/
tools/
```

## Step 3 — Fill the body files

Start with these files:

- `context/body/soul.md` — operating principles and decision style.
- `context/body/spine.md` — canonical system map and tool routing.
- `context/body/body.md` — what to load for which task.
- `context/body/current.md` — active work and near-term priorities.
- `context/body/memory.md` — durable user/system preferences. Keep sensitive relationship notes private.
- `context/body/hands.md` — task/action surfaces.
- `context/body/eyes.md` — dashboards, signals, observation surfaces.

Keep the body small enough for agents to load selectively. Put routing in `body.md` and task-specific details in the relevant organ.

## Step 4 — Configure runtime capabilities

Copy and edit:

```text
context/config/runtime-capabilities.example.json
```

Define what each runtime can do:

- shell
- git
- filesystem read/write
- hooks
- agent dispatch
- browser
- task connector
- email/calendar connector
- chat connector
- document store connector
- local analytics
- publishing

A workflow should fail gracefully when a runtime lacks a capability. Missing capability should produce a degraded mode, not silent failure.

## Step 5 — Choose connectors

Use `connectors/` as your adaptation layer. For each connector category, pick your tool and write the minimal interface:

| Category | Examples | What to define |
|---|---|---|
| Tasks | Asana, Jira, Linear, GitHub Issues | fields, statuses, write safety, audit log |
| Email/calendar | Outlook, Google Workspace | query window, draft/send boundary, timezone rules |
| Chat | Slack, Teams, Discord | channels, DMs, history, draft/post boundary |
| Document store | SharePoint, Drive, Notion, Confluence | source of truth, publish path, conflict handling |
| Spreadsheet ingestion | Excel, CSV, Sheets exports | schema checks, freshness, data quality gates |
| Local analytics | DuckDB, SQLite | schema, seed data, queries, read/write rules |
| Publishing | dashboards, docs, reports | human approval, failure recovery, visibility |

## Step 6 — Generate local analytics

The public repo includes schema and seed examples, not a binary database.

```bash
mkdir -p data/duckdb
duckdb data/duckdb/demo.duckdb < data/duckdb/schema.example.sql
duckdb data/duckdb/demo.duckdb < data/duckdb/seed.example.sql
duckdb data/duckdb/demo.duckdb < data/duckdb/queries/workflow-health.example.sql
```

In your private instance, use a local database path override such as:

```text
LOCAL_ANALYTICS_PATH=<repo-root>/data/duckdb/private.duckdb
```

Keep generated `.duckdb` files out of public repos.

## Step 7 — Enable workflow packs

Start with one workflow. Do not enable everything at once.

Recommended order:

1. `workflows/weekly-business-review/` if your work has recurring metrics, projections, callouts, or dashboards.
2. `workflows/end-of-day/` if you need daily reconciliation.
3. `workflows/morning-brief/` if you need daily planning from multiple sources.
4. `workflows/wiki-maintenance/` if you maintain a knowledge base.
5. `workflows/eval-routing/` before allowing agents to rewrite important docs.
6. `workflows/karpathy-compression/` once your context is large enough to need systematic compression.
7. `workflows/public-export/` when you want a sanitized public or team-shareable layer.

For each workflow, define:

- trigger,
- required capabilities,
- optional capabilities,
- input surfaces,
- output surfaces,
- state records,
- failure recovery,
- degraded mode,
- approval boundary.

## Step 8 — Install hooks or equivalent triggers

If your runtime supports hooks, adapt `.kiro/hooks/`. If not, keep hooks as runbooks.

A good hook is thin:

```text
trigger -> path/capability preflight -> read protocol -> execute phases -> write state -> report
```

Do not bury durable logic in a JSON hook string. Put the logic in `context/protocols/` and let hooks delegate.

## Step 9 — Add agent teams

Use `.kiro/agents/` for specialist roles. The public repo has generic examples; the catalogs show richer team patterns.

Common teams:

- researcher / writer / reviewer,
- wiki researcher / writer / critic / librarian / concierge,
- eval agents with different lenses,
- compression/curation agents,
- sync/audit agents.

Agent instructions should state:

- what they own,
- what they must not do,
- input/output format,
- quality bar,
- failure mode,
- escalation path.

## Step 10 — Add tests and audits

At minimum, create checks for:

- no machine-specific paths in portable files,
- generated database files ignored,
- connector config not committed,
- public export scan passes,
- workflow state schema valid,
- hook catalog up to date,
- local analytics queries compile.

The production system uses portability audits heavily because path drift and runtime assumptions are the most common failure mode.

## Step 11 — Validate on another machine/tool

A fresh runtime should be able to do this:

1. Read `AGENTS.md`.
2. Read `docs/START-HERE.md`.
3. Read `docs/system-map.md`.
4. Read this guide.
5. Resolve `<repo-root>`.
6. Identify available capabilities.
7. Pick one workflow pack.
8. Run or simulate the workflow.
9. Write output under `context/active/` or `context/intake/`.
10. Explain degraded capabilities honestly.

If a tool cannot execute shell commands, it should still be able to read the protocols and produce a manual run plan.

## Step 12 — Keep public and private layers separate

Use this rule:

```text
private repo = real work, real data, real connectors
public repo = reusable architecture, fictional examples, generated catalogs, sanitized templates
```

Never blind-sync private content into public. Export from an allowlist and scan before publishing.
