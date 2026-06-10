# Email and Calendar Connector Interface

Examples: Outlook, Google Workspace.

## Responsibilities

- Read calendar events for meeting context.
- Read email metadata/content needed for triage.
- Draft messages without sending by default.
- Create calendar blocks only when the workflow owns scheduling.

## Portable contract

- All times resolve to the user's configured timezone.
- Drafts are safer than sends.
- Missing email/calendar connector degrades to file-only recommendations.
