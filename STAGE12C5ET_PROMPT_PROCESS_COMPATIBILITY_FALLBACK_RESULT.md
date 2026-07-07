# Stage 12c5et – Prompt process compatibility fallback result owner

Diese Etappe verschiebt die finale Rückgabe des frühen interaktiven Compatibility-Fallbacks aus `prompt_main.mojo` in den Prompt-Process-Dispatch-Owner.

## Neue native Grenze

Compatibility-Fallback-Result: der frühe Fallback nach abgelehnter nativer Branch-Ausführung besitzt jetzt eine eigene Result-Projektion.

- `PromptCompatibilityFallbackProcessResultPlan`
- `plan_prompt_compatibility_fallback_process_result(...)`
- Contract-Marker: `compatibility_fallback_process_result=native-prompt-compatibility-fallback-result-boundary`

Der Controller führt weiterhin den echten `retaPrompt.py`-Kindprozess aus. Er entscheidet aber nicht mehr mit einem nackten `return True`, ob der Prompt-Loop nach dieser frühen Compatibility-Kante behandelt ist. Diese Projektion ist jetzt ein typisierter Result-Plan des Process-Owners.

## Kontrollfluss

Vorher:

```mojo
if compatibility_execution.should_execute:
    _ = run_reta_prompt_arguments_native(...)
    return True
```

Jetzt:

```mojo
if compatibility_execution.should_execute:
    _ = run_reta_prompt_arguments_native(...)
var compatibility_result = plan_prompt_compatibility_fallback_process_result(
    compatibility_execution
)
if compatibility_result.handled:
    return True
```

Damit ist die frühe Compatibility-Kette analog zur Residual-Fallback-Kette getrennt:

```text
Compatibility fallback decision
→ process execution plan
→ optional child-process I/O
→ process result plan
```

## Erwartete lokale Prüfung

```bash
RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5et.sh -- -j 8
scripts/build-all.sh -- -j 8
scripts/build-tests.sh -- -j 8
scripts/run-tests.sh --jobs 8
```
