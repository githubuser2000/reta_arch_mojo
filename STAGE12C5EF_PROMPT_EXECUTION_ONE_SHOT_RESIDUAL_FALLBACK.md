# Stage 12c5ef – Prompt execution one-shot residual fallback owner

Diese Etappe verschiebt die letzte nackte Restgrenze des nativen `-befehl`-Probewegs
in denselben Prompt-Execution-Fallbackplan wie den interaktiven Controller.

Vorher endete `_run_native_one_shot` nach allen nativen Dispatchern mit einem
direkten `return False`. Das war funktional richtig, aber die Entscheidung, dass
eine unbewiesene Restzeile an die Kompatibilitätsgrenze zurückgegeben werden muss,
war nicht als Prompt-Execution-Plan sichtbar.

Jetzt plant `_run_native_one_shot` die Restgrenze explizit:

```mojo
var one_shot_residual_fallback = plan_prompt_execution_residual_compatibility_fallback(line)
if one_shot_residual_fallback.should_run:
    return False
```

Der aufrufende `main`-Pfad bleibt Besitzer des eigentlichen Kompatibilitätsaufrufs.
Der Prompt-Execution-Owner besitzt aber auch für `-befehl` die Entscheidung und die
unveränderte Quellzeile, bevor sie die native Probe verlässt.

Lokale Prüfung:

```sh
RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5ef.sh -- -j 4
```
