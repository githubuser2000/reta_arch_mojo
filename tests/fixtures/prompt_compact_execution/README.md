# Compact prompt execution fixtures

These byte fixtures were generated from the unmodified Python 3.13.5 reference
with `PYTHONHASHSEED=0`.  The fixed hash seed is required because the historical
prompt deliberately exposes `set` iteration order in its visible expansion
announcement.  The normal release test runs only the native Mojo prompt binary
and compares it with these frozen outputs.

Regenerate explicitly with:

```sh
RETA_REGENERATE_PROMPT_COMPACT_FIXTURES=1 \
  scripts/check_prompt_compact_execution_parity.sh
```
