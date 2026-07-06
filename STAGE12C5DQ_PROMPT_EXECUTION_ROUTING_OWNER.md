# Stage 12c5dq: Prompt execution routing owner

This stage reduces one more prompt-execution rest island by moving the shared,
non-I/O front half of `PromptVonGrosserAusgabeSonderBefehlAusgaben` into the
native prompt-execution owner.

No `.so`/`.dll` split is implemented here.  This is another source-level owner
split that keeps the future library boundary cleaner.

## New native owner plan

`src/reta_mojo/prompt_execution.mojo` now owns `PromptExecutionRoutingPlan` and
`plan_prompt_execution_routing(...)`.

The plan computes the deterministic execution-routing state once:

- raw prompt tokens
- compact-command expansion
- replacement-normalized tokens and line
- localized single-command classification
- prepared-token selection for historical compact echo
- numeric-default detection
- prepared-vs-normalized table-planning token selection
- quiet compact-output flag

Before this stage, the interactive prompt path and the one-shot `-befehl` path
both repeated that same logic inside `src/prompt_main.mojo`.  The controller now
requests the typed routing plan twice and keeps the remaining terminal I/O,
storage recursion, external process boundary and renderer effects local.

## Ownership-map effect

The `prompt_execution_owners()` evidence for
`PromptVonGrosserAusgabeSonderBefehlAusgaben` now points at
`prompt_execution.mojo` / `plan_prompt_execution_routing` instead of the process
controller `_run_command`.

That does not claim the whole historical function is finished.  It means the
front half that is pure parsing/routing is now owned by the prompt-execution
module, while unproved rear branches still fall through the explicit
compatibility boundary.

## Compatibility

The visible execution path is unchanged: table planning, mulpri composition,
logging effects, storage effects and external process dispatch still run through
the same typed plans as before.  The new tests check compact numeric routing,
ordinary table routing and short help classification through the shared routing
plan.
