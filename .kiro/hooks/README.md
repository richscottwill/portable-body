# Hooks

Hooks are runtime entrypoints, not the durable home of workflow logic.

A portable hook should do five things:

1. detect `<repo-root>`,
2. check required runtime capabilities,
3. read the linked protocol,
4. execute or delegate the protocol phases,
5. write workflow state and a concise report.

If a runtime cannot execute hooks, treat these files as runbook examples and invoke the linked protocols manually.
