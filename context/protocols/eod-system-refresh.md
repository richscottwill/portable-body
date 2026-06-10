# Eod System Refresh — Sanitized Workflow Pattern

Private source path: `context/protocols/eod-system-refresh.md`
Public status: sanitized structural export. This preserves workflow mechanics and removes private people, internal projects, IDs, URLs, and live data.

## What this demonstrates

- Trigger and precondition design
- Phase/step sequencing
- Visible degraded modes
- File/protocol boundaries
- Failure recovery and auditability
- Runtime portability via `<repo-root>` and capability checks

## Sanitized structure

<!-- DOC-XXXX | duck_id: protocol-eod-system-refresh -->
# EOD System Refresh Protocol

## Portability contract

Apply `<repo-root>/context/protocols/path-standardization.md` before execution. Resolve `<repo-root>` from `$AGENT_BRIDGE_ROOT` or `tools/scripts/agent_bridge_paths.py root`; do not assume a literal `<repo-root>` checkout. For executable shell snippets, set `REPO_ROOT=<resolved repo root>` and use `$REPO_ROOT/...`. Use `$PS_DUCKDB_PATH` for DuckDB override when needed; otherwise default to `<repo-root>/data/duckdb/ps-analytics.duckdb`.

## Pause Flag (operator kill switch)

If `<repo-root>/context/active/eod-paused.flag` exists, skip all phases and exit silently. Use case: pause EOD mid-day without editing protocol or killing the agent. Removing the flag re-enables EOD on next invocation. Check this BEFORE Step 0 to avoid wasting the Delta Sync round-trip on a paused run.

Phases ordered by criticality. Execute in order. Do not skip ahead.

All Asana writes follow the Guardrail Protocol in asana-command-center.md.

## Phase 1: Asana EOD Reconciliation

### Context Load
DuckDB: All queries go through DuckDB MCP (`execute_query`). Do NOT use Python `duckdb.connect()` with DuckDB tokens. The MCP server is already connected to `ps_analytics`. If a query fails, check MCP server status — do not fall back to direct Python connections.

### Step 0 — Asana Delta Sync to DuckDB
Execute the Delta Sync procedure from <repo-root>/context/protocols/asana-duckdb-sync.md:
1. Pull today's completions → UPDATE asana_tasks
2. Detect new tasks since morning → INSERT into asana_tasks
3. Update daily snapshot in asana_task_history
4. Run coherence check (DuckDB vs hands.md, current.md, asana-command-center.md)
5. Query schema_changes for today's drift events → include in summary if any

### Step 0 failure recovery

If Step 0 fails (MCP timeout, schema drift on `asana_tasks`, DuckDB connection error, coherence check inconsistency), follow this branch — do NOT silently proceed to Phase 2:

1. **Classify the failure:**
   - **MCP timeout / transient error:** retry Step 0 once after a 5-second sleep. If the second attempt succeeds, log the transient and continue.
   - **Schema drift (column missing, type mismatch on `asana_tasks` or `asana_task_history`):** hard-fail. Schema bugs require a migration; retrying produces the same error. Log to `<repo-root>/context/active/eod-system-refresh-errors.jsonl` with `phase: "step0_schema_drift"` and the offending column. Skip ALL downstream phases.
   - **Coherence check failure (DuckDB vs hands.md/current.md disagrees):** hard-fail with a structured diff. The coherence check IS the gate per the worked failure above — proceeding past a known disagreement is exactly what produced the 2026-04-23 double-booking incident.
2. **Surface the failure to ExamplePerson** — print the structured diff or error to chat. EOD-Frontend should NOT present a summary built on a known-broken backend; it should display the Step 0 failure so ExamplePerson knows the day's reconciliation didn't run.
3. **Halt downstream phases** (Phase 2 onwards). Do NOT do partial reconciliation, do NOT update hands.md, do NOT mark anything completed. Asana stays on its prior state until Step 0 succeeds on the next invocation.
4. **Recovery for next run:** the failure log persists. The next EOD invocation reads the log first; if the same schema_drift signature is unresolved, it surfaces a `[eod] step 0 still broken — schema migration pending` message instead of attempting Step 0 again. Resolution requires ExamplePerson to apply a migration.

