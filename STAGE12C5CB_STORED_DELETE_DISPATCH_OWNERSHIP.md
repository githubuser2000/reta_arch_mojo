# Stage 12c5cb - stored delete dispatch ownership

This stage moves the initial `l` / `BefehlSpeicherungLöschen` dispatch boundary out of
`prompt_main.mojo` and into the typed prompt interaction owner.

## Native ownership

`src/reta_mojo/prompt_interaction.mojo` now exposes `PromptStoredDeletePlan` and
`plan_stored_delete_command(...)`.

The native plan covers the three observable historical branches:

1. `l` with an empty prompt store prints `Kein Befehl gespeichert.`.
2. `l` with stored tokens prints the numbered store and switches the session into delete-selection mode.
3. `l <selection>` deletes immediately and prints the remaining stored command text.

The subsequent physical delete-selection line is still handled by `accept_prompt_input(...)`, which already owned cancel and selection mode. The process controller now only prints the returned plan.

## Regression boundary

`tests/test_prompt_interaction.mojo` adds `test_stored_delete_execution_is_planned_by_interaction_owner`.
`tests/test_stage12c5cb_source.py` prevents the process controller from regrowing the open-coded delete branch. The stage script also rebuilds `tests/test_table_adapters.mojo` so a broad `run-tests.sh` failure can be separated from stale `target/tests-all` binaries.

## Local stage command

```sh
scripts/build-all.sh -- -j 8
RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5cb.sh -- -j 8
```
