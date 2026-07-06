# Stage 12c5da - PromptProfile explicit copy for fallback argv test

This stage fixes a Mojo ownership regression introduced by the fallback argv
planning tests.  `PromptProfile` is `Copyable` but not `ImplicitlyCopyable`, so
reading `.profile` from the temporary `PromptStartup` returned by
`parse_prompt_startup("rpe", [])` must use an explicit `.copy()` when a local
profile variable is created for `plan_prompt_fallback_process_dispatch`.

The runtime ownership model from stages 12c5cy/12c5cz remains unchanged:

- the interaction owner plans fallback process argv,
- the external process adapter consumes payload/argv only,
- the shared `reta_child_arguments_native` owner stays in
  `prompt_external_commands.mojo`.

The change is deliberately small: it makes the focused Mojo test source compile
under Mojo's current non-implicit copy rules without weakening the argv ownership
assertions.
