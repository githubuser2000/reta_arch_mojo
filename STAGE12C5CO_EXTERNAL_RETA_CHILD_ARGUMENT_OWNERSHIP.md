# Stage 12c5co: External reta child argument ownership

This stage closes the last raw-line split in the interactive external `reta`
prompt boundary.

Previous stages already moved external command routing, raw payload extraction,
`reta` argument vector construction and process-effect flags into
`prompt_interaction.mojo`.  The interactive process controller still used
`run_reta_line_native(external_process.raw)` when a `reta ...` prompt command
was not in the proved native `reta` subset.  That meant the compatibility child
adapter reparsed the raw prompt line even though the interaction owner had
already produced the exact argument vector.

12c5co keeps the observable process boundary unchanged but switches the
unsupported `reta` fallback child to `run_reta_arguments_native(
external_process.arguments, reference_root())`.  The one-shot controller already
falls back atomically to the historical prompt facade for unsupported cases; the
interactive path now also consumes the planned argv vector for the direct
`reta.py` child.  The raw line is still retained in the plan for diagnostics and
older compatibility assertions, but it is no longer the child-spawn input for
external `reta` dispatch.

Compiler-free guards cover:

- the new `external_reta_child` ownership snapshot marker,
- removal of `run_reta_line_native(external_process.raw)` from the controller,
- continued use of payload-owned shell/Python/math process calls,
- compatibility of older source-stage guards with the stronger argv-owned child
  boundary,
- the current-stage wrapper and archive contract.
