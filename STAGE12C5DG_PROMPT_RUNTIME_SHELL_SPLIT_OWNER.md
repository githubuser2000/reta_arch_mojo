# Stage 12c5dg – Prompt runtime shell-split owner

Diese Stage verschiebt den POSIX-artigen `shell_split(...)`-Parser aus dem
externen Prozessadapter in den Prompt-Runtime-Owner.

## Änderung

- `shell_split(text)` liegt jetzt in `src/reta_mojo/prompt_runtime.mojo`.
- `src/reta_mojo/prompt_external_commands.mojo` importiert den Parser nur noch,
  um einen bereits getrennten Shell-Payload in einen sicher quotierten
  Prozessaufruf umzusetzen.
- `prompt_interaction.mojo`, `legacy_mojo_bridge.mojo`, die externe Probe und
  `tests/test_prompt_external_commands.mojo` importieren `shell_split` direkt aus
  `prompt_runtime.mojo`.

## Warum

`shell_split` startet keinen Prozess und ruft kein Betriebssystem. Es ist eine
historische Prompt-/argv-Tokenisierungsregel. Deshalb gehört der Parser nicht in
die spätere Prozessadapter-`.so`, sondern in die Prompt-Runtime-Grenze.

## Ergebnis

Die geplanten `.so/.dll`-Grenzen werden klarer:

```text
prompt_runtime           -> Prompt-Profile, Fallback-argv, shell-style Tokenisierung
prompt_interaction       -> Dispatch-Pläne und Effektentscheidungen
prompt_external_commands -> nur Child-Prozess-Ausführung und Shell-Quoting
```

Neuer Snapshotmarker:

```text
fallback_shell_split=runtime-owned-argv-tokenizer
```
