# Stage 12c5dd – fallback process run flag

This stage makes the atomic prompt fallback process plan mirror the other native
dispatch plans more closely.  `PromptFallbackProcessDispatchPlan` now carries an
explicit `run_reta_prompt` effect flag in addition to `handled`,
`profile_arguments` and `command_arguments`.

The controller no longer assumes that every handled fallback plan is necessarily
the retaPrompt compatibility child.  It checks both `handled` and
`run_reta_prompt` before delegating to `run_reta_prompt_fallback_arguments_native`.

The external process adapter remains payload/argv-only.  No raw prompt line or
Python object boundary is reintroduced.

New snapshot marker:

```text
fallback_process_flags=native-explicit-fallback-run-flag
```
