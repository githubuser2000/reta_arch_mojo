# Stage 12c5dy – Prompt execution branch owns mulpri render

This stage keeps the 12c5dw compact-announcement regression fix and moves one
more controller decision into the native prompt-execution owner.

## Native ownership change

`PromptExecutionNativeBranchPlan` now carries the already planned
`PromptExecutionMulpriRenderPlan` as `mulpri_render`.  The interactive prompt and
`-befehl` controller no longer call `plan_prompt_execution_mulpri_render(...)`
directly and no longer keep a private `_run_native_mulpri(...)` planning helper.
They only print `branch.mulpri_render.output_lines` when the plan is handled.

This keeps the merged table/mulpri branch as a single pure owner value:

- ownership and fallback decision,
- compact announcement line,
- historical side effects and logging transition,
- render flags for table execution,
- complete `mulpri`/`p` output lines.

## Regression fix kept

The Stage 12c5dv/dw test expected the composite command `15` to emit a localized
`Primzahl` marker.  That marker is only produced by the historical `multis` empty
list replacement for prime numbers, so the contract now uses `17` for that line.

## Runtime boundary

No `.so`/`.dll` split is implemented here.  This is a pure source-level ownership
move inside the native Mojo prompt execution path.
