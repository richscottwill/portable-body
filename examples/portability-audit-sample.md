# Portability Audit Sample

Example output from a portability scan:

| Check | Count | Meaning |
|---|---:|---|
| hardcoded_home_path | 0 | no personal machine paths |
| raw_tmp_path | 0 | temp files use repo-local scratch |
| missing_repo_root_preflight | 1 | one workflow needs path setup |
| unsupported_capability | 2 | workflows need degrade rules |

The point of the audit is not a perfect score on day one. It is to make hidden coupling visible.
