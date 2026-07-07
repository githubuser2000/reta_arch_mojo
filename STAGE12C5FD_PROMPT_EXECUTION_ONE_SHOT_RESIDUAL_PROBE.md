# Stage 12c5fd – Prompt Execution One-Shot Residual Probe

## Ziel

`_run_native_one_shot` soll die letzte Residual-Kompatibilitätskante nicht mehr
selbst aus Fallback, Boundary und Result zusammensetzen. Nach nativer Tabelle,
lokalen One-Shot-Dispatchern und expliziten Prozesskommandos bleibt nur noch
der finale historische Kompatibilitätsrand. Dieser Rand gehört jetzt als reine
Projektion zu `prompt_execution.mojo`.

## Native Ownership

Neu ist:

- `PromptExecutionOneShotResidualProbePlan`
- `plan_prompt_execution_one_shot_residual_probe(...)`

Der Plan kapselt:

1. `plan_prompt_execution_residual_compatibility_fallback(source)`
2. `plan_prompt_execution_one_shot_compatibility_boundary(..., True)`
3. `plan_prompt_execution_one_shot_residual_result(...)`

Der Controller konsumiert nur noch:

```mojo
var one_shot_residual_probe = plan_prompt_execution_one_shot_residual_probe(line)
return one_shot_residual_probe.result.handled
```

## Wirkung

Damit ist die finale One-Shot-Probe-Rückgabe vollständig in `prompt_execution.mojo`
zentralisiert. `_run_native_one_shot` behält nur noch I/O und tatsächliche
Ausführung, nicht mehr die boolesche Residual-Fallback-Algebra.

## Tests

- `tests/test_prompt_execution.mojo`
- `tests/test_stage12c5fd_source.py`
- bisherige Source-Guards bis `12c5fc`

