# Sanitization Contract

This repository is safe to show only because it contains templates and fictional examples.

## Strip completely

- employer, customer, vendor, and competitor names
- real people names, aliases, levels, locations, and reporting lines
- task IDs, Slack IDs, calendar IDs, email addresses, URLs, and SharePoint paths
- project names, launch plans, strategy docs, metrics, forecasts, spend, performance data
- compensation, promotion, career, and relationship notes
- meeting transcripts, email text, chat logs, operational changelogs
- credentials, tokens, MCP config, private binary/tool names

## Keep

- architecture diagrams and explanations
- generic body-file patterns
- generic protocol shapes
- hook delegation pattern
- decision/review/failure-loop patterns
- path portability conventions such as `<repo-root>` and `AGENT_BRIDGE_ROOT`

## Rewrite pattern

| Private value | Public replacement |
|---|---|
| real person | `[Person A]`, `[Manager]`, `[Stakeholder]` |
| real company | `[Company]` |
| real project | `[Project X]` |
| real metric | `[metric]`, `[redacted number]` |
| real tool | `[tool]`, `[task system]`, `[calendar system]` |
| real path | `<repo-root>/...` |

## Publish gate

Before publishing, run a denylist scan for names, company terms, internal project names, IDs, credentials, and absolute paths. If any hit remains, do not publish.
