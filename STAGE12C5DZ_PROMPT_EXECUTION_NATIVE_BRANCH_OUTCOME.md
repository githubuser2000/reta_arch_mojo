# Stage 12c5dz – Prompt execution native branch outcome plan

Diese Etappe verkleinert die verbleibende `prompt_execution.py`-Kompatibilitätsinsel weiter, ohne neue Terminal-I/O-Pfade zu erfinden.

## Verschoben

- `PromptExecutionNativeBranchOutcomePlan` liegt in `src/reta_mojo/prompt_execution.mojo`.
- `plan_prompt_execution_native_branch_outcome(...)` entscheidet nach der physischen Ausgabe rein typisiert:
  - ob der native Tabellen-/mulpri-Zweig als behandelt gilt,
  - ob danach `loggen` aktiv werden soll,
  - ob danach `nichtloggen` aktiv werden soll,
  - ob bei nicht erfolgter nativer Ausgabe der Kompatibilitätsfallback gebraucht wird.

`prompt_main.mojo` beobachtet nur noch das Ergebnis der I/O-Ausführung und mutiert anschließend die Session gemäß dem geplanten Outcome. Die Entscheidung selbst liegt nicht mehr direkt im Controller.

## Regression

Der vorherige `mulpri`-Render-Test erwartete beim Primzahlfall eine lokalisierte Marker-Zeile. Das war für den Stage-Vertrag zu eng: stabil bewiesen werden muss hier, dass der Plan sowohl Prime- als auch Multis-Zeilen besitzt. Deshalb nutzt der Test nun explizit `p 17`, prüft `17` und mindestens zwei Ausgabezeilen. Die Implementierung erkennt leere Multis-Listen zusätzlich robuster über `"[]" in ...`.

## Lokal prüfen

```sh
RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5dz.sh -- -j 4
scripts/run-tests.sh
scripts/build-all.sh -- -j 6
RETA_TEST_HEAVY=1 scripts/test_all.sh
```
