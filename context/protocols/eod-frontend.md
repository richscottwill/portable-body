# End-of-Day Frontend — Public Template

Private source path: `context/protocols/eod-frontend.md`
Showcase status: summarized template only; private body is not copied.

## Pattern demonstrated

- human review gate
- carry-forward decisions
- approval queues
- summary generation
- safe no-send defaults

## Portable operating contract

- Resolve `<repo-root>` before reading or writing files.
- Check runtime capabilities before invoking shell, connectors, hooks, or agent dispatch.
- Write run state to `context/active/` or an equivalent runtime state surface.
- Degrade visibly when optional capabilities are missing.
- Keep generated data local unless an explicit public-safe export step exists.

## Omitted from this public template

Private details removed: people, projects, connector IDs, metrics, meeting notes, dashboards, credentials, and operational data.
