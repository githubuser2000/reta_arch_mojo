# Native numeric prompt execution fixtures

These byte fixtures freeze the observable Python 3.13.5 output for pure
number shortcuts and the historical `15_…`, `16_…`, and `16_15_…` catalog
families.  Regeneration is deterministic:

```sh
RETA_REGENERATE_PROMPT_NUMERIC_FIXTURES=1 \
  ./scripts/check_prompt_numeric_execution_parity.sh
```

`PYTHONHASHSEED=0` is intentional because the legacy prompt uses Python sets
when ordering multiple numeric selections.
