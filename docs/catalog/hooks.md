# Hook Catalog — Public-Safe

This catalog is generated from private hook metadata. It preserves the workflow map without copying hook prompt bodies.

| Private hook path | Showcase name | Trigger | Runtime tag | Pattern shown |
|---|---|---|---|---|
| .kiro/hooks/agent-bridge-sync.kiro.hook | 06 · Agent Bridge Sync | userTriggered | both | durability / repository synchronization |
| .kiro/hooks/am-auto.kiro.hook | .AM-Backend: Ingest + Process | userTriggered | local-only | morning orchestration |
| .kiro/hooks/am-backend.kiro.hook | 01 · AM Backend | userTriggered | server-only | morning orchestration |
| .kiro/hooks/am-frontend.kiro.hook | 02 · AM Frontend | userTriggered | server-only | morning orchestration |
| .kiro/hooks/audit-asana-writes.kiro.hook | · _ Audit: Asana Writes (postToolUse) | postToolUse | both | safety guardrail |
| .kiro/hooks/context-preloader.kiro.hook | · _ Context Pre-Loader (promptSubmit) | promptSubmit | local-only | workflow trigger |
| .kiro/hooks/data-freshness-warning.kiro.hook | · _ Data Freshness Warning (promptSubmit) | promptSubmit | both | morning orchestration |
| .kiro/hooks/duckdb-onedrive-push.kiro.hook | · _ DuckDB OneDrive Push (fileEdited) | fileEdited | server-only | morning orchestration |
| .kiro/hooks/eod-meeting-sync.kiro.hook | .EOD-Backend: Sync + Reconcile + Maintain | userTriggered | local-compatible | daily closeout orchestration |
| .kiro/hooks/eod-refresh.kiro.hook | .EOD-Frontend: Summary + Decisions | userTriggered | local-compatible | daily closeout orchestration |
| .kiro/hooks/eod.kiro.hook | 03 · EOD (Sync + Summary + Decisions) | userTriggered | portable | daily closeout orchestration |
| .kiro/hooks/forecast-sharepoint-push.kiro.hook | · _ Forecast SharePoint Push (fileEdited) | fileEdited | server-only | weekly review / projection pipeline |
| .kiro/hooks/git-change-mesh-edit.kiro.hook | · _ Git Change Mesh (fileEdited) | fileEdited | local-only | workflow trigger |
| .kiro/hooks/git-kiro-sync-new.kiro.hook | · _ Git Kiro Sync New (fileCreated) | fileCreated | local-only | durability / repository synchronization |
| .kiro/hooks/git-kiro-sync.kiro.hook | · _ Git Kiro Sync (fileEdited) | fileEdited | local-only | durability / repository synchronization |
| .kiro/hooks/git-pull-sync.kiro.hook | 10 · Git Pull + Sync (local) | userTriggered | local-only | durability / repository synchronization |
| .kiro/hooks/guard-asana.kiro.hook | · _ Guard: Asana (preToolUse) | preToolUse | both | safety guardrail |
| .kiro/hooks/guard-calendar.kiro.hook | · _ Guard: Calendar (preToolUse) | preToolUse | both | safety guardrail |
| .kiro/hooks/guard-email.kiro.hook | · _ Guard: Email (preToolUse) | preToolUse | both | safety guardrail |
| .kiro/hooks/harmony-forecast-deploy.kiro.hook | · _ Harmony Forecast Deploy (fileEdited) | fileEdited | server-only | morning orchestration |
| .kiro/hooks/mpe-parity.kiro.hook | · _ MPE Parity (fileEdited) | fileEdited | server-only | workflow trigger |
| .kiro/hooks/open-items-reminder.kiro.hook | · _ Open Items Reminder (promptSubmit) | promptSubmit | both | workflow trigger |
| .kiro/hooks/organ-change-detector.kiro.hook | · _ Organ Change Detector (fileEdited) | fileEdited | both | workflow trigger |
| .kiro/hooks/pre-mortem-nudge.kiro.hook | · _ Pre-Mortem Nudge (postToolUse) | postToolUse | both | morning orchestration |
| .kiro/hooks/public-demo-store-dashboard-rebuild.kiro.hook | 11 · public-demo-store-dashboard Redeploy | userTriggered | server-only | morning orchestration |
| .kiro/hooks/public-demo-store-dashboard-wiki-refresh.kiro.hook | · _ public-demo-store-dashboard Wiki Refresh (fileEdited) | fileEdited | server-only | knowledge base maintenance |
| .kiro/hooks/session-summary.kiro.hook | · _ Session Summary (agentStop) | agentStop | both | workflow trigger |
| .kiro/hooks/sharepoint-sync.kiro.hook | 07 · SharePoint Sync | userTriggered | both | morning orchestration |
| .kiro/hooks/state-file-constraints-sync.kiro.hook | · _ State File Constraints Sync (fileEdited) | fileEdited | server-only | weekly review / projection pipeline |
| .kiro/hooks/steering-integrity-check.kiro.hook | · _ Steering Integrity Check (fileCreated) | fileCreated | both | workflow trigger |
| .kiro/hooks/wbr-callouts.kiro.hook | 05 · WBR Callouts (weekly) | userTriggered | portable-candidate | weekly review / projection pipeline |
| .kiro/hooks/wbr-pipeline-trigger.kiro.hook | · _ WBR Pipeline Trigger (fileCreated) | fileCreated | server-only | weekly review / projection pipeline |
| .kiro/hooks/weekly-learning-review.kiro.hook | 12 · Weekly Learning Review (Friday weekly) | userTriggered | portable | log consumption and learning loop |
| .kiro/hooks/wiki-health-snapshot.kiro.hook | · _ Wiki Health Snapshot (fileEdited) | fileEdited | server-only | knowledge base maintenance |
| .kiro/hooks/wiki-maintenance.kiro.hook | 04 · Wiki Maintenance (Friday weekly) | userTriggered | both | morning orchestration |
| .kiro/hooks/writing-quality-audit.kiro.hook | 08 · Writing Quality Audit | userTriggered | both | weekly review / projection pipeline |
| .kiro/hooks/youtube-feed-sync.kiro.hook | 09 · YouTube Feed Sync | userTriggered | both | morning orchestration |
