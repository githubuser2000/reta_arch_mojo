# Stage 12c5ez — prompt execution one-shot loop-control result owner

This stage moves the first one-shot return projection in `_run_native_one_shot`
out of the controller and into `prompt_execution.mojo`.

`plan_loop_control_dispatch` still belongs to `prompt_reaction_dispatch.mojo`,
because empty input and explicit prompt exit are prompt-reaction concerns.  The
new `PromptExecutionOneShotLoopControlResultPlan` owns only the controller-facing
boolean algebra used by the native one-shot probe:

- handled loop-control command: stop the probe successfully;
- unhandled command: continue into native branch execution probing.

The controller now consumes
`plan_prompt_execution_one_shot_loop_control_result(...)` instead of directly
returning from `loop_control.handled`.

## Validation

- `tests/test_prompt_execution.mojo` covers both handled and declined result
  projections.
- `tests/test_stage12c5ez_source.py` guards the controller region so the raw
  `if loop_control.handled: return True` form does not come back.
- `scripts/test_stage12c5ez.sh` chains `12c5ey` and the full source-contract
  guard set.
