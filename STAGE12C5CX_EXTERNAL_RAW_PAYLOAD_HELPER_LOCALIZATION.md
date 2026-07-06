# Stage 12c5cx – external raw payload helper localization

This stage removes the last raw prompt-line payload helper from the external
process adapter.

`prompt_external_commands.mojo` now exposes only executable process boundaries:

- shell/python/math payload children
- reta argv children
- retaPrompt argv/fallback children

The historical `line.partition(" ")[2]` compatibility rule is no longer an
adapter export.  It is owned locally by the legacy `mojo_bridge.py` facade and
by the test probe that still accepts raw line input for compatibility checks.
This keeps raw prompt-line compatibility at the facade edge while the runtime
adapter remains payload-/argv-only.

New owner snapshot marker:

```text
external_raw_payload_helper=legacy-local
```

No Mojo/native compilation is required to inspect this stage; the stage script
builds the affected Mojo tests when run locally.
