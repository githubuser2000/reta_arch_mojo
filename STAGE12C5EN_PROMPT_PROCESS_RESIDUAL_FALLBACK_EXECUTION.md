# Stage 12c5en – Prompt process residual fallback execution owner

Diese Etappe schließt die interaktive Rest-Kompatibilitätsgrenze weiter aus dem
Prompt-Controller heraus. Der Prompt-Execution-Owner plant weiterhin mit
`plan_prompt_execution_residual_compatibility_fallback`, dass eine unbewiesene
Restzeile an die historische `retaPrompt.py`-Grenze muss. Neu ist, dass der
Prompt-Process-Dispatch-Owner die letzte Ausführungsprojektion besitzt:

- `PromptResidualFallbackProcessExecutionPlan`
- `plan_prompt_residual_fallback_process_execution(...)`

Damit interpretiert `prompt_main.mojo` nicht mehr selbst `fallback.should_run`
und `fallback.source`, sondern verbraucht nur noch `should_execute` und einen
bereits materialisierten argv-Vektor.

Der echte Kindprozess bleibt bewusst im Controller/Adapter, damit die künftige
Shared-Library-Schicht pure Planung und Betriebssystem-I/O sauber trennen kann.

## Geschützte Verträge

- `tests/test_prompt_interaction.mojo` prüft die neue Residual-Fallback-Execution.
- `tests/test_legacy_reta_prompt.mojo` aktualisiert den sichtbaren Legacy-`PromptScope`.
- `tests/test_stage12c5en_source.py` schützt Controller-, Owner-, Matrix- und
  Dokumentationsvertrag.

## Ergebnis

12c5en reduziert die verbleibende Controller-Algebra an der letzten interaktiven
Kompatibilitätsgrenze weiter.
