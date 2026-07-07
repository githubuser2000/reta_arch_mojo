# Stage 12c5fi — prompt execution one-shot pre-native probe owner

This stage moves the early one-shot loop-control gate out of the prompt
controller and into `prompt_execution.mojo`.

## Native owner added

`PromptExecutionOneShotPreNativeProbeResultPlan` and
`plan_prompt_execution_one_shot_pre_native_probe_result(...)` now own the
transition after `plan_prompt_execution_one_shot_loop_control_result(...)`:

- handled loop-control commands stop the one-shot native probe successfully;
- declined loop-control commands continue into the native branch probe.

## Controller reduction

`_run_native_one_shot` no longer returns directly from
`loop_control_result.stop_native_probe`.  It consumes the typed pre-native probe
result and only checks whether native branch probing should continue.

## Local validation

This stage is guarded by `tests/test_stage12c5fi_source.py` and extends
`tests/test_prompt_execution.mojo` with the pre-native probe gate contract.
