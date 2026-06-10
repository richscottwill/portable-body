# Context Enrichment — Sanitized Workflow Pattern

Private source path: `context/protocols/context-enrichment.md`
Public status: sanitized structural export. This preserves workflow mechanics and removes private people, internal projects, IDs, URLs, and live data.

## What this demonstrates

- Trigger and precondition design
- Phase/step sequencing
- Visible degraded modes
- File/protocol boundaries
- Failure recovery and auditability
- Runtime portability via `<repo-root>` and capability checks

## Sanitized structure

<!-- DOC-XXXX | duck_id: protocol-context-enrichment -->
# Context Enrichment Protocol — Phase 2.5
*Reading order: top-to-bottom; later sections assume earlier ones. Skim the section headers first to find the right entry point for your task.*

> Step 2.5A (Meeting Series File Updates) as previously written depended on `main.meeting_analytics`, `main.meeting_highlights`, and `main.meeting_series` DuckDB tables. Those tables are deprecated.
> - Subagent E (AM-Backend Phase 1) now writes Hedy-sourced Log entries directly into `<repo-root>` per `<repo-root>`
> - Step 2.5B (Relationship Activity): meeting_counts now derives from counting Log entries across topic docs + meeting-series files rather than querying `meeting_analytics`
> - Step 2.5D (Five Levels Tagging): meeting signal now pulled from `signals.signal_tracker WHERE source_channel='hedy'` instead of `meeting_analytics`

Runs after Phase 2 (signal processing) and before Phase 3 (task enrichment). Takes the raw ingested data from Phase 1 and flows it into richer context stores that compound over time.

## Step 0: Precondition (early-exit, runs BEFORE any tier processing)

The enrichment phase MUST honor these checks before any DuckDB query, file read, or organ update:

1. **Pause flag.** If `<repo-root>` exists, exit silently with `[context-enrichment] paused: <flag line 2>`. Do NOT query DuckDB, do NOT read hedy-digest.md, do NOT update meeting series files, do NOT touch memory.md or current.md. The pause flag is the operator's kill switch during deprecation transitions (e.g., the 2026-05-06 meeting-tables migration above) or bulk wiki refactors where partial enrichment would create misleading staleness signals.
2. **Phase 1 complete.** If Phase 1 (signal ingestion) has not completed for today, surface a warning by writing one line to `<repo-root>` (`<ISO-timestamp> phase1-incomplete: <missing-source>`) and exit. Do NOT proceed with empty inputs — that produces a degraded enrichment that downstream agents cannot distinguish from a normal run.
3. **Deprecation guard.** Before any Step 2.5A SQL executes, scan the SQL string for the deprecated table names (`main.meeting_analytics`, `main.meeting_highlights`, `main.meeting_series`). If found, refuse to execute the query, log `[context-enrichment] deprecated-table-detected: <table>` to the failures log, and use the replacement source (topic-log Log entries / Hedy MCP / signals.signal_tracker) per the deprecation notice above.

**Worked example — deprecation guard fires.** A reused SQL fragment in Step 2.5A reads `SELECT meeting_id FROM main.meeting_analytics WHERE date >= CURRENT_DATE - 7`. The guard scans the string, matches `main.meeting_analytics`, refuses to execute, and writes `2026-05-29T03:20:00Z deprecated-table-detected: main.meeting_analytics` to `context-enrichment-failures.log`. Replacement: `SELECT topic, last_seen FROM signals.signal_tracker WHERE source_channel='hedy' AND last_seen >= CURRENT_TIMESTAMP - INTERVAL '7 days'` — same intent (recent meeting-derived signals) without the deprecated table. Lesson: the guard is a string-level scan, so SQL inside multi-line CTEs or comments still trips it; if a CTE is named `meeting_analytics_view` against a different schema, alias it locally to avoid the false positive.

Order matters: pause → phase1-complete → deprecation-guard. If deprecation-guard ran before pause, an operator pausing during a deprecation rewrite would still pay the cost of validating SQL strings — which scans protocol metadata and can trigger spurious warnings. If phase1-complete ran before pause, a paused enrichment would still touch the watermark store unnecessarily.

## Failure Recovery — Step 2.5A persistent failure

If Step 2.5A (Meeting Series File Updates) raises an error or returns malformed data:

1. **Do not retry inline.** Inline retries amplify upstream failures and can fan out into duplicate file writes if the meeting series file is left mid-write.
2. **Log the failure** to `<repo-root>` as one line:
   `<ISO-timestamp>\tStep2.5A\t<error_class>\t<one-line-message>`
3. **Skip Step 2.5A only.** Continue to Step 2.5B (Relationship Activity), Step 2.5C, and Step 2.5D — they read different sources and do not depend on Step 2.5A's writes.
4. **Three-strike circuit breaker.** If the failure log shows 3+ consecutive Step 2.5A failures within 7 days, the engine writes `<repo-root>` and skips this protocol entirely (all of Step 2.5A through Step 2.5D) until the flag is cleared by hand. Prevents a broken Hedy MCP credential or schema drift from spamming the failure log indefinitely.

