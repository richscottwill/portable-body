# Decision Agent — Sanitized Workflow Pattern

Private source path: `context/protocols/decision-agent.md`
Public status: sanitized structural export. This preserves workflow mechanics and removes private people, internal projects, IDs, URLs, and live data.

## What this demonstrates

- Trigger and precondition design
- Phase/step sequencing
- Visible degraded modes
- File/protocol boundaries
- Failure recovery and auditability
- Runtime portability via `<repo-root>` and capability checks

## Sanitized structure

# Decision Agent v0

**Status:** v0 — single-file protocol, not yet a separate agent invocation. Any agent reading a build/system-change request applies this protocol inline.
**Authority:** ExamplePerson authorized the build during the Emma-transcript brainstorm. Future protocol changes route to karpathy (it touches the experiment / system-change layer).
**Lives at:** `<repo-root>`

## Purpose

Most "should I build X" questions in this system get answered by ExamplePerson asking 2-3 agents and synthesizing manually. That's expensive, inconsistent, and produces ~50 ideas with no shipped move (see 2026-05-25-emma-transcript-ideas.md).

The decision agent forces every build/system-change proposal through the same explicit decision tree, logs the answer + reasoning, and makes the trail reviewable later. It does not decide for ExamplePerson — it makes ExamplePerson's decision visible and consistent.

## When to invoke this protocol

- Proposing a new agent, skill, hook, MCP power, or steering file.
- Proposing a new automation, dashboard, or workflow that takes >1 hour to build.
- Proposing a new persistent log, scheduled job, or data table.
- Renaming/relocating any organ, protocol, or steering file.

- Proposing a >50-line edit to an existing organ, protocol, or steering file.
- Proposing a new wiki article (the wiki pipeline already has a critic; this is for "should it exist" not "is it good").

- One-off scripts in /workspace that won't persist.
- Single-turn investigations or queries.
- Edits ExamplePerson has explicitly directed in the same conversation.

## The decision tree (run in order, stop at first NO)

### 0. Lock the proposal (preflight, before any gate runs)

Capture the proposal as written before invoking gate 1. This makes gate-shopping (re-framing the proposal mid-run to satisfy a failing gate) auditable.

- Write the proposal in one sentence: subject, verb, object, scope. Example: `Add a new hook that posts daily Slack digest to #example-channel`.
- Append the captured sentence to the decision log row's `proposal` field at the start of the run. If a downstream gate fails and the proposal is reworded, that's a NEW protocol invocation with a new row — not an edit to the locked text.
- If the proposal is too vague to capture in one sentence, return verdict `INVESTIGATE_FIRST` immediately. Do not run any gates against a moving target.

This preflight is a hard precondition. Skipping it is the most common path to invisible-decline gate-shopping. Order matters: gate 0 must complete before gate 1 reads the locked text.

### 1. Does this already exist?

Check before building. Your stack has 60+ steering files, ~10 agents, ~12 skills/powers, and many DuckDB tables. New things often duplicate old things you forgot.

- Search agent-bridge: `<repo-root>`, `<repo-root>`, steering files, skills inventory.
- Search the workspace for similar names or purposes.
- If something close exists: extend it, don't add a new one. (Soul.md principle 3: subtraction before addition.)

**STOP if:** something within 80% of the proposed scope already exists. Document why extending is wrong before continuing.

### 2. Has the off-the-shelf option been pushed to its limit?

Default soul.md principle 8 question. Override applies for agentic builds where flexibility/composability is the explicit goal (decision captured 2026-05-25). For non-agentic builds (UI, dashboard, integration), this question is binding.

- If a Microsoft tool, Outlook rule, Loop feature, or existing power does 70% of this — try the 70% solution before building.
- For agentic builds: skip if "agent flexibility" is the genuine reason (not a rationalization). Document why.

### 3. What does it cost to build, run, and maintain?

- **Build cost:** hours of focused time.
- **Run cost:** tokens per invocation × invocations per week. Or compute, or storage.
- **Maintenance cost:** how often will this break or need re-tuning? What happens when the model swaps?

### 4. Does it embody soul.md system design principles?

- **Routine as liberation (1):** Does it remove a recurring decision?
- **Structural over cosmetic (2):** Does it change defaults/friction, or just rearrange surfaces?
- **Subtraction before addition (3):** What's being removed to make room?
- **Protect the habit loop (4):** Does this break or strengthen an existing routine?
- **Invisible over visible (5):** Will it disappear into the system, or trigger novelty effects?
- **Reduce decisions, not options (6):** Does it lower friction without limiting choice?
- **Human-in-the-loop on high-stakes (7):** If high-stakes, does it preserve the gate?
- **Check device.md (8):** Repetitive enough? Adoption realistic?

### 5. Which Five Levels does it advance?

- **L1 Sharpen Yourself:** weekly artifact streak protection or acceleration.
- **L2 Drive WW Testing:** test methodology, hypothesis library, results pipeline.
- **L3 Team Automation:** team-portable artifacts; tools teammates adopt 30+ days.
- **L4 Zero-Click Future:** AEO/AIO instrumentation or POV.
- **L5 Agentic Orchestration:** autonomous workflows.

### 6. Portability test (for anything team-facing)

- Will this survive being pasted into ChatGPT-enterprise with no body system?
- Will it work without your DuckDB / hooks / agent-bridge?
- Can a teammate use it without ExamplePerson explaining anything?

### 7. What gets removed?

