# Layer Boundary Contract

Portable Body uses three layers.

## 1. Private working layer

The private layer contains real work: active plans, logs, dashboards, source data, relationships, meeting notes, credentials configuration, and live automation.

Never publish it directly.

## 2. Public showcase layer

The public layer contains templates and architecture examples. It should teach the pattern without revealing the operator's actual data.

Allowed:
- generic body templates
- protocol templates
- hook examples
- architecture diagrams/narratives
- fictional walkthroughs

Forbidden:
- real people, projects, orgs, IDs, metrics, private URLs, meeting notes, or operational logs

## 3. Private durability layer

The durability layer stores private recovery snapshots. It may be portable across the operator's devices, but it is not public.

## Export rule

Public showcase is generated from an allowlist. It is never a blind mirror of the private working layer.
