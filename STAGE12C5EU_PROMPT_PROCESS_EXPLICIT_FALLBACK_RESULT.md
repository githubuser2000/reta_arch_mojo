# Stage 12c5eu – Prompt process explicit fallback result owner

Diese Etappe verlagert die finale Ergebnisprojektion des expliziten
`retaPrompt.py`-Fallbacks in den Prompt-Process-Dispatch-Owner.

Vorher las `_run_fallback` den Ausführungsplan direkt:

```mojo
if not fallback_execution.should_execute:
    return
```

Jetzt entscheidet der neue Plan:

```mojo
var fallback_result = plan_prompt_fallback_process_result(fallback_execution)
if not fallback_result.process_executed:
    return
```

Damit besitzt `prompt_process_dispatch.mojo` nicht nur argv-Bau und
Ausführungsgate, sondern auch den finalen Fallback-Result-Vertrag. Der
Controller reicht nur noch die fertigen Argumente an den Prozessadapter weiter.

Neue API:

```mojo
PromptFallbackProcessResultPlan
plan_prompt_fallback_process_result(...)
```

Source-Guards und Legacy-Scope dokumentieren den neuen Marker:

```text
fallback_process_result=native-prompt-fallback-result-boundary
```
