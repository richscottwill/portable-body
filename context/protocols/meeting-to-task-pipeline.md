# Meeting To Task Pipeline — Sanitized Workflow Pattern

Private source path: `context/protocols/meeting-to-task-pipeline.md`
Public status: sanitized structural export. This preserves workflow mechanics and removes private people, internal projects, IDs, URLs, and live data.

## What this demonstrates

- Trigger and precondition design
- Phase/step sequencing
- Visible degraded modes
- File/protocol boundaries
- Failure recovery and auditability
- Runtime portability via `<repo-root>` and capability checks

## Sanitized structure

<!-- DOC-XXXX | duck_id: protocol-meeting-to-task-pipeline -->
# Meeting-to-Task Pipeline
*Reading order: top-to-bottom; later sections assume earlier ones. Skim the section headers first to find the right entry point for your task.*

Extends EOD Phase 1 Meeting Ingestion. After Subagent E has written topic-log entries, extract ExamplePerson-owned action items and create Asana tasks.

**MCP Chain:** Topic logs (read) → Asana (write) → Slack → DuckDB

**2026-05-06 migration note:** This pipeline previously wrote to `main.meeting_analytics` and `main.meeting_highlights` and consumed data directly from Hedy. As of 2026-05-06, those DuckDB tables are deprecated. The canonical post-meeting artifact is the topic log Log entry; action items are parsed from the topic-log entry's `#### Actions` block. See `<repo-root>` for the topic-log contract.

## Early Exit (runs before any step below)

If `<repo-root>` exists, exit silently. Do NOT execute any step in this protocol. This pause flag is the operator's kill switch — it must be honored before any side-effect-producing work begins (DuckDB queries, LLM calls, file writes). Removal of the flag re-enables the protocol on the next invocation.

## Step 1: Action Item Extraction

After Subagent E has written topic-log entries for today's sessions, walk every new Log entry added this run and parse its `#### Actions` block. Every action in a topic log already carries owner + text + due date per INGEST-PROTOCOL. Extract:

- **Assignee**: Parse for names. If ExamplePerson/ExamplePerson → ExamplePerson's item. If another name → dependency item. **Multi-assignee** ("ExamplePerson and ExamplePerson-Kang to draft the deck"): split into BOTH a ExamplePerson-owned task (Step 3 path) AND a dependency item (Step 5 path), cross-linked so each side carries the other as a named collaborator. Do NOT collapse a shared action into a single dependency item (that drops ExamplePerson's accountability) and do NOT collapse it into a single ExamplePerson task (that loses the dependency tracking on the partner). Shared ownership is two records, not one — consistent with soul.md's cross-team shared-ownership preference. **Ownerless/ambiguous action** ("we should follow up on the ExampleProject dashboard", "someone needs to check the MarketB pacing"): no name is parseable, so default the assignee to ExamplePerson and tag the task `derived_owner` — ExamplePerson owns triage of unassigned items surfaced in his meetings, and a born-unassigned action that goes to no one is the most common silent drop. Do NOT skip an ownerless action (it vanishes) and do NOT log it as a dependency item (a dependency with no owner can never be chased). ExamplePerson re-assigns or closes it during review; the `derived_owner` tag lets the operator see it was auto-attributed rather than explicitly his.
- **Description**: The full action item text as stated

### Split-action partial-failure (multi-assignee write atomicity)

A multi-assignee action produces TWO records that must stay cross-linked: a ExamplePerson-owned task (Step 3) and a dependency item (Step 5). These writes are not transactional — the Step 3 `CreateTask` can succeed while the Step 5 dependency write fails (or vice versa), leaving a half-linked shared action. Handle the two failure directions differently because their recovery costs are asymmetric:

- **Step 3 (ExamplePerson task) succeeded, Step 5 (dependency) failed.** Do NOT roll back the ExamplePerson task — ExamplePerson's accountability record is the higher-value half and is already correct. Instead append the orphaned dependency to `<repo-root>` tagged `[split-partner: <richard_task_gid>]`, and add a `⚠ partner-link pending` note to the ExamplePerson task's collaborator field so the cross-link is visibly incomplete rather than silently missing. Next run back-fills the dependency and clears the note.
- **Step 5 (dependency) succeeded, Step 3 (ExamplePerson task) failed.** This is the dangerous direction — the dependency exists pointing at a ExamplePerson task that was never created, so the partner is tracked but ExamplePerson's accountability silently vanished (the exact drop the split rule exists to prevent). Do NOT leave the dependency standing alone: tag it `[split-partner: PENDING-ExamplePerson-TASK]` and route the ExamplePerson half to `signal-deferred.md` for guaranteed next-run creation. The dependency must never reference a non-existent ExamplePerson task as though the link were complete.

