# Stage 12c5cu - external line wrapper elimination

This stage removes the last raw-line convenience wrappers from the native
`prompt_external_commands.mojo` process adapter.

The adapter now exposes only the executable process boundaries that are owned
by the native prompt/controller pipeline:

- shell/python/math receive already separated payload strings,
- direct `reta` children receive an argv vector,
- `retaPrompt.py` fallback receives profile argv plus the explicitly retained
  atomic fallback line.

The historical `mojo_bridge.py` compatibility facade still accepts its public
line-shaped functions, but it owns that compatibility locally by converting
prompt lines into payloads or argv before crossing the process adapter.  This
keeps raw prompt-line compatibility out of the lower external-process owner.