- A steering file that overlaps.
- A skill that hasn't fired in 30+ days.
- A hook whose output you never read.
- An agent that hasn't earned its place.

### 8. What's the success metric and review date?

- **Metric:** measurable, not vibes. "Used 2x unprompted by ExamplePerson" beats "feels useful."
- **Review date:** when do we revisit. Default = 30 days for tools, 60 days for protocols, 90 days for organs.
- **Kill criteria:** what would make this earn its way off the system.

## Failure recovery (gate-input or log-write errors mid-run)

The decision tree depends on two things that can fail: the searches gates 1 and 6 perform (filesystem/agent-bridge reads), and the final append to `decision-log.tsv`. A gate that cannot complete its check must NOT silently pass or silently fail — either error mode corrupts the audit trail the protocol exists to produce. Handle in this order:

1. **Gate-input read failure (gate 1 "does this exist" search, or gate 6 portability check, errors or times out).** Do NOT treat an errored search as "nothing found" — a search that failed is not evidence of absence, and passing gate 1 on a failed search is exactly how duplicates get built. Re-run the failed read once. If it fails again, return verdict `INVESTIGATE_FIRST` with `gate_failed=<N>-read-error`, log the row, and STOP. The proposal is parked, not declined — a tooling failure is not a decision.
2. **Verdict reached but `decision-log.tsv` append fails (disk full, permission denied, file lock).** The decision itself is valid — do NOT re-run the gates. Capture the full intended row to `<repo-root>` (a side queue), surface `[decision-agent] verdict=<V> but log append failed — queued to decision-log-pending.tsv` to ExamplePerson, and proceed to act on the verdict. The next protocol run drains the pending queue into decision-log.tsv before locking its own proposal. Losing the audit row is worse than a duplicate row; the side queue guarantees the decision is never lost, and a deduped drain (keyed on ts+proposal) prevents double-logging.
3. **decision-log.tsv unreadable at start of run (corrupt / partial write from a prior crash).** Gate 1's "search the stack" still runs against the live files, so the protocol is not blocked. Rename the corrupt log to `decision-log.corrupt-<ISO>.tsv` (preserve for forensics, never delete), start a fresh log, note `[decision-agent] prior log corrupt — preserved + restarted` in the row's short_reason, and proceed. A poison-pill log must never gate a live decision.

Order rationale: read failures (path 1) gate the verdict — a decision made on incomplete search data is wrong, so it fails-safe to INVESTIGATE_FIRST. Log-write failures (path 2) happen AFTER a valid verdict, so they fail-forward (act on the decision, queue the audit row) — the opposite bias from path 1, because here the decision is sound and only the record is at risk. Reversed (treating a log-write failure as INVESTIGATE_FIRST) would re-litigate a decision ExamplePerson already made; reversed (treating a search failure as fail-forward BUILD) would build on a false "nothing exists" signal.

## Output format

When this protocol runs, it appends one row to `<repo-root>`:

- `ts`: ISO 8601 UTC.
- `proposal`: 1-line description.
- `verdict`: `BUILD` / `EXTEND` / `DECLINE` / `DEFER` / `INVESTIGATE_FIRST`.
- `short_reason`: one sentence.
- `gate_failed`: which gate (1–8) tripped, or `none` if BUILD.
- `level`: L1/L2/L3/L4/L5 or `none`.
- `review_date`: YYYY-MM-DD.
- `metric`: one phrase.
- `subtraction`: what's being removed.

## Verdict semantics

- **BUILD** — passed all gates. Schedule, build, log.
- **EXTEND** — gate 1 fired (something close exists). Modify the existing thing instead.
- **DECLINE** — gate 2/4/5 fired (off-the-shelf does it / violates principles / no level fit).
- **DEFER** — gate 3 fired (cost wrong-sized for current capacity). Park, set re-evaluation date.
- **INVESTIGATE_FIRST** — gate 1 ambiguous, gate 6 ambiguous, or success metric unclear. 30-min investigation before re-running protocol.

## Failure modes to watch

- **Gate-shopping.** Forcing a "yes" by reframing until each gate passes. The decision log makes this visible — if every proposal "barely passes" gate 7 with thin subtraction, the bias is exposed.
- **Invisible declines.** A DECLINE without a logged decision = the idea comes back next quarter and gets re-litigated. Always log, even (especially) when declining.
- **Sequence collapse.** Running gates out of order to confirm a pre-decided answer. Order matters — gate 1 (does this exist) before gate 3 (cost) prevents budgeting for duplicates.
- **Over-engineering at v0.** This protocol is itself v0. Don't add more gates until you've run it 10+ times and seen the patterns.

## Calibration

- BUILD verdicts that didn't ship within their review date → why?
- DECLINE verdicts that came back as proposals later → why was the original decline wrong?
- DEFER verdicts that aged past 90 days → kill or escalate.
- BUILDs without subtraction → trigger a subtraction pass.

Adjust gate thresholds based on what's surfacing. Authority for tuning gates: karpathy (sits in the experiment-protocol layer). Authority for capture mechanics (where it logs, format): infrastructure (kiro-server / kiro-local).

## Open question (recurring)

Does this protocol get queryable across agents (shared decision store) or stay as an inline check each agent runs? A shared store would make decisions queryable across agents. Inline check is faster to ship. Decision deferred to v1; v0 stays inline.


## Private details intentionally omitted

- real people, teams, organizations, and project names
- live connector IDs and private URLs
- private analytics, dashboards, and metric values
- internal document paths or URLs
- private career and relationship context