## Value Weighting Framework

Not all ingested data deserves the same treatment. The enrichment phase applies a value weight to decide what gets short-form treatment (DuckDB row) vs long-form treatment (file update + DuckDB).

| Value Tier | Weight | Short-Form (DuckDB only) | Long-Form (file + DuckDB) | Examples |
|------------|--------|--------------------------|---------------------------|----------|
| **Tier 1: Decisions & Commitments** | 5.0 | signal_tracker row | Meeting series file update, current.md update, project timeline | ExecutionLens: "cancel StrategyLens meeting", "treat underspend as process failure", ExamplePerson: "full ExampleProject switch" |
| **Tier 2: Action Items & Deadlines** | 4.0 | signal_tracker row | Meeting series Open Items, Asana task cross-ref, current.md pending actions | "ExamplePerson: obtain TPS checklist from Abdul", "Year-One Optimization one-pager by Apr 16" |
| **Tier 3: Strategic Context & Insights** | 3.0 | signal_tracker row | Wiki article enrichment, meeting Running Themes, project context tasks | ExampleProject brainstorm themes, Google Summit AI-MAX insights, Jasper AI content strategy |
| **Tier 4: Relationship Signals** | 2.0 | relationship_activity row | memory.md staleness update (if >14d shift) | ExecutionLens DM, ExamplePerson email, ExamplePerson Slack thread, ExamplePerson sync |
| **Tier 5: Status Updates & FYI** | 1.0 | signal_tracker row only | None (short-form sufficient) | ExampleProject CA launch confirmed, 3P Event Guidelines, team photos |

## Step 2.5A: Meeting Series File Updates (~2 min)

**Output:** Updated `<repo-root>` files, updated main.meeting_series

### Procedure

1. Query meeting_analytics for sessions since last enrichment run:

2. For each new session not yet in its series file:

3. For each matched session, pull rich context:
   d. Query meeting_highlights for decisions already extracted

4. Apply the Multi-Source Ingestion Protocol from meetings/README.md:
   a. Hedy is primary source
   b. Check email threads (±2 days) for pre/post meeting context
   c. Synthesize ONE clean summary per the README cleaning rules

5. Update the series file:
   a. Read current file content (read-before-write)
   c. Write new "Latest Session" with: date, duration, key discussion points, decisions, action items
   e. Update "Running Themes" if patterns shift

### Scope Control
- Max 5 series file updates per run (prioritize by: manager > stakeholder > team > peer)
- Skip sessions older than 14 days (they should have been caught by EOD-1)
- If Hedy MCP is unavailable, use meeting_analytics + meeting_highlights from DuckDB (already ingested)

## Step 2.5B: Relationship Activity Tracking (~30s)

**Output:** main.relationship_activity (DuckDB)

### Procedure

Compute weekly interaction counts per person from all ingested sources:

    total_score, interaction_trend)
    COALESCE(s.cnt, 0) + COALESCE(e.cnt, 0) * 2 + COALESCE(m.cnt, 0) * 3 as total_score,

## Step 2.5C: Wiki Candidate Detection (~15s)

**Input:** signals.signal_tracker (already populated by Phase 1 + 2)
**Output:** Logged to am-signals-processed.json for frontend surfacing

The `signals.wiki_candidates` view already exists and auto-computes from signal_tracker:
-- Topics with strength >= 3.0, channel_spread >= 2, mentions >= 3

### Procedure
1. **Slug normalization pass** (run BEFORE querying the view):
   - Query all active topics: `SELECT DISTINCT topic FROM signals.signal_tracker WHERE is_active`
   - Identify slug variants that refer to the same concept (e.g., "Brand LP ExampleProject Transition", "ExampleProject-lp-testing", "ExampleProject-lp-revert" → all should be "ExampleProject-brand-lp")
   - UPDATE mismatched slugs to the canonical form (lowercase-hyphenated, project-scoped)
   - Canonical slug rules: `{project-or-topic}-{subtopic}` — e.g., `ExampleProject-brand-lp`, `MarketB-budget-ieccp`, `MarketA-cpa-cvr`, `ExampleProject-rollout`, `liveramp-enhanced-match`
   - This is critical because Slack ingestion uses display names ("Brand LP ExampleProject Transition") while Hedy uses slugs ("ExampleProject-lp-testing"). Without normalization, the same topic fragments across rows and never reaches the quality threshold.
2. Query the view: `SELECT * FROM signals.wiki_candidates`
3. Cross-reference against wiki.publication_registry — exclude topics that already have articles
4. Cross-reference against `<repo-root>` — exclude topics that already have drafts in flight
5. Remaining = genuine wiki gaps. Append to am-signals-processed.json under `wiki_candidates` key
6. If any candidate has quality_score >= 10.0: flag as "strong candidate" for frontend

