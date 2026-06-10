# Eod Meeting Sync — Sanitized Workflow Pattern

Private source path: `context/protocols/eod-meeting-sync.md`
Public status: sanitized structural export. This preserves workflow mechanics and removes private people, internal projects, IDs, URLs, and live data.

## What this demonstrates

- Trigger and precondition design
- Phase/step sequencing
- Visible degraded modes
- File/protocol boundaries
- Failure recovery and auditability
- Runtime portability via `<repo-root>` and capability checks

## Sanitized structure

<!-- DOC-XXXX | duck_id: protocol-eod-meeting-sync -->

## Portability contract

Apply `<repo-root>/context/protocols/path-standardization.md` before execution. Resolve `<repo-root>` from `$AGENT_BRIDGE_ROOT` or `tools/scripts/agent_bridge_paths.py root`; do not assume a literal `<repo-root>` checkout. For executable shell snippets, set `REPO_ROOT=<resolved repo root>` and use `$REPO_ROOT/...`. Use `$PS_DUCKDB_PATH` for DuckDB override when needed; otherwise default to `<repo-root>/data/duckdb/ps-analytics.duckdb`.

# EOD Meeting Sync Protocol

**2026-05-06 migration:** This protocol used to write to `signals.hedy_meetings`, `main.meeting_analytics`, `main.meeting_highlights`, `main.meeting_series` DuckDB tables. Those tables are deprecated. Topic logs at `<repo-root>/wiki/topics/` are the canonical post-meeting artifact. Meeting series files at `<repo-root>/wiki/meetings/` continue as recurring-meeting logs. Hedy MCP remains the transcript source of truth.

## Step 0: Preconditions (early-exit, runs BEFORE Context Load)

Order matters — these run cheapest binary check first so a paused or no-op invocation never pays the multi-MCP query cost (Hedy + Outlook + ~15-30s wall clock).

1. **Pause flag (cheapest, ~1ms file existence check).** If `<repo-root>/context/active/eod-meeting-sync-paused.flag` exists, exit silently with `[eod-meeting-sync] paused: <flag line 2>` and DO NOT load context, DO NOT call Hedy/Outlook MCPs, DO NOT write to topic logs. Pause flag is the override during weeks ExamplePerson does meeting writeups manually (e.g., a leadership offsite where the topic logs are intentionally delayed).

