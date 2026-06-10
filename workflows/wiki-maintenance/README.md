# Wiki Maintenance Workflow

This is a public, vendor-neutral version of a hook-managed workflow pattern from the private operating layer.

## Connector interfaces

- `document-store`
- `chat`
- `agent-dispatch`

## Phase pattern

1. broad sweep
2. researcher/writer/critic/librarian pipeline
3. gap detection
4. publication checks

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
