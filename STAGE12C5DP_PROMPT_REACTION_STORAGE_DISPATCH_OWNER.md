# Stage 12c5dp: Prompt reaction storage dispatch owner

This stage continues the planned prompt shared-library boundary split.  The
previous stage already introduced `prompt_reaction_storage.mojo` for shared
storage decisions.  This stage moves the remaining storage lifecycle dispatch
plans into that owner as well and fixes the compiler warning reported during the
local native build.

No `.so`/`.dll` split is implemented here.  This is still a source-level owner
and contract split so a later build system can extract libraries cleanly.

## User-reported warning fixed

The local Mojo compiler reported:

```text
src/reta_mojo/prompt_reaction_storage.mojo:141:29: warning: assignment to
'ambiguous' was never used; assign to '_' instead?
```

The cause was an accidental duplicate assignment in the inline stored-output
alias ambiguity branch.  The duplicate assignment was removed; the real
`ambiguous` flag remains used by the decision guard.

## New ownership

`src/reta_mojo/prompt_reaction_storage.mojo` now owns:

- `PromptInlineStoragePlan`
- `PromptStorageOutputPlan`
- `PromptStoredDefaultPlan`
- `PromptStoredCommandDispatchPlan`
- `PromptStoredOutputExecutionPlan`
- `PromptStoredDeletePlan`
- `plan_inline_storage_command(...)`
- `plan_inline_storage_output_command(...)`
- `plan_stored_default_command(...)`
- `apply_inline_storage_command(...)`
- `plan_stored_command_dispatch(...)`
- `plan_inline_stored_output_command(...)`
- `plan_stored_output_command(...)`
- `plan_stored_delete_command(...)`

`src/reta_mojo/prompt_reaction_dispatch.mojo` now keeps only non-storage local
reaction effects:

- loop control
- logging
- one-shot logging
- terminal clear
- informational dispatch
- deterministic prompt-only output

## Target-library meaning

The desired future architecture becomes clearer:

```text
libreta-prompt-reaction
  input
  storage
  local dispatch

libreta-prompt-execution
  process dispatch

libreta-process
  OS / child process adapter
```

The storage owner still has no dependency on `prompt_process_dispatch`,
`prompt_external_commands`, Python objects or the reta core.  It only mutates the
native prompt session storage state and returns typed plans for the process entry
point to print or recursively execute.

## Compatibility

The public controller calls the same functions with the same names.  The visible
Mojo prompt tests still exercise the same behavior; only the owner module has
changed.

The historical `PromptScope(...)` remains reconstructed from split contracts.
The storage contract now carries the storage dispatch markers, while the local
reaction-dispatch contract carries only non-storage local effects.
