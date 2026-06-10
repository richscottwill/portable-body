# Eval Routing Workflow

This is a public, vendor-neutral version of a hook-managed workflow pattern from the private operating layer.

## Connector interfaces

- `agent-dispatch`
- `filesystem`

## Phase pattern

1. artifact classification
2. lens routing
3. blind eval
4. KEEP/REVISE/REVERT verdicts

## Operating rules

- Resolve `<repo-root>` before reading or writing files.
- Check runtime capabilities before invoking connectors, shell commands, or agent dispatch.
- Keep workflow state under `context/active/` or an equivalent runtime state surface.
- Prefer drafts/proposals over external writes unless the workflow owns the write guardrail.
- Degrade visibly when a connector is unavailable.

## Example implementation surfaces

- Hook envelope: `.kiro/hooks/*.example.md`
- Protocol: `context/protocols/*.md`
- State schema: local markdown, JSON, JSONL, or local analytical tables
- Audit: append-only log or workflow run table
