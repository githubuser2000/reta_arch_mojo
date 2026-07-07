# Stage 12c5fb — prompt execution one-shot local dispatch result owner

This stage removes the remaining small local return islands from
`_run_native_one_shot` after the first compatibility boundary.

The local dispatch owners are unchanged:

- `prompt_reaction_dispatch.mojo` still recognizes informational output,
  terminal clearing, one-shot logging and deterministic simple output.
- `prompt_main.mojo` still performs the visible terminal side effects.
- `prompt_execution.mojo` now owns the combined local dispatch result through
  `PromptExecutionOneShotLocalDispatchResultPlan` and
  `plan_prompt_execution_one_shot_local_dispatch_result(...)`.

The new plan records the historical local precedence:

1. informational help / command listings,
2. terminal clear,
3. one-shot logging,
4. deterministic simple output.

`_run_native_one_shot` now executes at most one local side-effect branch and
then consumes one typed prompt-execution result before either stopping the native
probe or continuing to external-process probing.

## Validation

- `tests/test_prompt_execution.mojo` covers the combined local dispatch result
  and its precedence.
- `tests/test_stage12c5fb_source.py` guards the one-shot local-dispatch region
  so direct per-branch `return ...handled` islands do not come back.
- The same source test also guards prompt-main imports for all
  `plan_prompt_execution_one_shot_*` functions used by the controller.
- `scripts/test_stage12c5fb.sh` chains `12c5ez` and the current source-contract
  guard set.
