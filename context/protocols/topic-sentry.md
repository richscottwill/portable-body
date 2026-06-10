# Topic Sentry — Sanitized Workflow Pattern

Private source path: `context/protocols/topic-sentry.md`
Public status: sanitized structural export. This preserves workflow mechanics and removes private people, internal projects, IDs, URLs, and live data.

## What this demonstrates

- Trigger and precondition design
- Phase/step sequencing
- Visible degraded modes
- File/protocol boundaries
- Failure recovery and auditability
- Runtime portability via `<repo-root>` and capability checks

## Sanitized structure

<!-- DOC-XXXX | duck_id: protocol-topic-sentry -->
# Topic Sentry Protocol — daily topic-driven scan

**Cadence:** daily, after AM-Backend completes so DuckDB is fresh. Runs in the orchestrator (no subagent fan-out needed — all reads, no MCP writes beyond the output file).

## Precondition (runs before Execution)

Two gates fire in order before any DuckDB query or output write:

1. **Pause flag** — if `<repo-root>` exists, exit silently with `[topic-sentry] paused: <flag line 2>`. Do NOT load the watchlist, do NOT query DuckDB, do NOT write `<repo-root>`. The pause flag is the operator's override for days when topic-watchlist.md is mid-edit (registry transitions, slug renames) and a partial scan would produce a misleading digest.
2. **AM-Backend freshness gate** — query `ops.data_freshness` for `signals.emails`, `signals.slack_messages`, `signals.hedy_meetings`, `docs.loop_pages`, `asana.asana_tasks`. If MORE THAN HALF of these sources are stale beyond `2.0x expected cadence` (overridable via env var `$TOPIC_SENTRY_FRESHNESS_THRESHOLD`, allowed range 1.0–5.0), DEGRADE rather than skip: produce the digest with a top-of-file `⚠️ AM-Backend likely failed — N/M sources stale` banner and continue. The watchlist coverage signal is more useful with a stale-data warning than absent entirely; skipping silently would let an AM-Backend failure mask itself for days.

Order: pause flag FIRST, freshness gate SECOND. Reversed (freshness first) wastes a freshness query when the operator has already paused. Reversed semantics (freshness blocks instead of degrades) creates the bug class where an AM-Backend outage propagates to "topic-sentry didn't run today" with no surfaced reason — the operator never sees the upstream failure.

