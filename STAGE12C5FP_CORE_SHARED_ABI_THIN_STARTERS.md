# Stage 12c5fp: Core Shared ABI and Thin Starters

This stage starts the actual shared-library migration requested after the
porting matrix reached full native ownership.  Stage 12c5fo froze the target
split; this stage adds the first concrete ABI path for the shared native core.

## New build target

`scripts/build_core_shared.sh` builds:

- `target/lib/reta/libreta_core_mojo.so`
- `target/bin/reta` as a thin C loader over `libreta_core_mojo.so`
- `target/bin/grundStrukHtml` as a thin C loader over `libreta_core_mojo.so`

The old direct native executables remain in place for compatibility and local
comparison:

- `target/bin/reta-native`
- `target/bin/grundStrukHtml-native`

This avoids a destructive switch while introducing the new dynamic ABI.  The new `reta` and `grundStrukHtml` programs are dünne Starter.

## ABI surface

`src/reta_core_abi.mojo` exports only C ABI values:

- `reta_core_abi_version()`
- `reta_core_reta_entry(argc, argv)`
- `reta_core_grundstrukhtml_entry(argc, argv)`

Mojo `String` and collection types do not cross the shared-library boundary.
The ABI copies C `argc`/`argv` into owned Mojo values internally and then calls
the native core implementation.

## Loader behavior

`tools/reta_core_loader.c` is shared by both thin starters.  It dispatches by
executable name:

- invoked as `reta` -> `reta_core_reta_entry`
- invoked as `grundStrukHtml` -> `reta_core_grundstrukhtml_entry`

It loads `libreta_core_mojo.so` from `../lib/reta/` relative to the executable, or
from `RETA_CORE_LIBRARY` when explicitly overridden for tests.  It also checks
that the loader and library have matching `.reta-source-id` sidecars before any
entry point is called.

## Scope boundary

This stage intentionally does not move `rp`, `rpl`, `rpe`, or `rpb` yet.  They
will be handled by the next layers:

- `libreta_prompt_mojo.so` for shared prompt execution used by `rp/rpl/rpe/rpb`
- `libreta_prompt_interactive_mojo.so` only for `rp/rpl/rpe`

`rpb` must not depend on the interactive prompt-input library; auf Deutsch: rpb lädt diese interaktive Bibliothek ausdrücklich nicht.
