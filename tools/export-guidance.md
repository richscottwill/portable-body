# Export Guidance

Do not copy from a private working repo directly into this public repo.

Recommended process:

1. Build an allowlist of public-safe architecture files.
2. Rewrite content through deterministic sanitization rules.
3. Run denylist scans.
4. Manually review the generated output.
5. Publish only after the scan is clean.

A clean export is a product artifact, not a backup.
