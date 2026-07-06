# Stage 12c5ci – Bare loop control dispatch ownership

This stage moves the remaining bare empty/exit prompt controls out of the
process controller and into the native prompt interaction owner.

## Native owner

`prompt_interaction.mojo` now exposes `PromptLoopControlDispatchPlan` and
`plan_loop_control_dispatch(...)`:

- empty input is a handled no-op that keeps the interactive prompt alive;
- exit input is a handled control that terminates the interactive loop;
- one-shot execution uses the same handled flag to avoid entering the Python
  compatibility boundary for empty or exit-only commands.

## Controller boundary

`prompt_main.mojo` no longer branches directly on `KIND_EMPTY` or `KIND_EXIT`.
The controller only applies the typed loop-control decision returned by the
interaction owner.

## Verification

The stage rebuilds the prompt interaction, legacy prompt facade and table
adapters in the local Mojo test environment.  Compiler-free source contracts
also ensure the old direct controller branches do not return.
