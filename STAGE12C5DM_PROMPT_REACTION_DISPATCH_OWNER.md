# Stage 12c5dm – Prompt reaction dispatch owner

This stage moves the local, non-process prompt dispatch plans into an explicit
native reaction-dispatch owner.

## Native owner split

`src/reta_mojo/prompt_interaction.mojo` now keeps the mutable interactive
controller lifecycle:

- startup to native prompt session,
- physical input acceptance,
- store/delete mode continuation,
- stored default enter handling,
- previous-command recording.

`src/reta_mojo/prompt_reaction_dispatch.mojo` now owns the local prompt reaction
plans that do not require the reta core and do not cross the OS process
boundary:

- inline storage planning,
- inline stored-output planning,
- loop control,
- store-next/store-previous dispatch,
- logging toggles,
- terminal clear flags,
- informational flags,
- deterministic prompt output lines,
- stored-output and stored-delete execution plans.

## Shared-library meaning

This is preparation only; no `.so`/`.dll` split is implemented here.

The target boundary is now clearer:

```text
libreta-prompt-reaction
  owns local interaction effects without libreta-core

libreta-prompt-execution
  owns external/fallback execution decisions and may use libreta-core

libreta-process
  only executes already-planned process argv/payloads
```

`prompt_main.mojo` imports the local dispatch plans directly from
`prompt_reaction_dispatch`, while `prompt_interaction` remains the compatibility
source for old callers by importing those names.

## Validation

Compiler-free source validation covers the new owner, the production imports,
the interaction/process/reaction snapshot split, known-defect ledger, porting
metrics and source archive contract.  Mojo compilation remains delegated to the
local machine.
