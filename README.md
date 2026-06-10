# Portable Body

A sanitized, public example of a portable AI operating-system pattern.

This repository is intentionally **architecture-only**. It shows how to structure a personal/team AI workspace so it can move across tools and runtimes without exposing private work data.

## What this demonstrates

- A repo-root based working layer instead of machine-specific paths
- A small set of durable "body" files that hold operating context
- Thin hooks that delegate to markdown protocols
- Runtime path contracts such as `<repo-root>` and `AGENT_BRIDGE_ROOT`
- Review, decision, and failure-log loops that make an agent system auditable
- Sanitization boundaries between private working state and public examples

## What is not included

This repo intentionally excludes:

- real company, customer, teammate, or personal data
- org charts, compensation, performance, or career material
- meeting notes, chat logs, email content, task IDs, or calendar IDs
- private database files, analytics, forecasts, or dashboards
- credentials, MCP configuration, tokens, or internal tool names
- real project names, metrics, strategy, or operational changelogs

## Layer model

| Layer | Purpose | Visibility |
|---|---|---|
| Private working layer | Real workflows, data, hooks, docs, and operational state | Private only |
| Sanitized showcase layer | Architecture patterns, templates, and example contracts | Public/shareable |
| Durability/backup layer | Recovery snapshots and private restore artifacts | Private only |

## Repository map

```text
architecture/   Narrative explanation of the pattern
body/           Sanitized body-file templates
protocols/      Portable protocol templates
hooks/          Thin hook examples without real integrations
agents/         Generic agent-role templates
examples/       Fictional end-to-end examples
tools/          Sanitization/export guidance
```

## Safe-use principle

Never mirror a private working repo into this repo. Export only allowlisted architecture patterns, run a leak scan, and review manually before publishing.
