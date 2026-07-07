# 12c5eq – Prompt process one-shot external result owner

Diese Etappe zieht die letzte Rückgabeprojektion der externen `-befehl`-Probe in den Prompt-Process-Dispatch-Owner.

## Änderung

Neu in `src/reta_mojo/prompt_process_dispatch.mojo`:

- `PromptOneShotExternalResultPlan`
- `plan_one_shot_external_process_result(...)`
- Snapshot-Marker `one_shot_external_result=native-prompt-process-one-shot-result-boundary`

`prompt_main.mojo` ruft nach `plan_one_shot_external_process_boundary(...)` nun den Result-Plan auf und gibt dessen `handled`-Feld zurück.

## Zweck

Die One-shot-External-Prozesskette ist damit analog zur interaktiven External-Prozesskette gegliedert:

1. External dispatch
2. One-shot external execution
3. One-shot external boundary
4. One-shot-External-Result

Der Controller führt weiterhin echte Prozess-I/O aus, interpretiert aber die finale Rückgabe nicht mehr direkt aus der Boundary-Struktur.

## Kein nativer Build im Assistant

Es wurden nur Source-/Contract-Checks ausgeführt. Mojo-Kompilierung bleibt lokal beim Nutzer.
