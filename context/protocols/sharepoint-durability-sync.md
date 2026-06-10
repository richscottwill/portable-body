# Sharepoint Durability Sync — Sanitized Workflow Pattern

Private source path: `context/protocols/sharepoint-durability-sync.md`
Public status: sanitized structural export. This preserves workflow mechanics and removes private people, internal projects, IDs, URLs, and live data.

## What this demonstrates

- Trigger and precondition design
- Phase/step sequencing
- Visible degraded modes
- File/protocol boundaries
- Failure recovery and auditability
- Runtime portability via `<repo-root>` and capability checks

## Sanitized structure

<!-- DOC-XXXX | duck_id: protocol-sharepoint-durability-sync -->

## Portability contract

Apply `<repo-root>/context/protocols/path-standardization.md` before execution. Resolve `<repo-root>` from `$AGENT_BRIDGE_ROOT` or `tools/scripts/agent_bridge_paths.py root`; do not assume a literal `<repo-root>` checkout. For executable shell snippets, set `REPO_ROOT=<resolved repo root>` and use `$REPO_ROOT/...`. Use `$PS_DUCKDB_PATH` for DuckDB override when needed; otherwise default to `<repo-root>/data/duckdb/ps-analytics.duckdb`.

# SharePoint Durability Sync Protocol

> **Durability root renamed 2026-06-05.** The old off-convention top-level `public-demo-store/` is RETIRED. The durability subsystem now lives under `public-demo-store/`, matching the business-area top-level taxonomy and the `(public-demo-store)` agentic-output convention used everywhere else. Internal structure (`system-state/`, `state-files/`, `portable-body/`, `meeting-briefs/`) is unchanged — only the root prefix moved. The stray top-level `system-state/` and the legacy `public-demo-store/{agent-state,portable-body,audit-logs}/` folders were folded into this same root in the same change.

**Why:** DevSpaces containers can die. `<repo-root>/` is persistent but only accessible via SSH. SharePoint survives container restarts and is accessible from any device (phone, local machine, browser). This protocol makes the system resilient to environment loss and gives ExamplePerson mobile access to key artifacts.

**Principle alignment:** Invisible over visible (Principle 5) — sync happens silently in the background. Structural over cosmetic (Principle 2) — changes the default durability without changing the workflow.

## Early Exit (runs before any step below)

If `<repo-root>/context/active/sharepoint-durability-sync-pause.flag` exists, exit silently. Do NOT execute any step in this protocol. This pause flag is the operator's kill switch — it must be honored before any side-effect-producing work begins (DuckDB queries, LLM calls, file writes). Removal of the flag re-enables the protocol on the next invocation.

## Step 0: Preconditions (early-exit, runs BEFORE any sync operation)

The single Early Exit gate (pause flag) is necessary but not sufficient. Three gates fire in order before any SharePoint call.

1. **Pause flag (cheapest, ~1ms file existence check).** If `<repo-root>/context/active/sharepoint-durability-sync-pause.flag` exists, exit silently. Do NOT execute any step in this protocol. This pause flag is the operator's kill switch — it must be honored before any side-effect-producing work begins (DuckDB queries, LLM calls, file writes). Removal of the flag re-enables the protocol on the next invocation.

2. **Token-expiry probe (medium cost, ~50ms).** Read the SharePoint auth token's expiry from the cached credential. If `expiry - now < 300 seconds` (5 minutes remaining), refresh the token BEFORE starting the sync rather than mid-sync. Token refresh mid-sync is the dominant failure mode the existing Auth-Expiry recovery branch handles, but pre-refreshing avoids the partial-state cleanup entirely. If refresh fails, exit with `[sharepoint-durability-sync] token refresh failed: <reason>` and let the operator re-auth.

3. **Quota-headroom probe.** Issue a lightweight `GetSiteQuota` call (or the equivalent capacity check). If used > 95% of allocated quota, exit with `[sharepoint-durability-sync] quota near-full: <used>/<allocated>` and surface to operator. The existing Branch 3 (quota exceeded mid-sync) handles 507 errors after the fact; the headroom probe prevents sync attempts that will hit 507 mid-batch and require partial cleanup.

After Step 0 passes, proceed to "Failure Recovery" branches below. Note: the existing Early Exit section above is now Step 0.1; the additional gates 0.2 and 0.3 are net-new behavior.

