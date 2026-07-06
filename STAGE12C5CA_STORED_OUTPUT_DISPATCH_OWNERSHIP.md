# Stage 12c5ca — Stored output dispatch ownership

This stage moves the remaining stored-output execution decision out of the
process controller and into the native prompt interaction owner.

## Native ownership

`src/reta_mojo/prompt_interaction.mojo` now exposes:

- `PromptStoredOutputExecutionPlan`
- `plan_stored_output_command(...)`
- `plan_inline_stored_output_command(...)`

The owner decides both historical outcomes of `o` / `BefehlSpeicherungAusgeben`:

- no stored command exists: print `Kein Befehl gespeichert.` and continue
- a stored command exists: return the exact command line to dispatch, including
  any typed addition following the output alias

The process entry point still performs printing and recursive dispatch, but no
longer decides the stored-output session semantics locally.

## Regression boundary

`tests/test_prompt_interaction.mojo` covers:

- classified `o` with no stored command
- classified `o` with a stored command
- classified `o` with an addition
- position-independent inline `o` suffix dispatch

`tests/test_stage12c5ca_source.py` also rejects reintroducing the old
`if command.kind == KIND_OUTPUT_STORED:` branch in `src/prompt_main.mojo`.
