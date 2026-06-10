# Thin Hook Example

A portable hook should be a small runtime envelope.

```text
1. Resolve `<repo-root>`.
2. Check pause/debounce state.
3. Read `<repo-root>/protocols/example.md`.
4. Execute the protocol.
5. Write run state and failures under `<repo-root>/context/active/`.
```

Keep workflow logic in markdown protocols, not escaped JSON strings.
