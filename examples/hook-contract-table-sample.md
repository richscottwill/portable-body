# Hook Contract Table Sample

| Hook | Purpose | Reads | Writes | External side effects | Degrade behavior |
|---|---|---|---|---|---|
| weekly-review | summarize logs | local logs | review markdown | none | skip missing sources visibly |
| publish-artifact | publish approved doc | markdown artifact | status file | external publish | write local pending artifact |
| sync-repo | push repo changes | git status | changelog | git push | stop on conflict |

A contract table helps agents modify hooks without rediscovering ownership from scratch.
