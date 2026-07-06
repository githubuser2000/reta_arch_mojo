# Stage 12c5ej – Prompt process fallback execution boundary owner

## Ziel

Der Prompt-Fallback hatte nach dem bereits portierten argv-Aufbau noch eine
kleine Controller-eigene Ausführungsalgebra: `_run_fallback` prüfte selbst, ob
der Fallbackprozess überhaupt behandelt ist und ob tatsächlich `retaPrompt.py`
gestartet werden soll.

## Änderung

Neu im Prompt-Process-Dispatch-Owner:

```mojo
def plan_prompt_fallback_process_execution(
    dispatch: PromptFallbackProcessDispatchPlan,
) -> PromptFallbackProcessExecutionPlan
```

Der Plan trägt:

- `should_execute`: der Kompatibilitäts-Kindprozess soll wirklich gestartet werden.
- `arguments`: der vom Owner gebaute argv-Vektor für `retaPrompt.py`.

## Wirkung

Fallback-Execution besitzt jetzt eine eigene Boundary im Process-Dispatch-Owner.
`prompt_main.mojo` führt weiterhin den echten Kindprozess aus, entscheidet aber
nicht mehr selbst aus `handled` und `run_reta_prompt`, ob diese Ausführung
stattfinden darf. Damit bleibt die spätere Shared-Library-Grenze sauberer: Der
Controller ist I/O-Adapter, der Owner liefert die fertige Ausführungsentscheidung.

## Lokale Prüfung

```bash
RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5ej.sh -- -j 4
scripts/run-tests.sh
scripts/build-all.sh -- -j 6
RETA_TEST_HEAVY=1 scripts/test_all.sh
```
