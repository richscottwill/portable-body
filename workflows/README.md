# Workflow Packs

Workflow packs are the highest-level replication units. Each pack describes one recurring operating workflow and points to the protocols, hooks, agents, connectors, state files, and local analytics patterns needed to recreate it.

Recommended enablement order:

1. `weekly-business-review/` — spreadsheet ingestion, projections, callouts, dashboards.
2. `end-of-day/` — daily reconciliation and status outputs.
3. `morning-brief/` — multi-source planning and triage.
4. `wiki-maintenance/` — knowledge base maintenance through agent teams.
5. `eval-routing/` — independent review and keep/revert gates.
6. `karpathy-compression/` — context compression through experiments and evals.
7. `public-export/` — sanitized public/reference layer generation.

A workflow is portable when it can state its required capabilities and degrade honestly when a runtime lacks them.
