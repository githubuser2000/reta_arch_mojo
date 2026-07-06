# Stage 12c5ce – Bare logging dispatch ownership

## Ausgangspunkt

Stage 12c5cc wurde vom Benutzer breit bestätigt: `test_table_adapters.mojo`
ist nach der Zählungsparität grün und die ausgewählte Mojo-Suite endet mit
`Ausführung aller ausgewählten Mojo-Tests erfolgreich: JA`. Der fokussierte
12c5cc-Stage-Lauf bestätigt dieselbe Grenze mit 72 Source-Verträgen.

Stage 12c5cd verschob danach die Einzelbefehle `S`/`s` aus dem
Prozesscontroller in den nativen Prompt-Interaktionsbesitzer. Die nächste noch
sichtbare Sessionmutation in `_run_command` war der alleinstehende
Logging-Dispatch.

## Native Änderung

`src/reta_mojo/prompt_interaction.mojo` besitzt jetzt:

- `PromptLoggingDispatchPlan`
- `plan_logging_dispatch(command, session)`
- Snapshot-Eintrag `logging_dispatch=native-session-logging-plan`

Damit entscheidet der Interaktionsbesitzer die alleinstehenden Befehle:

- `loggen` / `log` / lokalisierte Einschaltaliasse
- `nichtloggen` / `nolog` / lokalisierte Ausschaltaliasse

Der Prozesscontroller druckt nur noch die geplanten Zeilen. Die
positionsunabhängigen Logging-Begleiteffekte zusammengesetzter historischer
Tabellenpläne bleiben weiterhin im dafür zuständigen
`prompt_historical_ownership.mojo`, weil sie nach erfolgreicher Tabellenplanung
komponieren.

## Vertragsgrenzen

- `tests/test_prompt_interaction.mojo` enthält einen direkten Regressionstest
  für den neuen Logging-Plan.
- `tests/test_stage12c5ce_source.py` verbietet, dass der interaktive
  `_run_command` wieder bare `KIND_LOG_ON`-/`KIND_LOG_OFF`-Branches enthält.
- Der 12c5ce-Stage-Lauf baut wie die Vorgänger die Prompt-, Legacy-Prompt- und
  Tabellenadapterziele frisch.

## Benutzerprüfung

```sh
scripts/build-all.sh -- -j 8
RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5ce.sh -- -j 8

scripts/build-tests.sh -- -j 8
scripts/run-tests.sh --jobs 8
```
