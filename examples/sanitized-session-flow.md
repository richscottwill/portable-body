# Sanitized Session Flow

User: "Prepare my weekly review."

Agent flow:

1. Read `body/soul.template.md` for operating principles.
2. Read `body/current.template.md` for active priorities.
3. Load `protocols/workflow-state.template.md`.
4. Resolve `<repo-root>`.
5. Read fictional logs from `examples/`.
6. Produce a markdown review with patterns and open decisions.
7. Write a run record.

Output example:

```text
Weekly review complete.
Sources read: 5/5
Patterns: 2
Open decisions: 1
Review: <repo-root>/context/intake/weekly-review.md
```
