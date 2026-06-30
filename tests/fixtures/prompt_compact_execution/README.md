# Compact prompt execution fixtures

These eleven byte fixtures were generated from the unmodified Python 3.13.5 reference
with `PYTHONHASHSEED=0`.  The fixed hash seed is required because the historical
prompt deliberately exposes `set` iteration order in its visible expansion
announcement.  The normal release test runs only the native Mojo prompt binary
and compares it with these frozen outputs.

Regenerate explicitly with:

```sh
RETA_REGENERATE_PROMPT_COMPACT_FIXTURES=1 \
  scripts/check_prompt_compact_execution_parity.sh
```

Stage 12c adds the exact `a1` regression and retains the renderer-sensitive `B2`, `E2`, `T2`, `W2`, and
`u2` cases.  Existing-hyphen wrapping is now reproduced by the native renderer.

The command echo is a complete physical line.  No fixture may contain ANSI
table bytes on the `reta ...` command line.  `--breite=0` is checked separately
under 80-, 120- and 200-column pseudo-terminals.
