# Start Here — Portable Body Tour

This repo is a sanitized map of a portable AI operating layer. It is not tied to one app. It is designed around a stable repo shape that can be read by many runtimes.

## Five-minute tour

1. `README.md` — the portability thesis and repo map.
2. `AGENTS.md` — the bootstrap an AI runtime reads first.
3. `context/body/body.md` — the navigation map for body-system files.
4. `docs/architecture/tool-landscape.md` — why the system is designed for Aki, Kiro, Quick Desktop, coding agents, and future tools.
5. `context/protocols/path-standardization.md` — the core repo-root contract.
6. `.kiro/hooks/thin-hook.example.md` — the thin-hook pattern.

## Twenty-minute tour

After the five-minute tour, read:

- `docs/architecture/runtime-capability-model.md` — how runtimes differ.
- `docs/architecture/adapter-patterns.md` — how workflows avoid hardcoding one tool.
- `context/config/runtime-capabilities.example.json` — machine-readable capability map.
- `context/active/hook-contract-table.md` — how workflows are indexed.
- `docs/examples/sanitized-session-flow.md` — a full run with private details removed.

## What to copy into your own system

Copy the structure, not the fictional example content:

- `AGENTS.md` for bootstrap.
- `context/body/` for durable context.
- `context/protocols/` for reusable operating contracts.
- `.kiro/hooks/` or equivalent for thin automation envelopes.
- `context/config/runtime-capabilities.example.json` for runtime planning.
- `tools/portable-body-export/` pattern for public/export safety.


## Replication path

If your goal is to recreate the private working-layer pattern on another machine, read these in order:

1. `docs/system-map.md` — visual map of the operating layer.
2. `docs/recreate-agent-bridge-system.md` — step-by-step reproduction guide.
3. `docs/replication-checklist.md` — machine/runtime validation checklist.
4. Directory README files under `.kiro/`, `context/`, `docs/`, `workflows/`, `connectors/`, and `data/` — deeper maps for each subsystem.

A new runtime should be able to read those files and explain how it would run or degrade each workflow.
