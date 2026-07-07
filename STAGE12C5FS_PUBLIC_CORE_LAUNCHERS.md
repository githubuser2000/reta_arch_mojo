# Stage 12c5fs: public launchers use the core thin starters

This stage turns the already-built core ABI path into the public launcher path.

The source-tree launchers `bin/reta` and `bin/grundStrukHtml` are now thin shell
wrappers over the compiled C starters in `target/bin/`.  They no longer route
through `reta-mojo-compat`, `reta-native`, `grundStrukHtml-native`, or direct
`mojo run` fallbacks.

Required runtime layout:

- `target/bin/reta`
- `target/bin/grundStrukHtml`
- `target/lib/reta/libreta-core.so`
- matching `.reta-source-id` sidecars for both thin starters and the core library

The install path was tightened as well: `scripts/install.sh` now installs
`libreta-core.so` and its source-id sidecar into the private runtime tree, so
installed public commands can resolve the same shared core layout as the source
checkout.

The historical native executables stay available as explicit comparison and
compatibility targets:

- `target/bin/reta-native`
- `target/bin/grundStrukHtml-native`

This keeps the new public contract simple:

- `reta` is a launcher for `target/bin/reta`, which loads `libreta-core.so`.
- `grundStrukHtml` is a launcher for `target/bin/grundStrukHtml`, which loads
  `libreta-core.so`.
- `rpb` still does not depend on the interactive prompt-input library.
