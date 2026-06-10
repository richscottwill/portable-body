# Spine Template

The spine is the navigation map for a portable AI workspace.

## Load order

1. Read the bootstrap file.
2. Resolve `<repo-root>`.
3. Load task-specific protocols only.
4. Write durable outputs under `<repo-root>/context/`.

## Anti-patterns

- Loading every file by default.
- Hardcoding one machine's home path.
- Mixing private working data into public templates.
