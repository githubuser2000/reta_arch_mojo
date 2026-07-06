# Stage 12c5df – Fallback runtime argv builder owner

Diese Stage verschiebt den letzten reinen `retaPrompt.py`-Fallback-argv-Builder aus dem
externen Prozessadapter in den Prompt-Runtime-Owner.

## Änderung

- `reta_prompt_fallback_arguments_native(profile_flags, command_args)` liegt jetzt in
  `src/reta_mojo/prompt_runtime.mojo`.
- `src/reta_mojo/prompt_external_commands.mojo` behält nur noch echte Prozessausführung:
  `run_shell_prompt_payload_native`, `run_python_prompt_payload_native`,
  `run_math_prompt_payload_native`, `run_reta_arguments_native` und
  `run_reta_prompt_arguments_native`.
- `prompt_interaction.mojo`, `legacy_mojo_bridge.mojo` und die externe Probe importieren
  den Fallback-argv-Builder aus `prompt_runtime.mojo`.

## Warum

Der Builder startet keinen Prozess. Er fügt nur Profilflags und tokenisierte
Fallback-Kommandos zu einem `retaPrompt.py`-argv-Vektor zusammen. Das ist
Prompt-Runtime-Semantik und sollte deshalb nicht im Betriebssystem-/Prozessadapter
liegen.

## Ergebnis

Die Prozessadapter-Grenze ist sauberer:

```text
prompt_runtime           -> baut Fallback-argv
prompt_interaction       -> plant Fallback-Effekt und finalen argv-Vektor
prompt_external_commands -> führt nur fertige payload/argv-Prozesse aus
```

Neuer Snapshotmarker:

```text
fallback_runtime_arguments=runtime-owned-argv-builder
```
