# Stage 12c5eo – Prompt process compatibility fallback execution owner

Diese Etappe verschiebt die interaktive Kompatibilitäts-Fallback-Ausführung
nach einem abgewiesenen nativen Prompt-Branch in den Prompt-Process-Dispatch-
Owner.

## Änderung

Neu in `src/reta_mojo/prompt_process_dispatch.mojo`:

- `PromptCompatibilityFallbackProcessExecutionPlan`
- `plan_prompt_compatibility_fallback_process_execution(...)`
- Contract-Marker
  `compatibility_fallback_process_execution=native-prompt-compatibility-fallback-execution-boundary`

`src/prompt_main.mojo` liest nach `plan_prompt_execution_compatibility_fallback(...)`
nicht mehr direkt `compatibility_fallback.should_run` und
`compatibility_fallback.source`. Stattdessen erhält der Controller einen fertigen
Execution-Plan mit `should_execute` und argv-Vektor.

## Grenze

Der Controller führt weiterhin den echten `retaPrompt.py`-Kindprozess aus. Die
Entscheidung, ob dieser Compatibility-Fallback-Prozess laufen soll, sowie die
Übersetzung der Quelle in historische `retaPrompt.py`-Argumente liegen jetzt im
Process-Dispatch-Owner.

## Motivation

Damit haben der frühe Compatibility-Fallback nach nativer Branch-Ablehnung und
der spätere Residual-Fallback dieselbe saubere Prozessgrenze. Der Controller
interpretiert keine nackten Fallback-Booleans mehr an diesen beiden Stellen.

## Prüfpfad

- `tests/test_prompt_interaction.mojo`
- `tests/test_legacy_reta_prompt.mojo`
- `tests/test_stage12c5eo_source.py`
- `scripts/test_stage12c5eo.sh`
