# Stage 12c5cz – shared reta child argv owner

This stage removes the last duplicated ``reta`` child-argument normalizer from
legacy/probe compatibility edges.

## Change

``prompt_external_commands.mojo`` now exposes a pure argv helper:

```mojo
def reta_child_arguments_native(arguments: List[String]) -> List[String]
```

It drops an optional historical entry point token (``reta``, ``reta.py`` or a
path ending in ``/reta.py``) from an already-tokenized argv vector.  This keeps
raw prompt-line compatibility at the caller edge while making the child-process
adapter the single owner of reta-child argv normalization.

## Boundary reduction

Before this stage, both ``legacy_mojo_bridge.mojo`` and
``prompt_external_commands_probe.mojo`` carried their own private
``_reta_child_arguments`` implementation.  After this stage they both call the
shared native helper and keep only their local raw-line tokenization.

The resulting boundary shape is:

- shell/python/math: local historical line payload -> process payload
- reta lines: local historical line tokenization -> shared reta argv normalizer
- retaPrompt fallback: interaction/legacy argv plan -> process argv

No Python interpreter is embedded and no raw prompt-line helper is exported by
the external process adapter.

## Snapshot marker

```
reta_child_arguments=shared-native-argv-owner
```
