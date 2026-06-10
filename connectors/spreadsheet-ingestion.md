# Spreadsheet / Excel Ingestion Interface

Examples: Excel `.xlsx`, CSV exports, Google Sheets exports.

## Responsibilities

- Accept a dropped spreadsheet or exported file.
- Validate expected tabs/columns.
- Normalize rows into a local analytical store.
- Produce quality-gate results before downstream forecasts or narratives run.

## Pattern

```text
file drop -> schema validation -> ingest -> quality gates -> local analytics -> forecast/callout/dashboard
```

Spreadsheet ingestion is public-safe as a pattern. Real business metrics are not.