## Failure Recovery — Auth Expiry Mid-Sync

SharePoint auth tokens expire on a rolling window. Mid-sync expiry is the most common partial-failure mode (e.g., 12 of 18 files pushed before the 13th call returns 401). The protocol handles this without crashing the calling pipeline.

### Branch 1: Auth expired (401 / 403 from sharepoint_write_file)
1. **Do NOT retry inline more than once.** Auth is not a transient error — re-firing the same call within the same invocation produces the same 401. One quick retry handles edge cases (clock skew, stale cache).
2. **Capture the partial-sync manifest.** Log to `<repo-root>/context/active/sharepoint-sync-errors.jsonl` with one JSON object: `{"phase": "auth_expired", "synced": ["<path1>", "<path2>", ...], "remaining": ["<pathN>", ...], "ts": "<ISO>"}`. The manifest tells the next run what's already done so it doesn't re-push 12 files unnecessarily.
3. **Surface to ExamplePerson** with a one-liner so he can refresh auth: `[sharepoint-sync] auth expired after <N>/<M> files — manifest at sharepoint-sync-errors.jsonl, refresh auth then re-run`. Do NOT swallow silently — ExamplePerson needs to know the durability copy is incomplete until he refreshes auth.
4. **Resumable on next invocation.** The next call to this protocol reads the most recent `auth_expired` manifest, skips the already-synced files, and pushes only the remaining set. If auth is still expired, surface the same message and stop.

### Branch 2: Network unreachable (timeout, DNS error)
Treat as transient. Retry the failed write once after a 5-second sleep. If still failing, log to `sharepoint-sync-errors.jsonl` with `phase: "network_unreachable"` and continue with the remaining files. Network issues are usually local and partial; do NOT abort the whole sync because of one bad file.

### Branch 3: SharePoint quota exceeded (507 / quota error)
Hard-stop. Quota is not transient — retrying produces the same error. Log with `phase: "quota_exceeded"` and surface to ExamplePerson. Do not delete local files to make room; the durability principle requires the local copy as the canonical write.

### Recovery loop

### Circuit breaker (recovery-loop runaway guard)
If the same `remaining` file fails to sync on 3 consecutive sync invocations — increment a per-path `attempts` counter in the manifest on each failed re-attempt, and reset it to 0 the moment that path syncs successfully — stop re-attempting that file once `attempts` reaches 3: move it to a `quarantined` array in the manifest and surface `[sharepoint-sync] quarantined <path> after 3 failed re-attempts — manual reconcile needed`. This prevents a single permanently-broken file (corrupt local copy, unresolvable path) from blocking the `remaining` set on every run forever. Quarantined files are skipped by the recovery loop until a human clears them; the rest of the `remaining` set still syncs.

### Quarantine aging (auto-retry stale quarantine entries)

A file that quarantined for a *transient-but-slow* reason (a multi-day SharePoint outage, a temporary permission revocation later restored) would otherwise sit in `quarantined` forever until a human notices — defeating the durability goal for that file indefinitely. To bound this without re-introducing the runaway the circuit breaker prevents, age out quarantine entries: stamp each quarantined entry with `quarantined_at: <ISO>` when it enters the array. At the start of the recovery loop, BEFORE draining `remaining`, scan `quarantined` for any entry whose `quarantined_at` is older than `$SHAREPOINT_Q<user-id>_TTL_HOURS` (default 72, allowed range 24–336). For each aged-out entry: move it back to `remaining` with `attempts` reset to 0, and log `[sharepoint-sync] quarantine-aged <path> after <H>h — re-attempting once`. This gives a permanently-broken file at most one re-attempt per TTL window (not per run), so a corrupt local copy costs one failed write every 72h instead of one every run, while a transiently-broken file self-heals without manual intervention once the upstream recovers.

Order rationale (age-out scan BEFORE draining `remaining`): an aged-out file must be promoted back to `remaining` first so it is included in this run's sweep; if the drain ran first, the just-promoted file would wait a full extra run. What breaks if the TTL were applied per-run instead of per-wall-clock-age: a fast-cycling hook (firing every prompt) would re-attempt a corrupt file dozens of times an hour — exactly the runaway the 3-strike quarantine exists to stop. Anchoring the retry to wall-clock age, not run count, decouples re-attempt frequency from hook cadence.

