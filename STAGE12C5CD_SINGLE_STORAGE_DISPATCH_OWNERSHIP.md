# Stage 12c5cd — single storage dispatch ownership

Stage 12c5cd moves the remaining single-word `S` / `s` prompt-storage
branch from the process controller into `reta_mojo.prompt_interaction`.

The compound position-independent storage branch was already native, and the
physical store/delete input modes were already owned by `accept_prompt_input`.
The remaining open-coded controller fragment was the bare dispatch decision:

- `S` / `BefehlSpeicherungNächsterBefehl` switches the session into store-next
  mode and prints the localized historical confirmation.
- `s` / `BefehlSpeicherungVorherigerBefehl` stores the previous executable
  command when one exists and otherwise remains a handled no-op.

The new `PromptStoredCommandDispatchPlan` and
`plan_stored_command_dispatch(...)` keep those state mutations beside the
other prompt-store plans. `prompt_main.mojo` now only prints the returned plan.

## Regression boundary

`tests/test_prompt_interaction.mojo` now covers save-next, save-previous,
empty previous-command handling and non-storage rejection through the native
owner.  Source tests also forbid the old `KIND_STORE_NEXT` / `KIND_STORE_PREVIOUS`
branches from reappearing in `prompt_main.mojo`.

The uploaded broad-suite logs for 12c5cb still show the older table-adapter
counting assertion (`left: 1`, `right: 0`). That is the Stage 12c5cc fix and is
kept in the stage chain; 12c5cd builds on top of it rather than reverting it.
