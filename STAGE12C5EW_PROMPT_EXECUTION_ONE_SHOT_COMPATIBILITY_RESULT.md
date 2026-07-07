# Stage 12c5ew – Prompt execution one-shot compatibility result owner

## Ziel

`_run_native_one_shot` soll nach der ersten Kompatibilitätsgrenze nicht mehr
selbst aus `compatibility_boundary.stop_native_probe` ableiten, ob der native
Probe-Lauf mit `False` zurückkehrt. Diese Rückgabeprojektion gehört zum
Prompt-Execution-Owner.

## Änderung

Neu in `src/reta_mojo/prompt_execution.mojo`:

- `PromptExecutionOneShotCompatibilityResultPlan`
- `plan_prompt_execution_one_shot_compatibility_result(...)`

`src/prompt_main.mojo` erzeugt weiterhin die One-Shot-Kompatibilitätsgrenze an
der gleichen Stelle. Der Controller konsumiert danach aber einen typisierten
Result-Plan und gibt bei einem nötigen Python-Kompatibilitätsübergang nur noch
`compatibility_result.handled` zurück.

## Warum klein und sicher

Die Stage verändert keine Ausgabe und startet keinen Prozess. Sie verschiebt nur
die reine Boolean-Projektion

```text
Fallback nötig -> nativer Probe-Lauf endet mit False
kein Fallback -> weitere native One-Shot-Dispatcher dürfen weiter prüfen
```

vom Controller in den Prompt-Execution-Owner.

## Prüfungen

Source-Guards prüfen:

- neuen Struct und Planner im Prompt-Execution-Owner
- Import und Nutzung in `prompt_main.mojo`
- Entfernung der aktiven direkten Controller-Abfrage auf
  `compatibility_boundary.stop_native_probe`
- neuen Mojo-Contract-Test in `tests/test_prompt_execution.mojo`
