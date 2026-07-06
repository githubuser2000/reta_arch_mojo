# Stage 12c5ds: Prompt execution compact announcement owner

This stage moves the last small pure compact-command announcement token helper
out of `src/prompt_main.mojo` and into the native prompt-execution owner.

`src/reta_mojo/prompt_execution.mojo` now owns
`prompt_execution_compact_announcement_tokens(...)`.  The helper preserves the
historical visible compact echo rule for `mulpri`/`p`: when the prepared prompt
contains the combined prime/multiple shortcut, the visible announcement also
contains the localized `multis`, `prim` and `primfaktorenvergleich` command
words once and in fixed order.

`src/prompt_main.mojo` still performs terminal I/O, but no longer locally owns
that token enrichment rule or a private token-membership helper.  The controller
now asks the prompt-execution owner for the visible compact announcement tokens
and then prints the existing `compact_prompt_announcement_line(...)` result.

No `.so`/`.dll` split is implemented here.  This is another internal ownership
cleanup before the later executable/library separation.
