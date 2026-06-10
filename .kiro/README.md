# .kiro Directory

This directory mirrors the runtime-facing layer used by Kiro-style systems.

- `hooks/` contains thin trigger envelopes. They should resolve `<repo-root>`, check capabilities, then delegate to `context/protocols/`.
- `agents/` contains specialist role definitions. They should describe role, inputs, outputs, quality bar, and failure behavior.

If your runtime is not Kiro, keep this directory as a design reference and implement equivalent triggers/agents in your tool.