**Worked example — circuit-breaker progression:** Sync run A pushes 17 of 18 files; `forecast-q3.xlsx` fails (corrupt local copy returns a 400). Manifest records `remaining: ["forecast-q3.xlsx"]`, `attempts: 1`. Run B drains the manifest, re-attempts `forecast-q3.xlsx` first — fails again, `attempts: 2`. Run C — fails again, `attempts: 3` reached, so the file moves to `quarantined: ["forecast-q3.xlsx"]` and surfaces `[sharepoint-sync] quarantined forecast-q3.xlsx after 3 failed re-attempts — manual reconcile needed`. Run D and onward: the recovery loop skips the quarantined file entirely and syncs only healthy `remaining` paths, so one corrupt file never again stalls the sweep. After ExamplePerson repairs the local copy and clears it from `quarantined`, the next run re-attempts it with `attempts` reset to 0. Contrast without the counter: `forecast-q3.xlsx` would be re-attempted first on every single run forever, and because the recovery loop drains `remaining` before new files, a permanently-broken file at the head of the queue could starve the rest of the durability copy indefinitely.

## SharePoint Target

- Library: `Documents` (personal OneDrive)
- Base folder: `public-demo-store/`  *(was `public-demo-store/` before the 2026-06-05 rename)*
- No siteUrl needed (defaults to personal OneDrive)

#### SharePoint Target — Details

- Subfolders auto-created on first write

## Folder Structure

├── system-state/          # Hook output artifacts (updated every AM/EOD run)
│   ├── hook-protocol-audit.md
├── audit-logs/            # Folded in from legacy public-demo-store/audit-logs/ (2026-06-05)

**Note:** Published work products live in their business-area `(public-demo-store)/` subfolders (managed by the sharepoint-sync hook + cli.py with .docx conversion, SHA-256 dedup, incremental sync). `public-demo-store/` is exclusively for system state, snapshots, audit logs, and meeting briefs — the operational durability layer, separate from the published-knowledge layer. The old top-level `Artifacts/` folder was retired 2026-06-05.

## PUSH: When to Write to SharePoint

### Automatic Push Triggers (agent decides)

| Trigger | What Gets Pushed | SharePoint Path | Create or Update |
|---------|-----------------|----------------|-----------------|
| EOD Backend Phase 7.5 | eod-reconciliation.md, eod-maintenance.md, eod-experiments.md, daily-brief-latest.md | system-state/ | **Update** (overwrite same filename — always latest) |
| AM Backend Phase 6.5 | am-enrichment-queue.json, am-portfolio-findings.json, daily-brief-latest.md | system-state/ | **Update** |
| `forecast-sharepoint-push.kiro.hook` Step 1 | `ps-forecast-tracker.xlsx` durability copy | `public-demo-store/system-state/ps-forecast-tracker.xlsx` | **Update** |
| Friday EOD (or on-demand) | Portable body snapshot, rw-tracker.md | portable-body/, system-state/ | **Create** new dated snapshot + **Update** rw-tracker |
| Wiki article reaches PUBLISH stage | Final article as .docx | business-area `(public-demo-store)/` | Managed by sharepoint-sync hook — NOT part of durability sync |
| Strategic artifact shipped (Testing Approach, AEO POV, etc.) | Final doc as .docx | business-area `(public-demo-store)/` | Managed by sharepoint-sync hook — NOT part of durability sync |
| Meeting prep doc created | Prep brief | meeting-briefs/ | **Create** |
| AM-Backend Step 2E / EOD Step 9 | State file .docx per market (MarketB, MarketA, WW Testing) | `public-demo-store/state-files/` | **Update** (overwrite — always latest version) |
| `state-file-constraints-sync.kiro.hook` Step 3 | Constraint-patched SharePoint state file | `public-demo-store/state-files/<filename>` | **Update** |

### Decision Logic: Create vs Update

