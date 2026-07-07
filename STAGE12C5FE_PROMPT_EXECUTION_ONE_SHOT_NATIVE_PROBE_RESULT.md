# Stage 12c5fe – prompt execution one-shot native probe result owner

`12c5fe` pulls the first native one-shot probe result out of
`src/prompt_main.mojo` and into `src/reta_mojo/prompt_execution.mojo`.

Previously `_run_native_one_shot` assembled these pure decisions directly:

- `plan_prompt_execution_one_shot_native_completion_result`
- `plan_prompt_execution_compatibility_fallback`
- `plan_prompt_execution_one_shot_compatibility_boundary`
- `plan_prompt_execution_one_shot_compatibility_result`

The controller now consumes one value:

- `PromptExecutionOneShotNativeProbeResultPlan`
- `plan_prompt_execution_one_shot_native_probe_result(...)`

This keeps the observable one-shot behavior unchanged: handled native table or
compact branches return `True`; native-branch compatibility returns `False` so
the caller can enter the historical compatibility path; declined non-fallback
branches continue into local dispatch.

The stage also fixes the residual-probe constructor ownership edge discovered
by local Mojo test compilation: `PromptExecutionOneShotResidualResultPlan` is
not implicitly copyable, so `plan_prompt_execution_one_shot_residual_probe(...)`
transfers the planned result with `result^` when embedding it into
`PromptExecutionOneShotResidualProbePlan`.
