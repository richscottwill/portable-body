# Replication Checklist

Use this checklist to verify that a new machine or AI runtime can recreate the operating layer.

## Fresh-clone checks

- [ ] Clone succeeds without private credentials.
- [ ] `AGENTS.md` explains how an AI runtime should start.
- [ ] `docs/START-HERE.md` gives a fast tour.
- [ ] `docs/system-map.md` explains the architecture visually.
- [ ] `docs/recreate-agent-bridge-system.md` gives setup steps.
- [ ] No generated `.duckdb` files are committed.
- [ ] No private IDs, credentials, or private paths appear.

## Runtime checks

For each target runtime — Codex, Claude Code, Antigravity 2, Aki, Kiro, Quick Desktop, or another tool — answer:

- [ ] Can it read files from the repo?
- [ ] Can it edit files?
- [ ] Can it run shell commands?
- [ ] Can it run git?
- [ ] Can it access browser or desktop surfaces?
- [ ] Can it call task/email/chat/document connectors?
- [ ] Can it run local analytics queries?
- [ ] Can it trigger hooks, or does it need manual runbooks?
- [ ] Can it spawn specialist agents, or does it need single-agent fallback?

Record answers in `context/config/runtime-capabilities.example.json` or your private equivalent.

## Directory-depth checks

- [ ] `.kiro/README.md` explains hooks and agents.
- [ ] `.kiro/hooks/README.md` explains the thin-hook contract.
- [ ] `.kiro/agents/README.md` explains role files and agent teams.
- [ ] `context/README.md` explains active/intake/body/protocol/config boundaries.
- [ ] `context/body/README.md` explains each organ.
- [ ] `context/protocols/README.md` explains workflow contracts.
- [ ] `docs/README.md` explains architecture, catalogs, and examples.
- [ ] `docs/catalog/README.md` explains generated inventories.
- [ ] `workflows/README.md` explains workflow packs and enablement order.
- [ ] `connectors/README.md` explains connector categories.
- [ ] `data/README.md` explains local analytics.

## Workflow checks

- [ ] Morning brief can be adapted to your task/calendar/chat connectors.
- [ ] End-of-day can write status outputs without sending anything automatically.
- [ ] Weekly business review can ingest spreadsheets and produce forecast/callout/dashboard outputs.
- [ ] Wiki maintenance can run researcher → writer → critic → librarian → concierge pattern.
- [ ] Eval routing can compare outputs before mutation.
- [ ] Compression/curriculum can reduce context with keep/revert gates.
- [ ] Public export can generate a sanitized layer from an allowlist.

## Safety checks

- [ ] Connector credentials live outside git.
- [ ] Private data lives in the private repo only.
- [ ] Public export is allowlisted.
- [ ] Public export scanner passes.
- [ ] Workflows have degraded modes.
- [ ] Human approval boundaries are explicit for external publishes or writes.
