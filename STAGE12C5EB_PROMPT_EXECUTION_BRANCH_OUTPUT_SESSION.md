# Stage 12c5eb – Prompt execution native branch output/session owner

This stage keeps shrinking `src/prompt_main.mojo` around the native prompt
execution branch.

## Native ownership moved

`src/reta_mojo/prompt_execution.mojo` now owns two additional pure decisions:

- `PromptExecutionNativeBranchOutputPlan` with
  `plan_prompt_execution_native_branch_output(...)` merges the table-render
  result and the preplanned `mulpri` render result into one explicit handled
  value. The controller no longer recomputes `handled_table or
  branch.mulpri_render.handled` itself.
- `PromptExecutionSessionLoggingPlan` with
  `plan_prompt_execution_session_logging_update(...)` computes whether the
  prompt session logging flag must be updated and which value it receives.
  The controller still mutates its own session, but it no longer reads
  `outcome.enable_logging` / `outcome.disable_logging` directly.

## Controller boundary

`prompt_main.mojo` remains the terminal-I/O owner:

1. print the compact announcement,
2. print historical companion effects,
3. render the table branch,
4. print planned `mulpri` lines,
5. apply the planned logging mutation.

The branch output and session-update decisions are now typed prompt-execution
plans.

## Local verification

Run:

```sh
RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5eb.sh -- -j 4
```
