# Eval Routing — Sanitized Workflow Pattern

Private source path: `context/protocols/eval-routing.md`
Public status: sanitized structural export. This preserves workflow mechanics and removes private people, internal projects, IDs, URLs, and live data.

## What this demonstrates

- Trigger and precondition design
- Phase/step sequencing
- Visible degraded modes
- File/protocol boundaries
- Failure recovery and auditability
- Runtime portability via `<repo-root>` and capability checks

## Sanitized structure

<!-- DOC-XXXX | duck_id: protocol-eval-routing -->
# Eval Routing Protocol

This protocol makes Karpathy evaluator use explicit, tiered, and portable. It preserves the ExecutionLens/StrategyLens/ExecutiveLens lens system instead of collapsing style evaluation to a single judge.

## Source of truth

Machine-readable routing lives in `<repo-root>/context/config/eval-routing.json`.

Default tier: `standard` unless `EVAL_TIER=smoke|standard|full` is set.

## Evaluator roles

| Role | Agents | Purpose |
|---|---|---|
| Retrieval/comprehension | `eval-a`, `eval-b`, `eval-c` | Finds whether text lets an agent answer factual/protocol questions. |
| Behavior simulation | `eval-d` | Traces hook/protocol execution, order, branch, failure recovery, and blocking/non-blocking behavior. |
| Adversarial reader | `eval-e` | Finds the best case against the change; advisory except tie-band/high-strength flags. |
| Style lenses | `eval-ExecutionLens-v2`, `eval-StrategyLens-v2`, `eval-ExecutiveLens-v2` | Scores generated artifacts through manager/director/VP lenses using the shared 8-dimension rubric. |

## Tiers

### Smoke

Harness validation only. Use for first-experiment gate or platform invocation testing. It proves evaluator subprocesses can run without paying full cost.

### Standard

Default for EOD/Karpathy. Hooks/protocols use behavior simulation plus one prose evaluator and eval-e. Organs/configs use two retrieval perspectives plus eval-e. Style artifacts run all three v2 lenses plus eval-e.

### Full

Use for core protocols, EOD/Karpathy/path/workflow changes, leadership docs, high-disagreement cases, or high-stakes outputs.

## Style blend policy

| Blend | ExecutionLens | StrategyLens | ExecutiveLens | Use when |
|---|---:|---:|---:|---|
| `team_peer_default` | 0.50 | 0.30 | 0.20 | Team/peer artifact where execution clarity leads. |
| `strategic_doc_default` | 0.25 | 0.55 | 0.20 | 6-pager, PR-FAQ, experiment narrative, or doc needing a lot of StrategyLens with some ExecutionLens and medium ExecutiveLens. |
| `exec_vp_default` | 0.15 | 0.30 | 0.55 | VP/executive artifact. |
| `wbr_mbr_market_callout` | 0.45 | 0.40 | 0.15 | Market callout or recurring business review snippet. |
| `PlanningCycle_PlanningCycle_strategy` | 0.15 | 0.45 | 0.40 | ExampleProject/ExampleProject planning or strategy narrative. |

Blend score:

blend_score = sum(lens_weight * lens_weighted_score)

The old “gating lens” idea becomes diagnostic only. A single lens can still block if it falls below the critical lens floor (`0.55`) because that means the artifact fails a material reader population. Otherwise, the blend determines ship/revise/reject against the blend floor.

## Disagreement handling

Flag `lens_disagreement_flag` when any two style lens weighted scores differ by `>= 0.40`. Escalate to full tier or manual review rather than hiding the disagreement.

## Eval-e policy

`eval-e` remains advisory outside the tie band. In `|delta_ab| < 0.1`, `STRENGTH >= 0.5` reverts as `tie_break_adversarial`; otherwise keep/revert follows the primary score.


## Private details intentionally omitted

- real people, teams, organizations, and project names
- live connector IDs and private URLs
- private analytics, dashboards, and metric values
- internal document paths or URLs
- private career and relationship context
