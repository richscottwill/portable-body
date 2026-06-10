# Example Input — Public Export Workflow

## Trigger

Run `public-export` against fictional demo data.

## Input surface

An export manifest and sanitized templates plus private metadata used only for generated catalogs.

## Runtime declaration

```json
{
  "runtime": "example-runtime",
  "repo_root": "<repo-root>",
  "available_capabilities": ["filesystem_read", "filesystem_write", "git", "public_repo_publish"]
}
```
