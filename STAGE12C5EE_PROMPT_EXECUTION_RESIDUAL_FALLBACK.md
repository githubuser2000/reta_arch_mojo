# Stage 12c5ee – Prompt execution residual compatibility fallback owner

Diese Etappe verschiebt den letzten nackten `prompt_main.mojo`-Fallback am Ende
des interaktiven Prompt-Dispatchers in einen reinen Prompt-Execution-Plan.

## Neuer Owner

- `PromptExecutionCompatibilityFallbackPlan` bleibt das gemeinsame Boundary-Objekt.
- `plan_prompt_execution_residual_compatibility_fallback(source)` plant den
  finalen Residual-Fallback für Promptzeilen, die von keinem nativen
  Interaktions-, Tabellen-, Simple-Output- oder externen Prozess-Dispatcher
  übernommen wurden.

Der Controller ruft weiterhin die Python-Kompatibilitätsgrenze auf. Er liest
aber nicht mehr direkt die ursprüngliche `line` am Restzweig, sondern konsumiert
`residual_fallback.source` aus dem Prompt-Execution-Owner.

## Vertrag

Der neue Test
`test_prompt_execution_residual_compatibility_fallback_owns_last_boundary`
fixiert, dass der Residual-Fallback die unberührte Quellzeile unverändert an die
Boundary weiterreicht.

## Architekturwirkung

Damit sind nun drei Kompatibilitätsgrenzen explizit geplant:

1. abgewiesene historische Tabellen-/mulpri-Kandidaten,
2. Completion-Fallback nach einem geplanten nativen Branch,
3. der finale Residual-Fallback nach allen anderen nativen Dispatchern.

Die Änderung führt keine neue Fachsemantik ein; sie entfernt eine weitere
Restentscheidung aus dem Prozesscontroller.
