# Sanitization Rules

This repo is public. Treat every export as hostile until scanned.

## Strip / replace

- Employer names → `[Company]`
- People names → `[Manager]`, `[Teammate]`, `[Stakeholder]`
- Team/project names → `[Program]`, `[Project]`, `[Market]`
- Metrics and financials → `[metric]`, `[amount]`, `[target]`
- Tool IDs / URLs / GIDs / channel IDs → `[id]`, `[url]`
- Career, private workplace, performance details → remove entirely
- Meeting notes and relationship dynamics → remove entirely

## Keep

- Architecture patterns
- File layout patterns
- Protocol shapes
- Thin-hook delegation pattern
- Runtime/path portability pattern
- Generic examples using fictional context

## Required checks before publish

```bash
python3 tools/portable-body-export/scan_public_export.py <export-dir>
```

A passing scan is necessary but not sufficient. Human review is still required.