### Step 1 — Pull Current State (via DuckDB + Time Travel)
1. Query DuckDB: `SELECT * FROM asana_tasks WHERE completed = FALSE AND deleted_at IS NULL` → all incomplete tasks.
2. Query DuckDB: `SELECT * FROM asana_tasks WHERE completed = TRUE AND completed_at::DATE = CURRENT_DATE` → tasks completed today.
3. **Time travel diff against morning state:** Instead of reading asana-morning-snapshot.json, clone the morning snapshot:
**Fallback:** If no AM snapshot exists , fall back to reading `<repo-root>/context/active/asana-morning-snapshot.json`.
4. Query DuckDB: `SELECT * FROM asana_overdue` → overdue tasks with days_overdue.
5. Query DuckDB: `SELECT priority_rw, COUNT(*) FROM asana_tasks WHERE completed=FALSE AND deleted_at IS NULL GROUP BY priority_rw` → Today/Urgent counts for over-commitment check.

### Step 2 — Daily Reset
- Demote to Priority_RW=Urgent: UpdateTask(custom_fields={'<id>': '<id>'})
- Update Kiro_RW: 'M/D: Carried fwd. [reason]. [next action].'
- This ensures tomorrow's AM-2 starts with a clean Today slate.

### Step 3 — Recurring Task Check
For each task completed today, check if it matches a known recurring pattern (Weekly Reporting, Recurring Reporting, MarketA meeting agenda, MBR callout, ie%CCP calc, MarketA invoice, budget confirmation, Bi-monthly Flash, Individual Goals update, Bi-weekly with ExamplePerson).
- If recurring: verify next instance exists (search by name + future due date).
- If missing: flag 'Recurring task [name] completed — next instance needed. Cadence: [X]. Create now?'
- If ExamplePerson approves: create next instance with same Priority_RW + project.

### Step 4 — Update rw-tracker.md
- Tasks completed today (names + ⭐ if Important)
- Tasks carried forward; New tasks received since morning
- Net delta; Today/Urgent counts

### Step 5 — Five Levels Breakdown
- Format: 'Five Levels today: L1: X, L2: Y, L3: Z, L4: W, L5: V.'
- Highlight zero-effort levels: 'No L1 effort today — streak at risk.'

### Step 6 — Blocker Registry
- Update hands.md blocker list: task name, blocker description, owner, date first detected, days blocked.
- Format: '2 blocked: [task] on [owner] (Nd), [task] on [owner] (Nd).'

### Step 7 — New Task Detection

### Step 8 — Update hands.md

### Step 9 — State File Priority Patching
For each registered state file in `<repo-root>/context/protocols/state-file-engine.md` where status = ACTIVE:
1. Read the current state file .md from `<repo-root>/wiki/state-files/`
2. Filter today's reconciliation data to market-relevant tasks:
   - MarketB: tasks in MarketB project (GID from asana-command-center.md)
   - MarketA: tasks in MarketA project
   - WW Testing: tasks in WW Testing project
3. Regenerate ONLY the Strategic Priorities section:
   - Update priorities table with current deadlines and completion status
   - Update blocked items from the blocker registry (Step 6 output)
   - Update stakeholder actions from Asana comments and email signals
4. Patch the local .md file (touch ONLY Strategic Priorities + Blocked Items + Stakeholder Actions)
5. Validate: `python3 "$REPO_ROOT"/tools/state-files/validate_state_files.py`
7. Log to DuckDB: `INSERT INTO workflow_executions (workflow_name, ...) VALUES ('state-file-eod-patch-[market]', ...)`

**Validation-failure recovery (Step 5):** If `validate_state_files.py` exits non-zero after the patch, do NOT run the converter (Step 6) or log a success row (Step 7). Restore the pre-patch .md from the wiki snapshot, log `[state-file-eod-patch-<market>] validation_failed: <first error line>` to the EOD failures log, and surface the market as a degraded signal in the EOD summary. A failed patch must never produce a published .docx — a stale-but-valid state file beats a fresh-but-malformed one.

