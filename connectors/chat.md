# Chat Connector Interface

Examples: Slack, Microsoft Teams, Discord.

## Responsibilities

- Search recent conversations.
- Ingest channel/DM context into local analytics when permitted.
- Produce draft messages or self-notes.
- Never post to public/shared channels unless explicitly approved.

## Portable contract

Chat systems are high-signal but high-risk. Treat search/read as optional context and posting as a guarded write.
