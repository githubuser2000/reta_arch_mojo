# Stage 12c5ck – External process dispatch ownership

Stage 12c5ck moves the remaining bare external-process routing decision out of
`src/prompt_main.mojo` and into the prompt interaction owner.

## What changed

- `PromptExternalProcessDispatchPlan` now represents the prompt process edge.
- `plan_external_process_dispatch(...)` classifies the bare prompt process
  commands in `src/reta_mojo/prompt_interaction.mojo`:
  - `shell`
  - `python`
  - `math`
  - `reta`
- `src/prompt_main.mojo` still owns the actual operating-system I/O and process
  calls, but it no longer repeats the direct `KIND_SHELL`/`KIND_PYTHON`/
  `KIND_MATH` routing branches.
- One-shot handling uses the same plan and only accepts the natively supported
  `reta` subset before falling back atomically.
- The prompt interaction snapshot records
  `external_process_dispatch=native-prompt-process-edge-plan`.

## Why this is still only a dispatch move

The actual shell/Python/math/reta execution is intentionally still a process
boundary in `prompt_main.mojo`.  This stage only moves the command-kind routing
and keeps observable execution semantics unchanged.

## Source gates

The new stage gate verifies:

- the current-stage wrapper points to `test_stage12c5ck.sh`,
- `prompt_interaction.mojo` owns the new plan and constants,
- `prompt_main.mojo` delegates external process routing through the new plan,
- the Mojo interaction regression covers all four process classes, and
- previous prompt-controller ownership stages remain in the focused source gate.
