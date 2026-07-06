# Stage 12c5eh – Prompt process one-shot external boundary owner

## Ziel

`-befehl` darf externe Prozesse nicht nebenbei starten, wenn der native
Probeweg nur feststellen soll, ob ein Kommando vollständig nativ ist. Der
Controller hatte dafür noch eine direkte Sonderlogik: native `reta`-Argumente
konnten sofort abgeschlossen werden, alle anderen externen Prozesskommandos
führten zu `return False`.

## Änderung

Neu im Prompt-Process-Dispatch-Owner:

```mojo
def plan_one_shot_external_process_boundary(
    dispatch: PromptExternalProcessDispatchPlan, reta_native_handled: Bool
) -> PromptOneShotExternalBoundaryPlan
```

Der Plan trägt:

- `stop_native_probe`: die native `-befehl`-Probe muss verlassen werden.
- `handled_without_boundary`: der Probeweg ist vollständig nativ abgeschlossen.
- `reta_native_handled`: die direkte `reta`-Probe wurde nativ angenommen.

## Wirkung

One-shot-External-Kommandos bekommen damit eine eigene Boundary-Entscheidung.

`prompt_main.mojo` interpretiert einen externen Prozessplan in `_run_native_one_shot`
nicht mehr selbst als nacktes `return False`. Shell/Python/Math und nicht nativ
angenommene direkte `reta`-Argumente werden durch den Process-Dispatch-Owner an
die One-shot-Kompatibilitätsgrenze geführt. Nativ angenommene `reta`-Argumente
bleiben vollständig im nativen Probeweg.

Der Controller bleibt Prozessadapter-Besitzer. Die Entscheidung, ob der
One-shot-Probeweg nach einem externen Prozessplan stoppt oder fertig ist, liegt
jetzt beim process-facing Prompt-Execution-Owner.

## Lokale Prüfung

```bash
RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5eh.sh -- -j 4
scripts/run-tests.sh
scripts/build-all.sh -- -j 6
RETA_TEST_HEAVY=1 scripts/test_all.sh
```
