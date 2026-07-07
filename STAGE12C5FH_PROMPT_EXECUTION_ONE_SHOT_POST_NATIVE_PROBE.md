# Stage 12c5fh – Prompt Execution One-Shot Post-Native Probe Owner

This stage moves the next one-shot controller gate out of `src/prompt_main.mojo`
and into the prompt-execution owner.

## Native change

`src/reta_mojo/prompt_execution.mojo` now defines:

- `PromptExecutionOneShotPostNativeProbeResultPlan`
- `plan_prompt_execution_one_shot_post_native_probe_result(...)`

The new plan owns the transition after `plan_prompt_execution_one_shot_native_probe_result(...)`:

- a stopped native probe returns its handled value immediately;
- a declined native probe continues into local one-shot dispatchers.

## Controller effect

`_run_native_one_shot` no longer returns directly from `native_probe_result`.
It consumes a typed post-native gate before entering the informational,
terminal-clear, one-shot logging and simple-output local dispatch chain.

## Validation

The stage script is `scripts/test_stage12c5fh.sh`.  It chains from `12c5fg`
unless `RETA_STAGE_SKIP_PREVIOUS=1` is set, then builds and runs the prompt
stage tests plus the Python source-contract tests.