### Common EOD Failures
| Failure | Impact | Prevention |
|---------|--------|-----------|
| Patching State of Business section at EOD | Overwrites AM analysis with stale data | Only patch Strategic Priorities + Blocked Items + Stakeholder Actions |
| Skipping validate_state_files.py | Broken state file deployed to SharePoint | Always run validation before convert |
| Missing blocker registry update before state file patch | State file shows stale blockers | Run Step 6 before Step 9 |

## Phase 2: Portfolio Reconciliation

### Wiki Article Pipeline Reconciliation

Wiki articles are tracked in the Kiro dashboard (`shared/dashboards/wiki-search.html` Pipeline view) and stored in `<repo-root>/wiki/agent-created/`, with published copies in SharePoint `Documents/Artifacts/`. Reconciliation does NOT touch Asana for article work.

a. Rebuild the wiki search index: `python3 "$REPO_ROOT"/dashboards/build-wiki-index.py`. This crawls `<repo-root>/wiki/agent-created/` and refreshes `shared/dashboards/data/wiki-search-index.json`. Status badges (DRAFT/REVIEW/FINAL) come from article frontmatter.

c. SharePoint sync check: for any article whose frontmatter status is FINAL and whose local .md is newer than the corresponding `Documents/Artifacts/*/[slug].docx` in SharePoint, flag for the librarian to re-publish. Do not auto-publish — FINAL promotion is a human decision.

### Step 10B — Completion Section Moves

1. Check if the task is in a non-terminal section (i.e., not already in a Complete section).
2. If yes, move it to the project's terminal section via AddTaskToSection or section membership update.
3. Terminal section GID map:
   - MarketA Complete: `<id>`; MarketB Complete: `<id>`
   - WW Testing Complete: `<id>`
   - WW Acquisition Complete: `<id>`
   - Paid App Complete: `<id>`
4. Log each section move in the audit trail: `{"tool":"SectionMove","task_gid":"...","from_section":"...","to_section":"Complete","project":"...","result":"success"}`.
5. Skip tasks that are already in a terminal section or have no project membership.

### Portfolio Project Reconciliation

a. Use the morning time travel clone (from Step 1) or query `asana_task_history` for morning snapshot data. If the morning_state database is still attached, use it directly. Otherwise query:

d. Portfolio EOD output:
- Completed: [N] tasks across [projects]
- New overdue: [N] tasks
- Enrichment: [N] fields filled (coverage: [morning]% → [current]%)
- Recurring: [N] new instances; Blockers: [N] new, [N] resolved

### Context Surface Refresh (weekly, or on significant changes)
- Update MarketA context task (GID: `<id>`) html_notes with current state.
- Update MarketB context task (GID: `<id>`) html_notes with current state.
- Read-before-write. Keep under 4000 chars. M/D date stamps. Recent Decisions is append-only.
- Frequency: every Friday EOD, or on major decision/status change.

### Weekly Scorecard (Friday only)
Compile for rw-tracker.md: strategic artifacts shipped (⭐ Important completed this week), tools built, low-leverage volume (quick/admin tasks completed), meetings with clear output.

## Phase 3: Organ Cascade + Maintenance

### Compression Audit
1. Count words in each organ file (`<repo-root>/context/body/*.md`). Log to DuckDB `organ_word_counts` (organ_name, measured_date, word_count) AND `body_size_history` (with Bayesian prior signals):

2. Query the `prior_convergence` view for budget signals:
3. Sum total body word count. Log it. No hard ceiling — the `organ_size_accuracy` view tracks the size-accuracy curve.
4. Report only when priors suggest action: `🫁 Body: [X]w. [organ] has compression signal (COMPRESS prior: [X], n=[X]).` If no organ has a compression signal, skip report entirely.

### Workflow Observability Check

1. **Degradation detection:** Query DuckDB for workflows with <80% success rate over 7 days:
SELECT workflow_name, success_rate, total_runs, avg_duration_s, last_run
FROM workflow_reliability
⚠️ Degraded workflows (7-day window):
• {workflow}: {success_rate}% success ({total_runs} runs)

2. **Workflow summary:** Query overall execution stats:
    COUNT(*) FILTER (WHERE status = 'failed') AS failures