2. **Same-day idempotency.** Read `<repo-root>/context/active/eod-meeting-sync-last-run.txt`. If `last_run_date == today`, exit with `[eod-meeting-sync] already ran today at <HH:MM>`. Re-running same-day re-fetches the same Hedy sessions and double-appends to topic logs (the INGEST-PROTOCOL is append-with-dedup, but dedup checks add latency that's wasted when Step 0 can short-circuit).

3. **Topic-registry-readiness probe.** Verify `<repo-root>/wiki/topics/_registry.md` exists and has been read in the last 24h (mtime check). If the registry is missing or older than 24h, exit with `[eod-meeting-sync] registry stale or missing` and surface to operator. The registry maps `hedy_topic_id` to canonical slugs — operating without it routes everything to a fallback topic and contaminates the canonical logs.

4. **Registry mid-edit lock probe (runs AFTER the staleness check in 0.3, before committing the run).** A registry that EXISTS and is FRESH can still be mid-edit — a concurrent slug-rename or registry-regeneration may have the file in a half-written state (truncated, partial YAML, a slug line without its `hedy_topic_id` pair). Routing against a half-written registry is worse than routing against a stale one: a stale registry maps to last-known-good slugs, but a truncated one silently drops the mappings below the truncation point, routing those sessions to the fallback topic and contaminating canonical logs exactly as a missing registry would — except this passes the 0.3 freshness check because the mtime is current. Behavior: if `<repo-root>/context/active/topic-registry-editing.flag` exists OR the registry fails a structural parse (no closing marker / odd number of slug↔id pairs / zero parseable entries on a non-empty file), exit with `[eod-meeting-sync] registry mid-edit or malformed — deferring to next run` and do NOT write the last-run timestamp (so the deferred run is not blocked by Step 0.2's already-ran-today gate once the edit completes). Order rationale (exists/stale check 0.3 → mid-edit/parse check 0.4 → commit): the cheap mtime check fences the more expensive structural parse — no point parsing a registry that already failed the existence/staleness gate. What breaks if 0.4 ran before 0.3: every run would parse the full registry even on days the mtime check would have exited for free, and a missing-file case would hit a parse error rather than the clean `registry stale or missing` message.

After Step 0 passes, write `<today>` to `eod-meeting-sync-last-run.txt` and proceed to Context Load.

## Context Load

- `<repo-root>/wiki/topics/INGEST-PROTOCOL.md` — topic log append contract
- `<repo-root>/wiki/topics/_registry.md` — registered topic slugs + hedy_topic_id mapping
- `<repo-root>/wiki/meetings/README.md` — meeting series conventions

## Pull

- Hedy MCP: `GetSessions` (today), `GetSessionDetails`, `GetSessionToDos`, `GetSessionHighlights`
- Outlook: auto-meeting folder + related email threads
- current.md, nervous-system.md, series files

### Failure recovery — Hedy MCP unavailable or empty

Hedy is the transcript source of truth, but it can fail (MCP timeout, auth refresh, or simply zero sessions on a no-meetings day). The protocol MUST proceed regardless — Outlook ingestion is independent and meeting-derived tasks may still need to flow to Asana.

Recovery path (executed in this exact order):

1. **Hedy MCP timeout / 5xx / auth error** → record `[eod-meeting-sync] hedy: <error-class>` in the Audit step's flags list. Do NOT retry inline (a stuck Hedy session would block all downstream work). Continue to step 2 with `hedy_sessions = []`.
2. **Hedy returns 0 sessions on a no-meetings day** → not an error. Skip the topic-log routing step entirely (no sessions to route) but STILL run Outlook ingestion in step 3. The Pull → Analyze → Route to topic logs phases become no-ops only for Hedy-sourced data.
3. **Outlook ingestion is non-optional** → calendar meetings exist independently of Hedy. Even if Hedy returned zero, walk the auto-meeting folder. If both Hedy and Outlook return zero, skip Route + Update meeting series + Meeting-to-Task and jump to Audit, which logs `no sessions today` and exits cleanly.
3a. **Outlook ingestion ITSELF fails (the safety net fails)** → if the Outlook/calendar source errors (MCP timeout, auth, folder unreadable) AND Hedy also failed in step 1, this is a DOUBLE-SOURCE outage, not a no-meetings day. Do NOT log `no sessions today` (that would falsely assert the day was empty when it was actually unobserved). Instead, record `[eod-meeting-sync] DOUBLE-SOURCE FAILURE: hedy=<err> outlook=<err> — meeting data <user-id> today` in the Audit flags with severity=high, and write a sentinel to `<repo-root>/context/active/eod-meeting-sync-status.json` (`{date, status:"unobserved", hedy_err, outlook_err}`) so the next morning brief surfaces the gap rather than treating it as a quiet day. An unobserved day silently logged as `no sessions` is the inverse of the step-4 bug — it hides the outage instead of the data.
4. **DO NOT silently skip the whole protocol** because Hedy failed. The most common bug class is "Hedy timed out, so the whole EOD-meeting-sync skipped, and meeting-derived Asana tasks went missing for a week." Outlook is the safety net.

Order matters: handle the Hedy failure BEFORE pulling Outlook, never after. If Outlook ran first and succeeded, an inattentive operator would see "EOD meeting sync OK" and never investigate the Hedy outage — a successful Outlook pull masks the Hedy gap.

## Analyze

- Direct quotes where possible
- Decisions as stated (with who decided)
- Actions as committed (with owner + due date)
- Speaking share, topics discussed (on-demand via Hedy, not stored in DuckDB)
- Relationship dynamics for memory.md (noted, not quantified)

## Route to topic logs (primary write)

For each session, identify target topic docs per INGEST-PROTOCOL topic identification order. Each match attempt is BLOCKING — the next attempt only fires if the previous returned no match. Stop on first match:

1. `hedy_topic_id` exact match against `_registry.md` — strongest signal because it's deterministic; the topic was already registered against this Hedy session type. If matched here, do NOT also try slug match.
2. slug/alias match on session title + topic names — substring match on registry slugs and known aliases. If matched here, do NOT also try related-slug match.
3. related-slug match from adjacent topic docs — fuzzy match against topic docs that shared a previous Hedy session. Lowest-confidence; only used when 1 and 2 missed.

Reversed (related-slug first) produces topic-log churn: the same session lands in 3 different topic docs across 3 different EOD runs as the registry catches up. The hedy_topic_id match is the contract; aliases are the fallback; related-slug is the discovery hint.

- Prepend H3 Log entry with `#### Source hedy:<session_id>`, `#### What was said / what happened`, `#### Decisions`, `#### Actions`, optional `#### Notes`
- Prepend daily line to Simplified Timeline under current ISO-week H4 header
- Move resolved Open Items to Closed Items — Audit Trail (never delete)
- Update `updated:` frontmatter to today (PT)

Unregistered candidates with ≥3 mentions over 60d → append to `<repo-root>/wiki/topics/_discovery-queue.md`. The 3-mention threshold is a debounce: a single session creating a topic doc per run would flood the discovery queue. 60 days is the rolling window because shorter windows fragment topics that pause for >2 weeks.

## Update meeting series (secondary write)

- Prepend Latest Session entry
- Update Open Items + Running Themes per existing conventions

## Update Organs

- memory.md: relationship updates from meeting dynamics
- nervous-system.md: Loop 7 (meeting patterns), Loop 3 (pattern trajectory)
- current.md: people updates, new action items
- device.md: delegation updates

**Cascade failure + conflict handling.** The four organ writes are independent, non-transactional, and run in the order listed (memory → nervous-system → current → device). If one organ write fails (disk, permission, parse error), do NOT abort the remaining organ writes — each organ is independently valuable, and a meeting-derived memory update should still land even if the device.md write errors. Log each failed organ to the EOD summary's degraded section as `[eod-meeting-sync] organ-write failed: <organ> — <cause>` and continue. A partial organ cascade is acceptable; an aborted one that drops a relationship update because a later, lower-priority organ failed is not. **Conflict rule:** when a meeting update contradicts an existing current-state entry (e.g., a contact's role changed since memory.md's last entry), the meeting is the newer signal — overwrite the stale entry, but preserve the prior value in the changelog one-liner so the change is auditable. Never silently keep the stale organ value over a fresher meeting-sourced fact.

## Audit

Hedy: today's topics only. Flag discrepancies between transcript and routed topic-log entries. If a session was not routed to any topic doc, log reason (no match, intentional skip, etc.) in EOD summary.

## Meeting-to-Task Automation

After topic-log routing, execute `<repo-root>/context/protocols/meeting-to-task-pipeline.md`:

1. Walk new Log entries' `#### Actions` blocks
2. For ExamplePerson's items: dedup against Asana, CreateTask or comment
3. For others' items: append to hands.md dependencies
4. After all sessions: self_dm summary
5. Log execution to `ops.workflow_executions`

## Deprecated (do NOT perform)

- Do NOT INSERT into `signals.hedy_meetings`
- Do NOT INSERT into `main.meeting_analytics`
- Do NOT INSERT into `main.meeting_highlights`
- Do NOT UPDATE `main.meeting_series` (DuckDB table) — the meetings/*.md files remain as the meeting-series log
- Do NOT write `<repo-root>/context/intake/hedy-digest.md` or `<repo-root>/context/active/hedy-digest.md`
- Do NOT update `ops.data_freshness.hedy_meetings` row

## Report

### Log Hook Execution

INSERT INTO ops.hook_executions (hook_name, execution_date, start_time, end_time, duration_seconds,
 phases_completed, asana_reads, asana_writes, slack_messages_sent, duckdb_queries, summary)
 [phases], [reads], [writes], [slack_msgs], [queries], '[summary]');

### Worked example
Scenario: a typical run of the eod meeting sync workflow encounters a missing or malformed input. Expected behavior: log the failure mode with structured prefix (`[eod-meeting-sync]`), exit non-zero only if the failure is unrecoverable, otherwise emit a `[soft-fail]` log line and proceed with the documented fallback. Concrete: if the workflow expects a JSON payload and gets an empty file, log `[eod-meeting-sync] empty payload — using last-known-good` and read the prior run's artifact from `<repo-root>/context/active/eod-meeting-sync-last.json`.


## Private details intentionally omitted

- real people, teams, organizations, and project names
- live connector IDs and private URLs
- private analytics, dashboards, and metric values
- internal document paths or URLs
- private career and relationship context
