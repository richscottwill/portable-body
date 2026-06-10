# Runtime Capabilities — Morning Brief Workflow

## Required

- `filesystem_read`
- `filesystem_write`
- `local_analytics`

## Optional

- `task_system`
- `email_calendar`
- `chat`
- `agent_dispatch`
- `dashboard_publish`

## Platform notes

| Runtime | Expected behavior |
|---|---|
| Kiro Server/Local | Full run when hooks, shell, connectors, and agent dispatch are configured. |
| Aki | Full or near-full orchestration via shell/tools; use agent spawn/adapter for multi-agent phases. |
| Claude Code | Strong for code/file workflows; map hooks to commands and subagents where available. |
| Codex CLI | Strong for code/file/local analytics; scheduling and external publish usually manual. |
| Antigravity 2 | Use managed agents for parallel phases if filesystem and shell are available. |
| Quick Desktop | Monitoring/manual-runbook mode for complex workflows; useful as user-facing review surface. |
| Generic Chat | Manual runbook only; cannot execute shell, connectors, local analytics, or scheduling. |

## Capability-first rule

Do not branch on app name first. Branch on available capabilities: filesystem, shell, Python, local analytics, connector access, agent dispatch, hooks/scheduling, and publishing.
