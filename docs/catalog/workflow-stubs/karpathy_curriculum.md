# Compression and Curriculum Loop — Public Template

Private source path: `tools/scripts/karpathy_curriculum.py`
Showcase status: summarized template only; private body is not copied.

## Pattern demonstrated

- experiment queue
- compression/refactor proposals
- blind evaluation
- keep/revert gate
- learning log

## Portable operating contract

- Resolve `<repo-root>` before reading or writing files.
- Check runtime capabilities before invoking shell, connectors, hooks, or agent dispatch.
- Write run state to `context/active/` or an equivalent runtime state surface.
- Degrade visibly when optional capabilities are missing.
- Keep generated data local unless an explicit public-safe export step exists.

## Omitted from this public template

Private details removed: people, projects, connector IDs, metrics, meeting notes, dashboards, credentials, and operational data.
