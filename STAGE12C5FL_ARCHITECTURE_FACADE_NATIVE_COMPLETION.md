# Stage 12c5fl – Architecture facade native completion

This stage promotes `reta_architecture/facade.py` from `teilweise nativ` to
`nativ` in the authoritative porting matrix.  The promotion is intentionally
limited to the facade contract itself: ordered fields, method surface, bootstrap
assignment order, force-rebuild method graph and snapshot order.  Child bundles
remain accountable in their own matrix rows, so `prompt_execution.py` and
`reta.py` are not hidden behind the facade.

Native evidence added in `src/reta_mojo/architecture_facade.mojo`:

- `ArchitectureFacadeNativeCompletionPlan`
- `plan_architecture_facade_native_completion`
- `architecture_facade_native_completion_valid`

The witness requires the existing catalog invariant to hold:

- 45 fields
- 49 methods
- 45 bootstrap steps
- 44 force-rebuild methods
- 98 dependency edges
- 48 snapshot entries

Resulting metric target: `90/92` files fully native/generated, with only
`reta.py` and `reta_architecture/prompt_execution.py` remaining partial.
