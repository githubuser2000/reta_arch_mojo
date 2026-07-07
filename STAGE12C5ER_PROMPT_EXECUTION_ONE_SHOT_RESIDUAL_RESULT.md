# 12c5er – Prompt execution one-shot residual result owner

Diese Etappe verschiebt die letzte Rückgabeprojektion der nativen `-befehl`-
Probe aus `src/prompt_main.mojo` in den Prompt-Execution-Owner.

## Neuer Owner

`src/reta_mojo/prompt_execution.mojo` enthält jetzt:

- `PromptExecutionOneShotResidualResultPlan`
- `plan_prompt_execution_one_shot_residual_result(...)`

Die vorhandene `PromptExecutionOneShotCompatibilityBoundaryPlan` entscheidet
weiterhin, ob die native Probe an der Kompatibilitätsgrenze stoppen muss. Der
neue Result-Plan übersetzt diese Boundary in die finale Rückgabe von
`_run_native_one_shot`.

## Controller-Effekt

Vorher interpretierte der Controller direkt:

```mojo
if one_shot_residual_boundary.stop_native_probe:
    return False
return one_shot_residual_boundary.handled_without_fallback
```

Jetzt konsumiert er nur noch:

```mojo
var one_shot_residual_result = plan_prompt_execution_one_shot_residual_result(
    one_shot_residual_boundary
)
return one_shot_residual_result.handled
```

Damit ist die finale One-shot-Residual-Rückgabe genauso typisiert wie die
vorherige One-shot-External-Result-Etappe.

## Keine Build-Ausführung im Container

Diese Etappe ist source-/contract-geprüft. Mojo-Builds und vollständige native
Tests bleiben lokal beim Nutzer.
