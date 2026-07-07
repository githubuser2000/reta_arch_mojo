# Stage 12c5fk – Prompt execution one-shot probe pipeline state owner

This stage keeps the side-effecting one-shot controller work in `src/prompt_main.mojo`,
but moves the consumption of the normalized one-shot pipeline gates into a shared
pure state owner in `src/reta_mojo/prompt_execution.mojo`.

New owner surface:

- `PromptExecutionOneShotProbePipelineStatePlan`
- `plan_prompt_execution_one_shot_pipeline_initial_state(...)`
- `plan_prompt_execution_one_shot_pipeline_apply_gate(...)`

The previous stage already normalized phase-specific gates:

- pre-native gate
- post-native gate
- post-local gate
- final gate

`12c5fk` adds the running state projection across these gates. `_run_native_one_shot`
now initializes one `one_shot_pipeline_state`, applies each gate through the same
owner function, and returns from the state instead of returning directly from each
individual gate.

This is intentionally still a controller/pure-owner split:

- the controller performs terminal output, native branch execution and child-process attempts;
- prompt execution owns the return/continue state after each phase;
- no new Python compatibility path is introduced.

The porting metric can remain `89/92` because this stage continues to reduce the
remaining partial owner `reta_architecture/prompt_execution.py`; it does not yet
claim full ownership of the three still-partial reference files.
