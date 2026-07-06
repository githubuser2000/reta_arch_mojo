# Stage 12c5cn: External process effect flag ownership

This stage moves the final external prompt process routing decision out of the
thin `prompt_main.mojo` process controller.

Previous stages already gave `PromptExternalProcessDispatchPlan` the raw command,
byte-exact shell/Python/math payloads, and typed `reta` argument vectors.  The
controller still compared `external_process.process_kind` against
`EXTERNAL_PROMPT_*` constants to decide which observable process effect to run.

12c5cn keeps the numeric process kind for compatibility assertions, but adds
plan-owned booleans:

- `run_shell`
- `run_python`
- `run_math`
- `run_reta`

`prompt_main.mojo` now consumes those effect flags and no longer imports or
compares the `EXTERNAL_PROMPT_*` constants.  The actual process I/O remains in
the process entry point, while ownership of the routing decision is native and
localized in `prompt_interaction.mojo`.

Compiler-free guards cover:

- the new plan fields and snapshot marker,
- the removal of process-kind comparisons from the controller,
- regression assertions for every external command family,
- the current-stage wrapper and source-archive contract.
