# Stage 12c5dn – Prompt reaction input owner

This stage moves the physical prompt input and previous-command policy into an
explicit native reaction-input owner.

## Native owner split

`src/reta_mojo/prompt_reaction_input.mojo` now owns the prompt-reaction input
edge that does not require `libreta_core_mojo` and does not cross an OS process
boundary:

- terminal sentinels (`Ctrl-D` / `Ctrl-C`) as explicit typed exit plans,
- store-next continuation,
- delete-next selection and cancellation,
- empty-line stored-placeholder execution,
- previous-command update policy,
- compound storage/output history suppression.

`src/reta_mojo/prompt_interaction.mojo` is now a smaller compatibility and
lifecycle owner:

- startup to native prompt session,
- one-shot token assembly,
- thin wrappers for historical callers,
- a lifecycle-only contract snapshot.

`src/reta_mojo/prompt_reaction_dispatch.mojo` remains the owner for local prompt
effect dispatch plans. `src/reta_mojo/prompt_process_dispatch.mojo` remains the
owner for shell/python/math/reta/fallback process plans.

## Shared-library meaning

This is preparation only; no `.so`/`.dll` split is implemented here.

The target boundary is clearer:

```text
libreta_prompt_mojo-reaction
  owns physical input, session reaction and local prompt effects
  does not need libreta_core_mojo

libreta_prompt_mojo-execution
  owns reta/fallback/external execution decisions
  may use libreta_core_mojo

libreta-process
  only executes already-planned process argv/payloads
```

This keeps the future `rp`/`rpl`/`rpe` input-and-reaction library independent
from the reta table core. `rpb` can later use the execution/batch path without
pulling in the interactive prompt input owner.

## Compatibility

The old `accept_prompt_input(...)`, `record_prompt_command(...)` and
`record_prompt_line(...)` names still exist as thin wrappers in
`prompt_interaction.mojo`, but the implementation has moved to
`prompt_reaction_input.mojo`.

The historical `PromptScope(...)` facade reconstructs the old visible scope
ordering from the split interaction, reaction-input, reaction-dispatch and
process-dispatch contracts.

## Validation

Compiler-free source validation covers the new owner, production imports,
legacy facade composition, known-defect ledger, porting metrics and source
archive contract. Mojo compilation remains delegated to the local machine.