## Step 2.5D: Five Levels Tagging (~30s)

**Output:** main.five_levels_weekly (DuckDB)

### Level Classification Rules

| Signal/Topic Pattern | Level | Rationale |
|---------------------|-------|-----------|
| Testing, test design, ExampleProject, A/B, experiment | L2 | Drive WW Testing |
| MarketA, MarketB, market-specific, CPA, CPC, keyword, bid, campaign | L2 | Market execution |
| StrategyLens doc, Testing Approach, framework, methodology | L1 | Sharpen Yourself (artifact) |
| Tool, automation, script, dashboard, Kiro workflow | L3 | Team Automation |
| AEO, AI Overviews, zero-click, AI search, GenAI search | L4 | Zero-Click Future |
| Agent, MCP, orchestration, autonomous, Kiro power | L5 | Agentic Orchestration |
| ExampleProject, ExampleProject, LP, landing page, brand page | L2 | Testing/execution |
| Budget, PO, invoice, admin, compliance | L1 | Sharpen Yourself (admin) |
| ExampleProject, strategy, vision, roadmap | L1-L2 | Strategic planning |

### Procedure

## Step 2.5E: Project Timeline Events (~30s)

**Input:** All Phase 1 sources (Slack, Email, Hedy, Asana)
**Output:** DuckDB table (needs creation: main.project_timeline)

### Schema (create if not exists)
    source_channel VARCHAR, -- slack, email, hedy, asana
    source_id VARCHAR,

### Procedure
- Decisions from meeting_highlights (type='decision')
- Milestones from Asana (completed tasks in Milestones sections)
- Blockers from Slack (threads with "blocked", "waiting on", "can't proceed")
- Status changes from email (subject contains "update", "status", "progress")
- Launches from Slack (ExampleProject CA launch today, ExampleProject dial-ups)
- Escalations from email/Slack (ExecutionLens/StrategyLens involvement on a topic)

> ## Step 2.5F: Current.md Refresh (~30s)

**Input:** All Phase 1–2 outputs → **Output:** Updated `<repo-root>`
### Procedure
1. Read current.md (read-before-write)
2. Update "Active Projects" section with any status changes detected:
   - New Slack decisions → update project status
   - Completed Asana tasks → mark as done
   - New blockers → add to project notes
3. Update "Pending Actions" section:
   - Check completed items against Asana (completed=true) → mark [x]
   - Add new action items from hedy-digest (Tier 2 items)
   - Add new action items from email-triage (action_needed='respond')
   - Update overdue counts
4. Update "Key People" last interaction dates from relationship_activity
5. Do NOT rewrite the entire file — surgical updates only (read-before-write pattern)

### Scope Control
- Only update sections where data has changed
- Max 10 pending action updates per run
- Skip if current.md was updated within the last 4 hours (avoid thrashing)
## Execution Summary

| Step | Time | DuckDB Writes | File Writes | Value |
|------|------|---------------|-------------|-------|
| 2.5A: Meeting Series | ~2 min | meeting_series UPDATE | meetings/*.md | Long-form meeting context that compounds |
| 2.5B: Relationship Activity | ~30s | relationship_activity INSERT | None | Auto-computed staleness, replaces manual memory.md tracking |
| 2.5C: Wiki Candidates | ~15s | None (view query) | am-signals-processed.json append | Surfaces organic wiki article ideas from cross-channel signals |
| 2.5D: Five Levels | ~30s | five_levels_weekly INSERT | None | Weekly heatmap of where time goes vs where it should go |
| 2.5E: Project Timeline | ~30s | project_timeline INSERT | None | Chronological narrative arc per project |
| 2.5F: Current.md Refresh | ~30s | None | current.md | Keeps live state file fresh instead of frozen |
| **Total** | **~4 min** | **4 tables** | **≤6 files** | |

## Dependencies

- Requires Phase 1 complete (all ingestion data available)
- Requires Phase 2A-2D complete (signal routing done, so we know which signals are new vs reinforced)
- Phase 3+ can proceed after 2.5 completes (no circular dependencies)

## Error Handling

- If Hedy MCP unavailable for 2.5A: use DuckDB meeting_analytics + meeting_highlights (already ingested). Series files get a lighter update.
- If a meeting series file doesn't exist for a session: log as "unmatched session" in am-signals-processed.json. Don't create new series files automatically — queue for ExamplePerson.
- If current.md update fails: log error, continue. Current.md is important but not blocking.
- If project_timeline table doesn't exist: CREATE it (schema above). First run bootstraps.

## Portability Note

All outputs are either DuckDB tables (queried via MCP) or plain markdown files (portable by definition). No hooks, MCP, or subagent access required to read the outputs. A new AI on a different platform can pick up any series file or query any DuckDB table and understand the context cold.


## Private details intentionally omitted

- real people, teams, organizations, and project names
- live connector IDs and private URLs
- private analytics, dashboards, and metric values
- internal document paths or URLs
- private career and relationship context
