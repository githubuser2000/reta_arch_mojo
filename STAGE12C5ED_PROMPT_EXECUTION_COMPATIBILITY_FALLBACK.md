# Stage 12c5ed – Prompt execution compatibility fallback owner

This stage fixes the remaining fallback-boundary regression from the previous
prompt-execution split and moves one more controller decision into the native
prompt-execution owner.

## Regression fix

The unattempted-fallback contract now uses `r unportedtail 2`.  The previous
`r shell echo 2` fixture was misleading because `shell` is itself a prompt
command alias and can be normalized by the prompt vocabulary.  `unportedtail` is
a deliberately unowned token: the historical one-letter `r` still creates a
table candidate, but the compound must be rejected atomically before any native
table output is emitted.

## Native ownership moved

`src/reta_mojo/prompt_execution.mojo` now owns
`PromptExecutionCompatibilityFallbackPlan` and
`plan_prompt_execution_compatibility_fallback(...)`.

The controller still performs the actual compatibility call, but it no longer
branches directly on `completion.fallback_required`.  It consumes a typed
fallback-boundary plan and forwards the untouched source string from that plan.

This keeps both interactive prompt execution and `-befehl` aligned on the same
handled/fallback/session/fallback-boundary planning chain.

## Local verification

Run:

```sh
RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5ed.sh -- -j 4
```
