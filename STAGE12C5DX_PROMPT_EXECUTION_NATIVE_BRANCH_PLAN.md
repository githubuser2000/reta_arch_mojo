# Stage 12c5dx – Prompt execution native branch plan

This stage moves the remaining duplicated ownership/effect/announcement branch
selection for interactive prompt execution and one-shot `-befehl` into the native
`prompt_execution.mojo` owner.

`PromptExecutionNativeBranchPlan` now groups:

- table/mulpri ownership
- compact announcement planning
- historical companion side-effect planning
- table echo/quiet flags
- prepared planning tokens for mulpri rendering
- fallback requirement

`prompt_main.mojo` now performs only terminal I/O and session mutation for this
branch.
