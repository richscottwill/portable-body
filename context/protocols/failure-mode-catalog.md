# Failure Mode Catalog — Sanitized Workflow Pattern

Private source path: `context/protocols/failure-mode-catalog.md`
Public status: sanitized structural export. This preserves workflow mechanics and removes private people, internal projects, IDs, URLs, and live data.

## What this demonstrates

- Trigger and precondition design
- Phase/step sequencing
- Visible degraded modes
- File/protocol boundaries
- Failure recovery and auditability
- Runtime portability via `<repo-root>` and capability checks

## Sanitized structure

# Failure-Mode Catalog Protocol

**Purpose:** When an agent gives a bad answer, a hook fires wrong, or a skill misfires — capture it. After 3 months, cluster patterns to find root causes invisible from individual incidents.

## Step 0: Preconditions (early-exit, runs BEFORE the log write)

Order matters — these run cheapest binary check first so a paused or duplicate run never pays the disk-write cost in "Where to log" below.

1. **Pause flag (cheapest, ~1ms file existence check).** If `<repo-root>` exists, exit silently with `[failure-mode-catalog] paused: <flag line 2>` and DO NOT append to the TSV. Pause flag is the override during incident floods (e.g., a dependency outage producing 50+ failures/min) where the catalog itself would be drowned in noise — operator clears the flag once the underlying incident is contained.

2. **TSV-existence + write-permission probe.** Stat `<repo-root>`. If it does not exist, create it with the canonical header line. If it exists but is not writable by the current user, exit with `[failure-mode-catalog] tsv not writable: <path>` and emit a high-severity console warning — losing failure-mode data silently is itself a failure mode worth surfacing.

3. **Dedup probe (medium).** Hash the tuple `(ts_minute_bucket, agent_or_hook, failure_type, what_happened)` and compare against the last 50 lines of the TSV. If the same hash already exists within the same minute bucket, skip the append with `[failure-mode-catalog] dedup: identical entry already at <line>`. Prevents the same retry-loop from logging the same failure 30 times in 30 seconds and contaminating the monthly cluster review.

After Step 0 passes, proceed to "Where to log" below.

## Failure Recovery (branch when the log write itself fails)

If the append to `failure-mode-log.tsv` fails (disk full, permission revoked mid-run, filesystem corruption):

1. **Capture to fallback.** Write the line to `/tmp/failure-mode-log-fallback-<YYYY-MM-DD>.tsv` so the data is not lost. Subsequent runs check this file at Step 0 and drain it back into the canonical log once writability returns.
2. **Surface immediately.** Log `[failure-mode-catalog] write failed: <reason>` to stderr AND to `<repo-root>`. Do not silently swallow — losing the meta-log defeats the protocol.
3. **Do not retry inline.** A single retry on a busy filesystem amplifies the very congestion that caused the failure. The next invocation's Step 0 dedup probe naturally drains the fallback file once the canonical log is writable again.
4. **Bound the fallback.** If `/tmp/failure-mode-log-fallback-*.tsv` accumulates > 1000 lines (filesystem fully unrecoverable), pause this protocol via Step 0's pause flag and surface a high-severity ping to ExamplePerson.

## Where to log

`<repo-root>`

ts	severity	agent_or_hook	failure_type	what_happened	root_cause_guess	fix_applied	session_id

- `ts`: ISO 8601 UTC
- `severity`: low / medium / high (low = noise; medium = wrong output that didn't ship; high = wrong output that shipped or affected ExamplePerson's decisions)
- `agent_or_hook`: which artifact failed (e.g., `kiro-local`, `wbr-callouts`, `data-freshness-warning hook`)
- `failure_type`: one of: hallucination, drift, schema-mismatch, missing-context, gate-bypass, escalation-failure, sync-failure, output-quality, other
- `what_happened`: one sentence, concrete
- `root_cause_guess`: best hypothesis at moment of logging (refined later)
- `fix_applied`: what was done about it (or "deferred to monthly review")
- `session_id`: chat session, hook run id, etc.

## When to log

- Agent produces output that's factually wrong
- Hook fires when it shouldn't, or doesn't when it should
- Skill returns something ExamplePerson has to substantially rewrite
- Sync fails silently (data drift, schema mismatch caught later)
- Decision-agent gate gets bypassed in practice

- Agent declines to do something — that's not a failure
- Output ExamplePerson disagrees with on style/preference (use lens evals for that)
- Single-instance hallucinations ExamplePerson caught fast

### The substantial-rewrite vs style-disagreement boundary (the ambiguous middle)

"Substantially rewrite" (log it) and "disagrees with on style" (don't log) are the two edges of a spectrum, and most real edits fall between them. Classify by WHAT changed, not how many characters:

- **LOG (substantial rewrite):** ExamplePerson had to change the output's *substance* — a wrong fact, a missing constraint, an incorrect recommendation, a structural reorganization because the logic was wrong, or content he had to add because the draft omitted something load-bearing. The defect was in correctness or completeness.
- **DON'T LOG (style/preference):** ExamplePerson changed *how it reads* without changing what it says — word choice, tone, sentence order for flow, his-voice vs agent-voice, formatting. The draft was correct; he just prefers it differently.

**Worked example.** Agent drafts a ExecutionLens email. (a) ExamplePerson rewrites "we should consider pausing MarketA" → "pausing MarketA is the call" — tone/directness only, substance identical → DON'T LOG (style). (b) ExamplePerson rewrites because the draft cited the wrong CPA figure ($142 vs the actual $138) or omitted the budget-approval ask entirely → LOG, failure_type=output-quality or missing-context. (c) ExamplePerson reorders three paragraphs purely for flow → DON'T LOG; reorders them because the draft buried the decision the recipient needs → LOG (the burial is a substance defect). Heuristic: if a lens eval (ExecutionLens/StrategyLens/ExecutiveLens) would have caught it, it's style → use lens evals, don't log. If only a fact-check or completeness-check would have caught it, it's substance → log. The "substantially" qualifier means substance-bearing, not volume of text.

## Monthly cluster review

First Monday of each month, kiro-server (or whoever runs the pass) reads the last 30 days of entries and produces a summary at `<repo-root>`:

- How many entries by severity
- Top 3 failure_type clusters
- Top 3 agent/hook clusters
- 1-2 root-cause patterns visible across multiple entries that aren't visible in any single entry
- Actions: what gets fixed, what gets escalated to karpathy, what stays unflagged

## Why this earns its place

Today's eval pipeline catches regression (eval-a/b/c blind A/B). The failure-mode catalog catches the *systemic* class of problems — the inventory drift earlier today is one. If we'd had this catalog running for 3 months prior, the "agent-recalled inventory drifts from disk" failure mode would already have a cluster of entries, the fix would have happened sooner, and the gate-1 protocol revision would have been pre-loaded.

The eval pipeline tests *one artifact at a time*. The catalog reveals *patterns across artifacts*. Different shape, both useful.

## Failure modes of this protocol itself

- **Catalog never gets read** → same as unasked-declined. Log without consumption is dead. Mitigation: monthly cluster review is a hard cadence, not aspirational.
- **Severity inflation** → everything labeled high. Mitigation: high-severity entries trigger an immediate ping to ExamplePerson; if too many fire, the threshold is wrong.
- **Catalog becomes blame log** → entries focus on "kiro-server got it wrong" not on systemic causes. Mitigation: `root_cause_guess` is required and must be system-level, not "the agent was bad."


## Private details intentionally omitted

- real people, teams, organizations, and project names
- live connector IDs and private URLs
- private analytics, dashboards, and metric values
- internal document paths or URLs
- private career and relationship context
