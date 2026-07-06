# Stage 12c5el – Prompt process one-shot external execution owner

Diese Etappe zieht die letzte One-shot-External-Execution-Projektion aus
`prompt_main.mojo` in den Prompt-Process-Dispatch-Owner.

`prompt_process_dispatch.mojo` besitzt nun zusätzlich:

- `PromptOneShotExternalExecutionPlan`
- `plan_one_shot_external_process_execution`

Damit liest der `-befehl`-Controller nicht mehr direkt
`external_process.run_reta` oder `external_process.arguments`, um den nativen
`reta`-Kindprozessversuch auszulösen.  Shell, Python und Math bleiben in
One-shot bewusst an der Kompatibilitätsgrenze; nur direkte `reta`-Kommandos
bekommen eine native Probe.

## Native Eigentumsgrenze

1. `plan_external_process_dispatch` erkennt shell/python/math/reta und baut argv.
2. `plan_one_shot_external_process_execution` entscheidet, ob ein direkter
   nativer `reta`-Kindprozessversuch erlaubt ist.
3. `plan_one_shot_external_process_boundary` entscheidet danach, ob die native
   Probe abgeschlossen ist oder zur Kompatibilität zurückkehrt.

## Absicherung

- `tests/test_prompt_interaction.mojo` prüft den neuen Plan direkt.
- `tests/test_legacy_reta_prompt.mojo` erweitert den Legacy-`PromptScope`.
- `tests/test_stage12c5el_source.py` schützt Controller-, Snapshot-,
  Dokumentations- und Stage-Script-Verträge.