**Order / what breaks if reversed:** always create the ExamplePerson task (Step 3) BEFORE the dependency (Step 5) so the dependency can embed the real ExamplePerson task GID at creation time. If the dependency were written first, every split action would need a second pass to back-fill the GID, and a crash between the two writes would leave a dependency with a dangling partner reference — the harder-to-detect of the two partial states.

- **Due date**: As stated in the log entry. If stated, use; if derived from context, tag as derived.

### Due Date Derivation

| Signal in Discussion | Due Date |
|---------------------|----------|
| Explicit date ("by Friday", "next week", "April 10") | Parse to calendar date |
| Urgency signal ("ASAP", "today", "urgent", "immediately") | Tomorrow |
| No date signal | +3 business days from meeting date |
| Explicit date already PAST the meeting/processing date (stale transcript) | Tomorrow, tagged `derived` AND `stale_due` |

**Worked example — due-date derivation:** Topic-log Action reads "ExamplePerson to send the MarketB W21 callout to StrategyLens before the staff meeting Thursday." → explicit date signal ("Thursday") → parse to that Thursday's calendar date, due-date NOT tagged derived. Contrast: Action reads "ExamplePerson to follow up on the ExampleProject dashboard" with no date → no date signal → +3 business days from the meeting date, tagged `derived`. Contrast: "ExamplePerson needs the ExampleProject numbers ASAP for ExecutionLens" → urgency signal ("ASAP") → tomorrow, NOT tagged derived (urgency is an explicit signal). When two signals conflict (e.g., "by Friday, but urgent"), the explicit calendar date wins over the urgency default — Friday, not tomorrow. When the explicit date is already in the PAST relative to the processing date (a stale transcript processed days late — e.g., "by last Tuesday" parsed on Thursday), do NOT create a task with an already-overdue due date: set it to tomorrow and tag both `derived` and `stale_due`, so the operator sees the item was extracted late rather than missed. Creating a born-overdue task pollutes the overdue count and masks genuinely-missed deadlines.
## Step 2: Classify Action Items
- **ExamplePerson's items** → Asana task creation path (Step 3)
- **Others' items** → Dependency logging path (Step 5)
- **No items found** → Log "no actions" in meeting series file,

### Step 2 Early-Exit (zero-actionable gate)

After classification, if the run yields **zero ExamplePerson-owned items AND zero dependency items** across all sessions processed, SKIP Steps 2.5 through 7 entirely and jump straight to Step 8 (Slack DM Summary) using the simplified zero-tasks message.

Why: Steps 2.5–4 query Asana (CreateTask/SearchTasks calls) and Steps 5–7 write to organs and DuckDB. With nothing to insert/update, these steps are pure tool-call overhead. The simplified Step 8 message ("📋 EOD-1: [N] sessions processed, no new action items.") is the correct user-visible outcome.

