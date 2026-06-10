# System Map — Portable AI Operating Layer

This map shows the public, vendor-neutral version of the private operating system pattern. The goal is not to run one exact app. The goal is to keep the operating layer in a repo that many tools can read, modify, test, and execute.

## Visual map

```mermaid
flowchart TB
  Human["Human operator / team"] --> Runtime

  subgraph Runtime["Runtime layer: replaceable AI tools"]
    Aki["Aki-style local agent shell"]
    KiroServer["Kiro server / devspace hooks"]
    KiroLocal["Kiro local"]
    Quick["Quick Desktop / local desktop app"]
    Claude["Claude Code / Codex / coding agents"]
    Chat["General chat models"]
  end

  Runtime --> Bootstrap

  subgraph Repo["Repo-native operating layer: the durable system"]
    Bootstrap["AGENTS.md + docs/START-HERE.md\nbootstrap and routing"]
    Body["context/body/\nidentity, principles, current state, memory, tasks, observation"]
    Protocols["context/protocols/\nworkflow contracts, failure rules, eval rules"]
    Hooks[".kiro/hooks/\nthin trigger envelopes"]
    Agents[".kiro/agents/\nspecialist roles and review lenses"]
    Workflows["workflows/\nend-to-end operating packs"]
    State["context/active/ + context/intake/\nstatus, queues, run records, logs"]
    Analytics["data/duckdb/\nlocal analytical store pattern"]
    Catalogs["docs/catalog/\ninventory of hooks, protocols, agents, workflows"]
  end

  Bootstrap --> Body
  Body --> Protocols
  Protocols --> Hooks
  Protocols --> Agents
  Protocols --> Workflows
  Hooks --> State
  Agents --> State
  Workflows --> State
  Workflows --> Analytics
  Catalogs --> Hooks
  Catalogs --> Protocols
  Catalogs --> Agents

  subgraph Connectors["Connector layer: replaceable external tools"]
    Tasks["Task systems\nAsana / Jira / Linear / GitHub Issues"]
    Mail["Email + calendar\nOutlook / Google Workspace"]
    ChatSys["Chat\nSlack / Teams / Discord"]
    Docs["Document stores\nSharePoint / Drive / Notion / Confluence"]
    Sheets["Spreadsheets\nExcel / CSV / Sheets exports"]
    Publish["Publish surfaces\ndashboards / docs / reports"]
  end

  Workflows --> Connectors
  Analytics --> Sheets
  State --> Publish

  subgraph Boundary["Public/private boundary"]
    Private["Private production instance\nreal data, credentials, people, metrics"]
    Public["Portable Body reference implementation\nsanitized templates + generated catalogs"]
    Scanner["scan_public_export.py\nleak gate before publish"]
  end

  Repo --> Private
  Repo --> Public
  Public --> Scanner
```

## Read the map in four passes

1. **Runtime pass:** Aki, Kiro, Quick Desktop, Codex, Claude Code, Antigravity, and chat models are execution surfaces. None of them is the source of truth.
2. **Repo pass:** the repo is the operating layer. It stores memory, protocols, hooks, agents, workflow packs, state contracts, and local analytics schemas.
3. **Connector pass:** Asana, Outlook, Slack, SharePoint, Excel, DuckDB, and similar systems are connector categories. They are allowed public concepts; real IDs/data are not.
4. **Boundary pass:** private production content stays private. Public examples preserve structure, rationale, and workflow logic without copying sensitive state.

## Why this matters

AI tools move quickly. If your operating system lives inside one app, it breaks when the app, model, connector, or runtime changes. If the operating system lives in a repo with explicit protocols and capability contracts, a new tool can load the repo and continue the work.
