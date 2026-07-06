# Stage 12c5cy — fallback interaction argv plan

The remaining prompt fallback child is now planned by the native interaction
owner before the process adapter is called.

Previously `prompt_main.mojo` owned the last conversion from a raw fallback
prompt line to the `retaPrompt.py` child argv vector:

- `_run_fallback(profile, line)` called `fallback_profile_arguments(profile)`
  and `shell_split(line)` directly in the process controller.

Now the controller asks `prompt_interaction.mojo` for a typed fallback process
plan:

- `PromptFallbackProcessDispatchPlan` carries `profile_arguments` and
  `command_arguments`.
- `plan_prompt_fallback_process_dispatch(profile, line)` performs the native
  argv planning.
- `prompt_main.mojo` passes only the planned vectors to
  `run_reta_prompt_fallback_arguments_native(...)`.

The raw prompt line is still accepted at the historical compatibility edge, but
its shell-style tokenization no longer belongs to the process entry point or
the external process adapter.