- **system-state/** files: Always **update** (overwrite). These are "latest state" — only the current version matters.
- **portable-body/** snapshots: Always **create** with dated filename. Never overwrite old snapshots — they're the historical record.
- **meeting-briefs/**: **Create** only. Meeting briefs are point-in-time — never updated after creation. Index file is the exception (updated when new briefs are added).
- **Artifacts/**: Managed entirely by the sharepoint-sync hook. Not part of this protocol.

### Push Implementation

# Update pattern (system-state):
sharepoint_write_file(libraryName="Documents", folderPath="public-demo-store/system-state",
    fileName="eod-reconciliation.md", content=<read_local_file>)

# Create pattern (portable-body):
sharepoint_write_file(libraryName="Documents", folderPath="public-demo-store/portable-body",

# Published work products are NOT written here — the sharepoint-sync hook routes them
# to the business-area (public-demo-store)/ folders. This protocol only writes operational state.

## Hook-specific durability write contracts (2026-06-08 hardening)

These are the reusable SharePoint durability branches externalized out of the hook prompts. The hook still owns its trigger-specific preconditions, local validation, and any artifact-specific transform. This protocol owns only the SharePoint durability copy / read-write / recovery path.

### Forecast tracker durability copy (`forecast-sharepoint-push.kiro.hook`)

**Scope:** Step 1 only — copy local `<repo-root>/dashboards/ps-forecast-tracker.xlsx` to `public-demo-store/system-state/ps-forecast-tracker.xlsx`.

**Hook-owned (stays inline):** pause flag, debounce, freshness gate, local xlsx validation, Dashboards read-path copy, and final report.

**Protocol-owned contract:**
1. Write `sourcePath=<repo-root>/dashboards/ps-forecast-tracker.xlsx` to library `Documents`, folder `public-demo-store/system-state`, file `ps-forecast-tracker.xlsx`.
2. If the write fails, retry once after 10 seconds.
3. If the retry still fails, log `[forecast-push] durability-copy failed: <reason>` to `<repo-root>/context/intake/session-log.md` and return **DEGRADED** so the hook continues to its Dashboards copy. Do **not** block the read-path push on a durability-copy failure.
4. Treat this as a durability branch, not the primary success signal — the Dashboards copy remains the hook's primary external dependency for Harmony.

### State-file constraints sync write path (`state-file-constraints-sync.kiro.hook`)

**Scope:** Step 1 download + Step 3 write only. The hook still owns Step 2 marker splice.

**Inputs passed from the hook per file:** `filename`, `sharepoint_path`, and the already-built `updated_content`.

**Protocol-owned contract (per file):**
1. Download the current SharePoint file to `<repo-root>/context/active/scratch/<filename>` using the provided `sharepoint_path`.
2. If the download fails, log `[constraints-sync] download failed: <filename> reason=<error>` to `<repo-root>/context/intake/session-log.md` and skip this file. Never splice or write against stale local content.
3. After the hook computes `updated_content`, write it back to `public-demo-store/state-files/<filename>`.
4. On write failure, retry once after 5 seconds.
5. If the retry still fails, save the spliced output to `<repo-root>/context/active/scratch/<filename>.pending`, log `[constraints-sync] write failed: <filename> reason=<error>`, and continue.
6. Per-file failure isolation is required; one failed file never blocks the rest of the payload.
7. If all files fail, surface one summary `[constraints-sync] all N writes failed — SharePoint unreachable?` rather than spamming N separate alerts.

**Boundary:** this protocol does **not** decide marker placement or fabricate missing markers; the splice algorithm stays inline in the hook because it is specific to the constraint-block format. The hook may also skip the write entirely when the spliced content is byte-identical to the downloaded file.

## PULL: When to Read from SharePoint

### Automatic Pull Triggers (agent decides)

| Trigger | What Gets Pulled | When | Why |
|---------|-----------------|------|-----|

**Example:** If this section references a specific process, the concrete steps are: |---------|-----------------|------|-----|...

| Cold start (new container, no `<repo-root>/` state) | portable-body/body-snapshot-*.md (latest) | Session start, if local files missing | Bootstrap the system from last known good state |
| AM Backend can't find local output files | system-state/*.json | Phase 2+ of AM, if Phase 1 output missing | Container may have restarted between phases |
| EOD Frontend can't find backend output | system-state/eod-*.json | EOD Frontend Step 1, if local files missing | Backend may have run in a prior container session |
| ExamplePerson asks about a published artifact | artifacts/*.md | On demand | Artifact may have been created on a different machine or in a prior container |
| ExamplePerson asks "what did the brief say" from a different context | system-state/daily-brief-latest.md | On demand | Brief was generated in SSH but ExamplePerson is asking from local |

### Pull Decision Logic

1. **Always try local first.** `<repo-root>/` is the source of truth when available.
2. **Fall back to SharePoint** only when local file is missing, stale (>24h for system-state), or explicitly requested.
3. **Never overwrite local with SharePoint** unless local is confirmed missing. SharePoint is the backup, not the master.
4. **Staleness check:** For system-state files, compare local file mtime vs SharePoint Modified timestamp. If SharePoint is newer (e.g., another agent session wrote to it), pull and merge.

# Read text file inline:
sharepoint_read_file(serverRelativeUrl="/personal/example-user_ExampleCo_com/Documents/public-demo-store/system-state/daily-brief-latest.md",

# Download binary or large file:
sharepoint_read_file(serverRelativeUrl="/personal/example-user_ExampleCo_com/Documents/public-demo-store/portable-body/body-snapshot-2026-04-11.md",

## What Does NOT Get Synced

| Category | Why Not |
|----------|---------|
| Organs (body.md, brain.md, etc.) | Change every session. SharePoint latency creates stale reads. Live workspace is source of truth. |
| DuckDB data | Structured data. Not file-based. Query via DuckDB MCP (`execute_query`). |
| Intake files | Ephemeral. Processed and deleted within the same session. |
| Hook configs, steering files | IDE-bound. No cross-device need. |
| Audit logs (JSONL) | Append-only. Stays on filesystem + DuckDB. |
| Git repo state | Managed by git, not SharePoint. |

## Conflict Resolution

1. **system-state/**: Local wins. These are regenerated every run — the latest local version is always correct.
2. **state-files/**: Local wins. Generated by AM-Backend, patched by EOD. SharePoint is delivery copy only.
3. **portable-body/**: No conflict possible — each snapshot has a unique dated filename.
3. **meeting-briefs/**: No conflict possible — created once, never updated (except index).
4. **Artifacts/**: Managed by sharepoint-sync hook with SHA-256 dedup. Not part of this protocol.

### Common Pitfalls — Conflict Resolution
- **Treating a state-file SharePoint edit as authoritative.** If someone edits a state file directly in SharePoint, the next AM-Backend run overwrites it (local wins). Never hand-edit state-files/ in SharePoint expecting it to persist — the change is silently lost on the next sync.
- **Assuming portable-body snapshots can collide.** They cannot — each snapshot has a unique dated filename, so a "conflict" on a portable-body path means a filename-generation bug, not a real merge conflict. Investigate the timestamp logic, do not force-overwrite.
- **Letting an Artifacts/ conflict block this protocol.** Artifacts/ is managed by the separate sharepoint-sync hook with SHA-256 dedup. A conflict there is out of scope here; do not attempt to resolve it from the durability-sync path.

## Error Handling

- SharePoint write fails → log warning to DuckDB `workflow_executions`, continue. Local files are source of truth.
- SharePoint read fails → use local file. Log warning.
- SharePoint is a durability layer, not a dependency. **No hook should fail because SharePoint is unreachable.**
- Log all sync operations to DuckDB: `INSERT INTO workflow_executions (workflow_name, ...) VALUES ('sharepoint-durability-sync', ...)`

**Example:** This section demonstrates the pattern in practice — concrete instances ground abstract rules.

## Verification

## Failure Recovery (added by experiment)

If any step in this protocol errors: do not retry inline more than once. Log the failure with a one-line cause and continue with degraded output where possible. If a load-bearing step fails with no degraded path, report TASK_BLOCKED with the cause and stop — do not invent results. Order rationale: a partial-but-correct run beats a complete-but-fabricated one.

**Worked example:** the upstream query times out on step 2. The protocol retries once after a short wait; on a second failure it logs `[step2] query timeout` and proceeds to steps that don't depend on step 2's output, marking the dependent outputs as <user-id> rather than guessing.


## Private details intentionally omitted

- real people, teams, organizations, and project names
- live connector IDs and private URLs
- private analytics, dashboards, and metric values
- internal document paths or URLs
- private career and relationship context
