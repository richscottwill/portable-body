# Publishing Connector Interface

Examples: dashboard deploy, static site, document-store publish, wiki publish.

## Responsibilities

- Publish public/private artifacts to the configured destination.
- Return clear success/failure state.
- Preserve local output when publish fails.
- Never treat publish failure as workflow success.

## Portable contract

Publishing is optional for many workflows. A workflow can still complete in degraded mode by writing local artifacts and surfacing the publish gap.