Order check: this gate runs AFTER Step 2 classification (so we know the counts) and BEFORE Step 2.5 Consolidation (so we don't waste the Asana SearchTasks lookup on an empty set). Reversed (gate after Step 2.5) means every empty-meeting-day still incurs the parent-program lookup.

Recovery: if the gate misfires (zero count detected but Step 1 actually had items — e.g., a parsing bug dropped them), the next pipeline run re-extracts from the same topic-log entries. No data lost — extraction is idempotent.
## Step 2.5: Consolidation Check (MANDATORY — before creating any task)

Why: Tasks have an Asana MCP cost per create/update. Standalone granular tasks fragment the agenda, multiply the Today-list load, and lose the program narrative. Rolling weekly/operational items under a program parent keeps the system readable and reduces tool calls.

### Step 2.5a — Classify by urgency × importance × containment

| Urgent? | Important? | External hard deadline? | Action |
|---|---|---|---|
| Yes | Yes | — | **Standalone** top-level task |
| Yes | No | Yes (cross-team, ≤ 2 days) | **Standalone** one-off |
| Yes | No | No | **Subtask** of the right parent |
| No | Yes | No | **Subtask** of the right parent |
| No | No | — | **Bullet in parent notes** OR skip |

### Step 2.5b — Parent program lookup

Before calling `CreateTask`, check the parent-program table in `<repo-root>` § Step 2.5b. Examples specific to meetings:

- **MarketB ExampleCo Sync / MCS LP Review** action items → subtask of the matching MarketB program parent (or the in-scope MCS LP Review task). Don't create a new top-level task per meeting item.
- **MarketA meetings** action items → subtask of "MarketA meetings - Agenda" (the recurring weekly parent) OR subtask of the relevant MarketA program task.
- **ExecutionLens 1:1 / Paid Acq Deep Dive** action items → subtask of the prep task for that 1:1.
- **StrategyLens / stakeholder reviews** → usually warrant standalone (external visibility), but batch under a milestone task if multiple arrive from one meeting.
- **Hedy-captured "will follow up" items** with no deadline → bullet in parent notes, not a new task.

### Step 2.5c — When "bullet in parent notes" is right

- [YYYY-MM-DD] [meeting_name] ([session_id]): [one-line summary]

### Step 2.5d — Confirm bar

1. Does a parent program already exist for this action item? If yes → subtask or notes-bullet.
2. Is this Urgent + Important OR externally-bound? If no → not top-level.
3. Could multiple action items from this meeting be batched under one parent? If yes → batch.

### Step 2.5e — No-parent fallback (table says "subtask/bullet" but Step 2.5b finds NO matching parent)

The 2.5a table routes several rows to "Subtask of the right parent" or "Bullet in parent notes," and 2.5d defaults to subtask-or-bullet when in doubt — but these all presume a parent program exists. When Step 2.5b's parent-program lookup returns NO match for an item the table says must NOT be standalone, do NOT silently drop the item and do NOT force it to a top-level task just because no parent exists (that re-introduces the agenda fragmentation 2.5 exists to prevent). Resolve in this order:

1. **Create the program parent first, then attach.** If the action item clearly belongs to an identifiable-but-unregistered program (e.g., a new workstream surfaced in the meeting), create a single top-level program parent task once, register it in the parent-program table per `signal-to-task-pipeline.md` § Step 2.5b, then attach this item (and any siblings from the same meeting) as subtasks. One new parent for a workstream is acceptable; N orphan top-level tasks are not.
2. **If no coherent program parent can be identified** (a genuinely one-off low-priority item with no home), attach it as a notes-bullet on the meeting-series recurring task (e.g., "MarketA meetings - Agenda" for MarketA items, the relevant 1:1 prep task otherwise) under an `### Active signals / notes` subheading, using the same bullet format as 2.5c. The meeting-series task is the parent of last resort — every action item came from a meeting, so the series task always exists as a fallback home.
3. **Only if neither a program parent nor a meeting-series parent exists** (rare — a meeting with no registered series), fall through to a standalone task, and emit `[meeting-to-task] orphan: no parent for "<item>" — created standalone, register a parent` to `<repo-root>` so the missing-parent gap is visible and a parent can be registered for next time.

## Step 3: Deduplication Check (ExamplePerson's items only)

1. Extract 3-5 key noun phrases from the action item text
2. Search Asana: `SearchTasksInWorkspace(text="[key phrases]", assignee_any="<id>", completed=false)`
3. Evaluate matches:
   - **Strong match** (2+ phrase overlap in name or description, same project): Add comment to existing task → `CreateTaskStory(task_gid, text="Reinforced in [meeting_name] on [date]: [action_item_text]")`
   - **Weak match** (1 phrase overlap): Create new task with note "Possible duplicate of [existing_task_gid] — verify."
   - **No match**: Create new task (Step 4)

**Recently-completed guard (before declaring No-match):** the Step-3 search uses `completed=false`, so it cannot see a task ExamplePerson already finished. Before creating a new task on a No-match, run ONE additional search with `completed=true` scoped to the last 14 days. A strong match against a recently-completed task means the meeting re-surfaced an item that's already done — do NOT recreate it; instead add a `CreateTaskStory` to the completed task ("Re-mentioned in [meeting_name] on [date] — already completed [completion_date]; reopen if still needed") and skip creation. This prevents the recurring-meeting failure mode where a done action item gets recreated every time the standing meeting references it. Cap the completed-search to 14 days so the dedup cost stays bounded and genuinely-stale items can legitimately recur.

## Step 4: Asana Task Creation

### Step 4 Precondition (runs BEFORE any CreateTask call)

Before any `CreateTask` invocation in this step:

1. **Asana MCP health probe** — issue a single cheap call (`SearchTasksInWorkspace` with limit=1, completed=false). If the call returns 5xx, auth-failure, or times out, abort Step 4 with `[meeting-to-task] mcp unhealthy: <error-class>` and surface to operator. Do NOT proceed with partial creates — partial creates leave the topic-log entry inconsistent with Asana state and the next pipeline run will mis-deduplicate (Step 3 SearchTasks will miss already-created items because they failed mid-batch).
2. **Step 4 batch failure semantics** — if the probe passes but a `CreateTask` mid-batch fails (rate limit, transient 5xx), do NOT continue creating subsequent tasks in the same batch. Mark the batch as PARTIAL_FAIL in `<repo-root>` with `last_successful_index`, surface the error, and stop. The next pipeline run resumes from `last_successful_index + 1` after re-running Step 3 deduplication on the remaining items.
3. **Order matters** — health probe FIRST, batch creation SECOND. Reversed (start creating, hit a failure, then probe to diagnose) wastes Asana API budget and leaves partial state. The probe is cheap (one read) compared to N writes; failing fast on probe is the right shape.

    notes: "From [meeting_name] on [date].\n\n[full action item text]\n\nSource: Hedy session [session_id]",
    due_on: [derived due date from Step 1],

### Priority Assignment

| Action Item Content | Priority_RW | Star? |
|-------------------|-------------|-------|
| Testing, methodology, framework, experiment | Urgent | ⭐ yes |
| Budget, invoice, campaign change, operational | Today | Star if leadership-facing |
| Automation, data, reporting, system, tool | Today | Sometimes |
| Scheduling, access, approvals, admin | Today | No |

| MarketA-specific | MarketA project |
| MarketB-specific | MarketB project |

## Step 5: Dependency Logging (non-ExamplePerson items)

- **[Person Name]**: [action item text] (from [meeting_name], [date])

## Step 6: Meeting Analytics Insertion — DEPRECATED 2026-05-06

This step previously inserted into DuckDB `main.meeting_analytics`. That table is deprecated. Analytics that depended on this table (speaking share, hedging count, meeting type trends) now source from direct Hedy MCP queries on demand or from topic-log Log entry counts.

Skip this step. Do NOT insert into `main.meeting_analytics`.

## Step 7: Meeting Highlights Insertion — DEPRECATED 2026-05-06

This step previously inserted into DuckDB `meeting_highlights`. That table is deprecated. Key quotes and decisions now live inside topic-log Log entry `#### What was said / what happened` and `#### Decisions` blocks with direct source citation (hedy session ID).

Skip this step. Do NOT insert into `meeting_highlights`.

## Step 8: Slack DM Summary

## Workflow Observability

Log this pipeline execution to `workflow_executions` in DuckDB:

INSERT INTO workflow_executions (execution_id, workflow_name, trigger_source, mcp_servers_involved, start_time)

UPDATE workflow_executions SET end_time = CURRENT_TIMESTAMP, status = '[completed|partial|failed]',
    steps_completed = [N], steps_failed = [N],

## Failure Recovery

If any step above raises an exception or returns an error:

1. **Do not retry inline.** Inline retries amplify upstream failures into cascading work.
2. **Log the failure** to `<repo-root>` as one line:
   `<ISO-timestamp>\t<step_name>\t<error_class>\t<one-line-message>`
3. **Skip silently** for this invocation. Do NOT surface the error to the user. The protocol is non-blocking.
4. **Next invocation** (next trigger or next run): re-attempt from the failed step. If the failure log shows 3+ consecutive failures of the same step, the protocol auto-disables itself by writing a sentinel at `<repo-root>` and a human must clear it.

The 3-failure auto-disable prevents broken protocols from spamming logs indefinitely. It is a circuit breaker, not a fix.

### Worked example
Scenario: a typical run of the meeting to task pipeline workflow encounters a missing or malformed input. Expected behavior: log the failure mode with structured prefix (`[meeting-to-task-pipeline]`), exit non-zero only if the failure is unrecoverable, otherwise emit a `[soft-fail]` log line and proceed with the documented fallback. Concrete: if the workflow expects a JSON payload and gets an empty file, log `[meeting-to-task-pipeline] empty payload — using last-known-good` and read the prior run's artifact from `<repo-root>`.


## Private details intentionally omitted

- real people, teams, organizations, and project names
- live connector IDs and private URLs
- private analytics, dashboards, and metric values
- internal document paths or URLs
- private career and relationship context
