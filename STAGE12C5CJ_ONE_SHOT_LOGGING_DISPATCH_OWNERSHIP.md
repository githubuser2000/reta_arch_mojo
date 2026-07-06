# Stage 12c5cj – One-shot logging dispatch ownership

Stage 12c5cj closes a small remaining prompt-controller seam after the loop
control move in 12c5ci.

## Native owner

`src/reta_mojo/prompt_interaction.mojo` now exposes:

- `PromptOneShotLoggingDispatchPlan`
- `plan_one_shot_logging_dispatch(command)`

The interactive logging mutation remains in `plan_logging_dispatch(...)`, where
it updates `NativePromptSession.logging_enabled`.  The one-shot variant is
stateless: there is no durable prompt session to mutate, but the observable
logging message is still owned by the interaction layer.

The implementation shares `_logging_output_lines(...)` so interactive and
one-shot logging use the same text contract:

- `loggen` -> `Logging ist eingeschaltet.`
- `nichtloggen` -> `Logging ist ausgeschaltet.`

## Process controller boundary

`src/prompt_main.mojo` no longer imports `KIND_LOG_ON` or `KIND_LOG_OFF` and no
longer branches directly on those command kinds in `_run_native_one_shot(...)`.
The controller now prints the typed plan returned by
`plan_one_shot_logging_dispatch(...)`.

## Compile-safety correction

The stage also makes the loop-control owner explicit by importing `KIND_EMPTY`
in `prompt_interaction.mojo`.  The previous source contract already verified
that empty prompt input was owned there; 12c5cj also guards the compile-visible
import.

## Regression gates

- `tests/test_prompt_interaction.mojo` covers the stateless one-shot logging
  planner and the updated interaction snapshot.
- `tests/test_prompt_interaction_source.py` prevents `KIND_LOG_ON`/
  `KIND_LOG_OFF` branches or imports from growing back in `prompt_main.mojo`.
- `tests/test_stage12c5cj_source.py` binds the stage script, the new plan, the
  import correction and the one-shot dispatch ordering.
