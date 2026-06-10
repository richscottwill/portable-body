# Portable EOD Hook Example

Purpose: summarize a day without tying the workflow to one machine.

## Preflight

- Resolve `<repo-root>`.
- Read workflow state.
- Check pause flag under `<repo-root>/context/active/`.
- Detect capabilities: filesystem, task source, calendar source, publishing destination.

## Degrade behavior

If a source is unavailable, write a visible gap in the summary instead of failing silently.
