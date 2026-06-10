# Sharepoint Publish — Sanitized Workflow Pattern

Private source path: `context/protocols/sharepoint-publish.md`
Public status: sanitized structural export. This preserves workflow mechanics and removes private people, internal projects, IDs, URLs, and live data.

## What this demonstrates

- Trigger and precondition design
- Phase/step sequencing
- Visible degraded modes
- File/protocol boundaries
- Failure recovery and auditability
- Runtime portability via `<repo-root>` and capability checks

## Sanitized structure

<!-- DOC-XXXX | duck_id: protocol-sharepoint-publish -->
# SharePoint Publish Protocol

Shared publication contract for the wiki-to-team-site SharePoint surface driven by `sharepoint-sync.kiro.hook`.

This protocol keeps the SharePoint publication surface separate from the durability surface:

- `context/protocols/sharepoint-publish.md` owns the wiki md→docx→team-site publication workflow.
- `context/protocols/sharepoint-durability-sync.md` owns `public-demo-store/` operational durability, not published knowledge.
- `wiki-maintenance.kiro.hook` is an adjacent upstream producer: it refreshes many of the wiki artifacts this protocol later publishes, but it does not own the publication contract.

## Publication boundary

| Surface | Owner | Why |
|---|---|---|
| `<repo-root>`, `wiki/state-files/**`, `wiki/meetings/**`, `wiki/topics/**` | local wiki + upstream producers | Source material to stage into `.docx`. |
| `<repo-root>` | this protocol via `sharepoint-sync.kiro.hook` | Local staging area for publication-ready `.docx`. |
| Team-site `Documents/<business-area>` destinations | this protocol via `sp-upload.py::route_destination()` | Published knowledge surface. |
| `public-demo-store/**` | `sharepoint-durability-sync.md` | Operational durability, not publication. |

## Step 1: Stage markdown to `.docx`

**Command:** `python3 `<repo-root>` --mode directory --output-path `<repo-root>`

**Contract:**
1. Stage from these crawl roots: `<repo-root>`, `<repo-root>`, `<repo-root>`, `<repo-root>`.
2. Surface the staging summary counts: created, updated, skipped, failed.
3. If `cli.py` exits non-zero, stop immediately. Do **not** upload stale output from a prior run.
4. If the staging summary shows `0 created` and `0 updated`, stop with `No changes to sync.` Step 2 must not run when nothing new or changed was staged.
5. If a later upload step fails, preserve the staged `.docx` files in `<repo-root>` so the next run can resume publication without re-staging.

**Worked staging failure example:** if `cli.py` fails on control characters or null-byte contamination, report the staging error and stop. Do not continue into SharePoint upload with a partially-refreshed staging directory.

## Step 2: Upload staged `.docx` to team SharePoint

- `local_path`
- `filename`
- `sp_library`
- `sp_folder`
- `sp_site_url`
- `size_bytes`

**Protocol-owned contract:**
1. Treat `sp-upload.py` as the single routing authority. Its `route_destination()` function maps each staged `.docx` to the correct team-site home.
2. For each plan entry, call `sharepoint_write_file` with:
   - `libraryName=entry.sp_library`
   - `siteUrl=entry.sp_site_url`
   - `folderPath=entry.sp_folder`
   - `fileName=entry.filename`
   - `sourcePath=entry.local_path`
3. Pass the plan's `sp_folder` through verbatim. Do **not** hardcode `Artifacts/wiki-sync/`, `public-demo-store/`, or any replacement path. Those blanket destinations are retired.
4. `siteUrl` is **required**. Do not omit it; omission routes the write toward personal OneDrive and causes Access Denied on the team-site surface.
5. Upload in parallel batches. Batch size comes from `$KIRO_SP_UPLOAD_BATCH` with default `10`, allowed range `1-50`. Outside that range, fall back to `10` and note `override-was-ignored` in the run output.
6. Per-file failure isolation is required. One failed upload does not abort the rest of the batch or the rest of the run.
7. At most ONE per-file transient retry inside the current batch is allowed for throttles like a single `429`. If that single retry still fails, mark the file failed and continue. This is distinct from re-running the whole hook.

### Routing contract examples (`sp-upload.py::route_destination()`)

| Staged relative path | Expected SharePoint folder |
|---|---|
| `state-files/ww-testing-state.docx` | `testing` |
| `topics/tests/ExampleProject-brand-lp.docx` | `programs/(public-demo-store)/ExampleProject` |
| `topics/tests/enhanced-match-test.docx` | `testing/(public-demo-store)` |
| `agent-created/forecast-system.docx` | `ps-best-practice/(public-demo-store)` |
| unmatched staging path | `ps-best-practice/(public-demo-store)` default |

**Boundary:** this protocol documents team-site publication only. It does **not** own `public-demo-store/` durability writes and it does **not** change `sp-upload.py` routing logic.

## Step 3: Result reporting

- Always state the target path(s), even on full success.
- Do not dump per-file success lines unless a file failed.
- Partial success is valid: report uploaded count plus failed filenames.

## Failure handling boundary

The hook still owns the **Step 0 preconditions** before this protocol runs: pause flag, same-minute debounce, target-availability probe, and `.last-sharepoint-sync` timestamp claim.

This protocol owns the publication-workflow failure contract after Step 0:

1. Append `<ISO-timestamp>	sharepoint-sync	<step>	<error>` to `<repo-root>` when staging or upload fails.
2. Do **not** re-run the whole hook inline. The next trigger gets a fresh debounce window.
3. If staging succeeded but upload failed, preserve staged `.docx` files for the next run.
4. If one file exhausts its bounded retry, report that file as failed and continue with the rest of the plan.

## Verification guidance

- stage a small wiki subset (1-2 `.docx`) locally
- confirm `route_destination()` resolves each file to the same folder the protocol claims
- confirm `siteUrl` is threaded from the plan entry into the write call
- confirm one file can fail without aborting the rest of the publication run
- do parity against scratch folders like `testing/(public-demo-store)/_parity/`, not live team-site destinations

## Common failure patterns

- **Uploading stale staged output after a staging failure.** Always stop if `cli.py` exits non-zero.
- **Hardcoding the destination path.** Publication destinations come from `sp-upload.py::route_destination()`, not from the hook prompt.
- **Dropping `siteUrl`.** Team-site writes require it.
- **Retrying the whole hook after a throttle.** Use only the bounded per-file retry; whole-hook retries amplify throttling.
- **Confusing publication with durability.** `sharepoint-sync` publishes to business-area homes; `sharepoint-durability-sync` writes operational state to `public-demo-store/`.


## Private details intentionally omitted

- real people, teams, organizations, and project names
- live connector IDs and private URLs
- private analytics, dashboards, and metric values
- internal document paths or URLs
- private career and relationship context
