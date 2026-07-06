# Stage 12c5ei – Prompt process interactive external completion owner

## Ziel

Der interaktive Prompt hatte nach expliziten externen Prozesskommandos noch
Controller-eigene Abschlusslogik. Shell, Python und Math wurden direkt als
`return True` beendet; direkte `reta`-Aufrufe liefen erst nativ und fielen bei
Ablehnung direkt im Controller auf den Referenz-`reta`-Kindprozess zurück.

## Änderung

Neu im Prompt-Process-Dispatch-Owner:

```mojo
def plan_interactive_external_process_completion(
    dispatch: PromptExternalProcessDispatchPlan, reta_native_handled: Bool
) -> PromptInteractiveExternalCompletionPlan
```

Der Plan trägt:

- `handled`: der interaktive Promptbefehl ist nach dem externen Prozesspfad fertig.
- `run_reference_reta`: ein direkter `reta`-Kindprozess muss nach abgelehnter nativer Probe über den Referenzpfad laufen.
- `reta_native_handled`: die native direkte `reta`-Probe wurde angenommen.

## Wirkung

Interactive-External-Kommandos besitzen jetzt eine eigene Completion-Grenze im
Process-Dispatch-Owner. `prompt_main.mojo` führt weiterhin die echten
Kindprozesse aus, entscheidet aber nicht mehr selbst, ob nach einer abgelehnten
direkten `reta`-Probe der Referenzprozess nötig ist oder ob der Promptbefehl als
behandelt gilt.

Damit sind interaktive externe Prozesskanten und One-shot-External-Grenzen
parallel modelliert, ohne die spätere Shared-Library-Aufteilung zu vermischen.

## Lokale Prüfung

```bash
RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5ei.sh -- -j 4
scripts/run-tests.sh
scripts/build-all.sh -- -j 6
RETA_TEST_HEAVY=1 scripts/test_all.sh
```
