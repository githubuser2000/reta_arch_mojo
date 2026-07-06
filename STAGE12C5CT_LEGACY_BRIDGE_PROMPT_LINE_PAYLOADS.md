# Stage 12c5ct: legacy bridge prompt-line payload ownership

This stage removes another historical raw prompt-line detour from the
`mojo_bridge.py` compatibility facade.

The public legacy functions

- `run_shell_prompt_line(line)`,
- `run_python_prompt_line(line)`, and
- `run_math_prompt_line(line)`

still accept the old full prompt-line spelling.  Internally they no longer
call the line-oriented child-process adapters.  The bridge now extracts the
payload once with the native `raw_command_payload` helper and calls the payload
owners directly:

- `run_shell_prompt_payload_native(raw_command_payload(line), ...)`,
- `run_python_prompt_payload_native(raw_command_payload(line), ...)`, and
- `run_math_prompt_payload_native(raw_command_payload(line), ...)`.

The line-based functions remain in `prompt_external_commands.mojo` as public
compatibility entry points and probe targets.  The legacy bridge itself is now
payload/argument-oriented for shell, Python, math, and reta child processes.

New ownership marker:

```text
prompt_line_bridge=payload-owner
```
