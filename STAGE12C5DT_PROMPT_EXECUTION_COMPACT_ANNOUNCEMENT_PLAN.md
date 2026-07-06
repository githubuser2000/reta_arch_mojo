# Stage 12c5dt: Prompt execution compact announcement plan

This stage moves the remaining pure compact-command announcement decision out
of `src/prompt_main.mojo` and into the native prompt-execution owner.

`src/reta_mojo/prompt_execution.mojo` now owns
`PromptExecutionCompactAnnouncementPlan` and
`plan_prompt_execution_compact_announcement(...)`.  The plan decides whether the
historical compact announcement should be printed, enriches `mulpri`/`p` with
the visible companion words, and renders the exact newline-terminated
announcement text through the existing legacy echo renderer.

`src/prompt_main.mojo` still owns terminal I/O and prints the already-rendered
line when `should_print` is true.  It no longer imports
`compact_prompt_announcement_line(...)` directly and no longer passes separate
expansion/prepared/quiet pieces through its private announcement helper.

No `.so`/`.dll` split is implemented here.  This is another internal ownership
cleanup before the later executable/library separation.


## Compile guard

The compact-announcement and ownership split keeps the native `_run_native_mulpri` runner in `prompt_main.mojo`.  Its pure token tests are imported from `prompt_execution.mojo`, but the runner itself still owns terminal output for `prim`, `multis` and `primfaktorenvergleich`.  This prevents the controller from retaining duplicate `_has_mulpri`/integer parsing helpers while preserving the two historical call sites.
