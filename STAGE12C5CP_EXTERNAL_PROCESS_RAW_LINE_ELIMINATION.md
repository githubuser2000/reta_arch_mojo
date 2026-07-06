# Stage 12c5cp – external process raw line elimination

Die externe Prompt-Prozesskante war bereits in Stage 12c5cm/12c5co typisiert: Shell/Python/Math liefen über Payloads, direkte `reta`-Kindprozesse über argv. Diese Stage entfernt den letzten doppelten Besitz im ausführbaren Plan selbst.

## Änderung

- `PromptExternalProcessDispatchPlan` besitzt kein `raw: String` mehr.
- `prompt_main.mojo` konsumiert weiterhin nur `external_process.payload` und `external_process.arguments`.
- `prompt_interaction_contract_snapshot()` enthält `external_raw_line=eliminated-from-external-process-plan`.

## Zweck

Die rohe Promptzeile bleibt im klassifizierten `PromptCommand`, weil sie für exakte Payloadableitung und historische Fallback-Konservierung gebraucht wird. Sie wird aber nicht mehr in den konkreten externen Prozessplan kopiert. Dadurch ist die Prozesskante enger: ausführbare Effekte sehen nur noch typisierte Nutzlasten.

## Prüfung

Ohne Mojo-Kompilation prüfbar mit:

```sh
scripts/run_pytest.sh -q tests/test_stage12c5cp_source.py tests/test_prompt_interaction_source.py
```

Vollständige Stage-Prüfung lokal:

```sh
RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5cp.sh -- -j 4
```
