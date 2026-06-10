# Weekly Learning Review — Public Template

Private source path: `context/protocols/weekly-learning-review.md`
Showcase status: summarized template only; private body is not copied.

## Pattern demonstrated

- append-only log consumption
- pattern clustering
- decision calibration
- build-proposal review
- read-only recommendations

## Portable operating contract

- Resolve `<repo-root>` before reading or writing files.
- Check runtime capabilities before invoking shell, connectors, hooks, or agent dispatch.
- Write run state to `context/active/` or an equivalent runtime state surface.
- Degrade visibly when optional capabilities are missing.
- Keep generated data local unless an explicit public-safe export step exists.

## Omitted from this public template

Private details removed: people, projects, connector IDs, metrics, meeting notes, dashboards, credentials, and operational data.
