# Public Export Workflow

This workflow pack is a public, vendor-neutral reference implementation of a hook-managed workflow pattern from the private operating layer. It is intentionally detailed enough to recreate on another machine while using fictional inputs and replaceable connector interfaces.

## Purpose

Generate a public reference repo from private architecture without blindly copying private operating data.

## Connector interfaces

- `filesystem`
- `git`
- `scanner`

## Phase map

| # | Phase |
|---|---|
| 1 | Allowlist selection |
| 2 | Template export |
| 3 | Metadata catalog generation |
| 4 | Leak scan |
| 5 | Fresh clone verification |
| 6 | Human review |
| 7 | Publish |

## Design rationale

A prior public leak shows that regex redaction is not enough; public export must be allowlist-first with scanner and fresh-clone verification.

## Files in this pack

| File | Use |
|---|---|
| `protocol.md` | Step-by-step execution contract. |
| `capabilities.json` | Machine-readable capability requirements. |
| `runtime-capabilities.md` | Human-readable capability and platform notes. |
| `degradation-matrix.md` | What each runtime should produce when capabilities are missing. |
| `state-schema.example.json` | Run record and state-file examples. |
| `failure-modes.md` | Known failures and recovery branches. |
| `example-input/trigger-example.md` | Fictional trigger/input surface. |
| `example-output/run-report-example.md` | Fictional successful/degraded output. |

## Public/private boundary

This pack keeps workflow mechanics, ordering rationale, connector categories, and failure handling. It omits real people, organizations, private projects, IDs, URLs, credentials, and live metrics.
