# Sanitized Session Flow

1. User asks for a weekly review.
2. Hook resolves `<repo-root>`.
3. Hook reads a protocol template.
4. Agent reads fictional logs from `examples/`.
5. Agent writes a sanitized review artifact.
6. Audit log records the workflow outcome.

No real work data is included in this example.
