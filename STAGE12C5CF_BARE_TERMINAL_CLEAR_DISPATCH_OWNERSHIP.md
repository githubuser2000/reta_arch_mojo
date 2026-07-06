# Stage 12c5cf – Bare terminal-clear dispatch ownership

## Ausgangspunkt

Die vom Benutzer hochgeladenen Läufe bestätigen die 12c5cc/12c5cd-Grenzen:
`test_table_adapters.mojo` ist nach der Zählungsparität grün, die breite
Mojo-Auswahl endet mit `Ausführung aller ausgewählten Mojo-Tests erfolgreich:
JA`, und der fokussierte 12c5cd-Stage-Lauf baut Prompt-, Legacy-Prompt- und
Tabellenadapterziele frisch.

Stage 12c5ce verschob danach den alleinstehenden Logging-Dispatch in den
Interaktionsbesitzer. Die nächste sichtbare Controllerentscheidung war der
alleinstehende Terminal-Clear-Befehl.

## Native Änderung

`src/reta_mojo/prompt_interaction.mojo` besitzt jetzt:

- `PromptTerminalClearDispatchPlan`
- `plan_terminal_clear_dispatch(command)`
- Snapshot-Eintrag `terminal_clear_dispatch=native-terminal-clear-plan`

Damit entscheidet der Interaktionsbesitzer die alleinstehenden Befehle:

- `leeren`
- `clear`
- lokalisierte Clear-Aliasse, sobald sie als `KIND_CLEAR` klassifiziert sind

Der Prozesscontroller führt nur noch den geplanten Terminaleffekt aus. Die
zusammengesetzte Tabellenform von `leeren`/`clear` bleibt weiterhin in
`prompt_historical_ownership.mojo`, weil sie vor einer Tabelle die historische
`rows + 1`-Leerzeilensemantik nutzt und nicht den ANSI-Standalone-Clear.

## Vertragsgrenzen

- `tests/test_prompt_interaction.mojo` enthält einen direkten Regressionstest
  für den neuen Terminal-Clear-Plan.
- `tests/test_stage12c5cf_source.py` verbietet, dass `prompt_main.mojo` wieder
  bare `KIND_CLEAR`-Branches enthält.
- `tests/test_prompt_companion_effects_source.py` hält weiterhin die Ordnung
  Informationsausgaben → compound-clear → Tabelle → Standalone-Dispatch fest.
- Der 12c5cf-Stage-Lauf baut Prompt-, Legacy-Prompt- und Tabellenadapterziele
  frisch.

## Benutzerprüfung

```sh
scripts/build-all.sh -- -j 8
RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5cf.sh -- -j 8

scripts/build-tests.sh -- -j 8
scripts/run-tests.sh --jobs 8
```
