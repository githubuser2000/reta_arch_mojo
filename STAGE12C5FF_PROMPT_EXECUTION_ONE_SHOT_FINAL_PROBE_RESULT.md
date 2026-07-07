# Stage 12c5ff – prompt execution one-shot final probe result owner

## Ziel

`_run_native_one_shot` soll am Ende der nativen `-befehl`-Probe nicht mehr
selbst zwischen dem externen Prozessresultat und dem finalen residualen
Kompatibilitätsrand verzweigen.  Die finale Rückgabeprojektion gehört jetzt
wieder zu `prompt_execution.mojo`.

## Native Änderung

Neu in `src/reta_mojo/prompt_execution.mojo`:

- `PromptExecutionOneShotFinalProbeResultPlan`
- `plan_prompt_execution_one_shot_final_probe_result(...)`

Der Plan entscheidet rein typisiert:

1. Wenn der externe Prozesspfad die native Probe bereits gestoppt hat, wird
   dessen `handled`-Wert als finales Resultat verwendet.
2. Wenn der externe Prozesspfad weiterprobieren lässt, baut der Plan intern den
   residualen One-Shot-Kompatibilitätsrand und gibt dessen Resultat zurück.

Damit verbraucht `src/prompt_main.mojo` nach dem externen Prozesspfad nur noch
ein finales Ergebnis:

```mojo
var final_probe_result = plan_prompt_execution_one_shot_final_probe_result(
    external_result.handled, external_result.continue_native_probe, line
)
return final_probe_result.handled
```

## Guard

`tests/test_stage12c5ff_source.py` prüft, dass der Controller nicht mehr direkt
von `external_result.handled` zurückkehrt und nicht mehr selbst
`one_shot_residual_probe` zusammensetzt.

## Lokale Prüfung

```bash
scripts/build-all.sh -- -j 8 2>&1 | tee build-all.txt && scripts/build-tests.sh -- -j 8 2>&1 | tee build-tests.txt && RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5ff.sh -- -j 6 2>&1 | tee test_stage12c5ff.txt && scripts/run-tests.sh 2>&1 | tee run-tests.txt
```
