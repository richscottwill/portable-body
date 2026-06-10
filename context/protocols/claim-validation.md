# Claim Validation Template

Purpose: check factual claims before high-stakes output ships.

## Steps

1. Extract claims from the draft.
2. Classify each claim: factual, numeric, causal, forecast, opinion.
3. Find the source of truth.
4. Mark each claim as supported, unsupported, stale, or needs-human.
5. Revise the draft to remove unsupported certainty.

## Output

| Claim | Type | Source | Verdict | Fix |
|---|---|---|---|---|
| `[claim]` | factual | `[source]` | supported | none |
