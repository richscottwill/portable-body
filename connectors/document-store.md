# Document Store Connector Interface

Examples: SharePoint, Google Drive, Notion, Confluence.

## Responsibilities

- Publish human-readable artifacts.
- Maintain durable copies of important state.
- Detect drift between local markdown and published docs.
- Preserve a local source of truth when publish fails.

## Portable contract

A document store is an output surface, not the operating layer. The repo remains the source of workflow contracts.
