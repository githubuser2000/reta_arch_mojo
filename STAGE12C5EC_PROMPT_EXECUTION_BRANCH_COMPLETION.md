# Stage 12c5ec – Prompt execution native branch completion owner

This stage continues the prompt-execution ownership split after the native
branch outcome plan.

## Regression fix

The unattempted-fallback test now uses the actual historical shortcut form
`r unportedtail 2`.  The previous source used `r shell echo 2`, but `shell` is a real prompt command alias and not a stable unowned tail.  `r unportedtail 2` keeps the one-letter historical prefix while making the foreign tail explicit, so the atomic rejection path is exercised.

## Native ownership moved

`src/reta_mojo/prompt_execution.mojo` now owns
`PromptExecutionNativeBranchCompletionPlan` and
`plan_prompt_execution_native_branch_completion(...)`.

The completion plan combines the controller-visible handled/fallback/session branch result:

- handled/fallback decision,
- the already planned session logging mutation,
- the same shape for interactive prompt execution and `-befehl`.

`prompt_main.mojo` still owns terminal I/O, process execution and session
mutation, but it no longer branches directly on `outcome.handled` or
`outcome.fallback_required`.  It consumes a typed completion plan instead.

## Local verification

Run:

```sh
RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5ec.sh -- -j 4
```
