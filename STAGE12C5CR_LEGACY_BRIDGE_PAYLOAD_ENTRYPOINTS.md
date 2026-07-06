# Stage 12c5cr – Legacy bridge payload entrypoints

The historical `mojo_bridge.py` compatibility functions `run_shell_line`,
`run_python_code`, and `run_math_expression` now delegate directly to the native
payload entrypoints instead of re-creating synthetic prompt lines and parsing
those lines again.

This keeps the public bridge surface byte-compatible while removing one more
raw prompt-line boundary from the compatibility launcher:

- `run_shell_line(line)` -> `run_shell_prompt_payload_native(line, root)`
- `run_python_code(code)` -> `run_python_prompt_payload_native(code, root)`
- `run_math_expression(expr)` -> `run_math_prompt_payload_native(expr, root)`

The line-based prompt adapters remain available for the legacy functions that
really receive a full prompt line. The older convenience wrappers no longer
manufacture `shell `, `python `, or `math ` prefixes only to strip them again.
