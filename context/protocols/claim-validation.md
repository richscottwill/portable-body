# Claim Validation — Sanitized Workflow Pattern

Private source path: `context/protocols/claim-validation.md`
Public status: sanitized structural export. This preserves workflow mechanics and removes private people, internal projects, IDs, URLs, and live data.

## What this demonstrates

- Trigger and precondition design
- Phase/step sequencing
- Visible degraded modes
- File/protocol boundaries
- Failure recovery and auditability
- Runtime portability via `<repo-root>` and capability checks

## Sanitized structure

<!-- DOC-0512 | duck_id: protocol-claim-validation -->

# Claim Validation Protocol

**Status:** v1 — single-file protocol, run inline before a draft is finalized or circulated.
**Authority:** ExamplePerson requested a distinct claim/fact check separate from writing-quality review.
**Lives at:** `<repo-root>`

## Why this exists

Use this protocol when a draft contains:
- numbers or percentages
- statements about market performance or experiment results
- causal claims ("X caused Y")
- statements about customer behavior, competitor behavior, or org decisions
- recommendations that depend on a factual premise being true

The output is a claim table, not polished prose.

## When to invoke this protocol

- leadership-facing docs, 6-pagers, PR-FAQs, MBR/WBR narratives, or review docs with numbers
- any draft that will be forwarded outside ExamplePerson's immediate working session
- any draft where a recommendation rests on a factual claim

- wiki articles or meeting summaries that synthesize multiple sources
- experiment readouts or test proposals
- any draft where the writer had to use the words *estimate*, *likely*, *appears*, *suggests*, or *probably*

- pure style edits with no substantive facts
- private brainstorming notes clearly marked as hypotheses only
- drafts ExamplePerson explicitly labels as rough framing rather than evidence-backed output

## Early exit

## Failure recovery

If any step below fails:

1. **Do not silently pass the draft.** A failed validation step is not evidence the claim is fine.
2. **Retry one read/query once** if the failure is a file read or DuckDB access issue.
3. **If the retry fails, mark the affected claim `<user-id>`** and record the missing source or tool failure in the Evidence / Fix column.
4. **If 30%+ of claims are `<user-id>`, stop the pass and return `TASK_BLOCKED`** with the missing sources called out. A mostly-unverified validation pass gives false confidence.
5. **If a claim depends on a source you cannot access in the current environment, fail safe toward caveat or removal.** Do not upgrade a claim to supported from memory.

Order matters: retry the source read first, then downgrade the claim, then decide whether the whole pass is blocked. Reversed order would stop the pass early on a transient read error and lose the recoverable claims.

## Output format

| Claim | Type | Status | Evidence / Fix |
|---|---|---|---|
| `<verbatim or near-verbatim claim>` | `numeric \| factual \| causal \| judgment` | `SUPPORTED \| CAVEAT \| <user-id> \| <user-id>` | `<source path / query / reason / rewrite guidance>` |

- `Supported:` N
- `Needs caveat:` N
- `Unsupported:` N
- `Unverified:` N
- `Recommendation:` `ship`, `ship-with-caveats`, or `revise-before-send`

## The protocol (run in order)

### 1. Extract claims

Read the draft and pull the checkable claims. Extract at the sentence or sub-sentence level — one row per independently checkable proposition.

- "MX registrations were +12% vs ExampleProject in May" → one numeric claim
- "The May shortfall was primarily driven by CPC inflation after the bid change" → one causal claim
- "The AU test supports scaling to MX" → one judgment claim tied to evidence

### 2. Classify each claim

- **numeric** — numbers, percentages, counts, date ranges, spending, CPA, registrations
- **factual** — statements about what happened, who decided what, which system exists, what a source says
- **causal** — statements that one factor explains or drove another
- **judgment** — evidence-backed interpretation or recommendation

### 3. Check the strongest source available

Use the strongest source you can access in this order:

1. DuckDB / deterministic query output
2. canonical repo doc with DOC stamp or active-state file
3. primary artifact (xlsx, csv, meeting note, SharePoint/Quip doc)
4. secondary synthesis doc
5. memory or prior chat context **only as a lead to search, never as final evidence**

Every supported claim should point to a concrete source path, query, or named artifact.

### 4. Assign claim status

- **SUPPORTED** — source directly supports the claim as written.
- **CAVEAT** — the core claim is directionally right, but the wording is too strong, too precise, or missing an important condition/timeframe/source limitation.
- **<user-id>** — available evidence conflicts with the claim, or no available evidence supports it and the sentence states it as fact.
- **<user-id>** — the claim might be checkable, but the required source is inaccessible, missing, or the tool needed to verify it failed.

### 5. Rewrite risky claims in-place guidance

For every `CAVEAT`, `<user-id>`, or `<user-id>` item, provide the minimum safe rewrite in the Evidence / Fix column.

Patterns:
- unsupported certainty → downgrade to hypothesis: `"X caused Y"` → `"X may have contributed to Y; current evidence is pattern-based, not causal proof."`
- precision without source → reduce precision: `"+12.4%"` → `"roughly +12%"` only if a real source supports the rounded number
- claim with wrong scope → add scope/timeframe: `"AB is down"` → `"AB ExampleCo registrations were down WoW in W22"`
- inaccessible source → remove or flag: `"Needs Quip sheet access before this can be stated."`

### 6. Decide ship vs revise

- **ship** — all claims are `SUPPORTED`
- **ship-with-caveats** — no `<user-id>`, and only minor wording downgrades are needed
- **revise-before-send** — any `<user-id>`, or more than 2 `<user-id>`, or any unsupported causal claim tied to a recommendation

## Special rules by claim type

### Numeric claims

- Prefer DuckDB / Python / Excel output over prose sources.
- If a number appears in prose but not in source data, the prose is not enough.
- Round only after verification, not before.
- Cite timeframe and comparator (WoW, YoY, vs ExampleProject, vs forecast).

### Factual claims

- Prefer primary notes, decision logs, or canonical docs.
- If two sources conflict, mark `<user-id>` until the conflict is resolved.
- If the source only implies the claim, mark `CAVEAT` rather than `SUPPORTED`.

### Causal claims

Causal claims need the strongest scrutiny. Pattern, chronology, or correlation alone is not enough to state causality cleanly.

- the source explicitly states the cause
- a controlled test or decision log directly ties the intervention to the outcome
- the causal wording is modest and the document explicitly frames it as a hypothesis with bounded evidence

### Judgment claims

- `"The AU result is strong enough to justify an MX pilot"` can be `SUPPORTED` if the evidence and decision rule are explicit.
- `"This proves the full roadmap will work"` should not be.

## Common failure modes

- Treating writing quality review as fact-checking
- Accepting a source summary when a primary source is available
- Preserving a precise number that the source does not support
- Turning a correlation into a cause
- Using memory as evidence
- Leaving a caveat in your head instead of in the draft

## Relationship to other protocols

- Use **this protocol first** to validate support.
- Use `writing-reviewer.md` after that to validate clarity, audience fit, and shipping quality.
- For system/build proposals, use `decision-agent.md` separately — claim validation checks whether the statements are supported, not whether the build should happen.

## Minimal invocation template

1. Read the draft.
2. Extract checkable claims.
3. Verify each against the strongest available source.
4. Return the required claim table.
5. Recommend `ship`, `ship-with-caveats`, or `revise-before-send`.

Do not rewrite the whole document unless explicitly asked. First establish what is safe to say.


## Private details intentionally omitted

- real people, teams, organizations, and project names
- live connector IDs and private URLs
- private analytics, dashboards, and metric values
- internal document paths or URLs
- private career and relationship context
