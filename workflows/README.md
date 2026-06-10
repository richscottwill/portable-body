# Workflow Packs

This directory contains public, vendor-neutral reference implementations of the major private operating workflows.

Each workflow directory should include:

- `README.md` — overview and design rationale.
- `protocol.md` — step-by-step execution contract.
- `capabilities.json` — machine-readable capability requirements.
- `runtime-capabilities.md` — platform adaptation notes.
- `degradation-matrix.md` — outputs by capability tier.
- `state-schema.example.json` — run record and state-file examples.
- `failure-modes.md` — failure catalog and recovery branches.
- `example-input/` — fictional trigger/input examples.
- `example-output/` — fictional output/report examples.

The goal is not to copy private content. The goal is to preserve the operating logic: preflight ordering, verification gates, backend/frontend split, per-unit isolation, degraded mode, workflow state, and public/private boundaries.