3. **Watchlist-integrity gate (runs THIRD, after pause and freshness, before Phase 0 load).** The freshness gate validates the *data* sources but not the *watchlist* itself. If `<repo-root>` is missing, empty (zero bytes), or unparseable (no `### <topic-name>` blocks found), the scan has no topics to match against and the five channel queries would run and return nothing — wasted ~1s of DuckDB time producing a misleading "no matches" digest that looks like a clean scan when it is actually a configuration fault. Behavior: if the watchlist file does not exist OR parses to zero topic blocks, do NOT proceed to Phase 0/1. Write a null-state digest with header `🚨 Topic Sentry CONFIG FAULT — watchlist missing/empty/unparseable` (distinct from Phase 1's `_no active topics — watchlist empty after sunset filter_` null-state, which is a VALID empty-after-filter outcome). The distinction matters: an empty-after-sunset watchlist is a real "nothing to watch today" state (clean), whereas a missing/corrupt file is an operator-visible fault that should be fixed. Order rationale (pause → freshness → watchlist-integrity → Phase 0): pause is the cheapest (one stat) and a session-wide override; freshness is a single DuckDB query against `ops.data_freshness`; the watchlist-integrity check is a file read + parse, placed after freshness because a stale-data degrade still produces a useful digest from the watchlist, but a missing watchlist makes the whole scan moot regardless of data freshness. What breaks if watchlist-integrity ran BEFORE the freshness gate: on a normal day with a valid watchlist the parse cost is paid before the cheaper degrade decision, and more importantly a paused session would still parse the watchlist if this ran before pause — so it must stay after both cheaper gates.

## Execution

### Phase 0: Load watchlist

1. Read `<repo-root>`.
2. Parse each `### <topic-name>` block into a struct:
   - `name`, `status`, `priority` (P1/P2/P3/monitoring/sunset)
   - `keywords` (list of phrases — quoted phrases are exact-match, unquoted are case-insensitive token match)
   - `senders` (optional list)
   - `channels` (subset of {email, slack, loop, hedy, asana, all})
   - `why`, `review_date`
3. Skip `sunset` topics. Log any topic whose review_date has passed — include in the output's "Review needed" footer.

### Phase 1: Scan each channel

**Early exit:** If Phase 0 yielded zero non-sunset topics, skip Phase 1 entirely and write a null-state digest (`topic-sentry.md` with `# Topic Sentry — YYYY-MM-DD` header and a `_no active topics — watchlist empty after sunset filter_` body line). Phase 2/3 are skipped. This prevents firing five empty channel queries against DuckDB when there is no work to do — the queries cost ~200ms each and produce nothing usable.

**Parallel fan-out (5 channels are independent):** The five channel queries below have no inter-channel dependency — `signals.emails`, `signals.slack_messages`, `signals.hedy_meetings`, `docs.loop_pages`, and `asana.asana_tasks` each return their own per-topic match list. Run them as a parallel fan-out (asyncio gather, threadpool, or subprocess parallelism — whichever the runner supports), gathering all five before proceeding to Phase 2. The previous sequential ordering (email → slack → hedy → loop → asana) was incidental, not load-bearing — Phase 2's dedup/rank step is the join point. Reversing the order changes nothing; running them concurrently cuts wall-clock by ~4× when DuckDB is warm. Asana is still gated on per-topic opt-in (only run for topics with `asana` in `channels`); when no topic opts in, skip the Asana future entirely rather than launching it and returning empty.

**Failure isolation:** if a single channel query errors (e.g., `signals.slack_messages` table missing after a schema migration), log `[topic-sentry] channel <name> failed: <error>` and continue with the remaining four. The digest writes with a `⚠️ <channel> unavailable` banner appended to the freshness banner. One channel failure must not collapse the whole scan — the other four still produce useful watchlist coverage.

**Majority-channel-failure escalation (added because per-channel isolation alone degrades silently into uselessness).** Per-channel isolation handles 1-2 failures gracefully, but if 3 OR MORE of the 5 channels fail in the same run, the digest covers fewer than half the surfaces and a "coverage" digest built on ≤2 channels is misleading — it looks like a real scan but silently omits most of the watchlist's reach. When `failed_channels >= 3`: still write the digest from whatever succeeded (do NOT skip — partial coverage tagged is better than nothing), but escalate the banner from per-channel `⚠️` lines to a single top-of-file `🚨 DEGRADED SCAN — only N/5 channels available, treat absence of a topic as UNKNOWN not CLEAR` AND emit one Slack self_dm (this is the one case Topic Sentry breaks its no-MCP-write rule, because a near-total scan failure is exactly the AM-Backend-outage signal the freshness gate exists to surface). The 3-of-5 threshold is the env var `$TOPIC_SENTRY_MAX_CHANNEL_FAILURES` (default 3, allowed range 2–5). 

**Interaction with the freshness gate / order of precedence:** the freshness gate (Precondition #2) and this channel-failure escalation can both fire in the same run — freshness measures staleness of sources that DID respond, channel-failure measures sources that did NOT respond at all. They are independent signals: a channel can be fresh-but-erroring (table dropped) or stale-but-readable. When both fire, show BOTH banners (the freshness `⚠️` and the channel-failure `🚨`), `🚨` first because total absence outranks staleness. What breaks if channel-failure were treated as a freshness case: a dropped-table error (channel fails, returns nothing) would be invisible to the freshness gate (which only inspects sources that returned a `last_updated`), so folding the two together would let a 3-table-drop slip past as "sources look fresh" — the false-green the escalation exists to prevent.

#### Email (`signals.emails`)

**Worked example:** Apply SELECT when the precondition holds. If unclear, default to the safer option and document the assumption inline.

#### Slack (`signals.slack_messages`)

#### Phase 1: Scan each channel — Details

#### Hedy (`signals.hedy_meetings`)

#### Loop (`docs.loop_pages`)

#### Asana (`asana.asana_tasks` — optional)

### Phase 2: Dedup and rank

- A single source (email thread, Slack ts, Hedy session, Loop page) can match multiple topics. Include it under each matching topic; don't dedup across topics.
- Within a topic, dedup by source id (conversation_id for email, ts for Slack, etc.).
- Rank within topic by recency (most recent first).

### Phase 3: Write `topic-sentry.md`

# Topic Sentry — YYYY-MM-DD

#### Phase 3: Write `topic-sentry.md` — Details

_Scan window: last 24 hours. Watchlist: N active topics. Hits: M sources across K topics._

## P1 — must surface

### <topic-name> (N hits)

- [HH:MM email] <sender> — <subject> — [<one-line preview>] ([open](link-if-available))
- [HH:MM slack #<channel>] <author>: <one-line preview> ([open](link))
- [HH:MM hedy] <meeting_topic> — <recap_preview>
- [HH:MM loop] <page_title> — <content_preview>

### <topic-name> (0 hits)

## P2 — worth knowing

## P3 — background radar

## Monitoring

## Review needed

- <topic-name>: review_date YYYY-MM-DD has passed (N days ago). Confirm still worth watching.

## Operating notes

- Topics with 0 hits in 30 consecutive days: proposed for demotion to `monitoring` or sunset. Logged to `<repo-root>` for ExamplePerson review.
- Topics hitting >5 times in 7 days on P3: proposed for promotion to P2.
- Proposals never self-execute — they're suggestions for the weekly Broad Sweep review.

### Phase 4: Write to SharePoint (durability)

### Phase 5: Output consumed by AM-Frontend
- Surfaces up to 5 P1 topics with hits >= 1 in the brief
- Flags `⚠️ Topic Sentry: stale or missing` if the file is >24h old or absent
- Line 2 `_Scan window: ... Watchlist: N active topics. Hits: M sources across K topics._`
- H3 section headers with pattern `### <topic-slug> (N hits)` — N parsed as int, 0 means no activity
- Parses the header (total hits, topic count, Five Levels coverage)
- Line 3 bold `**Five Levels coverage (by hit count):** L1: X · L2: X · L3: X · L4: X · L5: X · operational: X`
- First bullet under each H3 (used as one-line summary in brief)

Topic Sentry produces `<repo-root>`. AM-Frontend (hook `.AM-Frontend`) reads this file during Step 1 Brief — see `am-frontend.md` § Topic Radar Section. The frontend:

This is the structural closure of the loop — without AM-Frontend consuming the file, Sentry produces unread output. The Brief's Topic Radar section renders:

🎯 TOPIC SENTRY — M sources across K topics (last 24h)

Breaking any of these patterns requires a matching update to `am-frontend.md` § Topic Radar Section.

3. Flag stale sources in the output header: `⚠️ Stale: email (last sync 18h ago), slack (last sync 6h ago)`
- `docs.loop_pages` populated by Subagent D
2. Proceed with the sources that are fresh
- `signals.hedy_meetings` populated by Subagent E
1. Log which data sources are stale (from `ops.data_freshness`)
- `signals.emails` populated by Subagent C
- `signals.slack_messages` populated by Subagent A

This means Topic Sentry is NOT a replacement for AM ingestion — it's a layer on top. If ingestion is degraded, Sentry coverage is degraded too. Honest about it.

## Failure handling
- If `topic-watchlist.md` is missing or unparseable: log error, fall back to writing an empty `topic-sentry.md` with a header telling ExamplePerson to fix the watchlist.
- If all DuckDB queries fail: log error, write minimal output saying "DuckDB unreachable."
- **Partial-scan integrity (channel scan dies mid-Phase-1).** If the Slack/MCP scan completes for only SOME of the watchlist channels before erroring (connection drop, rate-limit, timeout), the resulting digest is dangerously misleading: a P1 topic with zero hits in the SCANNED channels reads identically to a genuinely quiet P1 topic, but the unscanned channels may be where the hits actually are. Guard: track which channels were successfully scanned vs skipped. If ANY watchlist channel was not scanned, the digest MUST carry a `⚠️ PARTIAL SCAN: N/M channels scanned (skipped: <list>)` banner at the top, and every "0 hits" line for a P1 topic MUST be written as `0 hits in scanned channels — INCOMPLETE` rather than a bare `0 hits`. Order matters: record the scanned/skipped channel set BEFORE writing Phase 3 output, so the banner reflects the true scan coverage. Reversed (write digest then note partiality) risks AM-Frontend consuming a clean-looking digest before the partiality banner lands, surfacing a false "all quiet" to ExamplePerson when a P1 topic may be active in an unscanned channel.
- If the output write to `<repo-root>` itself fails (disk full, permission error, path missing): retry once after ensuring the parent dir exists; if it still fails, write the digest to `/tmp/topic-sentry-fallback-YYYY-MM-DD.md` and log `[topic-sentry] primary write failed: <error> — wrote fallback to /tmp`. Do NOT exit silently — AM-Frontend's `⚠️ stale or missing` check must have a logged cause to surface, otherwise a write failure masquerades as "no hits today."
- Never silently produce an empty digest. The output file should always exist with a clear status, so ExamplePerson can distinguish "no hits today" from "scanner broke."
## Tuning knobs

- **Scan window:** default 24h. Adjustable in the hook trigger if ExamplePerson wants a catch-up run (e.g., after a long weekend set to 72h).
- **Keyword matching:** ILIKE-based substring match. If false positives spike, move to tokenized match against a stopword-filtered FTS column.
- **Max hits per topic:** 10 in the digest. More than that collapses to `N hits total — top 10 shown, see DuckDB for rest`.
- **SharePoint retention:** the dated `topic-sentry-YYYY-MM-DD.md` files in `public-demo-store/system-state/` accumulate one per day and are never read after the day they describe (AM-Frontend reads only the local `<repo-root>`). Default retention: keep the most recent 14 dated files; on each Phase 4 push, delete dated files older than 14 days. Adjustable via `$TOPIC_SENTRY_SHAREPOINT_RETENTION_DAYS` (default `14`, allowed range `1`–`90`; unset/empty/non-numeric/out-of-range → use `14`, do not error). Retention cleanup is non-blocking and runs AFTER the push so a cleanup failure never costs today's durability copy.
- **Demotion/promotion windows:** the 30-day zero-hit demotion window and 7-day P3 promotion window in Operating notes are the defaults; both are advisory thresholds for the weekly Broad Sweep, not runtime gates, so changing them only affects which proposals get logged — never which topics get scanned.

## Failure Recovery (added by experiment)

If any step in this protocol errors: do not retry inline more than once. Log the failure with a one-line cause and continue with degraded output where possible. If a load-bearing step fails with no degraded path, report TASK_BLOCKED with the cause and stop — do not invent results. Order rationale: a partial-but-correct run beats a complete-but-fabricated one.

**Worked example:** the upstream query times out on step 2. The protocol retries once after a short wait; on a second failure it logs `[step2] query timeout` and proceeds to steps that don't depend on step 2's output, marking the dependent outputs as <user-id> rather than guessing.


## Private details intentionally omitted

- real people, teams, organizations, and project names
- live connector IDs and private URLs
- private analytics, dashboards, and metric values
- internal document paths or URLs
- private career and relationship context
