# Stage 12c5fc – Prompt process one-shot external probe result owner

Diese Stage zieht die letzte rohe Gate-Logik um den One-shot-External-Process-Block aus `src/prompt_main.mojo` heraus.

## Änderung

- `PromptOneShotExternalResultPlan` trägt jetzt zusätzlich `continue_native_probe`.
- `plan_one_shot_external_process_result(...)` unterscheidet drei Fälle explizit:
  - externes Kommando muss zur Kompatibilitätsgrenze: `handled=False`, `stop_native_probe=True`, `continue_native_probe=False`
  - direkte native `reta`-Probe war erfolgreich: `handled=True`, `stop_native_probe=False`, `continue_native_probe=False`
  - kein externes Prozesskommando: `handled=False`, `stop_native_probe=False`, `continue_native_probe=True`
- `_run_native_one_shot` berechnet External-Dispatch, One-shot-Execution, Boundary und Result ohne äußeres `if external_process.handled:`.

Damit entscheidet der Process-Dispatch-Owner, ob nach dem External-Prozessprobe-Result zurückgegeben oder weiter zum Residual-Fallback gegangen wird.

## Tests

- `tests/test_prompt_interaction.mojo` prüft die neue Continue-Projektion.
- `tests/test_stage12c5fc_source.py` schützt den Controller gegen eine Rückkehr zur rohen External-Dispatch-Gate-Insel.

Stage: `12c5fc`