FROM workflow_executions
🔧 Workflows (24h): {total_runs} runs, {success_rate}% success, avg {avg_duration_s}s. {failures} failures.

3. If no workflow_executions data exists yet, skip silently — no error.

### Maintenance
- Refresh ground truth in organs.
- Process intake/ files. Route Slack signals.
- Dashboard + focus update.

### Context Enrichment (KDS/ARCC)
Execute `<repo-root>/context/protocols/context-enrichment.md`:
1. Read current.md → extract active project names and topics
2. Generate 3-5 KDS queries from active projects
3. Execute KDS queries, score relevance (0-10) against project context
4. For findings with relevance >= 7: create intake files at `<repo-root>/context/intake/kds-{date}-{topic}.md`
5. Route findings: strategic → brain.md, market data → eyes.md, relationships → memory.md

### Cascade

## Phase 4: Recurring Task State Checks

Query DuckDB `recurring_task_state` table instead of reading JSON file. For each task:
- Compute current_period from today's date and cadence (monthly=YYYY-MM, weekly=YYYY-WNN, quarterly=YYYY-QN).
- If last_run_period != current_period → task is DUE.
- Run all due tasks. After each, update DuckDB:
- Also update the JSON file as fallback: `<repo-root>/context/active/recurring-task-state.json` (keep in sync until fully deprecated).
- Quick check view: `SELECT * FROM recurring_tasks_due WHERE is_due = TRUE;`

### Due Task Procedures
- **goal_updater** (monthly): Read asana-goal-updater-protocol.md. Execute Steps 1-8. Goal GIDs: <id>, <id>, <id>, <id>, <id>, <id>, <id>, <id>, <id>, <id>, <id>, <id>, <id>, <id>. Update children before parents. Draft-first.
- **meta_calibration_priors** (monthly): Prior-guided vs random comparison per meta-calibration-proposal.md.
- **meta_calibration_projections** (weekly): Audit last week's projection against actuals. Update MarketA-projections.md.
- **meta_calibration_output_quality** (quarterly): Validate output-quality prior convergence.
- **coherence_audit** (monthly): Cross-organ dependency matrix, gap/stale/dupe detection.
- **weekly_scorecard** (weekly/Friday): Compile weekly stats for rw-tracker.md.
- **context_surface_refresh** (weekly): Update MarketA/MarketB pinned context tasks in Asana.
- **agent_bridge_sync** (weekly/Friday): Sync shared/ to GitHub.

### Due Task Procedure: wiki_lint (DEPRECATED 2026-04-18)

Removed from daily EOD. Wiki maintenance runs as a separate manual hook: `shared/.kiro/hooks/wiki-maintenance.kiro.hook`. Trigger it manually (usually Friday). The hook covers:
- Consuming wiki-candidates.md from distributed hook contributions
- Orphan scan, stale content, broken cross-refs, missing frontmatter, SITEMAP drift, wiki-index consistency
- Signal-based freshness and idea sourcing from DuckDB
- Blackboard health check (until 2026-05-02 kill review)
- Roadmap update

### Communication Analytics (weekly)
Execute <repo-root>/context/protocols/communication-analytics.md:
- Compute weekly communication trends from meeting_analytics (trailing 4 weeks)
- Check coaching signal: group meeting speaking share < 15% for 3+ consecutive weeks
- Include trends in system refresh report
- If coaching signal active: flag in EOD-2 Slack DM

### Enrichments
- Weekly relationship (Friday). Monthly synthesis (1st). Quarterly audit (90d). Wiki maintenance moved to separate hook (shared/.kiro/hooks/wiki-maintenance.kiro.hook) — manual trigger, no longer daily.

**This phase is NOT expendable. Execute before experiments.**

- **DuckDB daily snapshot (via MCP):** Create a named snapshot for time travel and audit using `execute_query`:

<!-- Truncated for public showcase. Private implementation contains additional environment-specific details. -->


## Private details intentionally omitted

- real people, teams, organizations, and project names
- live connector IDs and private URLs
- private analytics, dashboards, and metric values
- internal document paths or URLs
- private career and relationship context
