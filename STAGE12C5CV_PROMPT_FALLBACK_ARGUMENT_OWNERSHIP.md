# Stage 12c5cv – Prompt fallback argument ownership

This stage removes the remaining raw-line fallback contract from the external
process adapter.

## Ownership change

`prompt_external_commands.mojo` no longer exposes
`run_reta_prompt_fallback_native(profile_args, raw_line, root)`.

The compatibility boundary is now:

- `run_reta_prompt_fallback_arguments_native(profile_args, command_args, root)`

The prompt controller and the legacy bridge facade still own the historical raw
text they receive.  They tokenize that text once with the existing POSIX
`shlex`-compatible `shell_split` owner and then pass argv fragments to the
external child-process adapter.

## Why this matters

The process adapter is now payload/argv-only for every child process family:

- shell/python/math use explicit payloads
- reta uses an explicit argv vector
- retaPrompt fallback uses an explicit argv vector

Raw prompt-line compatibility remains at the public facades where it belongs;
the subprocess adapter no longer parses a prompt line just before spawning the
reference child.

## Test focus

The stage source checks assert that:

- `prompt_main.mojo` imports `shell_split` and calls
  `run_reta_prompt_fallback_arguments_native(...)`
- `legacy_mojo_bridge.mojo` calls the same argv fallback owner
- `prompt_external_commands.mojo` contains no raw-line fallback entry point
- the legacy bridge snapshot records `fallback_bridge=native-argv-owner`
